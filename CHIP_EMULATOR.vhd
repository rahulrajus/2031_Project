LIBRARY IEEE;
LIBRARY ALTERA_MF;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE ALTERA_MF.ALTERA_MF_COMPONENTS.ALL;
USE LPM.LPM_COMPONENTS.ALL;


ENTITY CHIP_EMULATOR IS
	PORT(
		ADDR    : IN    STD_LOGIC_VECTOR(17 DOWNTO 0);
		OE_N    : IN    STD_LOGIC;
		WE_N    : IN    STD_LOGIC;
		DATA    : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END CHIP_EMULATOR;


ARCHITECTURE a OF CHIP_EMULATOR IS

	TYPE STATIC_MEMORY IS ARRAY (0 to 31) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL SRAM : STATIC_MEMORY;
	
	SIGNAL OUTPUT_DRIVE : STD_LOGIC;

BEGIN
	
	PROCESS (WE_N, DATA)
	BEGIN
		IF WE_N = '0' THEN
			SRAM(to_integer(unsigned(ADDR(4 DOWNTO 0)))) <= DATA;
		END IF;
	END PROCESS;

	OUTPUT_DRIVE <= NOT(OE_N) AND WE_N;
	 
	DATA <=
		"ZZZZZZZZZZZZZZZZ" WHEN OUTPUT_DRIVE = '0' ELSE
		SRAM(to_integer(unsigned(ADDR(4 DOWNTO 0)))) WHEN ADDR(17 DOWNTO 5) = "0000000000000" ELSE
		NOT ADDR(15 DOWNTO 0);
		
END a;
