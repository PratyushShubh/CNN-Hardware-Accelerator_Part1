// leaky_relu.v  --  plain Verilog-2001
module leaky_relu #
(
    parameter DATA_W = 8,
    parameter FRAC   = 4,
    parameter A_NUM  = 1,
    parameter A_DEN  = 4
)
(
    input  wire                     clk,
    input  wire                     rst,
    input  wire signed [DATA_W-1:0] in_data,
    input  wire                     in_valid,
    output reg  signed [DATA_W-1:0] out_data,
    output reg                      out_valid
);

    // wider product to hold multiply result
    reg signed [DATA_W+7:0] prod;
    reg signed [DATA_W+7:0] scaled;   // holds shifted / divided value

    always @(posedge clk) begin
        if (rst) begin
            out_data  <= 0;
            out_valid <= 0;
        end
        else begin
            if (in_valid) begin
                if (in_data[DATA_W-1] == 1'b0) begin
                    // positive input → passthrough
                    out_data <= in_data;
                end
                else begin
                    // negative input → scale by alpha = A_NUM / A_DEN
                    prod = in_data * A_NUM;

                    // choose divide amount
                    if (A_DEN == 1)
                        scaled = prod;
                    else if (A_DEN == 2)
                        scaled = prod >>> 1;
                    else if (A_DEN == 4)
                        scaled = prod >>> 2;
                    else
                        scaled = prod / A_DEN;

                    // take lower DATA_W bits for output
                    out_data <= scaled[DATA_W-1:0];
                end
                out_valid <= 1'b1;
            end
            else begin
                out_valid <= 1'b0;
            end
        end
    end
endmodule
