// Quartus Prime Verilog Template
// Binary counter

module BinaryCounter
#(parameter WIDTH=64)
(
    input clk, enable, reset_n,
    output reg [WIDTH-1:0] count
);

    // Reset if needed, or increment if counting is enabled
    always @ (posedge clk or negedge reset_n)
    begin
        if (!reset_n)
            count <= 0;
        else if (enable == 1'b1)
            count <= count + 1;
    end

endmodule
