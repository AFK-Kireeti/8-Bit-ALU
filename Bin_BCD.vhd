library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity bin_bcd is
	port(
		clk_bcd_bin: std_logic;  -- clock of the bcd to bin converter
		bin_in: in std_logic_vector(8 downto 0);  -- bin number to be converted
		bcd_out: out std_logic_vector(11 downto 0) := "000000000000" -- 12 bit otuput 
	);
end entity;

architecture brhave_bcd of bin_bcd is

--Declaring signals
signal bcd: std_logic_vector(11 downto 0) := "000000000000";  -- internal bcd output
signal counter: std_logic_vector(8 downto 0) := "000000000";  -- counter that counts till binary input

begin
	process(clk_bcd_bin) is begin
		if rising_edge(clk_bcd_bin) then
			-- increments LSB from 0-9
			if bcd(3 downto 0) = "1001" then
				bcd(3 downto 0) <= "0000";
				bcd(7 downto 4) <= bcd(7 downto 4)+1;
			else
				bcd(3 downto 0) <= bcd(3 downto 0)+1;
			end if;
			
			--increments MSB
			if bcd(7 downto 4) = "1001" and bcd(3 downto 0) = "1001" then
				bcd(7 downto 4) <= "0000";
				bcd(11 downto 8) <= bcd(11 downto 8)+1;
			end if;
			
			-- increments internal binary counter that increments bcd couner
			-- the same number of times till it reaches the value of binary
			-- input and then it resets.
			if counter = bin_in then
				bcd_out <= bcd;  -- Assigning output when we reach our binary number
				bcd <= "000000000000";  -- resetting bcd counter
				counter <= "000000000";  -- resetting binary counter
			else 
				counter <= counter+1;  -- increment otherwise
			end if;
		end if;
	end process;
end architecture;