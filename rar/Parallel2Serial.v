module Parallel2Series #(
    parameter DATA_WIDTH = 16
)(
    input I_clk,
    input I_rst_n,
    input I_en,
    input I_push,
    input [DATA_WIDTH-1:0] I_d0,
    input [DATA_WIDTH-1:0] I_d1,
    input [DATA_WIDTH-1:0] I_d2,
    input [DATA_WIDTH-1:0] I_d3,
    input [DATA_WIDTH-1:0] I_d4,
    input [DATA_WIDTH-1:0] I_d5,
    input [DATA_WIDTH-1:0] I_d6,
    input [DATA_WIDTH-1:0] I_d7,
    output [DATA_WIDTH-1:0] O_q,
    output reg O_data_valid
);

reg[DATA_WIDTH-1:0] d[0:7];
integer i;
always @(posedge I_clk or negedge I_rst_n) begin
    if (!I_rst_n) begin
        for (i=0; i<8; i=i+1) begin
            d[i] <= 0;
        end   
    end else if (I_en) begin
        if (I_push) begin
            d[0] <= I_d0;
            d[1] <= I_d1;
            d[2] <= I_d2;
            d[3] <= I_d3;
            d[4] <= I_d4;
            d[5] <= I_d5;
            d[6] <= I_d6;
            d[7] <= I_d7;
        end else begin
            for (i=0; i<7; i=i+1) begin
                d[i] <= d[i+1];
            end
            d[7] <= 0;
        end
    end
end

reg[2:0] data_left;
always @(posedge I_clk or negedge I_rst_n) begin
    if (!I_rst_n) begin
        data_left <= 0;
        O_data_valid <= 0;
    end else if (I_en) begin
        if (I_push) begin
            O_data_valid <= 1'd1;
            data_left <= 3'd0;
        end else begin
            if (O_data_valid) begin
                data_left <= data_left - 3'd1;
                if (data_left == 3'd1) O_data_valid <= 1'd0;
            end
        end
    end
end

assign O_q = d[0];

endmodule
