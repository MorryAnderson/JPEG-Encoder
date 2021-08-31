module DCT2D #(
    parameter INPUT_WIDTH = 10,
    parameter MID_WIDTH = 12,
    parameter OUTPUT_WIDTH = 14  
)(
    input I_clk,
    input I_rst_n,
    input I_en,
    input I_valid_data,
    input[7:0] I_data,
    output signed[OUTPUT_WIDTH-1:0] O_dct_0,
    output signed[OUTPUT_WIDTH-1:0] O_dct_1,
    output signed[OUTPUT_WIDTH-1:0] O_dct_2,
    output signed[OUTPUT_WIDTH-1:0] O_dct_3,
    output signed[OUTPUT_WIDTH-1:0] O_dct_4,
    output signed[OUTPUT_WIDTH-1:0] O_dct_5,
    output signed[OUTPUT_WIDTH-1:0] O_dct_6,
    output signed[OUTPUT_WIDTH-1:0] O_dct_7,
    output O_data_update,
    output O_data_valid
);

// convert unsigned 8bit data to signed 10bit Q2 data.
wire signed[INPUT_WIDTH-1:0] data;
assign data = {{~I_data[7]}, I_data[6:0], {(INPUT_WIDTH-8){1'b0}}};

wire signed[MID_WIDTH-1:0] f[0:7];
wire dct_update, dct_valid;

DCT1D  #(
    .INPUT_WIDTH(INPUT_WIDTH),
    .OUTPUT_WIDTH(MID_WIDTH)
) DCT1D_inst_1 (
    .I_clk(I_clk) ,
    .I_rst_n(I_rst_n) ,
    .I_en(I_en) ,
    .I_valid_data(I_valid_data) ,
    .I_data(data) ,
    .O_f0(f[0]) ,
    .O_f1(f[1]) ,
    .O_f2(f[2]) ,
    .O_f3(f[3]) ,
    .O_f4(f[4]) ,
    .O_f5(f[5]) ,
    .O_f6(f[6]) ,
    .O_f7(f[7]) ,
    .O_data_update(dct_update) ,
    .O_data_valid(dct_valid)
);

//
reg[6:0] address_counter;
reg address_counter_en;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        address_counter <= 0;
        address_counter_en <= 0;
    end else if (I_en) begin  
        if (dct_update) begin
            address_counter_en <= 1'b1;
            address_counter[2:0] <= 3'b001;
        end
        if (address_counter_en) begin
            address_counter <= address_counter + 7'b1;
            if (address_counter[2:0] == 3'b111) begin
                address_counter_en <= 1'b0;
            end
        end
    end
end


//assign address_counter_en = dct_valid & I_en;

//BinaryCounter #(7) write_address_counter (
//	.clk(I_clk) ,
//	.enable(address_counter_en) ,
//	.reset_n(I_rst_n) ,
//	.count(address_counter)
//);

//
wire[6:0] write_address;
assign write_address = address_counter;

//
wire signed[MID_WIDTH-1:0] dct_value;
assign dct_value = f[address_counter[2:0]];

// 
reg ram_1_re, ram_2_re;
wire ram_re;
reg[5:0] read_address;
reg ram_index;

assign ram_re = ram_1_re | ram_2_re;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        ram_1_re <= 0;
        ram_2_re <= 0;
        read_address <= 0;
        ram_index <= 0;
    end else if (I_en) begin
        if (address_counter[0 +: 6] == 6'o77) begin
            if (address_counter[6] == 1'b0) ram_1_re <= 1'b1;
            else ram_2_re <= 1'b1;
            ram_index <= address_counter[6];
            read_address <= 6'b0;
        end
        if (ram_re) begin
            read_address <= read_address + 6'd1;
            if (read_address == 6'o77) begin
                if (ram_index == 1'b0) begin
                    ram_1_re <= 1'b0;
                end else begin
                    ram_2_re <= 1'b0;
                end
            end
        end
    end
end

//
wire signed[MID_WIDTH-1:0] ram_data;
reg ram_data_valid;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        ram_data_valid <= 0;
    end else if (I_en) begin  
        ram_data_valid <= ram_re;
    end
end

wire[6:0] ram_read_addr;
assign ram_read_addr = {ram_index, read_address[2:0], read_address[5:3]};

DualPortRAM #(
    .DATA_WIDTH(MID_WIDTH),
    .ADDR_WIDTH(7)
) transpos_ram_inst(
	.data(dct_value) ,
	.read_addr(ram_read_addr) ,
	.write_addr(write_address) ,
	.we(dct_valid) ,  // TODO: I_en ?
	.clk(I_clk) ,
	.q(ram_data)
);

wire signed[OUTPUT_WIDTH-1:0] g[0:7];
wire dct2_update, dct2_valid;

DCT1D #(
    .INPUT_WIDTH(MID_WIDTH),
    .OUTPUT_WIDTH(OUTPUT_WIDTH)
) DCT1D_inst_2 (
    .I_clk(I_clk) ,
    .I_rst_n(I_rst_n) ,
    .I_en(I_en) ,
    .I_valid_data(ram_data_valid) ,
    .I_data(ram_data[MID_WIDTH-1:0]) ,
    .O_f0(g[0]) ,
    .O_f1(g[1]) ,
    .O_f2(g[2]) ,
    .O_f3(g[3]) ,
    .O_f4(g[4]) ,
    .O_f5(g[5]) ,
    .O_f6(g[6]) ,
    .O_f7(g[7]) ,
    .O_data_update(O_data_update) ,
    .O_data_valid(O_data_valid)
);

assign O_dct_0 = g[0];
assign O_dct_1 = g[1];
assign O_dct_2 = g[2];
assign O_dct_3 = g[3];
assign O_dct_4 = g[4];
assign O_dct_5 = g[5];
assign O_dct_6 = g[6];
assign O_dct_7 = g[7];

endmodule
