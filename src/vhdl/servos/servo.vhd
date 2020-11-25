
-- THE VHDL SERVO CONTROLLER

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.round; -- use the round function from the math_real library, which always rounds away from 0. 

ENTITY servo IS
  -- By using generic constants, we can create a module that will work for any PWM enabled RC servo.--
  GENERIC (
    clk_hz : real; --  the clock frequency of the FPGA 
    pulse_hz : real; -- PWM pulse frequency -- how often the PWM output shall be pulsed,
    -- set the pulse width in microseconds at the minimum and maximum positions.--
    min_pulse_us : real; -- uS pulse width at min position 
    max_pulse_us : real; -- uS pulse width at max position
    -- how many steps there are between the min and max position, including the endpoints.--
    step_count : POSITIVE -- Number of steps from min to max
  );
  PORT (
    clk : IN STD_LOGIC; -- Clock
    rst : IN STD_LOGIC; -- Reset 
    -- Position the control input to the servo module. 
    -- If we set it to zero, the module will produce min_pulse_us microseconds long PWM pulses. 
    -- When position is at the highest value, it will produce max_pulse_us long pulses.
    position : IN INTEGER RANGE 0 TO step_count - 1;
    -- The PWM output is the interface to the external RC servo. 
    -- It should go through an FPGA pin and connect to the “Signal” input on the servo, usually the yellow or white wire. 
    --Note that you will likely need to use a level converter. Most FPGAs use 3.3 V logic level, while most RC servos run on 5 V.
    pwm : OUT STD_LOGIC
  );
END servo;

ARCHITECTURE rtl OF servo IS

  -- Calculate Constants , Number of clock cycles in <us_count> Microseconds
  FUNCTION cycles_per_us (us_count : real) RETURN INTEGER IS
  BEGIN
    RETURN INTEGER(round(clk_hz / 1.0e6 * us_count));
  END FUNCTION;
  --  helper constants, which we will use to make the timing of the output PWM according to the generics.
  -- translate the min and max microsecond values to absolute number of clock cycles	
  CONSTANT min_count : INTEGER := cycles_per_us(min_pulse_us);
  CONSTANT max_count : INTEGER := cycles_per_us(max_pulse_us);
  --  calculate the range in microseconds between the two, from which we derive step_us, the duration difference between each linear position step
  CONSTANT min_max_range_us : real := max_pulse_us - min_pulse_us;
  CONSTANT step_us : real := min_max_range_us / real(step_count - 1);
  -- convert the microsecond real value to a fixed number of clock periods: cycles_per_step.
  CONSTANT cycles_per_step : POSITIVE := cycles_per_us(step_us);
  --  the PWM counter --  calculate the number of clock cycles we have to count to,
  --  This integer signal is a free-running counter that wraps pulse_hz times every second.
  --	That’s how we achieve the PWM frequency given in the generics. 
  CONSTANT counter_max : INTEGER := INTEGER(round(clk_hz / pulse_hz)) - 1;
  SIGNAL counter : INTEGER RANGE 0 TO counter_max;
  --  declare a copy of the counter named duty_cycle. This signal will determine the length of the high period on the PWM output.--
  SIGNAL duty_cycle : INTEGER RANGE 0 TO max_count;

BEGIN
  --- COUNTING CLOCK CYCLES ---
  --the process that implements the free-running counter.
  COUNTER_PROC : PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      IF rst = '1' THEN
        counter <= 0;

      ELSE
        IF counter < counter_max THEN
          counter <= counter + 1;
        ELSE
          counter <= 0; -- when the counter reaches the max value --
        END IF;

      END IF;
    END IF;
  END PROCESS;
  -- PWM OUTPUT PROCESS --
  -- To determine if the PWM output should be a high or low value, 
  -- we compare the counter and duty_cycle signals. If the counter is less than the duty cycle, 
  -- the output is a high value. Thus, the value of the duty_cycle signal controls the duration of the PWM pulse
  PWM_PROC : PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      IF rst = '1' THEN
        pwm <= '0';

      ELSE
        pwm <= '0';

        IF counter < duty_cycle THEN
          pwm <= '1';
        END IF;

      END IF;
    END IF;
  END PROCESS;
  -- CALCULATING THE DUTY CYCLE --
  -- The duty cycle should never be less than min_count clock cycles 
  -- because that’s the value that corresponds to the min_pulse_us generic input. 
  -- Therefore, we use min_count as the reset value for the duty_cycle signal, 
  DUTY_CYCLE_PROC : PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      IF rst = '1' THEN
        duty_cycle <= min_count;

      ELSE
        --  calculate the duty cycle as a function of the input position --
        --  The cycles_per_step constant is an approximation, rounded to the nearest integer. 
        --  Therefore, the error on this constant may be up to 0.5. When we multiply with the commanded position,
        --   the error will scale up.
        --  However, with the FPGA clock being vastly faster than the PWM frequency, it won’t be noticeable
        duty_cycle <= position * cycles_per_step + min_count;

      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE;