module Quantifier #(
    parameter OUTPUT_WIDTH = 14
)(
    input I_clk,
    input I_rst_n,
    input I_en,
    input I_data_valid,
    input I_data_update,
    input I_yc,
    input signed[OUTPUT_WIDTH-1:0] I_dct_0,
    input signed[OUTPUT_WIDTH-1:0] I_dct_1,
    input signed[OUTPUT_WIDTH-1:0] I_dct_2,
    input signed[OUTPUT_WIDTH-1:0] I_dct_3,
    input signed[OUTPUT_WIDTH-1:0] I_dct_4,
    input signed[OUTPUT_WIDTH-1:0] I_dct_5,
    input signed[OUTPUT_WIDTH-1:0] I_dct_6,
    input signed[OUTPUT_WIDTH-1:0] I_dct_7,
    output signed[OUTPUT_WIDTH-1+8-12-3 : 0] O_quantified,
    output O_block_update,
    output O_block_valid
);

// TODO：以下代码与DCT2D模块中的部分代码高度重复，考虑将其封装为模块
//
reg[6:0] address_counter;
reg address_counter_en;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        address_counter <= 0;
        address_counter_en <= 0;
    end else if (I_en) begin  
        if (I_data_update) begin
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

/*
wire[6:0] address_counter;
wire address_counter_en;

assign address_counter_en = I_data_valid & I_en;

BinaryCounter #(7) write_address_counter (
	.clk(I_clk) ,
	.enable(address_counter_en) ,
	.reset_n(I_rst_n) ,
	.count(address_counter)
);
*/

//
wire[6:0] write_address;
assign write_address = {address_counter[6], address_counter[2:0], address_counter[5:3]};

//
reg signed[OUTPUT_WIDTH-1:0] dct_value;
always @* begin
    case (address_counter[2:0])
        3'b000: dct_value = I_dct_0;
        3'b001: dct_value = I_dct_1;
        3'b010: dct_value = I_dct_2;
        3'b011: dct_value = I_dct_3;
        3'b100: dct_value = I_dct_4;
        3'b101: dct_value = I_dct_5;
        3'b110: dct_value = I_dct_6;
        3'b111: dct_value = I_dct_7;
        default: dct_value = 0;
    endcase
end

// 
reg ram_1_re, ram_2_re;
wire[5:0] read_address;
reg ram_index;
reg block_update;

wire ram_re;
assign ram_re = ram_1_re | ram_2_re;

ZigAddrGenerator zig_addr_generator_inst(
	.I_clk(I_clk) ,
	.I_rst_n(I_rst_n) ,
	.I_en(ram_re & I_en) ,
	.O_address(read_address)
);

// ping-pong ram
always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        ram_1_re <= 0;
        ram_2_re <= 0;
        block_update <= 0;
        ram_index <= 0;
    end else if (I_en) begin
        if (block_update == 1'b1) block_update <= 1'b0;
        if (address_counter[0 +: 6] == 6'o77) begin
            block_update <= 1'b1;
            if (address_counter[6] == 1'b0) begin
                ram_1_re <= 1'b1;
            end else begin
                ram_2_re <= 1'b1;
            end
            ram_index <= address_counter[6];
        end
        if (ram_re) begin
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


// data_valid
reg[2:0] block_valid_delay;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        block_valid_delay <= 3'b0;
    end else if (I_en) begin  
        block_valid_delay[0] <= ram_re;
        block_valid_delay[1] <= block_valid_delay[0];
        block_valid_delay[2] <= block_valid_delay[1];        
    end
end

// block_update
reg[2:0] block_update_delay;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        block_update_delay <= 3'b0;
    end else if (I_en) begin
        block_update_delay[0] <= block_update;
        block_update_delay[1] <= block_update_delay[0];
        block_update_delay[2] <= block_update_delay[1];
    end
end

//
wire[6:0] ram_read_addr;
assign ram_read_addr = {ram_index, read_address};

wire signed[OUTPUT_WIDTH-1:0] serial_dct_value;

DualPortRAM #(
    .DATA_WIDTH(OUTPUT_WIDTH),
    .ADDR_WIDTH(7)
) zig_zag_ram_inst (
	.data(dct_value) ,
	.read_addr(ram_read_addr) ,
	.write_addr(write_address) ,
	.we(I_data_valid) ,  // TODO: I_en ?
	.clk(I_clk) ,
	.q(serial_dct_value)
);

//
reg signed[OUTPUT_WIDTH-1:0] delayed_serial_dct_value;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        delayed_serial_dct_value <= 0;
    end else if (I_en) begin  
        delayed_serial_dct_value <= serial_dct_value;
    end
end

//
wire signed[7:0] table_value;

rom_quantization_table  quantization_table_inst (
    .aclr ( ~I_rst_n ),
    .address ( {I_yc, read_address} ),
    .clken ( I_en ),
    .clock ( I_clk ),
    .q ( table_value )
);

//
reg signed[OUTPUT_WIDTH-1+8:0] product;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        product <= 0;
    end else if (I_en) begin
        product <= delayed_serial_dct_value * table_value;
    end
end

// TODO:temp_prodcut为何只有7位??? 
wire signed[6:0] temp_prodcut;
wire signed[6:0] quantified;  
assign temp_prodcut = product[OUTPUT_WIDTH+4  : OUTPUT_WIDTH-2];

assign quantified = temp_prodcut[6] ? temp_prodcut+1 : temp_prodcut;
assign O_quantified = quantified;
assign O_block_update = block_update_delay[2];
assign O_block_valid = block_valid_delay[2];

endmodule
