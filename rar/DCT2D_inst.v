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
// Created on Tue Apr 09 15:42:16 2019

DCT2D DCT2D_inst
(
	.I_clk(I_clk_sig) ,	// input  I_clk_sig
	.I_rst_n(I_rst_n_sig) ,	// input  I_rst_n_sig
	.I_en(I_en_sig) ,	// input  I_en_sig
	.I_valid_data(I_valid_data_sig) ,	// input  I_valid_data_sig
	.I_data(I_data_sig) ,	// input [7:0] I_data_sig
	.O_dct_0(O_dct_0_sig) ,	// output [15:0] O_dct_0_sig
	.O_dct_1(O_dct_1_sig) ,	// output [15:0] O_dct_1_sig
	.O_dct_2(O_dct_2_sig) ,	// output [15:0] O_dct_2_sig
	.O_dct_3(O_dct_3_sig) ,	// output [15:0] O_dct_3_sig
	.O_dct_4(O_dct_4_sig) ,	// output [15:0] O_dct_4_sig
	.O_dct_5(O_dct_5_sig) ,	// output [15:0] O_dct_5_sig
	.O_dct_6(O_dct_6_sig) ,	// output [15:0] O_dct_6_sig
	.O_dct_7(O_dct_7_sig) ,	// output [15:0] O_dct_7_sig
	.O_data_update(O_data_update_sig) ,	// output  O_data_update_sig
	.O_data_valid(O_data_valid_sig) 	// output  O_data_valid_sig
);

