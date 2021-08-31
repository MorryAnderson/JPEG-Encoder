module DCT1D #(
    parameter INPUT_WIDTH = 12,
    parameter OUTPUT_WIDTH = INPUT_WIDTH + 3
)(
    input I_clk,
    input I_rst_n,
    input I_en,
    input I_valid_data,
    input signed[INPUT_WIDTH-1:0] I_data,
    output signed[OUTPUT_WIDTH-1:0] O_f0,
    output signed[OUTPUT_WIDTH-1:0] O_f1,
    output signed[OUTPUT_WIDTH-1:0] O_f2,
    output signed[OUTPUT_WIDTH-1:0] O_f3,
    output signed[OUTPUT_WIDTH-1:0] O_f4,
    output signed[OUTPUT_WIDTH-1:0] O_f5,
    output signed[OUTPUT_WIDTH-1:0] O_f6,
    output signed[OUTPUT_WIDTH-1:0] O_f7,
    output O_data_update,
    output O_data_valid
);

wire signed[INPUT_WIDTH-1:0] x[0:7];
wire p_data_update;
wire p_data_valid;
wire p_clk_en;

assign p_clk_en = p_data_update & I_en;

Serial2Parallel #(INPUT_WIDTH) Serial2parallel_inst(
    .I_clk(I_clk) ,
    .I_rst_n(I_rst_n) ,
    .I_en(I_en) ,
    .I_valid_data(I_valid_data),
    .I_data(I_data) ,
    .O_p0(x[0]) ,
    .O_p1(x[1]) ,
    .O_p2(x[2]) ,
    .O_p3(x[3]) ,
    .O_p4(x[4]) ,
    .O_p5(x[5]) ,
    .O_p6(x[6]) ,
    .O_p7(x[7]) ,
    .O_data_update(p_data_update) ,
    .O_data_valid(p_data_valid)
);

// O_data_valid
reg[0:6] flow;  // 7 stages total
assign O_data_valid = flow[6];

//integer i_f;
always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        flow <= 0;
    end else if (p_clk_en) begin
        flow[0] <= p_data_valid;
        flow[1:6] <= flow[0:5];      
    end
end

//
reg p_data_update_delay;

always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        p_data_update_delay <= 0;
    end else if (I_en) begin
        p_data_update_delay <= p_data_update;   
    end
end

assign O_data_update = p_data_update_delay & O_data_valid;

// stage 1
reg signed[INPUT_WIDTH+2:0] s1[0:7];
(* ramstyle = "M9K" *) reg signed[INPUT_WIDTH+2:0] s2_e[0:3], s2_e_a[0:3], s2_e_b[0:3];
reg signed[INPUT_WIDTH+2:0] s3_e[0:3];
reg signed[INPUT_WIDTH+2:0] s4_e[0:3];
reg signed[INPUT_WIDTH+2:0] s5_e[0:3];
(* ramstyle = "M9K" *) reg signed[INPUT_WIDTH+2:0] s2_o[0:3], s2_o_a[0:3], s2_o_b[0:3];
reg signed[INPUT_WIDTH+2:0] s3_o[0:3];
reg signed[INPUT_WIDTH+2:0] s4_o[0:3];
reg signed[INPUT_WIDTH+2:0] s5_o[0:3];

integer i1;
always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        for (i1=0; i1<8; i1=i1+1) begin
            s1[i1] <= 0;
        end
    end else if (p_clk_en) begin
        for (i1=0; i1<4; i1=i1+1) begin
            s1[i1] <= x[i1] + x[7-i1];
        end
        for (i1=4; i1<8; i1=i1+1) begin
            s1[i1] <= x[7-i1] - x[i1];
        end
    end
end

// precise value
//p1(C6/S6);      // 0.4142
//u1(C6*S6);      // 0.3536
//p2(S3/C3);      // 0.6682
//u2(S3*C3);      // 0.4619
//p3(C7/S7);      // 0.1989
//u3(C7*S7);      // 0.1913
//p4((1-S4)/C4);  // 0.4142
//u4(C4);         // 0.7071

// approx value
//p1(7/16);
//u1(3/8);
//p2(5/8);
//u2(7/16);
//p3(3/16);
//u3(3/16);
//p4(7/16);
//u4(3/4);

// stage 2 even
integer i2_e;
always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        for (i2_e=0; i2_e<4; i2_e=i2_e+1) begin
            s2_e[i2_e] <= 0;
            s2_e_a[i2_e] <= 0;
            s2_e_b[i2_e] <= 0;
        end
    end else if (p_clk_en) begin
        // stage 2a
        for (i2_e=0; i2_e<4; i2_e=i2_e+1) begin
            s2_e_a[i2_e] <= s1[i2_e];
        end
        // stage 2b
        for (i2_e=0; i2_e<4; i2_e=i2_e+1) begin
            s2_e_b[i2_e] <= s2_e_a[i2_e];
        end
        // stage 2
        for (i2_e=0; i2_e<4; i2_e=i2_e+1) begin
            s2_e[i2_e] <= s2_e_b[i2_e];
        end
    end
end

// stage 3 even
integer i3_e;
always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        for (i3_e=0; i3_e<4; i3_e=i3_e+1) begin
            s3_e[i3_e] <= 0;
        end
    end else if (p_clk_en) begin
        i3_e <= 0;
        s3_e[0] <= (s2_e[0] + s2_e[3]);
        s3_e[1] <= (s2_e[1] + s2_e[2]);
        s3_e[2] <= (s2_e[1] - s2_e[2]);
        s3_e[3] <= (s2_e[0] - s2_e[3]);    
    end
end

// stage 4 even
integer i4_e;
always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        for (i4_e=0; i4_e<4; i4_e=i4_e+1) begin
            s4_e[i4_e] <= 0;
        end    
    end else if (p_clk_en) begin
        i4_e <= 0;
        s4_e[0] <= s3_e[0] + s3_e[1];
        s4_e[1] <= s3_e[1];
        // s4_e[2] = -s3_e[2] + s3_e[3] * 7/16.
        // p1 = 7/16 = 1/2 - 1/16 = (>>>1) - (>>>4).
        s4_e[2] <= (-s3_e[2]) + ((s3_e[3] >>> 1) - (s3_e[3]>>>4));
        s4_e[3] <= s3_e[3];
    end
end

// stage 5 even
integer i5_e;
always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        for (i5_e=0; i5_e<4; i5_e=i5_e+1) begin
            s5_e[i5_e] <= 0;
        end    
    end else if (p_clk_en) begin
        i5_e <= 0;
        s5_e[0] <= s4_e[0];
        s5_e[1] <= (s4_e[0]>>>1) - s4_e[1];
        s5_e[2] <= s4_e[2];
        // s5_e[3] = s4_e[3] - s4_e[2] * 3/8
        // u1 = 3/8 = 1/2 - 1/8 = (>>>1) - (>>>3)
        s5_e[3] <= s4_e[3] - ((s4_e[2] - (s4_e[2]>>>2)) >>> 1);
    end
end

// stage 2 odd
integer i2_o_a;
always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        for (i2_o_a=0; i2_o_a<4; i2_o_a=i2_o_a+1) begin
            s2_o_a[i2_o_a] <= 0;
        end    
    end else if (p_clk_en) begin
        i2_o_a <= 0;
        s2_o_a[0] <= s1[4];
        s2_o_a[3] <= s1[7];
        // s2_o_a[1] = s1[5] - s1[6] * 7/16.
        // p4 = 7/16 = 1/2 - 1/16 = (>>>1) - (>>>4).
        s2_o_a[1] <= s1[5] - ((s1[6]>>>1) - (s1[6]>>>4));
        s2_o_a[2] <= s1[6];
    end
end

integer i2_o_b;
always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        for (i2_o_b=0; i2_o_b<4; i2_o_b=i2_o_b+1) begin
            s2_o_b[i2_o_b] <= 0;
        end    
    end else if (p_clk_en) begin
        i2_o_b <= 0;
        s2_o_b[0] <= s2_o_a[0];
        s2_o_b[3] <= s2_o_a[3];
        s2_o_b[1] <= s2_o_a[1];
        // u4 = 3/4 = 1 - 1/4 = 1 - (>>>2)
        s2_o_b[2] <= s2_o_a[2] + (s2_o_a[1] - (s2_o_a[1]>>>2));
     end
end

integer i2_o;
always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        for (i2_o=0; i2_o<4; i2_o=i2_o+1) begin
            s2_o[i2_o] <= 0;
        end    
    end else if (p_clk_en) begin
        i2_o <= 0;
        s2_o[0] <= s2_o_b[0];
        s2_o[3] <= s2_o_b[3];
        s2_o[2] <= s2_o_b[2];
        // p4 = 7/16 = 1/2 - 1/16 = (>>>1) - (>>>4).
        s2_o[1] <= (-s2_o_b[1]) + ((s2_o_b[2]>>>1) - (s2_o_b[2]>>>4));
    end
end

// stage 3 odd
integer i3_o;
always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        for (i3_o=0; i3_o<4; i3_o=i3_o+1) begin
            s3_o[i3_o] <= 0;
        end
    end else if (p_clk_en) begin
        i3_o <= 0;
        s3_o[0] <= s2_o[0] + s2_o[1];
        s3_o[1] <= s2_o[0] - s2_o[1];
        s3_o[2] <= s2_o[3] - s2_o[2];
        s3_o[3] <= s2_o[2] + s2_o[3];
    end
end

// stage 4 odd
integer i4_o;
always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        for (i4_o=0; i4_o<4; i4_o=i4_o+1) begin
            s4_o[i4_o] <= 0;
        end
    end else if (p_clk_en) begin
        i4_o <= 0;
        // s3_o[3] * 3/16
        // p3 = 3/16 = 1/4 - 1/16 = (>>>2) - (>>>4).
        s4_o[0] <= (-s3_o[0]) + ((s3_o[3]>>>2) - (s3_o[3]>>>4));
        s4_o[3] <= s3_o[3];
        // s3_o[2] * 5/8
        // p2 = 5/8 = 1/2 + 1/ 8 = (>>>1) + (>>>3).
        s4_o[1] <= s3_o[1] + ((s3_o[2]>>>1) + (s3_o[2]>>>3));
        s4_o[2] <= s3_o[2];
    end
end

// stage 5 odd
integer i5_o;
always @(posedge I_clk, negedge I_rst_n) begin
    if (!I_rst_n) begin
        for (i5_o=0; i5_o<4; i5_o=i5_o+1) begin
            s5_o[i5_o] <= 0;
        end
    end else if (p_clk_en) begin
        i5_o <= 0;
        s5_o[0] <= s4_o[0];
        // s4_o[3] * 3/16
        // u3 = 3/16 = 1/4 - 1/16 = (>>>2) - (>>>4).
        s5_o[3] <= s4_o[3] - ((s4_o[0]>>>2) - (s4_o[0]>>>4));
        s5_o[1] <= s4_o[1];
        // s4_o[1] * 7/16
        // u2 = 7/16 = 1/2 - 1/16 = (>>>1) - (>>>4).
        s5_o[2] <= s4_o[2] - ((s4_o[1]>>>1) - (s4_o[1]>>>4));
    end
end

assign O_f0 = s5_e[0][INPUT_WIDTH+2 -: OUTPUT_WIDTH];
assign O_f4 = s5_e[1][INPUT_WIDTH+2 -: OUTPUT_WIDTH];
assign O_f6 = s5_e[2][INPUT_WIDTH+2 -: OUTPUT_WIDTH];
assign O_f2 = s5_e[3][INPUT_WIDTH+2 -: OUTPUT_WIDTH];

assign O_f7 = s5_o[0][INPUT_WIDTH+2 -: OUTPUT_WIDTH];
assign O_f5 = s5_o[1][INPUT_WIDTH+2 -: OUTPUT_WIDTH];
assign O_f3 = s5_o[2][INPUT_WIDTH+2 -: OUTPUT_WIDTH];
assign O_f1 = s5_o[3][INPUT_WIDTH+2 -: OUTPUT_WIDTH];

endmodule
