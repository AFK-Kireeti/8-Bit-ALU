library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity seven_seg is
	port(
		clk_svn_seg: in std_logic;  -- clk of seven seg
		bcd_in: in std_logic_vector(3 downto 0);  -- no to be displayed
		neg_flag: in std_logic;
		led_out: out std_logic_vector(7 downto 0)  -- to enable led's, LSB is dot of seven seg
	);
end entity;

architecture behave_svn_seg of seven_seg is

begin
	process(clk_svn_seg) is begin
		if rising_edge(clk_svn_seg) then
			
			-- Note that the LED's are common anode, where it is 
			-- on only when the signal is low hence setting 0 for 
			-- LED's which we want to drive high, and 0 for the ones
			-- we want to drive low.
		
						  --abcdefgp   p is for dot
			if bcd_in = "0000" then   -- 0
				led_out <= "00000011";		
			elsif bcd_in = "0001" then-- 1
				led_out <= "10011111"; 		
			elsif bcd_in = "0010" then-- 2
				led_out <= "00100101";  	
			elsif bcd_in = "0011" then-- 3
				led_out <= "00001101";  	
			elsif bcd_in = "0100" then-- 4
				led_out <= "10011001";  	
			elsif bcd_in = "0101" then-- 5
				led_out <= "01001001";  	
			elsif bcd_in = "0110" then-- 6
				led_out <= "01000001";  	
			elsif bcd_in = "0111" then-- 7
				led_out <= "00011111";  	
			elsif bcd_in = "1000" then-- 8
				led_out <= "00000001";  	
			elsif bcd_in = "1001" then-- 9
				led_out <= "00001001";
			elsif bcd_in <= "1010" and neg_flag = '1' then
				led_out <= "11111101"; -- sets negative sign
			elsif bcd_in <= "1010" and neg_flag = '0' then
				led_out <= "11111111";  -- all led's set to low
			else  
				led_out <= "01100001";  -- displays E-->Error
			end if;
		end if;
	end process;
end architecture;
