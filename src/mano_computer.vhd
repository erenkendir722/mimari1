-------------------------------------------------------------------------------
-- Mano Computer — Üst Modül
-- Mano Temel Bilgisayarı (Mikroprogramlanmış Kontrol)
--
-- Bileşenler:
--   - reg12 x2  : AR, PC
--   - reg16 x4  : AC, DR, TR, IR
--   - alu       : Aritmetik/mantıksal işlemler
--   - ram4096   : Ana bellek
--   - common_bus: Ortak veri yolu
--   - control_unit: Mikroprogramlanmış kontrol birimi
--
-- Giriş/Çıkış:
--   - inpr  : 8-bit giriş aygıtı verisi
--   - outr  : 8-bit çıkış aygıtı verisi
--   - fgi   : Giriş bayrağı
--   - fgo   : Çıkış bayrağı
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mano_computer is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        inpr  : in  std_logic_vector(7 downto 0);
        outr  : out std_logic_vector(7 downto 0);
        fgi   : in  std_logic;
        fgo   : out std_logic;
        -- Debug
        debug_ac  : out std_logic_vector(15 downto 0);
        debug_pc  : out std_logic_vector(11 downto 0);
        debug_car : out std_logic_vector(6 downto 0)
    );
end entity mano_computer;

architecture structural of mano_computer is

    -- ── Veri yolu sinyalleri ──────────────────────────────────────────
    signal ar_out   : std_logic_vector(11 downto 0);
    signal pc_out   : std_logic_vector(11 downto 0);
    signal ac_out   : std_logic_vector(15 downto 0);
    signal dr_out   : std_logic_vector(15 downto 0);
    signal tr_out   : std_logic_vector(15 downto 0);
    signal ir_out   : std_logic_vector(15 downto 0);
    signal outr_reg : std_logic_vector(7 downto 0) := (others => '0');

    signal bus_out  : std_logic_vector(15 downto 0);
    signal bus_sel  : std_logic_vector(2 downto 0);

    signal alu_result    : std_logic_vector(15 downto 0);
    signal alu_carry_out : std_logic;
    signal alu_op        : std_logic_vector(2 downto 0);

    signal e_flag   : std_logic := '0';  -- Taşıma/taşma biti
    signal ac_zero  : std_logic;
    signal dr_zero  : std_logic;

    signal ram_out  : std_logic_vector(15 downto 0);

    -- ── Kontrol sinyalleri ────────────────────────────────────────────
    signal f1_add, f1_clrac, f1_incac, f1_drtac : std_logic;
    signal f1_andac, f1_comac, f1_clre           : std_logic;
    signal f2_sub, f2_or, f2_shl, f2_shr         : std_logic;
    signal f2_incpc, f2_artpc, f2_come           : std_logic;
    signal f3_read, f3_write, f3_pctar           : std_logic;
    signal f3_irtar, f3_actdr, f3_incdr, f3_drtir: std_logic;

    signal debug_mi : std_logic_vector(19 downto 0);

    -- ── Yazmaç yükleme sinyalleri ─────────────────────────────────────
    signal ar_load, ar_clr, ar_inc : std_logic;
    signal pc_load, pc_clr, pc_inc : std_logic;
    signal ac_load, ac_clr, ac_inc : std_logic;
    signal dr_load, dr_clr, dr_inc : std_logic;
    signal tr_load, tr_clr         : std_logic;
    signal ir_load                 : std_logic;

    signal ram_read, ram_write     : std_logic;

begin

    -- ══════════════════════════════════════════════════════════════════
    -- YAZMAÇLAR
    -- ══════════════════════════════════════════════════════════════════

    u_ar : entity work.reg12
        port map (clk, reset, ar_load, ar_clr, ar_inc,
                  bus_out(11 downto 0), ar_out);

    u_pc : entity work.reg12
        port map (clk, reset, pc_load, pc_clr, pc_inc,
                  bus_out(11 downto 0), pc_out);

    u_ac : entity work.reg16
        port map (clk, reset, ac_load, ac_clr, ac_inc,
                  alu_result, ac_out);

    u_dr : entity work.reg16
        port map (clk, reset, dr_load, dr_clr, dr_inc,
                  bus_out, dr_out);

    u_tr : entity work.reg16
        port map (clk, reset, tr_load, tr_clr, '0',
                  bus_out, tr_out);

    u_ir : entity work.reg16
        port map (clk, reset, ir_load, '0', '0',
                  bus_out, ir_out);

    -- ══════════════════════════════════════════════════════════════════
    -- ORTAK VERİ YOLU
    -- ══════════════════════════════════════════════════════════════════

    u_bus : entity work.common_bus
        port map (
            sel     => bus_sel,
            ar_in   => ar_out,
            pc_in   => pc_out,
            dr_in   => dr_out,
            ac_in   => ac_out,
            ir_in   => ir_out,
            tr_in   => tr_out,
            inpr_in => inpr,
            bus_out => bus_out
        );

    -- ══════════════════════════════════════════════════════════════════
    -- ALU
    -- ══════════════════════════════════════════════════════════════════

    u_alu : entity work.alu
        port map (
            a         => ac_out,
            b         => dr_out,
            op        => alu_op,
            carry_in  => e_flag,
            result    => alu_result,
            carry_out => alu_carry_out
        );

    -- ══════════════════════════════════════════════════════════════════
    -- BELLEK
    -- ══════════════════════════════════════════════════════════════════

    u_ram : entity work.ram4096
        port map (
            clk      => clk,
            address  => ar_out,
            data_in  => dr_out,
            read     => ram_read,
            write    => ram_write,
            data_out => ram_out
        );

    -- ══════════════════════════════════════════════════════════════════
    -- KONTROL BİRİMİ
    -- ══════════════════════════════════════════════════════════════════

    u_ctrl : entity work.control_unit
        port map (
            clk      => clk,
            reset    => reset,
            ir_reg   => ir_out,
            ac_sign  => ac_out(15),
            ac_zero  => ac_zero,
            e_flag   => e_flag,
            f1_add   => f1_add,   f1_clrac => f1_clrac,
            f1_incac => f1_incac, f1_drtac => f1_drtac,
            f1_andac => f1_andac, f1_comac => f1_comac,
            f1_clre  => f1_clre,
            f2_sub   => f2_sub,   f2_or    => f2_or,
            f2_shl   => f2_shl,   f2_shr   => f2_shr,
            f2_incpc => f2_incpc, f2_artpc => f2_artpc,
            f2_come  => f2_come,
            f3_read  => f3_read,  f3_write => f3_write,
            f3_pctar => f3_pctar, f3_irtar => f3_irtar,
            f3_actdr => f3_actdr, f3_incdr => f3_incdr,
            f3_drtir => f3_drtir,
            debug_car => debug_car,
            debug_mi  => debug_mi
        );

    -- ══════════════════════════════════════════════════════════════════
    -- KONTROL SİNYALLERİNDEN VERİ YOLU BAĞLANTISI
    -- ══════════════════════════════════════════════════════════════════

    -- F3 → bellek ve yazmaç transferleri
    ram_read  <= f3_read;
    ram_write <= f3_write;

    -- AR yükleme: PCTAR (AR←PC) veya IRTAR (AR←IR[11:0])
    ar_load <= f3_pctar or f3_irtar;
    ar_clr  <= '0';
    ar_inc  <= '0';
    bus_sel <= "010" when f3_pctar = '1' else   -- PC → bus → AR
               "101" when f3_irtar = '1' else   -- IR → bus → AR
               "011" when f3_drtir = '1' else   -- DR → bus → IR
               "011" when f3_actdr = '1' else   -- AC → DR (özel)
               "000";

    -- IR yükleme: DRTIR (IR←DR)
    ir_load <= f3_drtir;

    -- DR yükleme: bellekten okuma veya bus üzerinden
    dr_load <= f3_read or f3_actdr;
    dr_clr  <= '0';
    dr_inc  <= f3_incdr;

    -- PC
    pc_load <= f2_artpc;
    pc_clr  <= '0';
    pc_inc  <= f2_incpc;

    -- AC yükleme: herhangi bir F1 işlemi sonrası
    ac_load <= f1_add or f1_clrac or f1_incac or f1_drtac or
               f1_andac or f1_comac or f2_sub or f2_or or
               f2_shl or f2_shr;
    ac_clr  <= f1_clrac;
    ac_inc  <= f1_incac;

    -- E biti güncelleme
    process(clk, reset)
    begin
        if reset = '1' then
            e_flag <= '0';
        elsif rising_edge(clk) then
            if f1_clre = '1' then
                e_flag <= '0';
            elsif f2_come = '1' then
                e_flag <= not e_flag;
            elsif (f1_add or f1_incac or f2_shl or f2_shr) = '1' then
                e_flag <= alu_carry_out;
            end if;
        end if;
    end process;

    -- ALU işlem kodu seçimi
    alu_op <= "001" when f1_add   = '1' else
              "010" when f1_andac = '1' else
              "011" when f1_comac = '1' else
              "100" when f2_shr   = '1' else
              "101" when f2_shl   = '1' else
              "110" when f1_incac = '1' else
              "111" when f2_or    = '1' else
              "000";  -- PASSA

    -- OUTR (çıkış yazmacı): f3 alanından ayrıca sinyal gerekirdi;
    -- OUT komutu için yer tutucu
    outr <= outr_reg;
    fgo  <= '0';

    -- Durum bayrakları
    ac_zero <= '1' when ac_out = x"0000" else '0';
    dr_zero <= '1' when dr_out = x"0000" else '0';

    -- Debug
    debug_ac <= ac_out;
    debug_pc <= pc_out;

end architecture structural;
