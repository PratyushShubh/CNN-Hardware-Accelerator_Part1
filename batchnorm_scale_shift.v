module batchnorm_scale_shift #
(
    parameter DATA_W = 8,
    parameter FRAC   = 4,
    parameter GAMMA  = (1<<FRAC), // scale (1.0)
    parameter BETA   = 0          // offset
)
(
    input  wire                     clk,
    input  wire                     rst,
    input  wire signed [DATA_W-1:0] in_data,
    input  wire                     in_valid,
    output reg  signed [DATA_W-1:0] out_data,
    output reg                      out_valid
);
    reg signed [DATA_W+7:0] mult, res;

    always @(posedge clk) begin
        if (rst) begin
            out_data  <= 0;
            out_valid <= 0;
        end else begin
            if (in_valid) begin
                mult = in_data * GAMMA;
                res  = (mult >>> FRAC) + BETA;
                out_data <= res[DATA_W-1:0];
                out_valid <= 1'b1;
            end else
                out_valid <= 1'b0;
        end
    end
endmodule
