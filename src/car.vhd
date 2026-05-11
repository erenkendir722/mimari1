-------------------------------------------------------------------------------
-- Control Address Register (CAR) — 7 bit
-- Mano Mikroprogramlanmış Kontrol Birimi
--
-- İşlevler:
--   reset → CAR ← "1000000" (0x40 = FETCH başlangıcı)
--   load  → CAR ← load_data  (JMP, CALL, RET, MAP)
--   inc   → CAR ← CAR + 1    (sıralı mikrokomut okuma)
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity car is
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        load      : in  std_logic;
        inc       : in  std_logic;
        load_data : in  std_logic_vector(6 downto 0);
        car_out   : out std_logic_vector(6 downto 0)
    );
end entity car;

architecture behavioral of car is
    -- FETCH döngüsü başlangıç adresi: 0x40 = 64 = "1000000"
    constant FETCH_ADDR : std_logic_vector(6 downto 0) := "1000000";
    signal car_reg : std_logic_vector(6 downto 0) := FETCH_ADDR;
begin

    process(clk, reset)
    begin
        if reset = '1' then
            car_reg <= FETCH_ADDR;
        elsif rising_edge(clk) then
            if load = '1' then
                car_reg <= load_data;
            elsif inc = '1' then
                car_reg <= std_logic_vector(unsigned(car_reg) + 1);
            end if;
        end if;
    end process;

    car_out <= car_reg;

end architecture behavioral;
