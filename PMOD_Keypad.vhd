library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- /*
-- Our keypad is a 4x4 keypad. It works by keeping all the rows high and the columns connected to 
-- gnd. When any key is pressed one unique path conducts and then we get to know what key was pressed.
-- */

entity pmod_keypad is
	port(
		clk_kypd: in std_logic;  -- clock of keypad
 		row: in std_logic_vector(3 downto 0);  -- all rows on keypad
		column: out std_logic_vector(3 downto 0):="0000"; -- all columns on keypad
		key: out std_logic_vector (3 downto 0)  -- decoded key
	);
end entity;

architecture arc_keypad of pmod_keypad is

--Declaring signas
signal internal_clk: std_logic_vector(20 downto 0) := "000000000000000000000";

begin
	process(clk_kypd) is begin
		if clk_kypd' event and clk_kypd='1' then
			--counting till 1ms
			-- /*
			-- our internal clock is 450MHZ hence 1 clock cycle
			-- is (1 / 450*(10^6)). Now to get 1ms from that 
			-- we need to multiply 450000 to get 10^-3. 
			-- Hence for 450000 in binary is 1101101110111010000
			-- */
			if internal_clk = "001101101110111010000" then -- 1000Hz->1ms
				--setting column
				column <= "0111";
				internal_clk <= internal_clk+1;
			
			-- small time past 1ms to allow the column sig to settle
			elsif internal_clk = "001101101110111011010" then 
				-- check R1
				if row = "0111" then
					key <= "0001";  -- '1'
				-- check R2
				elsif row <= "1011" then 
					key <= "0100";  -- '4'
				-- check R3
				elsif row <= "1101" then
					key <= "0111";  -- '7'
				--Check R4
				elsif row <= "1110" then
					key <= "0000";  -- '0'
				end if;
				internal_clk <= internal_clk+1;
					
			-- At 2ms
			-- /*
			-- One single clock cycle takes (1 / 450*(10^6)) time. TO 
			-- make this 2ms i need to multiply 900000. Hence it becomes
			-- 2ms.
			-- */
			-- 2ms
			elsif internal_clk = "011011011101110100000" then 
				-- setting column
				column <= "1011";
				internal_clk <= internal_clk+1;
			
			-- little past 2ms
			elsif internal_clk = "011011011101110101010" then 
				-- check R1
				if row = "0111" then
					key <= "0010";  -- '2'
				-- check R2
				elsif row <= "1011" then 
					key <= "0101";  -- '5'
				-- check R3
				elsif row <= "1101" then
					key <= "1000";  -- '8'
				--Check R4
				elsif row <= "1110" then
					key <= "1111";  -- 'F'
				end if;
				internal_clk <= internal_clk+1;
			
			--At 3ms
			-- /*
			-- To get to 3ms we need to multiply 1350000.
			-- and 1350k in binary is 101001001100101110000
			-- */
			elsif internal_clk = "101001001100101110000" then 
				-- setting column
				column <= "1101";
				internal_clk <= internal_clk+1;
				
			-- little past 3ms
			elsif internal_clk = "101001001100101111010" then 
				-- check R1
				if row = "0111" then
					key <= "0011";  -- '3'
				-- check R2
				elsif row <= "1011" then 
					key <= "0110";  -- '6'
				-- check R3
				elsif row <= "1101" then
					key <= "1001";  -- '9'
				--Check R4
				elsif row <= "1110" then
					key <= "1110";  -- 'E'
				end if;
				internal_clk <= internal_clk+1;
					
			
			--At 4ms
			-- /*
			-- To get to 4ms we need to multiply 1800.
			-- and 1800k in binary is 110110111011101000000
			-- */
			elsif internal_clk = "110110111011101000000" then 
				-- setting column
				column <= "1110";
				internal_clk <= internal_clk+1;
				
			-- little past 4ms
			elsif internal_clk = "110110111011101001010" then 
				-- check R1
				if row = "0111" then
					key <= "1010";  -- 'A'
				-- check R2
				elsif row <= "1011" then 
					key <= "1011";  -- 'B'
				-- check R3
				elsif row <= "1101" then
					key <= "1100";  -- 'C'
				--Check R4
				elsif row <= "1110" then
					key <= "1101";  -- 'D'
				end if;
				
				--Resetting our counter after it counts till 4ms
				internal_clk <= "000000000000000000000";
				
			else
				--Incrementing clock for all other cases
				internal_clk <= internal_clk+1;
			end if;
		end if;
	end process;
end architecture;
