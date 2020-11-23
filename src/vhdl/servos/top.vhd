-- Top level containt Servo and Addition component to control the servo 
-- ADD Additional Component , SINE ROM Component to change the input position, Counter Component , reset module Component to reset .

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- -- The top module’s entity consists of the clock and reset inputs and the PWM output, which controls the RC servo --

ENTITY top IS
  PORT (
    clk : IN STD_LOGIC;
    rst_n : IN STD_LOGIC; -- I’ve connected the rst signal to a pin configured with an internal pull-up resistor.	
    pwm : OUT STD_LOGIC -- control signal 
  );
END top;

ARCHITECTURE str OF top IS

  CONSTANT clk_hz : real := 50.0e6; -- 50 MHz clock.FPGA clock 
  CONSTANT pulse_hz : real := 50.0; -- Frequency 

  CONSTANT min_pulse_us : real := 700.0; -- FEETECH FS5106B values
  CONSTANT max_pulse_us : real := 2300.0; -- FEETECH FS5106B values
  CONSTANT step_bits : POSITIVE := 8; -- 0 to 255
  CONSTANT step_count : POSITIVE := 2 ** step_bits;

  --  cnt signal for the free-running counter  -- 
  -- Wraps in 2.8 seconds at 12 MHz (Need to be edit for our FPGA ) 
  CONSTANT cnt_bits : INTEGER := 25;
  SIGNAL cnt : unsigned(cnt_bits - 1 DOWNTO 0);

  -- Additional Component , Reset , Sine ROM (FOR Position) rom_data , rom_addr (for Counter)
  -- declare the signals that will connect the top-level modules according to the data flow chart 
  SIGNAL rst : STD_LOGIC;
  SIGNAL position : INTEGER RANGE 0 TO step_count - 1;
  SIGNAL rom_addr : unsigned(step_bits - 1 DOWNTO 0);
  SIGNAL rom_data : unsigned(step_bits - 1 DOWNTO 0);

BEGIN
  --the concurrent assignments to connect the Counter module, the Sine ROM module, and the Servo module.
  -- The Servo module’s position input is a copy of the Sine ROM output, but we have to convert the unsigned value to an integer because they are of different types. For the ROM address input, we use the top bits of the free-running counter. By doing this, 
  -- the sine wave motion cycle will complete when the cnt signal wraps, after 2.8 seconds (value need to edit for our FPGA ).
  position <= to_integer(rom_data);
  rom_addr <= cnt(cnt'left DOWNTO cnt'left - step_bits + 1);

  -- Reset module instantiation -- 
  RESET : ENTITY work.reset(rtl)
    PORT MAP(
      clk => clk,
      rst_n => rst_n,
      rst => rst
    );

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
  -- SELF-WRAPPING COUNTER INSTANTIATION -- 
  -- a free-running counter that counts to counter_bits, and then goes to zero again-- 

  COUNTER : ENTITY work.counter(rtl)
    GENERIC MAP(
      counter_bits => cnt_bits
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      count_enable => '1',
      counter => cnt
    );

  -- SINE ROM INSTANTIATION --
  --  translates a linear number value to a full sine wave with the same min/max amplitude. 
  --  The input is the addr signal, and the sine values appear on the data output

  SINE_ROM : ENTITY work.sine_rom(rtl)
    GENERIC MAP(
      data_bits => step_bits,
      addr_bits => step_bits
    )
    PORT MAP(
      clk => clk,
      addr => rom_addr,
      data => rom_data
    );

END ARCHITECTURE;