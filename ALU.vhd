--Defining Barrel Shifter
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--updating entity
entity barrel_shifter is
	port(
		clk_barrel_shifter: in std_logic;
		reg_a_bs: in std_logic_vector(7 downto 0); --input to our barrel shifter
		reg_out_bs: out std_logic_vector(7 downto 0); --output
		shift_by_bs: in std_logic_vector(2 downto 0); --Amount of shift
		shift_lt_rt_bs: in std_logic  --shifts either left or  right
	);
end entity;

architecture behave_barrel_shifter of barrel_shifter is begin

	p1: process(clk_barrel_shifter, reg_a_bs, shift_lt_rt_bs, shift_by_bs) is 
	--Creating variables 
	variable x, y: std_logic_vector(7 downto 0);
	variable ctrl0, ctrl1, ctrl2 : std_logic_vector(1 downto 0);
	
	begin
		ctrl0 := shift_by_bs(0) & shift_lt_rt_bs;
		ctrl1 := shift_by_bs(1) & shift_lt_rt_bs;
		ctrl2 := shift_by_bs(2) & shift_lt_rt_bs;
		
		if (clk_barrel_shifter'event and clk_barrel_shifter = '1') then
			case ctrl0 is
				when "00" | "01" => x := reg_a_bs;
				when "10" => x := reg_a_bs(6 downto 0) & reg_a_bs(7);
				when "11" => x := reg_a_bs(0) & reg_a_bs(7 downto 1);
				when others => null;
			end case;
			
			case ctrl1 is
				when "00" | "01" => x := reg_a_bs;
				when "10" => y := x(5 downto 0) & x(7 downto 6);
				when "11" => y := x(1 downto 0) & x(7 downto 2);
				when others => null;
			end case;
			
			case ctrl2 is
				when "00" | "01" => reg_out_bs <= y;
				when "10" | "11" => reg_out_bs <= y(3 downto 0) & y(7 downto 4);
				when others => null;
			end case;
		end if;
	end process;
end architecture;


--Defining signed adder
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signed_adder is 
	port(
		clk_addr: in std_logic; --internal clk of the adder 
		reg_a_addr, reg_b_addr: in signed(7 downto 0); -- signed input registers
		out_reg_addr: out std_logic_vector(8 downto 0); -- output register
		neg_flag: out std_logic --checks if the output is negative
	);
end entity;
 
architecture behave_signed_addr of signed_adder is 
	--Internal signals
	--signal check_neg: std_logic; --checks for negative flag
	signal internal_out: signed(8 downto 0);
	
	begin
		adding: process(clk_addr, reg_a_addr, reg_b_addr) is begin
			if rising_edge(clk_addr) then
				internal_out <= signed(resize(reg_a_addr, 9) + resize(reg_b_addr, 9));
			end if;
		end process;
		
		--Assigning to output
		sync: process(internal_out) is begin
				if internal_out(8) = '1' then  -- if neg flag is 1 then take 2's compliement
					neg_flag <= '1';  -- set neg flag 1
					out_reg_addr <= std_logic_vector(not(internal_out) + 1);  -- converting to 2's compliment
				else
					neg_flag <= '0';  -- set neg flag to 0
					out_reg_addr <= std_logic_vector(internal_out);
				end if;
		end process;
end architecture;


--Defining signed subtractor
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signed_subtractor is 
	port(
		clk_str: in std_logic; --internal clk of the adder 
		reg_a_str, reg_b_str: in signed(7 downto 0); --input registers
		out_reg_str: out std_logic_vector(8 downto 0); --output register
		neg_flag: out std_logic --checks if the output is negative
	);
end entity;
 
architecture behave_signed_str of signed_subtractor is 
	--Internal signals
	signal internal_out: signed(8 downto 0);
	
	begin
		adding: process(clk_str, reg_a_str, reg_b_str) is begin
			if rising_edge(clk_str) then
				internal_out <= signed(resize(reg_a_str, 9) - resize(reg_b_str, 9));
			end if;
		end process;
		
		--Assigning to output
		sync: process(internal_out) is begin  --synching the output
				if internal_out(8) = '1' then
					neg_flag <= '1';
					out_reg_str <= std_logic_vector(not(internal_out) + 1);
				else
					neg_flag <= '0';
					out_reg_str <= std_logic_vector(internal_out);
				end if;
		end process;
end architecture;


--Defining ALU
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is 
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
end entity;

architecture behave of ALU is
	--Defining components
	component signed_adder --signed adder
	port(
		clk_addr: in std_logic; --internal clk of the adder 
		reg_a_addr, reg_b_addr: in signed(7 downto 0); --input registers
		out_reg_addr: out std_logic_vector(8 downto 0); --output register
		neg_flag: out std_logic --checks if the output is negative
	);
	end component;
	
	component signed_subtractor --signed subtractor
	port(
		clk_str: in std_logic; --internal clk of the adder 
		reg_a_str, reg_b_str: in signed(7 downto 0); --input registers
		out_reg_str: out std_logic_vector(8 downto 0); --output register
		neg_flag: out std_logic --checks if the output is negative
	);
	end component;
	
	component barrel_shifter  --Barrel shifter
		port(
			clk_barrel_shifter: in std_logic;
			reg_a_bs: in std_logic_vector(7 downto 0); --input to our barrel shifter
			reg_out_bs: out std_logic_vector(7 downto 0); --output
			shift_by_bs: in std_logic_vector(2 downto 0); --Amount of shift
			shift_lt_rt_bs: in std_logic  --shifts either left or  right
		);
	end component;

	--Defining internal signals
	signal internal_output: std_logic_vector(8 downto 0);
	signal internal_out_reg_addr: std_logic_vector(8 downto 0);
	signal internal_out_reg_str: std_logic_vector(8 downto 0);
	signal internal_out_reg_barl_sftr: std_logic_vector(7 downto 0);
	signal neg_flag_addr, neg_flag_str: std_logic;
	
	signal reg_a, reg_b: std_logic_vector(7 downto 0) := "00000000"; --input registers  
	begin
	
		input_sync: process(clk, ip_sel) is begin
			if rising_edge(clk) then
				if ip_sel = "00" then
					reg_a(7) <= master_ip(3);
					reg_a(6) <= master_ip(2);
					reg_a(5) <= master_ip(1);
					reg_a(4) <= master_ip(0);
				elsif ip_sel = "01" then
					reg_a(3) <= master_ip(3);
					reg_a(2) <= master_ip(2);
					reg_a(1) <= master_ip(1);
					reg_a(0) <= master_ip(0);
				elsif ip_sel = "10" then 
					reg_b(7) <= master_ip(3);
					reg_b(6) <= master_ip(2);
					reg_b(5) <= master_ip(1);
					reg_b(4) <= master_ip(0);
				elsif ip_sel = "11" then
					reg_b(3) <= master_ip(3);
					reg_b(2) <= master_ip(2);
					reg_b(1) <= master_ip(1);
					reg_b(0) <= master_ip(0);
				end if;
			end if;
		end process;
	
		alu_op: process(clk) is begin
			if rising_edge(clk) then
				if op_code = "0000" then --signed addition operation
					internal_output <= internal_out_reg_addr; --Conditional assignment of addr output
					nzcv(3) <= neg_flag_addr;  -- setting negative flag
					if internal_output(8) = '1' then -- setting for overflow
						nzcv(0) <= '1';
					else
						nzcv(0) <= '0';
					end if;
				elsif op_code = "0001" then --signed substraction operation
					internal_output <= internal_out_reg_str; --Conditional assignment of subr output
					nzcv(3) <= neg_flag_str;
					if internal_output(8) = '1' then -- setting for overflow
						nzcv(0) <= '1';
					else 
						nzcv(0) <= '0';
					end if;
				elsif op_code = "0010" then --and operation
					internal_output <= std_logic_vector(resize(unsigned(unsigned(reg_a) and unsigned(reg_b)), 9));
				elsif op_code = "0011" then --or op 
					internal_output <= std_logic_vector(resize(unsigned(unsigned(reg_a) or unsigned(reg_b)), 9));
				elsif op_code = "0100" then --xor op
					internal_output <= std_logic_vector(resize(unsigned(unsigned(reg_a) xor unsigned(reg_b)), 9));
				elsif op_code = "0101" then --nand op
					internal_output <= std_logic_vector(resize(unsigned(unsigned(reg_a) nand unsigned(reg_b)), 9));
				elsif op_code = "0110" then --xnor op
					internal_output <= std_logic_vector(resize(unsigned(unsigned(reg_a) xnor unsigned(reg_b)), 9));
				elsif op_code = "0111" then --nor op 
					internal_output <= std_logic_vector(resize(unsigned(unsigned(reg_a) nor unsigned(reg_b)), 9));
				elsif op_code = "1000" then --barrel Shifter
					internal_output <= std_logic_vector(resize(unsigned(internal_out_reg_barl_sftr), 9));	
				else
					internal_output <= "ZZZZZZZZZ"; --otherwise the output will remain high impedance
				end if;
			end if;
			
			if internal_output <= "000000000" then --setting zero flag
				nzcv(2) <= '1';
			else
				nzcv(2) <= '0';
			end if;
		end process;						

		-- port maping for signed adder
		addr1: signed_adder port map(  
			clk_addr => clk, reg_a_addr => signed(reg_a),
			reg_b_addr => signed(reg_b), out_reg_addr => internal_out_reg_addr,
			neg_flag => neg_flag_addr);
		
		-- port maping for signed subtractor
		sub1: signed_subtractor port map(  
			clk_str => clk, reg_a_str => signed(reg_a),
			reg_b_str => signed(reg_b), out_reg_str => internal_out_reg_str,
			neg_flag => neg_flag_str);			
			
		-- port maping for barrel shifter	
		barel_shift1: barrel_shifter port map(reg_a_bs => std_logic_vector(reg_a), clk_barrel_shifter => clk,
											shift_by_bs=> shift_by, shift_lt_rt_bs => shift_lt_rt,
											reg_out_bs => internal_out_reg_barl_sftr);
					
		sync_output: process(clk) is begin
			if rising_edge(clk) then
				out_reg <= internal_output;
			end if;
		end process;
end architecture;
