-------------------------------------------------------------------------------
-- ALU — Aritmetik ve Mantıksal Birim
-- Mano Temel Bilgisayarı
--
-- Tüm işlemler 16-bit AC üzerinde gerçekleşir.
-- E biti (taşıma/taşma) carry_in ile verilir, carry_out ile üretilir.
--
-- op kodları (3 bit):
--   000 = PASSA  → result ← a          (veri yolu geçişi)
--   001 = ADD    → result ← a + b, E ← carry
--   010 = AND    → result ← a AND b
--   011 = COM    → result ← NOT a
--   100 = SHR    → result ← '0' & a(15:1), E ← a(0)
--   101 = SHL    → result ← a(14:0) & '0', E ← a(15)
--   110 = INC    → result ← a + 1
--   111 = OR     → result ← a OR b
--   (SUB F2 alanından ayrıca üretilir: a - b = a + NOT(b) + 1)
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    port (
        a         : in  std_logic_vector(15 downto 0);  -- AC
        b         : in  std_logic_vector(15 downto 0);  -- DR
        op        : in  std_logic_vector(2 downto 0);
        carry_in  : in  std_logic;                       -- E biti
        result    : out std_logic_vector(15 downto 0);
        carry_out : out std_logic                        -- yeni E
    );
end entity alu;

architecture behavioral of alu is
    signal sum17 : std_logic_vector(16 downto 0);
begin

    process(a, b, op, carry_in)
        variable tmp17 : unsigned(16 downto 0);
    begin
        carry_out <= '0';

        case op is
            when "000" =>  -- PASSA
                result <= a;

            when "001" =>  -- ADD
                tmp17  := ('0' & unsigned(a)) + ('0' & unsigned(b));
                result    <= std_logic_vector(tmp17(15 downto 0));
                carry_out <= tmp17(16);

            when "010" =>  -- AND
                result <= a and b;

            when "011" =>  -- COM (tümleyen)
                result <= not a;

            when "100" =>  -- SHR (sağa kaydır, E'den MSB gelir)
                result    <= carry_in & a(15 downto 1);
                carry_out <= a(0);

            when "101" =>  -- SHL (sola kaydır, E'den LSB gelir)
                result    <= a(14 downto 0) & carry_in;
                carry_out <= a(15);

            when "110" =>  -- INC
                tmp17  := ('0' & unsigned(a)) + 1;
                result    <= std_logic_vector(tmp17(15 downto 0));
                carry_out <= tmp17(16);

            when "111" =>  -- OR
                result <= a or b;

            when others =>
                result <= (others => '0');
        end case;
    end process;

end architecture behavioral;
