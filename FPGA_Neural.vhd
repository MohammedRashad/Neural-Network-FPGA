LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.package_types.ALL;

----------------------------------------

ENTITY FPGA_Neural IS

	GENERIC (
		inputSize : POSITIVE := 2;
		hiddenSize : POSITIVE := 3;
		outputSize : POSITIVE := 1
	);

	PORT (
		clk : IN std_logic;
		start : IN std_logic;
		input : IN matrix(inputSize - 1 DOWNTO 0, 1 DOWNTO 1);
		output : OUT matrix(outputSize - 1 DOWNTO 0, 1 DOWNTO 1)
	);
END FPGA_Neural; 

----------------------------------------

ARCHITECTURE implementation OF FPGA_Neural IS
BEGIN
	mlp_network : ENTITY work.network
			GENERIC MAP(inputSize  =>2, hiddenSize => 3, outputSize => 1)
			PORT MAP(clk => clk, start => start, input => input, output => output);
END implementation;