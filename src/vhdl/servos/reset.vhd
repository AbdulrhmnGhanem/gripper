LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY reset IS
  PORT (
    clk : IN STD_LOGIC;
    rst_n : IN STD_LOGIC; -- Pullup
    rst : OUT STD_LOGIC
  );
END reset;

ARCHITECTURE rtl OF reset IS

  SIGNAL sreg : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

  SREG_PROC : PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      sreg <= sreg(sreg'high - 1 DOWNTO 0) & rst_n;
    END IF;
  END PROCESS;

  RESET_PROC : PROCESS (sreg)
    CONSTANT all_ones : STD_LOGIC_VECTOR(sreg'RANGE) := (OTHERS => '1');
  BEGIN

    IF sreg = all_ones THEN
      rst <= '0';
    ELSE
      rst <= '1';
    END IF;

  END PROCESS;

END ARCHITECTURE;