// maxpool2x2.v - Verilog-2001
// Non-overlapping 2x2 maxpool.
// All ports plain Verilog-2001, inputs/outputs declared signed so comparisons are signed.

module maxpool2x2 #
(
    parameter DATA_W = 8
)
(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     in_valid,
    input  wire signed [DATA_W-1:0] p00,
    input  wire signed [DATA_W-1:0] p01,
    input  wire signed [DATA_W-1:0] p10,
    input  wire signed [DATA_W-1:0] p11,
    output reg  signed [DATA_W-1:0] out_data,
    output reg                      out_valid
);

    reg signed [DATA_W-1:0] max1;
    reg signed [DATA_W-1:0] max2;

    always @(posedge clk) begin
        if (rst) begin
            out_valid <= 1'b0;
            out_data  <= {DATA_W{1'b0}};
            max1 <= {DATA_W{1'b0}};
            max2 <= {DATA_W{1'b0}};
        end else begin
            if (in_valid) begin
                // compute pairwise maxima (signed comparison)
                if (p00 > p01) max1 <= p00;
                else           max1 <= p01;

                if (p10 > p11) max2 <= p10;
                else           max2 <= p11;

                // choose final max
                if ( (p00 > p01 ? p00 : p01) > (p10 > p11 ? p10 : p11) )
                    out_data <= (p00 > p01 ? p00 : p01);
                else
                    out_data <= (p10 > p11 ? p10 : p11);

                out_valid <= 1'b1;
            end else begin
                out_valid <= 1'b0;
            end
        end
    end

endmodule
