--PT 13:15 Paulina S³awiñska 238992 "browar"
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
  
ENTITY test2 IS
END test2;
 
ARCHITECTURE behavior OF test2 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT uut
    PORT( 
         woda : IN  std_logic;
         clk : IN  std_logic;
         reset : IN  std_logic;
         postep : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal woda : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal postep : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut1: uut PORT MAP (
          woda => woda,
          clk => clk,
          reset => reset,
          postep => postep
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
    reset <= '0'; wait for clk_period; --najpierw reset jest rowny 0, czekaj jeden okres zegara
	  reset <= '1'; --reset nieaktywny
	  woda <= '1'; wait for 40*clk_period; --czekaj 40 cykli zegara
	  assert false severity failure;

      wait;
   end process;

END;
