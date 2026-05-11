-------------------------------------------------------------------------------
-- RAM — 4096 x 16-bit Senkron Bellek
-- Mano Temel Bilgisayarı
--
-- read  = '1' → data_out ← M[address]  (okuma, saat yükselen kenarında)
-- write = '1' → M[address] ← data_in   (yazma, saat yükselen kenarında)
-- Aynı çevrimde read ve write ikisi birden '1' ise write önceliklidir.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ram4096 is
    port (
        clk      : in  std_logic;
        address  : in  std_logic_vector(11 downto 0);
        data_in  : in  std_logic_vector(15 downto 0);
        read     : in  std_logic;
        write    : in  std_logic;
        data_out : out std_logic_vector(15 downto 0)
    );
end entity ram4096;

architecture behavioral of ram4096 is
    type mem_type is array (0 to 4095) of std_logic_vector(15 downto 0);
    signal mem : mem_type := (others => (others => '0'));
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if write = '1' then
                mem(to_integer(unsigned(address))) <= data_in;
            end if;
            if read = '1' and write = '0' then
                data_out <= mem(to_integer(unsigned(address)));
            end if;
        end if;
    end process;

end architecture behavioral;
