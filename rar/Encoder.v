module Encoder #(
    parameter OUTPUT_WIDTH = 14
)(
    input I_clk,
    input I_rst_n,
    input I_en,
    input I_valid_data,
    input[1:0] I_ycbcr,
    input[7:0] I_data,
    input I_end_of_img,
    output [31:0] O_stream,
    output O_stream_valid
);

wire signed[OUTPUT_WIDTH-1:0] dct_data[0:7];
wire dct_data_valid;
wire dct_data_update;

reg[247:0] ycbcr_yc_delay;
reg[247:0] ycbcr_br_delay;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        ycbcr_yc_delay <= 0;
        ycbcr_br_delay <= 0;
    end else begin
        ycbcr_yc_delay[0] <= I_ycbcr[1];
        ycbcr_yc_delay[247:1] <= ycbcr_yc_delay[246:0];
        ycbcr_br_delay[0] <= I_ycbcr[0];
        ycbcr_br_delay[247:1] <= ycbcr_br_delay[246:0];
    end
end

DCT2D #(
    .INPUT_WIDTH(10),
    .MID_WIDTH(12),
    .OUTPUT_WIDTH(OUTPUT_WIDTH) 
) DCT2D_inst(
	.I_clk(I_clk) ,
	.I_rst_n(I_rst_n) ,
	.I_en(I_en) ,
	.I_valid_data(I_valid_data) ,
	.I_data(I_data) ,
	.O_dct_0(dct_data[0]) ,
	.O_dct_1(dct_data[1]) ,
	.O_dct_2(dct_data[2]) ,
	.O_dct_3(dct_data[3]) ,
	.O_dct_4(dct_data[4]) ,
	.O_dct_5(dct_data[5]) ,
	.O_dct_6(dct_data[6]) ,
	.O_dct_7(dct_data[7]) ,
	.O_data_update(dct_data_update) ,
	.O_data_valid(dct_data_valid)
);

wire signed[OUTPUT_WIDTH-1+8-12-3 : 0] quantified;
wire block_update;
wire block_valid;

Quantifier #(OUTPUT_WIDTH) quantifier_inst(
	.I_clk(I_clk) ,
	.I_rst_n(I_rst_n) ,
	.I_en(I_en) ,
	.I_data_valid(dct_data_valid) ,
    .I_data_update(dct_data_update) ,
    .I_yc(ycbcr_yc_delay[244]),
	.I_dct_0(dct_data[0]) ,
	.I_dct_1(dct_data[1]) ,
	.I_dct_2(dct_data[2]) ,
	.I_dct_3(dct_data[3]) ,
	.I_dct_4(dct_data[4]) ,
	.I_dct_5(dct_data[5]) ,
	.I_dct_6(dct_data[6]) ,
	.I_dct_7(dct_data[7]) ,
	.O_quantified(quantified) ,
	.O_block_update(block_update) ,
	.O_block_valid(block_valid)
);

wire signed[7:0] quant_value;
wire [4:0] huff_len;
wire [15:0] huff_code;
wire [2:0] amp_size;
wire [7:0] amp_code;
wire zrl;
wire huff_code_valid;
wire end_of_block;

assign quant_value = quantified;

EntropyEncoder EntropyEncoder_inst(
    .I_clk(I_clk) ,
    .I_rst_n(I_rst_n) ,
    .I_en(I_en) ,
    .I_data_valid(block_valid) ,
    .I_yc(ycbcr_yc_delay[247]),
    .I_br(ycbcr_br_delay[247]),
    .I_block_update(block_update) ,
    .I_data(quant_value) ,
	.O_huff_len(huff_len) ,
	.O_huff_code(huff_code) ,
	.O_amp_size(amp_size) ,
	.O_amp_code(amp_code) ,
    .O_zrl(zrl),
	.O_huff_code_valid(huff_code_valid) ,
	.O_end_of_block(end_of_block)
);

wire[31:0] stream;
wire stream_valid;

Streamer streamer_inst(
    .I_clk ( I_clk ),
    .I_rst_n ( I_rst_n ),
    .I_en ( I_en ),
    .I_huff_code_valid ( huff_code_valid ),
    .I_end_of_block ( end_of_block ),
    .I_huff_len ( huff_len ),
    .I_huff_code ( huff_code ),
    .I_amp_size ( amp_size ),
    .I_amp_code ( amp_code ),
    .I_zrl ( zrl ),
    .O_stream ( stream ),
    .O_stream_valid ( stream_valid )
);

assign O_stream = stream;
assign O_stream_valid = stream_valid;

endmodule
