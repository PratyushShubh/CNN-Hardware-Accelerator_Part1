// cnn_top_with_pool.v
// Verilog-2001 top-level CNN pipeline with true 2x2 maxpooling
// pipeline: pixel_stream -> linebuffer_3x3 -> conv3x3 -> batchnorm -> leaky_relu -> linebuffer_2x2 -> maxpool2x2

module cnn_top_with_pool #
(
    parameter DATA_W = 8,
    parameter FRAC   = 4,
    parameter IMG_W  = 8
)
(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     in_valid,
    input  wire signed [DATA_W-1:0] pixel_in,

    output reg                      out_valid,
    output reg signed [DATA_W-1:0]  out_data
);

    // ---------------- Line Buffer (3x3 for Conv) ----------------
    wire lb_valid;
    wire signed [DATA_W-1:0] p00,p01,p02,p10,p11,p12,p20,p21,p22;

    linebuffer_3x3 #(.DATA_W(DATA_W), .IMG_W(IMG_W)) lb (
        .clk(clk), .rst(rst),
        .in_valid(in_valid), .pixel_in(pixel_in),
        .out_valid(lb_valid),
        .p00(p00),.p01(p01),.p02(p02),
        .p10(p10),.p11(p11),.p12(p12),
        .p20(p20),.p21(p21),.p22(p22)
    );

    // ---------------- Convolution ----------------
    reg conv_in_valid;
    wire conv_out_valid;
    wire signed [DATA_W-1:0] conv_out_data;

    conv3x3_single_ch #(
        .DATA_W(DATA_W), .FRAC(FRAC),
        .W00(0),  .W01(-16), .W02(0),
        .W10(-16),.W11(64),  .W12(-16),
        .W20(0),  .W21(-16), .W22(0),
        .BIAS(0)
    ) conv (
        .clk(clk), .rst(rst), .in_valid(conv_in_valid),
        .p00(p00),.p01(p01),.p02(p02),
        .p10(p10),.p11(p11),.p12(p12),
        .p20(p20),.p21(p21),.p22(p22),
        .out_data(conv_out_data), .out_valid(conv_out_valid)
    );

    // ---------------- BatchNorm ----------------
    reg bn_in_valid;
    wire bn_out_valid;
    wire signed [DATA_W-1:0] bn_out_data;

    batchnorm_scale_shift #(
        .DATA_W(DATA_W), .FRAC(FRAC),
        .GAMMA(24), .BETA(4)
    ) bn (
        .clk(clk), .rst(rst),
        .in_data(conv_out_data), .in_valid(bn_in_valid),
        .out_data(bn_out_data), .out_valid(bn_out_valid)
    );

    // ---------------- Leaky ReLU ----------------
    reg relu_in_valid;
    wire relu_out_valid;
    wire signed [DATA_W-1:0] relu_out_data;

    leaky_relu #(
        .DATA_W(DATA_W), .FRAC(FRAC),
        .A_NUM(1), .A_DEN(4)
    ) lrelu (
        .clk(clk), .rst(rst),
        .in_data(bn_out_data), .in_valid(relu_in_valid),
        .out_data(relu_out_data), .out_valid(relu_out_valid)
    );

    // ---------------- LineBuffer (2x2 for Pooling) ----------------
    wire lb2_valid;
    wire signed [DATA_W-1:0] pb00,pb01,pb10,pb11;

    linebuffer_2x2 #(.DATA_W(DATA_W), .IMG_W(IMG_W)) pool_lb (
        .clk(clk), .rst(rst),
        .in_valid(relu_out_valid),
        .pixel_in(relu_out_data),
        .out_valid(lb2_valid),
        .p00(pb00), .p01(pb01),
        .p10(pb10), .p11(pb11)
    );

    // ---------------- MaxPool 2x2 (real spatial pooling) ----------------
    reg pool_in_valid;
    wire pool_out_valid;
    wire signed [DATA_W-1:0] pool_out_data;

    maxpool2x2 #(.DATA_W(DATA_W)) pool (
        .clk(clk), .rst(rst),
        .in_valid(pool_in_valid),
        .p00(pb00), .p01(pb01),
        .p10(pb10), .p11(pb11),
        .out_data(pool_out_data), .out_valid(pool_out_valid)
    );

    // ---------------- Handshake / control pipeline ----------------
    always @(posedge clk) begin
        if (rst) begin
            conv_in_valid <= 0;
            bn_in_valid   <= 0;
            relu_in_valid <= 0;
            pool_in_valid <= 0;
            out_valid     <= 0;
            out_data      <= 0;
        end else begin
            conv_in_valid <= lb_valid;
            bn_in_valid   <= conv_out_valid;
            relu_in_valid <= bn_out_valid;
            pool_in_valid <= lb2_valid;

            if (pool_out_valid) begin
                out_valid <= 1'b1;
                out_data  <= pool_out_data;
            end else begin
                out_valid <= 1'b0;
            end
        end
    end
endmodule
