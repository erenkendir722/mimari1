-------------------------------------------------------------------------------
-- Microinstruction Decoder — Mikrokomut Çözücü
-- Mano Mikroprogramlanmış Kontrol Birimi
--
-- 20 bitlik mikrokomutu alıp veri yoluna gönderilecek kontrol
-- sinyallerini üretir.
--
-- Giriş:  microinstruction (20 bit)
-- Çıkış:  Tüm kontrol sinyalleri (ALU, yazmaç, bellek, dallanma)
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity microinstruction_decoder is
    port (
        microinstruction : in  std_logic_vector(19 downto 0);

        -- ══ F1 çıkışları (ALU / AC işlemleri) ══
        f1_add    : out std_logic;   -- AC ← AC + DR
        f1_clrac  : out std_logic;   -- AC ← 0
        f1_incac  : out std_logic;   -- AC ← AC + 1
        f1_drtac  : out std_logic;   -- AC ← DR
        f1_andac  : out std_logic;   -- AC ← AC AND DR
        f1_comac  : out std_logic;   -- AC ← NOT AC
        f1_clre   : out std_logic;   -- E ← 0

        -- ══ F2 çıkışları (Yazmaç transfer / Shift) ══
        f2_sub    : out std_logic;   -- AC ← AC - DR
        f2_or     : out std_logic;   -- AC ← AC OR DR
        f2_shl    : out std_logic;   -- Sola kaydır
        f2_shr    : out std_logic;   -- Sağa kaydır
        f2_incpc  : out std_logic;   -- PC ← PC + 1
        f2_artpc  : out std_logic;   -- PC ← AR
        f2_come   : out std_logic;   -- E ← NOT E

        -- ══ F3 çıkışları (Bellek / I/O) ══
        f3_read   : out std_logic;   -- DR ← M[AR]
        f3_write  : out std_logic;   -- M[AR] ← DR
        f3_pctar  : out std_logic;   -- AR ← PC
        f3_irtar  : out std_logic;   -- AR ← IR(11:0)
        f3_actdr  : out std_logic;   -- DR ← AC
        f3_incdr  : out std_logic;   -- DR ← DR + 1
        f3_drtir  : out std_logic;   -- IR ← DR

        -- ══ Dallanma alanları (ham çıkış) ══
        cd_field  : out std_logic_vector(1 downto 0);  -- Koşul kodu
        br_field  : out std_logic_vector(1 downto 0);  -- Dallanma tipi
        ad_field  : out std_logic_vector(6 downto 0)   -- Hedef adres
    );
end entity microinstruction_decoder;

architecture behavioral of microinstruction_decoder is
    signal f1 : std_logic_vector(2 downto 0);
    signal f2 : std_logic_vector(2 downto 0);
    signal f3 : std_logic_vector(2 downto 0);
begin

    -- Alan ayırma
    f1 <= microinstruction(19 downto 17);
    f2 <= microinstruction(16 downto 14);
    f3 <= microinstruction(13 downto 11);

    cd_field <= microinstruction(10 downto 9);
    br_field <= microinstruction(8  downto 7);
    ad_field <= microinstruction(6  downto 0);

    -- ══ F1 Çözücü ══
    f1_add   <= '1' when f1 = "001" else '0';
    f1_clrac <= '1' when f1 = "010" else '0';
    f1_incac <= '1' when f1 = "011" else '0';
    f1_drtac <= '1' when f1 = "100" else '0';
    f1_andac <= '1' when f1 = "101" else '0';
    f1_comac <= '1' when f1 = "110" else '0';
    f1_clre  <= '1' when f1 = "111" else '0';

    -- ══ F2 Çözücü ══
    f2_sub   <= '1' when f2 = "001" else '0';
    f2_or    <= '1' when f2 = "010" else '0';
    f2_shl   <= '1' when f2 = "011" else '0';
    f2_shr   <= '1' when f2 = "100" else '0';
    f2_incpc <= '1' when f2 = "101" else '0';
    f2_artpc <= '1' when f2 = "110" else '0';
    f2_come  <= '1' when f2 = "111" else '0';

    -- ══ F3 Çözücü ══
    f3_read  <= '1' when f3 = "001" else '0';
    f3_write <= '1' when f3 = "010" else '0';
    f3_pctar <= '1' when f3 = "011" else '0';
    f3_irtar <= '1' when f3 = "100" else '0';
    f3_actdr <= '1' when f3 = "101" else '0';
    f3_incdr <= '1' when f3 = "110" else '0';
    f3_drtir <= '1' when f3 = "111" else '0';

end architecture behavioral;
