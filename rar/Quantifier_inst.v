// Copyright (C) 2017  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.


// Generated by Quartus Prime Version 17.1 (Build Build 590 10/25/2017)
// Created on Thu Apr 11 12:16:36 2019

Quantifier Quantifier_inst
(
	.I_clk(I_clk_sig) ,	// input  I_clk_sig
	.I_rst_n(I_rst_n_sig) ,	// input  I_rst_n_sig
	.I_en(I_en_sig) ,	// input  I_en_sig
	.I_data_valid(I_data_valid_sig) ,	// input  I_data_valid_sig
	.I_dct_0(I_dct_0_sig) ,	// input [OUTPUT_WIDTH-1:0] I_dct_0_sig
	.I_dct_1(I_dct_1_sig) ,	// input [OUTPUT_WIDTH-1:0] I_dct_1_sig
	.I_dct_2(I_dct_2_sig) ,	// input [OUTPUT_WIDTH-1:0] I_dct_2_sig
	.I_dct_3(I_dct_3_sig) ,	// input [OUTPUT_WIDTH-1:0] I_dct_3_sig
	.I_dct_4(I_dct_4_sig) ,	// input [OUTPUT_WIDTH-1:0] I_dct_4_sig
	.I_dct_5(I_dct_5_sig) ,	// input [OUTPUT_WIDTH-1:0] I_dct_5_sig
	.I_dct_6(I_dct_6_sig) ,	// input [OUTPUT_WIDTH-1:0] I_dct_6_sig
	.I_dct_7(I_dct_7_sig) ,	// input [OUTPUT_WIDTH-1:0] I_dct_7_sig
	.O_quantified(O_quantified_sig) ,	// output [OUTPUT_WIDTH-1+8-12:0] O_quantified_sig
	.O_block_update(O_block_update_sig) ,	// output  O_block_update_sig
	.O_block_valid(O_block_valid_sig) 	// output  O_block_valid_sig
);

defparam Quantifier_inst.OUTPUT_WIDTH = 14;
