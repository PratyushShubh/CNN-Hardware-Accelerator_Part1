// linebuffer_3x3.v -- Verilog-2001 compatible
// Sliding 3x3 window generator for convolution
// Works for streaming single-channel image input

module linebuffer_3x3 #
(
    parameter DATA_W = 8,
    parameter IMG_W  = 8     // width of image row (number of pixels per line)
)
(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     in_valid,
    input  wire signed [DATA_W-1:0] pixel_in,

    output reg                      out_valid,
    output reg signed [DATA_W-1:0]  p00, p01, p02,
    output reg signed [DATA_W-1:0]  p10, p11, p12,
    output reg signed [DATA_W-1:0]  p20, p21, p22
);

    // Two line buffers to store the last two rows
    reg signed [DATA_W-1:0] line1 [0:IMG_W-1];
    reg signed [DATA_W-1:0] line2 [0:IMG_W-1];
    integer i;

    reg [15:0] col; // column counter

    always @(posedge clk) begin
        if (rst) begin
            for (i=0; i<IMG_W; i=i+1) begin
                line1[i] <= 0;
                line2[i] <= 0;
            end
            col <= 0;
            out_valid <= 0;

            p00 <= 0; p01 <= 0; p02 <= 0;
            p10 <= 0; p11 <= 0; p12 <= 0;
            p20 <= 0; p21 <= 0; p22 <= 0;
        end
        else if (in_valid) begin
            // Shift pixel rows
            line2[col] <= line1[col];
            line1[col] <= pixel_in;

            // After we have at least 2 previous columns
            if (col >= 2) begin
                p00 <= line2[col-2];
                p01 <= line2[col-1];
                p02 <= line2[col];
                p10 <= line1[col-2];
                p11 <= line1[col-1];
                p12 <= line1[col];
                p20 <= 0; // bottom row placeholder until next row arrives
                p21 <= 0;
                p22 <= 0;
                out_valid <= 1'b1;
            end else begin
                out_valid <= 1'b0;
            end

            // Increment column index
            if (col == IMG_W-1)
                col <= 0;
            else
                col <= col + 1;
        end else begin
            out_valid <= 0;
        end
    end
endmodule
