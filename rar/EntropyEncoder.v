module EntropyEncoder(
    input I_clk,
    input I_rst_n,
    input I_en,
    input I_data_valid,
    input I_yc,
    input I_br,
    input I_block_update,
    input signed[7:0] I_data,
    output [4:0] O_huff_len,
    output [15:0] O_huff_code,
    output [2:0] O_amp_size,
    output [7:0] O_amp_code,
    output O_zrl,
    output O_huff_code_valid,
    output O_end_of_block
);

// TODO：考虑删除使能信号中的I_data_valid
//
wire is_dc;
assign is_dc = I_block_update;

//
reg[3:0] is_dc_delay;
reg[3:0] data_valid_delay;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        is_dc_delay <= 0;
        data_valid_delay <= 0;
    end else if (I_en) begin
        is_dc_delay[0] <= is_dc;
        is_dc_delay[3:1] <= is_dc_delay[2:0];
        data_valid_delay[0] <= I_data_valid;
        data_valid_delay[3:1] <= data_valid_delay[2:0];
    end
end

//
reg[1:0] yc_delay;
reg[1:0] br_delay;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        yc_delay <= 0;
        br_delay <= 0;
    end else if (I_en) begin
        yc_delay[0] <= I_yc;
        yc_delay[1] <= yc_delay[0];
        br_delay[0] <= I_br;
        br_delay[1] <= br_delay[0];
    end
end

//
reg signed[7:0] prev_dc_y;
reg signed[7:0] prev_dc_cb;
reg signed[7:0] prev_dc_cr;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        prev_dc_y <= 0;
        prev_dc_cb <= 0;
        prev_dc_cr <= 0;
    end else if (I_en & is_dc & I_data_valid) begin  // 此处的I_data_valid不可删除
        case ({I_yc, I_br})
        2'b00: prev_dc_y <= I_data;
        2'b10: prev_dc_cb <= I_data;
        2'b11: prev_dc_cr <= I_data;
        default: prev_dc_y <= I_data;
        endcase
    end
end

//
reg signed[7:0] prev_dc;
wire signed[7:0] dpcm;

always @* begin
    case ({I_yc, I_br})
    2'b00: prev_dc = prev_dc_y;
    2'b10: prev_dc = prev_dc_cb;
    2'b11: prev_dc = prev_dc_cr;
    default: prev_dc = prev_dc_y;
    endcase
end

assign dpcm = I_data - prev_dc;

//
reg signed[7:0] value;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        value <= 0;
    end else if (I_en & I_data_valid) begin
        value <= is_dc ? dpcm : I_data;
    end
end

//
wire sign_bit;
assign sign_bit = value[7];

//
wire[7:0] amplitude_code;
assign amplitude_code = value + {8{sign_bit}};

//
reg[2:0] data_length;

always @* begin
    casez (value)
        8'b01??_????: data_length = 3'd7;
        8'b001?_????: data_length = 3'd6;
        8'b0001_????: data_length = 3'd5;
        8'b0000_1???: data_length = 3'd4;
        8'b0000_01??: data_length = 3'd3;
        8'b0000_001?: data_length = 3'd2;
        8'b0000_0001: data_length = 3'd1;
        
        8'b0000_0000: data_length = 3'd0;
        
        8'b1100_0000: data_length = 3'd7;
        8'b1110_0000: data_length = 3'd6;
        8'b1111_0000: data_length = 3'd5;
        8'b1111_1000: data_length = 3'd4;
        8'b1111_1100: data_length = 3'd3;
        8'b1111_1110: data_length = 3'd2;
        8'b1111_1111: data_length = 3'd1;
        
        8'b10??_????: data_length = 3'd7;
        8'b110?_????: data_length = 3'd6;
        8'b1110_????: data_length = 3'd5;
        8'b1111_0???: data_length = 3'd4;
        8'b1111_10??: data_length = 3'd3;
        8'b1111_110?: data_length = 3'd2;
        default: data_length = 3'd0;
    endcase
end

//
wire is_zero;
assign is_zero = ~(|value);

//
reg[3:0] zero_count;
reg zero_counter_full;
wire zero_counter_en = data_valid_delay[0] & is_zero & ~is_dc_delay[0];  // & ~is_dc_delay[0]：遇到DC值要将零计数器清零

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        zero_count <= 0;
        zero_counter_full <= 0;
    end else if (I_en & zero_counter_en) begin  
        zero_count <= zero_count + 4'b1;
        if (zero_count == 4'd14) zero_counter_full <= 1'b1;
        else zero_counter_full <= 1'b0;
    end else begin
        zero_count <= 4'b0;
        zero_counter_full <= 1'b0;
    end
end

//
reg[5:0] data_count;  // 块第一个数据进入后，向上计数至0，再停止
wire last_data_of_block;

assign last_data_of_block = &data_count;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        data_count <= 0;
    end else if (I_en & data_valid_delay[0] & ( is_dc_delay[0] | (|data_count) ) ) begin
        data_count <= data_count + 1'b1;
    end
end

//
wire new_code_en;
assign new_code_en = (is_dc_delay[0]) ? 1'b1 : ( (~is_zero) | zero_counter_full | last_data_of_block);

//
reg[3:0] ac_run_length;
reg[2:0] ac_size;
reg[7:0] ac_amp;
reg code_valid;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        ac_run_length <= 0;
        ac_size <= 0;
        ac_amp <= 0;
        code_valid <= 0;
    end else if (I_en & new_code_en) begin
        ac_run_length <= (last_data_of_block && data_length==0) ? 4'b0 : zero_count;  // (last_data_of_block && data_length==0) ?
        ac_size <= data_length;
        ac_amp <= amplitude_code;
        code_valid <= 1'b1;
    end else begin
        code_valid <= 1'b0;
    end
end

wire[2:0] dc_huff_len;
wire[15:0] dc_huff_code;
wire[3:0] ac_huff_len;
wire[15:0] ac_huff_code;

HuffmanTableDC dc_huff_table_inst(
    .I_clk ( I_clk ),
    .I_index ( yc_delay[1] ),
    .I_size ( ac_size ),
    .O_length ( dc_huff_len ),
    .O_code ( dc_huff_code )
);


// 注意：为了减小rom大小，ac_huff_len为真实长度减一
rom_huffman_table ac_huffman_table_inst (
	.clock ( I_clk ),
	.address ( {yc_delay[1] , ac_size, ac_run_length} ),
	.q ( {ac_huff_len, ac_huff_code} )
);

// ac_huff_len最大值为15，对应长度16，需要5位。
reg[4:0] huff_len;
reg[15:0] huff_code;
(* ramstyle = "logic" *) reg[2:0] amp_size_delay[0:1];
(* ramstyle = "logic" *) reg[7:0] amp_code_delay[0:1];
reg[2:0] amp_size;
reg[7:0] amp_code;

reg[7:0] amp_code_mask;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        amp_code_mask <= 0;
    end else if (I_en) begin
        case (amp_size_delay[0])
            3'd0: amp_code_mask <= 8'b0000_0000;
            3'd1: amp_code_mask <= 8'b0000_0001;
            3'd2: amp_code_mask <= 8'b0000_0011;
            3'd3: amp_code_mask <= 8'b0000_0111;
            3'd4: amp_code_mask <= 8'b0000_1111;
            3'd5: amp_code_mask <= 8'b0001_1111;
            3'd6: amp_code_mask <= 8'b0011_1111;
            3'd7: amp_code_mask <= 8'b0111_1111;
            default: amp_code_mask <= 8'b0000_0000;
        endcase
    end
end

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        huff_len <= 0;
        huff_code <= 0;
        
        amp_size_delay[0] <= 0;
        amp_size_delay[1] <= 0;
        
        amp_code_delay[0] <= 0;
        amp_code_delay[1] <= 0;
        
        amp_size <= 0;
        amp_code <= 0;
    end else if (I_en) begin
        huff_len <= is_dc_delay[3] ? dc_huff_len : ac_huff_len + 1;  // 注意：为了减小rom大小，ac_huff_len为真实长度减一
        huff_code <= is_dc_delay[3] ? dc_huff_code : ac_huff_code;
        
        amp_size_delay[0] <= ac_size;
        amp_size_delay[1] <= amp_size_delay[0];
        
        amp_code_delay[0] <= ac_amp;
        amp_code_delay[1] <= amp_code_delay[0];
        
        amp_size <= amp_size_delay[1];
        amp_code <= amp_code_delay[1] & amp_code_mask;
    end
end

//
(* ramstyle = "logic" *) reg[3:0] ac_run_len_delay[0:1];
reg zrl;  // zero run length

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        ac_run_len_delay[0] <= 0;
        ac_run_len_delay[1] <= 0;
        zrl <= 0;
    end else if (I_en) begin
        ac_run_len_delay[0] <= ac_run_length;
        ac_run_len_delay[1] <= ac_run_len_delay[0];
        if ( ~(is_dc_delay[3] | (|amp_size_delay[1])) ) begin
            zrl <= 1'b1;
        end else begin
            zrl <= 1'b0;       
        end
    end
end

//
reg[2:0] code_valid_delay;

assign O_huff_code_valid = code_valid_delay[2];

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        code_valid_delay <= 0;
    end else if (I_en) begin
        code_valid_delay[0] <= code_valid;
        code_valid_delay[2:1] <= code_valid_delay[1:0];
    end
end

//
reg[3:0] last_data_delay;

assign O_end_of_block = last_data_delay[3];

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        last_data_delay <= 0;
    end else if (I_en) begin
        last_data_delay[0] <= last_data_of_block;
        last_data_delay[3:1] <= last_data_delay[2:0];
    end
end

assign O_huff_len = huff_len;
assign O_huff_code = huff_code;
assign O_amp_size = amp_size;
assign O_amp_code = amp_code;
assign O_zrl = zrl;

endmodule
