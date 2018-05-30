LIBRARY ieee;
use ieee.numeric_std.all;
USE ieee.std_logic_1164.ALL;
USE work.package_types.ALL;
----------------------------------------

ENTITY Network IS

	GENERIC (
		inputSize : POSITIVE := 2;
		hiddenSize : POSITIVE := 3;
		outputSize : POSITIVE := 1
	);

	PORT (
		clk : IN std_logic;
		start : IN std_logic;
		input : IN matrix(inputSize - 1 DOWNTO 0, 0 DOWNTO 0);
		output : OUT matrix(outputSize - 1 DOWNTO 0, 0 DOWNTO 0)
	);

END Network;

----------------------------------------

ARCHITECTURE implementation OF Network IS

	SIGNAL input_sig  : matrix(inputSize - 1 DOWNTO 0, 0 DOWNTO 0);
	SIGNAL hidden_sig_final : matrix(hiddenSize - 1 DOWNTO 0, 0 DOWNTO 0);
	SIGNAL hidden_sig_inter : matrix(hiddenSize - 1 DOWNTO 0, 0 DOWNTO 0);
	SIGNAL hidden_sig : matrix(hiddenSize - 1 DOWNTO 0, 0 DOWNTO 0);
	SIGNAL output_sig_inter : matrix(outputSize - 1 DOWNTO 0, 0 DOWNTO 0);
	SIGNAL output_sig : matrix(outputSize - 1 DOWNTO 0, 0 DOWNTO 0);
	SIGNAL result		: matrix(outputSize - 1 DOWNTO 0, 0 DOWNTO 0);

	SIGNAL w1 : matrix(hiddenSize - 1 DOWNTO 0, inputSize - 1 DOWNTO 0);
	SIGNAL w2 : matrix(outputSize - 1 DOWNTO 0, hiddenSize - 1 DOWNTO 0);

   signal hidden_std_in  : std_logic_vector(31 downto 0);
   signal hidden_std_out : std_logic_vector(31 downto 0);
	
   signal out_std_in  : std_logic_vector(31 downto 0);
   signal out_std_out : std_logic_vector(31 downto 0);

	SIGNAL activate_hidden : std_logic;
	SIGNAL activate_output : std_logic;
	SIGNAL activate_sig_output : std_logic;

	---------------

BEGIN
	input_sig <= input;

	-- Wieghts Matrices ((Change with your weights))
	w1 <= ((0, 0),
			 (1, 1),
			 (2, 2));
			 
	w2(0,0) <= 0;
	w2(0,1) <= 0;
	w2(0,2) <= 3;
	
	
	sigmoid_one : ENTITY work.sigmoid
		PORT MAP(Y => hidden_std_in, O => hidden_std_out, clk => clk);

		sigmoid_two : ENTITY work.sigmoid
			PORT MAP(Y => out_std_in, O => out_std_out, clk => clk);

			--------------------------------------------------------------------------------------------------------
			-- Input to hidden layer calculation
			LayerOne : PROCESS (CLK,start)

				VARIABLE i, j, k : INTEGER RANGE 0 TO 999;
			BEGIN
				i := 0;
				j := 0;
				k := 0;

				IF CLK'EVENT AND CLK = '1' AND start = '1' THEN

					-- W1 x Input = hidden
					IF i < hiddenSize THEN
						IF j < 1 THEN
							IF k < inputSize THEN
								hidden_sig(i, j) <= hidden_sig_inter(i, j) + (w1(i, k) * input_sig(k, j));
								k := k + 1;
							END IF;
							j := j + 1;
						END IF;
						i := i + 1;
					else
						activate_hidden <= '1';
						hidden_sig <= hidden_sig_inter;
					END IF;
				END IF;

			END PROCESS;

			--------------------------------------------------------------------------------------------------------
			-- layer one activation
			SigmoidOne : PROCESS (CLK, activate_hidden)

				VARIABLE i : INTEGER RANGE 0 TO 999;
			BEGIN
				i := 0;
				-- Activate
				IF CLK'EVENT AND CLK = '1' AND activate_hidden = '1' THEN
					IF i < hiddenSize THEN
					hidden_std_in <= std_logic_vector(to_unsigned(hidden_sig(i, 0), hidden_std_in'length));
					hidden_sig_final(i, 0)  <= to_integer(unsigned(hidden_std_out));
					i := i + 1;
					else
						activate_hidden <= '0';
						activate_output <= '1';
					END IF;
				END IF;

			END PROCESS;

			--------------------------------------------------------------------------------------------------------
			-- Hidden layer to output calculation
			LayerTwo : PROCESS (CLK, activate_output)

				VARIABLE i, j, k : INTEGER RANGE 0 TO 999;
			BEGIN
				-- W2 x Hidden = output
				IF CLK'EVENT AND CLK = '1' AND activate_output = '1' THEN
					IF i < outputSize THEN
						IF j < 1 THEN
							IF k < hiddenSize THEN
								output_sig_inter(i, j) <= output_sig_inter(i, j) + (w2(i, k) * hidden_sig_final(k, j));
								k := k + 1;
							END IF;
							j := j + 1;
						END IF;
						i := i + 1;
					else
						activate_hidden <= '1';
						output_sig <= output_sig_inter;
					END IF;
				END IF;
			END PROCESS;

			--------------------------------------------------------------------------------------------------------
			-- layer two activation
			SigmoidTwo : PROCESS (CLK, activate_sig_output)

				VARIABLE i: INTEGER RANGE 0 TO 999;
			BEGIN
				i := 0;
				-- Activate
				IF CLK'EVENT AND CLK = '1' AND activate_sig_output = '1' THEN
				
					IF i < outputSize THEN
					out_std_in <= std_logic_vector(to_unsigned(output_sig(i, 0), out_std_in'length));
					result(i, 0) <= to_integer(unsigned(out_std_out));
					i := i + 1;
					END IF;
				END IF;

			END PROCESS;

			--------------------------------------------------------------------------------------------------------
			-- Output of the network
			output <= result;

END implementation;