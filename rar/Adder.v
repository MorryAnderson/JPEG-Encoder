module Adder(
    input signed [7:0] a, b,
    output signed [7:0] s
);

assign s = a + (b>>2);

endmodule
  