-------------------------------------------------------------------------------
-- Control Unit — Mikroprogramlanmış Kontrol Birimi (Üst Modül)
-- Mano Temel Bilgisayarı
--
-- Bu modül CAR, SBR, Control Memory ve Microinstruction Decoder'ı
-- birleştirir. Dallanma mantığını (JMP, CALL, RET, MAP) yönetir.
--
-- Dışarıya kontrol sinyalleri üretir (veri yoluna bağlanacak).
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_unit is
    port (
        clk   : in std_logic;
        reset : in std_logic;

        -- Durum girişleri (veri yolundan)
        ir_reg   : in std_logic_vector(15 downto 0);  -- IR içeriği
        ac_sign  : in std_logic;                       -- AC(15) — işaret biti
        ac_zero  : in std_logic;                       -- AC = 0 bayrağı
        e_flag   : in std_logic;                       -- E (taşma) biti

        -- ══ F1 kontrol çıkışları ══
        f1_add   : out std_logic;
        f1_clrac : out std_logic;
        f1_incac : out std_logic;
        f1_drtac : out std_logic;
        f1_andac : out std_logic;
        f1_comac : out std_logic;
        f1_clre  : out std_logic;

        -- ══ F2 kontrol çıkışları ══
        f2_sub   : out std_logic;
        f2_or    : out std_logic;
        f2_shl   : out std_logic;
        f2_shr   : out std_logic;
        f2_incpc : out std_logic;
        f2_artpc : out std_logic;
        f2_come  : out std_logic;

        -- ══ F3 kontrol çıkışları ══
        f3_read  : out std_logic;
        f3_write : out std_logic;
        f3_pctar : out std_logic;
        f3_irtar : out std_logic;
        f3_actdr : out std_logic;
        f3_incdr : out std_logic;
        f3_drtir : out std_logic;

        -- Debug çıkışları
        debug_car : out std_logic_vector(6 downto 0);
        debug_mi  : out std_logic_vector(19 downto 0)
    );
end entity control_unit;

architecture structural of control_unit is

    -- ── Dahili sinyaller ──────────────────────────────────────────────
    signal car_out      : std_logic_vector(6 downto 0);
    signal car_load     : std_logic;
    signal car_inc      : std_logic;
    signal car_load_data: std_logic_vector(6 downto 0);

    signal sbr_out      : std_logic_vector(6 downto 0);
    signal sbr_load     : std_logic;
    signal sbr_data_in  : std_logic_vector(6 downto 0);

    signal mi           : std_logic_vector(19 downto 0);  -- mikrokomut

    signal cd           : std_logic_vector(1 downto 0);
    signal br           : std_logic_vector(1 downto 0);
    signal ad           : std_logic_vector(6 downto 0);

    signal condition    : std_logic;  -- dallanma koşulu sonucu
    signal car_next     : std_logic_vector(6 downto 0);
    signal map_addr     : std_logic_vector(6 downto 0);

begin

    -- ══════════════════════════════════════════════════════════════════
    -- ALT MODÜL ÖRNEKLEMELERİ
    -- ══════════════════════════════════════════════════════════════════

    -- CAR (Control Address Register)
    u_car : entity work.car
        port map (
            clk       => clk,
            reset     => reset,
            load      => car_load,
            inc       => car_inc,
            load_data => car_load_data,
            car_out   => car_out
        );

    -- SBR (Subroutine Register)
    u_sbr : entity work.sbr
        port map (
            clk      => clk,
            reset    => reset,
            load     => sbr_load,
            data_in  => sbr_data_in,
            data_out => sbr_out
        );

    -- Control Memory (ROM)
    u_cmem : entity work.control_memory
        port map (
            address => car_out,
            data    => mi
        );

    -- Microinstruction Decoder
    u_decoder : entity work.microinstruction_decoder
        port map (
            microinstruction => mi,
            f1_add   => f1_add,
            f1_clrac => f1_clrac,
            f1_incac => f1_incac,
            f1_drtac => f1_drtac,
            f1_andac => f1_andac,
            f1_comac => f1_comac,
            f1_clre  => f1_clre,
            f2_sub   => f2_sub,
            f2_or    => f2_or,
            f2_shl   => f2_shl,
            f2_shr   => f2_shr,
            f2_incpc => f2_incpc,
            f2_artpc => f2_artpc,
            f2_come  => f2_come,
            f3_read  => f3_read,
            f3_write => f3_write,
            f3_pctar => f3_pctar,
            f3_irtar => f3_irtar,
            f3_actdr => f3_actdr,
            f3_incdr => f3_incdr,
            f3_drtir => f3_drtir,
            cd_field => cd,
            br_field => br,
            ad_field => ad
        );

    -- ══════════════════════════════════════════════════════════════════
    -- DALLANMA MANTIĞI
    -- ══════════════════════════════════════════════════════════════════

    -- CD (Condition) değerlendirmesi
    with cd select
        condition <=
            '1'      when "00",   -- Koşulsuz
            ir_reg(15) when "01", -- I: Dolaylı bit
            ac_sign  when "10",   -- S: AC işaret biti
            ac_zero  when "11",   -- Z: AC = 0
            '0'      when others;

    -- MAP adresi: '0' & IR(14:12) & "000"
    map_addr <= '0' & ir_reg(14 downto 12) & "000";

    -- ══════════════════════════════════════════════════════════════════
    -- CAR / SBR KONTROL MANTIĞI
    -- ══════════════════════════════════════════════════════════════════
    --
    -- BR = 00 (JMP):  koşul doğruysa CAR ← AD, değilse CAR ← CAR+1
    -- BR = 01 (CALL): koşul doğruysa SBR ← CAR+1, CAR ← AD
    --                  değilse CAR ← CAR+1
    -- BR = 10 (RET):  CAR ← SBR
    -- BR = 11 (MAP):  CAR ← map_addr
    --

    process(br, condition, ad, sbr_out, map_addr, car_out)
    begin
        -- Varsayılan: sıralı ilerleme
        car_load     <= '0';
        car_inc      <= '1';
        car_load_data <= (others => '0');
        sbr_load     <= '0';
        sbr_data_in  <= (others => '0');

        case br is
            when "00" =>  -- JMP
                if condition = '1' then
                    car_load      <= '1';
                    car_inc       <= '0';
                    car_load_data <= ad;
                end if;
                -- condition='0' → CAR ← CAR+1 (varsayılan)

            when "01" =>  -- CALL
                if condition = '1' then
                    -- SBR ← CAR + 1
                    sbr_load    <= '1';
                    sbr_data_in <= std_logic_vector(unsigned(car_out) + 1);
                    -- CAR ← AD
                    car_load      <= '1';
                    car_inc       <= '0';
                    car_load_data <= ad;
                end if;

            when "10" =>  -- RET
                car_load      <= '1';
                car_inc       <= '0';
                car_load_data <= sbr_out;

            when "11" =>  -- MAP
                car_load      <= '1';
                car_inc       <= '0';
                car_load_data <= map_addr;

            when others =>
                null;
        end case;
    end process;

    -- Debug çıkışları
    debug_car <= car_out;
    debug_mi  <= mi;

end architecture structural;
