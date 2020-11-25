LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY top IS
  PORT (
    clk : IN STD_LOGIC;
    rst_n : IN STD_LOGIC;
    pwm : OUT STD_LOGIC);
END top;

ARCHITECTURE str OF top IS

  -- [ Declaration constant  ] -- 
  CONSTANT clk_hz : real := 50.0e6; -- 50 MHz clock.FPGA clock 
  CONSTANT pulse_hz : real := 50.0; -- Frequency 
  CONSTANT min_pulse_us : real := 700.0; -- FEETECH FS5106B values
  CONSTANT max_pulse_us : real := 2300.0; -- FEETECH FS5106B values 
  CONSTANT step_bits : POSITIVE := 8;
  CONSTANT step_count : POSITIVE := 2 ** step_bits; -- 0 to 255 steps

  -- Declare the signals that will connect the top-level modules according to the data flow char [ Reset ,  Position ] 
  SIGNAL rst : STD_LOGIC;
  ---- Position ---
  -- Position the control input to the servo module. 
  SIGNAL position : INTEGER RANGE 0 TO step_count - 1; -- 0 to 255 steps 

BEGIN

  -- Reset module instantiation -- 
  RESET : ENTITY work.reset(rtl)
    PORT MAP(
      clk => clk,
      rst_n => rst_n,
      rst => rst
    );

  -- Position --
  -- If we set it to zero, the module will produce min_pulse_us microseconds long PWM pulses. 
  -- When position is at the highest value, it will produce max_pulse_us long pulses.

  position <= 255; -- 255 give 180 degree ,steps give clockwise and other counter clockwise when 1000～2000 μsec Rotate CounterClockWise From DataSheet 
  -- The servo module instantiation : constant to generic, and local signal to port signal.
  SERVO : ENTITY work.servo(rtl)
    GENERIC MAP(
      clk_hz => clk_hz,
      pulse_hz => pulse_hz,
      min_pulse_us => min_pulse_us,
      max_pulse_us => max_pulse_us,
      step_count => step_count
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      position => position,
      pwm => pwm
    );

END ARCHITECTURE;