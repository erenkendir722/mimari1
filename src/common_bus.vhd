-------------------------------------------------------------------------------
-- Common Bus — 16-bit Ortak Veri Yolu
-- Mano Temel Bilgisayarı
--
-- 3-bitlik sel sinyali ile 8 kaynaktan birini veri yoluna bağlar.
--
-- sel | Kaynak       | Açıklama
-- ----+--------------+-----------------------------
-- 000 | (yok / HiZ)  | Kimse seçilmemiş
-- 001 | AR (12-bit)  | Üst 4 bit sıfır doldurulur
-- 010 | PC (12-bit)  | Üst 4 bit sıfır doldurulur
-- 011 | DR (16-bit)  |
-- 100 | AC (16-bit)  |
-- 101 | IR (16-bit)  |
-- 110 | TR (16-bit)  |
-- 111 | INPR (8-bit) | Üst 8 bit sıfır doldurulur
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity common_bus is
    port (
        sel      : in  std_logic_vector(2 downto 0);
        ar_in    : in  std_logic_vector(11 downto 0);
        pc_in    : in  std_logic_vector(11 downto 0);
        dr_in    : in  std_logic_vector(15 downto 0);
        ac_in    : in  std_logic_vector(15 downto 0);
        ir_in    : in  std_logic_vector(15 downto 0);
        tr_in    : in  std_logic_vector(15 downto 0);
        inpr_in  : in  std_logic_vector(7 downto 0);
        bus_out  : out std_logic_vector(15 downto 0)
    );
end entity common_bus;

architecture behavioral of common_bus is
begin

    with sel select
        bus_out <=
            (others => '0')           when "000",
            "0000" & ar_in            when "001",
            "0000" & pc_in            when "010",
            dr_in                     when "011",
            ac_in                     when "100",
            ir_in                     when "101",
            tr_in                     when "110",
            "00000000" & inpr_in      when "111",
            (others => '0')           when others;

end architecture behavioral;
