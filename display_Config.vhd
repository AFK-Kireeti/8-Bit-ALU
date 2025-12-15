library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity display is
	port(
		clk_display: in std_logic;  -- clock for display
		seg_sel: out std_logic_vector(7 downto 0) := "11111111";  -- active low displays
		bcd_in: in std_logic_vector(11 downto 0);  -- the number you want to display
		neg_flag: in std_logic;  -- reads negative flag to set '-' sign in seven seg
		led: out std_logic_vector(7 downto 0)  -- to enable led's, LSB is dot of seven seg
	);
end entity;

architecture behave_display of display is 

-- Declarign component
component seven_seg 
	port(
		clk_svn_seg: in std_logic;  -- clk of seven seg
		bcd_in: in std_logic_vector(3 downto 0);  -- no to be displayed
		neg_flag: in std_logic;  -- checks for negative flag
		led_out: out std_logic_vector(7 downto 0)  -- to enable led's, LSB is dot of seven seg
	);
end component;

-- Declaring signals
signal counter: std_logic_vector(20 downto 0) := "000000000000000000000"; -- timer module 
signal bcd: std_logic_vector(3 downto 0) := "0000";  -- stores the bcd digit to be displayed in seven seg

begin
	process(clk_display) is begin
		if rising_edge(clk_display) then
			-- counting till 1 ms
			if counter = "001101101110111010000" then
				seg_sel <= "11111110";  -- selecting lsb
				counter <= counter+1;
				
			-- little past 1ms
			elsif counter = "001101101110111011010" then
				bcd <= bcd_in(3 downto 0);  -- to display lsb
				counter <= counter+1;
				
			-- at 2ms
			elsif counter = "011011011101110100000" then
				seg_sel <= "11111101";
				counter <= counter+1;
				
			-- little past 2ms
			elsif counter = "011011011101110101010" then
				bcd <= bcd_in(7 downto 4);
				counter <= counter+1;
				
			-- at 3ms
			elsif counter = "101001001100101110000" then  
				seg_sel <= "11111011";  -- selecting msb seven seg
				counter <= counter+1;
				
			-- little past 3ms
			elsif counter = "101001001100101111010" then
				bcd <= bcd_in(11 downto 8);  -- sending msb to display
				counter <= counter+1;
				
			-- at 4ms	
			elsif counter = "110110111011101000000" then
				seg_sel <= "11110111";  -- selectes the seven seg
				counter <= counter+1;
				
			--  little past 4ms 
			elsif counter = "110110111011101001010" then
				bcd <= "1010";  -- sets unused bits
				
				-- Resetting the counter
				counter <= "000000000000000000000";
				
			else
				counter <= counter+1;  -- incrementing timiing counter
			end if;
		end if;
	end process;
	
	a0: seven_seg port map(clk_svn_seg=>clk_display, bcd_in=>bcd, led_out=>led, neg_flag=>neg_flag);
end architecture;

