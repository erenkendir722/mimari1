-------------------------------------------------------------------------------
-- Control Unit Testbench
-- FETCH döngüsünü ve AND/ADD/LDA komutlarını simüle eder
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_unit_tb is
end entity control_unit_tb;

architecture sim of control_unit_tb is

    signal clk      : std_logic := '0';
    signal reset    : std_logic := '1';
    signal ir_reg   : std_logic_vector(15 downto 0) := (others => '0');
    signal ac_sign  : std_logic := '0';
    signal ac_zero  : std_logic := '0';
    signal e_flag   : std_logic := '0';

    -- F1 çıkışları
    signal f1_add, f1_clrac, f1_incac, f1_drtac : std_logic;
    signal f1_andac, f1_comac, f1_clre           : std_logic;

    -- F2 çıkışları
    signal f2_sub, f2_or, f2_shl, f2_shr    : std_logic;
    signal f2_incpc, f2_artpc, f2_come       : std_logic;

    -- F3 çıkışları
    signal f3_read, f3_write, f3_pctar, f3_irtar : std_logic;
    signal f3_actdr, f3_incdr, f3_drtir          : std_logic;

    -- Debug
    signal debug_car : std_logic_vector(6 downto 0);
    signal debug_mi  : std_logic_vector(19 downto 0);

    constant CLK_PERIOD : time := 20 ns;

begin

    -- Saat üreteci
    clk <= not clk after CLK_PERIOD / 2;

    -- DUT (Design Under Test)
    uut : entity work.control_unit
        port map (
            clk      => clk,
            reset    => reset,
            ir_reg   => ir_reg,
            ac_sign  => ac_sign,
            ac_zero  => ac_zero,
            e_flag   => e_flag,
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
            debug_car => debug_car,
            debug_mi  => debug_mi
        );

    -- Test süreci
    stim_proc : process
    begin
        -- ══ RESET ══
        report "=== TEST BASLIYOR ===" severity note;
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD;

        -- ══ FETCH DÖNGÜSÜ TESTİ ══
        report "--- FETCH Döngüsü ---" severity note;

        -- FETCH Adım 0 (0x40): AR ← PC → f3_pctar aktif olmalı
        report "CAR = " & integer'image(to_integer(unsigned(debug_car)))
             & " | f3_pctar = " & std_logic'image(f3_pctar)
             severity note;
        assert debug_car = "1000000"
            report "HATA: CAR reset sonrası 0x40 olmalı!" severity error;
        assert f3_pctar = '1'
            report "HATA: FETCH-0 adımında f3_pctar aktif olmalı!" severity error;
        wait for CLK_PERIOD;

        -- FETCH Adım 1 (0x41): DR ← M[AR], PC ← PC+1
        report "CAR = " & integer'image(to_integer(unsigned(debug_car)))
             & " | f3_read = " & std_logic'image(f3_read)
             & " | f2_incpc = " & std_logic'image(f2_incpc)
             severity note;
        assert f3_read = '1'
            report "HATA: FETCH-1 adımında f3_read aktif olmalı!" severity error;
        assert f2_incpc = '1'
            report "HATA: FETCH-1 adımında f2_incpc aktif olmalı!" severity error;
        wait for CLK_PERIOD;

        -- FETCH Adım 2 (0x42): IR ← DR
        report "CAR = " & integer'image(to_integer(unsigned(debug_car)))
             & " | f3_drtir = " & std_logic'image(f3_drtir)
             severity note;
        assert f3_drtir = '1'
            report "HATA: FETCH-2 adımında f3_drtir aktif olmalı!" severity error;
        wait for CLK_PERIOD;

        -- ══ AND KOMUTU TESTİ (opcode=000) ══
        report "--- AND Komutu (opcode=000, I=0) ---" severity note;
        -- IR = 0_000_xxxxxxxxxxxx → AND, direct
        ir_reg <= "0000000000100000";  -- AND, direct, addr=0x020
        wait for CLK_PERIOD;
        -- FETCH Adım 3 (0x43): MAP → CAR ← '0' & "000" & "000" = 0x00
        report "CAR = " & integer'image(to_integer(unsigned(debug_car)))
             severity note;

        -- AND 0x00: I=0 → koşul sağlanmaz, CAR+1 (0x01'e gider)
        wait for CLK_PERIOD;
        report "AND-0: CAR = " & integer'image(to_integer(unsigned(debug_car)))
             severity note;

        -- AND 0x01: DR ← M[AR]
        wait for CLK_PERIOD;
        report "AND-1: CAR = " & integer'image(to_integer(unsigned(debug_car)))
             & " | f3_read = " & std_logic'image(f3_read)
             severity note;

        -- AND 0x02: AC ← AC AND DR → f1_andac aktif
        wait for CLK_PERIOD;
        report "AND-2: CAR = " & integer'image(to_integer(unsigned(debug_car)))
             & " | f1_andac = " & std_logic'image(f1_andac)
             severity note;
        assert f1_andac = '1'
            report "HATA: AND execute adımında f1_andac aktif olmalı!" severity error;

        -- Fetch'e dönmeli (0x40)
        wait for CLK_PERIOD;
        report "Fetch'e dönüş: CAR = " & integer'image(to_integer(unsigned(debug_car)))
             severity note;
        assert debug_car = "1000000"
            report "HATA: AND sonrası FETCH'e (0x40) dönmeli!" severity error;

        -- ══ ADD KOMUTU TESTİ (opcode=001) ══
        report "--- ADD Komutu (opcode=001, I=0) ---" severity note;
        -- Fetch döngüsünü hızlıca geçelim
        wait for CLK_PERIOD * 3;  -- F0, F1, F2
        ir_reg <= "0010000000010000";  -- ADD, direct, addr=0x010
        wait for CLK_PERIOD;       -- F3: MAP → CAR ← 0x08

        -- ADD 0x08: I=0 kontrol
        wait for CLK_PERIOD;
        report "ADD-0: CAR = " & integer'image(to_integer(unsigned(debug_car)))
             severity note;

        -- ADD 0x09: DR ← M[AR]
        wait for CLK_PERIOD;
        report "ADD-1: CAR = " & integer'image(to_integer(unsigned(debug_car)))
             & " | f3_read = " & std_logic'image(f3_read)
             severity note;

        -- ADD 0x0A: AC ← AC + DR
        wait for CLK_PERIOD;
        report "ADD-2: CAR = " & integer'image(to_integer(unsigned(debug_car)))
             & " | f1_add = " & std_logic'image(f1_add)
             severity note;
        assert f1_add = '1'
            report "HATA: ADD execute adımında f1_add aktif olmalı!" severity error;

        -- Fetch'e dönmeli
        wait for CLK_PERIOD;
        assert debug_car = "1000000"
            report "HATA: ADD sonrası FETCH'e dönmeli!" severity error;

        -- ══ LDA KOMUTU TESTİ (opcode=010) ══
        report "--- LDA Komutu (opcode=010, I=0) ---" severity note;
        wait for CLK_PERIOD * 3;
        ir_reg <= "0100000000110000";  -- LDA, direct
        wait for CLK_PERIOD;  -- MAP → CAR ← 0x10
        wait for CLK_PERIOD;  -- LDA-0: I kontrol
        wait for CLK_PERIOD;  -- LDA-1: DR ← M[AR]
        wait for CLK_PERIOD;  -- LDA-2: AC ← DR
        report "LDA-2: f1_drtac = " & std_logic'image(f1_drtac)
             severity note;
        assert f1_drtac = '1'
            report "HATA: LDA execute adımında f1_drtac aktif olmalı!" severity error;

        wait for CLK_PERIOD;
        assert debug_car = "1000000"
            report "HATA: LDA sonrası FETCH'e dönmeli!" severity error;

        -- ══ TEST TAMAMLANDI ══
        report "=== TÜM TESTLER TAMAMLANDI ===" severity note;
        wait for CLK_PERIOD * 5;
        assert false report "Simülasyon bitti." severity failure;
        wait;
    end process;

end architecture sim;
