LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE ieee.math_real.ALL;

ENTITY sine_rom IS
  GENERIC (
    addr_bits : INTEGER RANGE 1 TO 30;
    data_bits : INTEGER RANGE 1 TO 31
  );
  PORT (
    clk : IN STD_LOGIC;
    addr : IN unsigned(addr_bits - 1 DOWNTO 0);
    data : OUT unsigned(data_bits - 1 DOWNTO 0)
  );
END sine_rom;

ARCHITECTURE rtl OF sine_rom IS

  SUBTYPE addr_range IS INTEGER RANGE 0 TO 2 ** addr_bits - 1;
  TYPE rom_type IS ARRAY (addr_range) OF unsigned(data_bits - 1 DOWNTO 0);

  -- Fill the ROM with sine values
  FUNCTION init_rom RETURN rom_type IS
    VARIABLE rom_v : rom_type;
    VARIABLE angle : real;
    VARIABLE sin_scaled : real;
  BEGIN

    FOR i IN addr_range LOOP

      angle := real(i) * ((2.0 * MATH_PI) / 2.0 ** addr_bits);
      sin_scaled := (1.0 + sin(angle)) * (2.0 ** data_bits - 1.0) / 2.0;
      rom_v(i) := to_unsigned(INTEGER(round(sin_scaled)), data_bits);

    END LOOP;

    RETURN rom_v;
  END init_rom;

  CONSTANT rom : rom_type := init_rom;

BEGIN

  ROM_PROC : PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      data <= rom(to_integer(addr));
    END IF;
  END PROCESS;

END ARCHITECTURE;