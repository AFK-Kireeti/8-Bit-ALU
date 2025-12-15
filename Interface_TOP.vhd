--Top Module
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity interface_top is
	port(
		clk_interface: in std_logic; -- master clock
		JA: inout std_logic_vector(7 downto 0);  -- pmod phy connec ports
		an: out std_logic_vector(7 downto 0);  -- seven seg select --> anode sel
		seg: out std_logic_vector(7 downto 0); -- seven seg led select 
		op_code: in std_logic_vector(3 downto 0); --operational code
		out_reg: inout std_logic_vector(8 downto 0); --output register, msb: overflow bit
		shift_by: in std_logic_vector(2 downto 0); --Amount of shift
		shift_lt_rt: in std_logic; --shifts either left or  right
		nzcv: inout std_logic_vector(3 downto 0) := "0000"; --neg(n), zero(z), carry(c), overflow(v)
		master_ip: in std_logic_vector(3 downto 0);  -- master input 
		ip_sel: in std_logic_vector(1 downto 0) -- selectes which register to be entered
	);
end entity;

architecture arc_interface of interface_top is 
	
	-- including components
	component pmod_keypad -- outputs decoded key from keypad 
		port(
			clk_kypd: in std_logic;  -- clock of keypad
			row: in std_logic_vector(3 downto 0);  -- all rows on keypad
			column: out std_logic_vector(3 downto 0); -- all columns on keypad
			key: out std_logic_vector (3 downto 0)  -- decoded key
		);
	end component;
	
	component ALU -- outputs result from ALU
		port(
			clk: in std_logic; --master clock
			op_code: in std_logic_vector(3 downto 0); --operational code
			out_reg: out std_logic_vector(8 downto 0); --output register the msb: overflow bit
			shift_by: in std_logic_vector(2 downto 0); --Amount of shift
			shift_lt_rt: in std_logic; --shifts either left or  right
			nzcv: out std_logic_vector(3 downto 0) := "0000"; --neg(n), zero(z), carry(c), overflow(v)
			master_ip: in std_logic_vector(3 downto 0);  -- master input 
			ip_sel: in std_logic_vector(1 downto 0) -- selectes which register to be entered
		);
	end component;
	
	component bin_bcd  -- convertes binary input to bcd output
		port(
			clk_bcd_bin: std_logic;  -- clock of the bcd to bin converter
			bin_in: in std_logic_vector(8 downto 0);  -- bin number to be converted
			bcd_out: out std_logic_vector(11 downto 0) := "000000000000" -- 12 bit otuput 
		);
	end component;
	
	component display -- configures all 8 seven segs
		port(
			clk_display: in std_logic;  -- clock for display
			seg_sel: out std_logic_vector(7 downto 0) := "11111111";  -- active low displays
			bcd_in: in std_logic_vector(11 downto 0);  -- the number you want to display
			neg_flag: in std_logic := '0'; -- checks for neg flag only
			led: out std_logic_vector(7 downto 0)  -- to enable led's, LSB is dot of seven seg
		);
	end component;
	
	
	-- Defining signals
	signal decode: std_logic_vector(3 downto 0);  -- the decoded keypad will be stored here
	signal bcd: std_logic_vector(11 downto 0);  -- stores the bcd output from bin to bcd converter
	signal bin: std_logic_vector(8 downto 0);  -- Stores the binary output from ALU
	
	begin
	
		c0: pmod_keypad port map(clk_kypd=>clk_interface, row=>JA(7 downto 4),  -- decodes the keypress
								 column=>JA(3 downto 0), key=>decode);
								 
		c1: ALU port map(clk=>clk_interface, master_ip=>decode, op_code=>op_code, out_reg=>out_reg,  -- reading key press
						 shift_by=>shift_by, shift_lt_rt=>shift_lt_rt, nzcv=>nzcv, ip_sel=>ip_sel);
						 
		c2: bin_bcd port map(clk_bcd_bin=>clk_interface, bin_in=>out_reg, bcd_out=>bcd);  -- converting binary output from ALU to bcd
		
		c3: display port map(clk_display=>clk_interface, seg_sel=>an, bcd_in=>bcd, led=>seg, neg_flag=>nzcv(3));  -- displays output in LED
		
		
end architecture;



