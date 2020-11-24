library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  port (
    clk : in std_logic;
    rst_n : in std_logic; 
    pwm : out std_logic );
end top;

architecture str of top is

 -- [ Declaration constant  ] -- 
  constant clk_hz : real := 50.0e6; -- 50 MHz clock.FPGA clock 
  constant pulse_hz : real := 50.0;  -- Frequency 
  constant min_pulse_us : real := 700.0; -- FEETECH FS5106B values
  constant max_pulse_us : real := 2300.0; -- FEETECH FS5106B values 
  constant step_bits : positive := 8;  
  constant step_count : positive := 2**step_bits;  -- 0 to 255 steps

  -- Declare the signals that will connect the top-level modules according to the data flow char [ Reset ,  Position ] 
  signal rst : std_logic; 
  ---- Position ---
  -- Position the control input to the servo module. 
  signal position : integer range 0 to step_count - 1;  -- 0 to 255 steps 
  
  BEGIN 

	-- Reset module instantiation -- 
  RESET : entity work.reset(rtl)
  port map (
    clk => clk,
    rst_n => rst_n,
    rst => rst
  );
  
	-- Position --
	-- If we set it to zero, the module will produce min_pulse_us microseconds long PWM pulses. 
	-- When position is at the highest value, it will produce max_pulse_us long pulses.
	
	position <= 255 ;   -- 255 give 180 degree ,steps give clockwise and other counter clockwise when 1000～2000 μsec Rotate CounterClockWise From DataSheet 
	
	
	-- The servo module instantiation : constant to generic, and local signal to port signal.
  SERVO : entity work.servo(rtl)
  generic map (
    clk_hz => clk_hz,
    pulse_hz => pulse_hz,
    min_pulse_us => min_pulse_us,
    max_pulse_us => max_pulse_us,
    step_count => step_count
  )
  port map (
    clk => clk,
    rst => rst,
    position => position,
    pwm => pwm
  );
		
		end architecture;
	