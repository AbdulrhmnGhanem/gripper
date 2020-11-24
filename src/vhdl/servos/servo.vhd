
-- THE VHDL SERVO CONTROLLER

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.round; -- use the round function from the math_real library, which always rounds away from 0. 

entity servo is
-- By using generic constants, we can create a module that will work for any PWM enabled RC servo.--
  generic (
    clk_hz : real; --  the clock frequency of the FPGA 
    pulse_hz : real; -- PWM pulse frequency -- how often the PWM output shall be pulsed,
	-- set the pulse width in microseconds at the minimum and maximum positions.--
    min_pulse_us : real; -- uS pulse width at min position 
    max_pulse_us : real; -- uS pulse width at max position
	-- how many steps there are between the min and max position, including the endpoints.--
    step_count : positive -- Number of steps from min to max
  );
  port (
    clk : in std_logic;  -- Clock
    rst : in std_logic;  -- Reset 
	-- Position the control input to the servo module. 
	-- If we set it to zero, the module will produce min_pulse_us microseconds long PWM pulses. 
	-- When position is at the highest value, it will produce max_pulse_us long pulses.
    position : in integer range 0 to step_count - 1;
    -- The PWM output is the interface to the external RC servo. 
	-- It should go through an FPGA pin and connect to the “Signal” input on the servo, usually the yellow or white wire. 
	--Note that you will likely need to use a level converter. Most FPGAs use 3.3 V logic level, while most RC servos run on 5 V.
	pwm : out std_logic
  );
end servo;

architecture rtl of servo is
 
  -- Calculate Constants , Number of clock cycles in <us_count> Microseconds
  function cycles_per_us (us_count : real) return integer is
  begin
    return integer(round(clk_hz / 1.0e6 * us_count));
  end function;
	--  helper constants, which we will use to make the timing of the output PWM according to the generics.
    -- translate the min and max microsecond values to absolute number of clock cycles	
  constant min_count : integer := cycles_per_us(min_pulse_us);
  constant max_count : integer := cycles_per_us(max_pulse_us);
  --  calculate the range in microseconds between the two, from which we derive step_us, the duration difference between each linear position step
  constant min_max_range_us : real := max_pulse_us - min_pulse_us;
  constant step_us : real := min_max_range_us / real(step_count - 1);
  -- convert the microsecond real value to a fixed number of clock periods: cycles_per_step.
  constant cycles_per_step : positive := cycles_per_us(step_us);
		--  the PWM counter --  calculate the number of clock cycles we have to count to,
		--  This integer signal is a free-running counter that wraps pulse_hz times every second.
		--	That’s how we achieve the PWM frequency given in the generics. 
  constant counter_max : integer := integer(round(clk_hz / pulse_hz)) - 1;
  signal counter : integer range 0 to counter_max;
	--  declare a copy of the counter named duty_cycle. This signal will determine the length of the high period on the PWM output.--
  signal duty_cycle : integer range 0 to max_count;

begin
			--- COUNTING CLOCK CYCLES ---
			--the process that implements the free-running counter.
  COUNTER_PROC : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        counter <= 0;

      else
        if counter < counter_max then
          counter <= counter + 1;
        else
          counter <= 0; -- when the counter reaches the max value --
        end if;

      end if;
    end if;
  end process;
				-- PWM OUTPUT PROCESS --
-- To determine if the PWM output should be a high or low value, 
-- we compare the counter and duty_cycle signals. If the counter is less than the duty cycle, 
-- the output is a high value. Thus, the value of the duty_cycle signal controls the duration of the PWM pulse
  PWM_PROC : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        pwm <= '0';

      else
        pwm <= '0';

        if counter < duty_cycle then
          pwm <= '1';
        end if;

      end if;
    end if;
  end process;
				-- CALCULATING THE DUTY CYCLE --
-- The duty cycle should never be less than min_count clock cycles 
-- because that’s the value that corresponds to the min_pulse_us generic input. 
-- Therefore, we use min_count as the reset value for the duty_cycle signal, 
  DUTY_CYCLE_PROC : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        duty_cycle <= min_count;

      else
	  --  calculate the duty cycle as a function of the input position --
	  --  The cycles_per_step constant is an approximation, rounded to the nearest integer. 
	  --  Therefore, the error on this constant may be up to 0.5. When we multiply with the commanded position,
	  --   the error will scale up.
	  --  However, with the FPGA clock being vastly faster than the PWM frequency, it won’t be noticeable
        duty_cycle <= position * cycles_per_step + min_count;

      end if;
    end if;
  end process;

end architecture;