-- Servo movement easer; to prevent inertia effects.
-- uses easeInOutQuint

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Easer IS
    GENERIC (
        clk_hz : real;
        step_count : POSITIVE; -- Number of steps from min to max
        -- The milisecond from required to move from initial position to final postion
        easeing_duration : real
    );
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        -- the postion(in steps) the servo should be at after the easing_duration
        newPosition : IN INTEGER RANGE 0 TO step_count - 1;

        step : OUT INTEGER RANGE 0 TO step_count - 1; -- this should be the input to the servo controller.
        ack : OUT STD_LOGIC -- Should go high if the servo is at newPosition
    );
END Easer;

ARCHITECTURE behavioral OF Easer IS
    -- I think you will need these value for the implementation, feel free to change, delte, or create new ones.
    SIGNAL initial_position : INTEGER RANGE 0 TO step_count - 1 := 0;
    SIGNAL current_position : INTEGER RANGE 0 TO step_count - 1;
    SIGNAL ticks : INTEGER RANGE 0 TO clk_hz;
BEGIN
END behavioral;