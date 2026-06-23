For running the testbench, firstly, run the associated python script to get a reference hex file with the inputs and golden outputs. Then modify the golden output file present in the sv testbench and run the code.

For multiplier:
1. Python code: arith_test.py
2. SV TB: config_mult_tb_2.sv

For adder:
1. Python code: adder_test.py
2. SV TB: config_adder_tb_2.sv

Ensure that your GPU supports BF16 arithmetic and cuda is being utilized while running the python script. Otherwise, the outputs generated for BF16 will not be proper in the reference code. 
