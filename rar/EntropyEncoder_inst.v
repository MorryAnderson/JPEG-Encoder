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
// Created on Sat Apr 13 15:44:53 2019

EntropyEncoder EntropyEncoder_inst
(
	.I_clk(I_clk_sig) ,	// input  I_clk_sig
	.I_rst_n(I_rst_n_sig) ,	// input  I_rst_n_sig
	.I_en(I_en_sig) ,	// input  I_en_sig
	.I_data_valid(I_data_valid_sig) ,	// input  I_data_valid_sig
	.I_block_update(I_block_update_sig) ,	// input  I_block_update_sig
	.I_data(I_data_sig) ,	// input [7:0] I_data_sig
	.O_huff_len(O_huff_len_sig) ,	// output [4:0] O_huff_len_sig
	.O_huff_code(O_huff_code_sig) ,	// output [15:0] O_huff_code_sig
	.O_amp_size(O_amp_size_sig) ,	// output [2:0] O_amp_size_sig
	.O_amp_code(O_amp_code_sig) ,	// output [7:0] O_amp_code_sig
	.O_huff_code_valid(O_huff_code_valid_sig) ,	// output  O_huff_code_valid_sig
	.O_end_of_block(O_end_of_block_sig) 	// output  O_end_of_block_sig
);
