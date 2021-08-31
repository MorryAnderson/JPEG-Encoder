// megafunction wizard: %LPM_CLSHIFT%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: LPM_CLSHIFT 

// ============================================================
// File Name: BarrelShifter.v
// Megafunction Name(s):
// 			LPM_CLSHIFT
//
// Simulation Library Files(s):
// 			
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 17.1.0 Build 590 10/25/2017 SJ Standard Edition
// ************************************************************


//Copyright (C) 2017  Intel Corporation. All rights reserved.
//Your use of Intel Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Intel Program License 
//Subscription Agreement, the Intel Quartus Prime License Agreement,
//the Intel FPGA IP License Agreement, or other applicable license
//agreement, including, without limitation, that your use is for
//the sole purpose of programming logic devices manufactured by
//Intel and sold by Intel or its authorized distributors.  Please
//refer to the applicable agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module BarrelShifter (
	aclr,
	clken,
	clock,
	data,
	distance,
	result);

	input	  aclr;
	input	  clken;
	input	  clock;
	input	[63:0]  data;
	input	[5:0]  distance;
	output	[63:0]  result;

	wire  sub_wire0 = 1'h1;
	wire [63:0] sub_wire1;
	wire [63:0] result = sub_wire1[63:0];

	lpm_clshift	LPM_CLSHIFT_component (
				.aclr (aclr),
				.clken (clken),
				.clock (clock),
				.data (data),
				.direction (sub_wire0),
				.distance (distance),
				.result (sub_wire1)
				// synopsys translate_off
				,
				.overflow (),
				.underflow ()
				// synopsys translate_on
				);
	defparam
		LPM_CLSHIFT_component.lpm_pipeline = 1,
		LPM_CLSHIFT_component.lpm_shifttype = "ROTATE",
		LPM_CLSHIFT_component.lpm_type = "LPM_CLSHIFT",
		LPM_CLSHIFT_component.lpm_width = 64,
		LPM_CLSHIFT_component.lpm_widthdist = 6;


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
// Retrieval info: PRIVATE: LPM_SHIFTTYPE NUMERIC "2"
// Retrieval info: PRIVATE: LPM_WIDTH NUMERIC "64"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: PRIVATE: lpm_widthdist NUMERIC "6"
// Retrieval info: PRIVATE: lpm_widthdist_style NUMERIC "0"
// Retrieval info: PRIVATE: new_diagram STRING "1"
// Retrieval info: PRIVATE: port_direction NUMERIC "1"
// Retrieval info: LIBRARY: lpm lpm.lpm_components.all
// Retrieval info: CONSTANT: LPM_PIPELINE NUMERIC "1"
// Retrieval info: CONSTANT: LPM_SHIFTTYPE STRING "ROTATE"
// Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_CLSHIFT"
// Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "64"
// Retrieval info: CONSTANT: LPM_WIDTHDIST NUMERIC "6"
// Retrieval info: USED_PORT: aclr 0 0 0 0 INPUT NODEFVAL "aclr"
// Retrieval info: USED_PORT: clken 0 0 0 0 INPUT NODEFVAL "clken"
// Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL "clock"
// Retrieval info: USED_PORT: data 0 0 64 0 INPUT NODEFVAL "data[63..0]"
// Retrieval info: USED_PORT: distance 0 0 6 0 INPUT NODEFVAL "distance[5..0]"
// Retrieval info: USED_PORT: result 0 0 64 0 OUTPUT NODEFVAL "result[63..0]"
// Retrieval info: CONNECT: @aclr 0 0 0 0 aclr 0 0 0 0
// Retrieval info: CONNECT: @clken 0 0 0 0 clken 0 0 0 0
// Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
// Retrieval info: CONNECT: @data 0 0 64 0 data 0 0 64 0
// Retrieval info: CONNECT: @direction 0 0 0 0 VCC 0 0 0 0
// Retrieval info: CONNECT: @distance 0 0 6 0 distance 0 0 6 0
// Retrieval info: CONNECT: result 0 0 64 0 @result 0 0 64 0
// Retrieval info: GEN_FILE: TYPE_NORMAL BarrelShifter.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL BarrelShifter.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL BarrelShifter.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL BarrelShifter.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL BarrelShifter_inst.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL BarrelShifter_bb.v TRUE
