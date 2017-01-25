--------------------------------------------------------------------------------
--
--   FileName:         lcd_controller.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 32-bit Version 11.1 Build 173 SJ Full Version
--
--   This file is a derivation of the implementation found at
--	  https://eewiki.net/download/attachments/4096079/lcd_controller.vhd?version=3&modificationDate=1339620193283&api=v2
--
--   Version History
--   Version 1.0 6/2/2006 Scott Larson
--     Initial Public Release
--    Version 2.0 6/13/2012 Scott Larson
--		Version 3.0 10/01/2017 Mayur Panchal
--
--   CLOCK FREQUENCY: to change system clock frequency, change Line 65
--
--   LCD INITIALIZATION SETTINGS: to change, comment/uncomment lines:
--
--   Function Set  
--      2-line mode, display on             Line 93    lcd_data <= "00111100";
--      1-line mode, display on             Line 94    lcd_data <= "00110100";
--      1-line mode, display off            Line 95    lcd_data <= "00110000";
--      2-line mode, display off            Line 96    lcd_data <= "00111000";
--   Display ON/OFF
--      display on, cursor off, blink off   Line 104   lcd_data <= "00001100";
--      display on, cursor off, blink on    Line 105   lcd_data <= "00001101";
--      display on, cursor on, blink off    Line 106   lcd_data <= "00001110";
--      display on, cursor on, blink on     Line 107   lcd_data <= "00001111";
--      display off, cursor off, blink off  Line 108   lcd_data <= "00001000";
--      display off, cursor off, blink on   Line 109   lcd_data <= "00001001";
--      display off, cursor on, blink off   Line 110   lcd_data <= "00001010";
--      display off, cursor on, blink on    Line 111   lcd_data <= "00001011";
--   Entry Mode Set
--      increment mode, entire shift off    Line 127   lcd_data <= "00000110";
--      increment mode, entire shift on     Line 128   lcd_data <= "00000111";
--      decrement mode, entire shift off    Line 129   lcd_data <= "00000100";
--      decrement mode, entire shift on     Line 130   lcd_data <= "00000101";
--    
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY lcd_controller IS
  PORT(
    clk        : IN    STD_LOGIC;  --system clock
    reset_n    : IN    STD_LOGIC;  --active low reinitializes lcd
    rw, rs, e  : OUT   STD_LOGIC;  --read/write, setup/data, and enable for lcd
    lcd_data   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0); --data signals for lcd
	 line1_buffer : IN STD_LOGIC_VECTOR(127 downto 0); -- Data for the top line of the LCD
	 line2_buffer : IN STD_LOGIC_VECTOR(127 downto 0)); -- Data for the bottom line of the LCD
END lcd_controller;

ARCHITECTURE controller OF lcd_controller IS
  TYPE CONTROL IS(power_up, initialize, RESETLINE, line1, line2, send);
  SIGNAL    state      : CONTROL;
  CONSTANT  freq       : INTEGER := 100; --system clock frequency in MHz
  SIGNAL 	ptr     	  : natural range 0 to 16 := 15; -- To keep track of what character we are up to
  SIGNAL 	line		  : STD_LOGIC := '1';
BEGIN
  PROCESS(clk)
    VARIABLE clk_count : INTEGER := 0; --event counter for timing
  BEGIN
  IF(clk'EVENT and clk = '1') THEN
    
      CASE state IS
        
        --wait 50 ms to ensure Vdd has risen and required LCD wait is met
        WHEN power_up =>
          IF(clk_count < (50000 * freq)) THEN    --wait 50 ms
            clk_count := clk_count + 1;
            state <= power_up;
          ELSE                                   --power-up complete
            clk_count := 0;
            rs <= '0';
            rw <= '0';
            lcd_data <= "00110000";
            state <= initialize;
          END IF;
          
        --cycle through initialization sequence  
        WHEN initialize =>
          clk_count := clk_count + 1;
          IF(clk_count < (10 * freq)) THEN       --function set
            lcd_data <= "00111100";      --2-line mode, display on
            --lcd_data <= "00110100";    --1-line mode, display on
            --lcd_data <= "00110000";    --1-line mdoe, display off
            --lcd_data <= "00111000";    --2-line mode, display off
            e <= '1';
            state <= initialize;
          ELSIF(clk_count < (60 * freq)) THEN    --wait 50 us
            lcd_data <= "00000000";
            e <= '0';
            state <= initialize;
          ELSIF(clk_count < (70 * freq)) THEN    --display on/off control
            lcd_data <= "00001100";      --display on, cursor off, blink off
            --lcd_data <= "00001101";    --display on, cursor off, blink on
            --lcd_data <= "00001110";    --display on, cursor on, blink off
            --lcd_data <= "00001111";    --display on, cursor on, blink on
            --lcd_data <= "00001000";    --display off, cursor off, blink off
            --lcd_data <= "00001001";    --display off, cursor off, blink on
            --lcd_data <= "00001010";    --display off, cursor on, blink off
            --lcd_data <= "00001011";    --display off, cursor on, blink on            
            e <= '1';
            state <= initialize;
          ELSIF(clk_count < (120 * freq)) THEN   --wait 50 us
            lcd_data <= "00000000";
            e <= '0';
            state <= initialize;
          ELSIF(clk_count < (130 * freq)) THEN   --display clear
            lcd_data <= "00000001";
            e <= '1';
            state <= initialize;
          ELSIF(clk_count < (2130 * freq)) THEN  --wait 2 ms
            lcd_data <= "00000000";
            e <= '0';
            state <= initialize;
          ELSIF(clk_count < (2140 * freq)) THEN  --entry mode set
            lcd_data <= "00000110";      --increment mode, entire shift off
            --lcd_data <= "00000111";    --increment mode, entire shift on
            --lcd_data <= "00000100";    --decrement mode, entire shift off
            --lcd_data <= "00000101";    --decrement mode, entire shift on
            e <= '1';
            state <= initialize;
          ELSIF(clk_count < (2200 * freq)) THEN  --wait 60 us
            lcd_data <= "00000000";
            e <= '0';
            state <= initialize;
          ELSE                                   --initialization complete
            clk_count := 0;
            state <= RESETLINE;
          END IF;    
			 
		  WHEN resetline =>
			 ptr <= 16;
			 if line = '1' then
		      lcd_data <= "10000000";
            rs <= '0';
            rw <= '0';
            clk_count := 0; 
            state <= send;
			 else
			   lcd_data <= "11000000";
            rs <= '0';
            rw <= '0';
            clk_count := 0; 
            state <= send;
			 end if;
       
        WHEN line1 =>
				line <= '1';
				lcd_data <= line1_buffer(ptr*8 + 7 downto ptr*8);
            rs <= '1';
            rw <= '0';
            clk_count := 0; 
				line <= '1';
            state <= send;
				
		  WHEN line2 =>
				line <= '0';
				lcd_data <= line2_buffer(ptr*8 + 7 downto ptr*8);
            rs <= '1';
            rw <= '0';
            clk_count := 0;            
            state <= send;
		  
        --send instruction to lcd        
        WHEN send =>
			  IF(clk_count < (50 * freq)) THEN  --do not exit for 50us
				  IF(clk_count < freq) THEN      --negative enable
					e <= '0';
				  ELSIF(clk_count < (14 * freq)) THEN  --positive enable half-cycle
					e <= '1';
				  ELSIF(clk_count < (27 * freq)) THEN  --negative enable half-cycle
					e <= '0';
				  END IF;
				  clk_count := clk_count + 1;
				  state <= send;
			  ELSE
			  	  clk_count := 0;
				  if line = '1' then
					   if ptr = 0 then
							line <= '0';
							state <= resetline;
						else
							ptr <= ptr - 1;
							state <= line1;
						end if;
				  else
						if ptr = 0 then
							line <= '1';
							state <= resetline;
						else
							ptr <= ptr - 1;
							state <= line2;
						end if;
				  end if;
			  END IF;

      END CASE;    
    
      --reset
      IF(reset_n = '0') THEN
          state <= power_up;
      END IF;
    
    END IF;
  END PROCESS;
END controller;
