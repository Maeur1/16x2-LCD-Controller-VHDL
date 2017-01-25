----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Mayur Panchal
-- 
-- Create Date:    14:13:20 11/06/2016 
-- Design Name: 
-- Module Name:    ControllerTest_TOP - Behavioral 
-- Project Name: 	 LCD Controller Test
-- Target Devices: 	XC5VLX50T
-- Tool versions: 	ISE 14.7
-- Description: 	Handles controlling the 16x2 Character LCD screen
--
-- Dependencies: 
--
-- Revision: 1
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ControllerTest_TOP is
	port (
		clk          : in  std_logic;
		rst          : in  std_logic;
		lcd_e        : out std_logic;
		lcd_rs       : out std_logic;
		lcd_rw       : out std_logic;
		lcd_db       : out std_logic_vector(7 downto 0));
		
end ControllerTest_TOP;

architecture Behavioral of ControllerTest_TOP is

	COMPONENT lcd_controller IS
	  PORT(
		 clk        : IN    STD_LOGIC;  --system clock
		 reset_n    : IN    STD_LOGIC;  --active low reinitializes lcd
		 rw, rs, e  : OUT   STD_LOGIC;  --read/write, setup/data, and enable for lcd
		 lcd_data   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0); --data signals for lcd
		 line1_buffer : IN STD_LOGIC_VECTOR(127 downto 0); -- Data for the top line of the LCD
		 line2_buffer : IN STD_LOGIC_VECTOR(127 downto 0)); -- Data for the bottom line of the LCD
	END COMPONENT;
	
	-- These lines can be configured to be input from anything. 
	-- 8 bits per character
	signal top_line : std_logic_vector(127 downto 0) := x"4d617975722773204650474120202020"; -- Translates to Mayur's FPGA
	signal bottom_line : std_logic_vector(127 downto 0) := x"5445535420666f72204c434420202020";

begin

LCD: lcd_controller port map(
	clk => clk,
	reset_n => rst,
	e => lcd_e,
	rs => lcd_rs,
	rw => lcd_rw,
	lcd_data => lcd_db,
	line1_buffer => top_line,
	line2_buffer => bottom_line 
);

end Behavioral;

