LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE ieee.math_real.ALL;

ENTITY counter IS
  GENERIC (
    counter_bits : INTEGER
  );
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    count_enable : STD_LOGIC;
    counter : OUT unsigned(counter_bits - 1 DOWNTO 0)
  );
END counter;

ARCHITECTURE rtl OF counter IS

  SIGNAL counter_i : unsigned(counter'RANGE);

BEGIN

  counter <= counter_i;

  COUNTER_PROC : PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      IF rst = '1' THEN
        counter_i <= (OTHERS => '0');

      ELSE
        IF count_enable = '1' THEN
          counter_i <= counter_i + 1;
        END IF;

      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE;