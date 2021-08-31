// 由于采用JPEG推荐量化表，因此DC值最长为7位，
// 对应的最大Huffman码长为7。
// 为了与AC系数的最大Huffman码长（16）一致，
// 输出码值为16位。
//
// 此Huffman表包含亮度和色度两张表
// index为0时读取亮度表，为1时读取色度表 
// 注意： 码值以左对齐方式读取.
module HuffmanTableDC(
    input I_clk,
    input I_index,
    input[2:0] I_size,
    output reg[2:0] O_length,
    output[15:0] O_code
);

reg[3:0] address;

always @(posedge I_clk) begin
    address <= {I_index, I_size};
end 

always @(posedge I_clk) begin
    case (address)
        // for luminance
        4'b0000: O_length <= 3'd2;
        4'b0001: O_length <= 3'd3;
        4'b0010: O_length <= 3'd3;
        4'b0011: O_length <= 3'd3;
        4'b0100: O_length <= 3'd3;
        4'b0101: O_length <= 3'd3;
        4'b0110: O_length <= 3'd4;
        4'b0111: O_length <= 3'd5;
        // for chrominance 3'd
        4'b1000: O_length <= 3'd2;
        4'b1001: O_length <= 3'd2;
        4'b1010: O_length <= 3'd2;
        4'b1011: O_length <= 3'd3;
        4'b1100: O_length <= 3'd4;
        4'b1101: O_length <= 3'd5;
        4'b1110: O_length <= 3'd6;
        4'b1111: O_length <= 3'd7;    
        default: O_length <= 3'd0;
    endcase
end

//
reg[6:0] short_code;

assign O_code = {short_code, 9'b0};  // 为与AC系数最长Huffman码值相同，扩展为16位

always @(posedge I_clk) begin
    case (address)
        // for luminance
        4'b0000: short_code <= 7'b00_00000;
        4'b0001: short_code <= 7'b010_0000;
        4'b0010: short_code <= 7'b011_0000;
        4'b0011: short_code <= 7'b100_0000;
        4'b0100: short_code <= 7'b101_0000;
        4'b0101: short_code <= 7'b110_0000;
        4'b0110: short_code <= 7'b1110_000;
        4'b0111: short_code <= 7'b11110_00;
        // for chrominance       
        4'b1000: short_code <= 7'b00_00000;
        4'b1001: short_code <= 7'b01_00000;
        4'b1010: short_code <= 7'b10_00000;
        4'b1011: short_code <= 7'b110_0000;
        4'b1100: short_code <= 7'b1110_000;
        4'b1101: short_code <= 7'b11110_00;
        4'b1110: short_code <= 7'b111110_0;
        4'b1111: short_code <= 7'b1111110;     
        default: short_code <= 7'b0;
    endcase
end

endmodule

