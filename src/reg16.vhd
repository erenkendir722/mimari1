-------------------------------------------------------------------------------
-- 16-bit Genel Amaçlı Yazmaç
-- Kullanım: AC, DR, TR, IR
--
-- Sinyaller:
--   clr  → senkron sıfırlama
--   load → paralel yükleme (data_in)
--   inc  → değeri 1 artır (AC için)
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reg16 is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        load     : in  std_logic;
        clr      : in  std_logic;
        inc      : in  std_logic;
        data_in  : in  std_logic_vector(15 downto 0);
        data_out : out std_logic_vector(15 downto 0)
    );
end entity reg16;

architecture behavioral of reg16 is
    signal reg : std_logic_vector(15 downto 0) := (others => '0');
begin

    process(clk, reset)
    begin
        if reset = '1' then
            reg <= (others => '0');
        elsif rising_edge(clk) then
            if clr = '1' then
                reg <= (others => '0');
            elsif load = '1' then
                reg <= data_in;
            elsif inc = '1' then
                reg <= std_logic_vector(unsigned(reg) + 1);
            end if;
        end if;
    end process;

    data_out <= reg;

end architecture behavioral;
