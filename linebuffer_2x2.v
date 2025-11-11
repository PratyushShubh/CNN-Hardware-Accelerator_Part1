// linebuffer_2x2.v
// Verilog-2001 : generates 2×2 window from pixel stream (for pooling)
module linebuffer_2x2 #
(
    parameter DATA_W = 8,
    parameter IMG_W  = 8
)
(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     in_valid,
    input  wire signed [DATA_W-1:0] pixel_in,

    output reg                      out_valid,
    output reg signed [DATA_W-1:0]  p00, p01,
    output reg signed [DATA_W-1:0]  p10, p11
);

    // shift register for previous row
    reg signed [DATA_W-1:0] linebuf [0:IMG_W-1];
    integer i;
    reg [15:0] col;
    reg row_valid;

    always @(posedge clk) begin
        if (rst) begin
            col <= 0;
            out_valid <= 0;
            row_valid <= 0;
            for (i=0;i<IMG_W;i=i+1)
                linebuf[i] <= 0;
        end else if (in_valid) begin
            // shift pixels in current row
            if (col < IMG_W)
                col <= col + 1;
            else
                col <= 1;

            // form 2×2 window when at least 2 rows and 2 cols available
            if (row_valid && col >= 2) begin
                p00 <= linebuf[col-2];
                p01 <= linebuf[col-1];
                p10 <= pixel_in;
                p11 <= pixel_in; // placeholder until next pixel arrives
                out_valid <= 1;
            end else begin
                out_valid <= 0;
            end

            // update line buffer with current pixel (stores previous row)
            linebuf[col-1] <= pixel_in;
        end else begin
            out_valid <= 0;
        end
    end

    // mark after first row complete
    always @(posedge clk) begin
        if (rst)
            row_valid <= 0;
        else if (in_valid && col == IMG_W)
            row_valid <= 1;
    end
endmodule
