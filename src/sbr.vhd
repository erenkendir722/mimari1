-------------------------------------------------------------------------------
-- Subroutine Register (SBR) — 7 bit
-- Mano Mikroprogramlanmış Kontrol Birimi
--
-- CALL işleminde dönüş adresini saklar (SBR ← CAR + 1)
-- RET  işleminde geri döner        (CAR ← SBR)
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sbr is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        load     : in  std_logic;
        data_in  : in  std_logic_vector(6 downto 0);
        data_out : out std_logic_vector(6 downto 0)
    );
end entity sbr;

architecture behavioral of sbr is
    signal sbr_reg : std_logic_vector(6 downto 0) := (others => '0');
begin

    process(clk, reset)
    begin
        if reset = '1' then
            sbr_reg <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                sbr_reg <= data_in;
            end if;
        end if;
    end process;

    data_out <= sbr_reg;

end architecture behavioral;
