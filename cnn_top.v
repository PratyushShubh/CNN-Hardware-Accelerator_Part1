// cnn_top.v
// Top-level pipeline: pixel stream -> linebuffer -> conv -> batchnorm -> leaky_relu -> output
// Verilog-2001, parameterizable image width.

module cnn_top #
(
    parameter DATA_W = 8,
    parameter FRAC   = 4,
    parameter IMG_W  = 8
)
(
    input  wire                     clk,
    input  wire                     rst,
    // pixel stream input
    input  wire                     in_valid,
    input  wire signed [DATA_W-1:0] pixel_in,
    // top-level output (activation after relu)
    output reg                      out_valid,
    output reg signed [DATA_W-1:0]  out_data
);

    // INTERMEDIATE SIGNALS
    wire lb_valid;
    wire signed [DATA_W-1:0] p00,p01,p02,p10,p11,p12,p20,p21,p22;

    // conv interface
    reg  conv_in_valid;
    wire conv_out_valid;
    wire signed [DATA_W-1:0] conv_out_data;

    // batchnorm interface
    reg  bn_in_valid;
    wire bn_out_valid;
    wire signed [DATA_W-1:0] bn_out_data;

    // relu interface
    reg  relu_in_valid;
    wire relu_out_valid;
    wire signed [DATA_W-1:0] relu_out_data;

    // Instantiate linebuffer
    linebuffer_3x3 #(.DATA_W(DATA_W), .IMG_W(IMG_W)) lb (
        .clk(clk), .rst(rst),
        .in_valid(in_valid), .pixel_in(pixel_in),
        .out_valid(lb_valid),
        .p00(p00),.p01(p01),.p02(p02),
        .p10(p10),.p11(p11),.p12(p12),
        .p20(p20),.p21(p21),.p22(p22)
    );

    // Instantiate conv3x3_single_ch (example weights: edge detector)
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

    // Instantiate batchnorm (example gamma=1.5, beta=0.25)
    batchnorm_scale_shift #(.DATA_W(DATA_W), .FRAC(FRAC), .GAMMA(24), .BETA(4)) bn (
        .clk(clk), .rst(rst),
        .in_data(conv_out_data), .in_valid(bn_in_valid),
        .out_data(bn_out_data), .out_valid(bn_out_valid)
    );

    // Instantiate leaky relu (alpha = 1/4)
    leaky_relu #(.DATA_W(DATA_W), .FRAC(FRAC), .A_NUM(1), .A_DEN(4)) lrelu (
        .clk(clk), .rst(rst),
        .in_data(bn_out_data), .in_valid(relu_in_valid),
        .out_data(relu_out_data), .out_valid(relu_out_valid)
    );

    // Simple control FSM (stateless pipeline handshake)
    // When linebuffer produces a valid 3x3 window, assert conv_in_valid.
    // Propagate valid signals from stage to stage on next cycles.
    always @(posedge clk) begin
        if (rst) begin
            conv_in_valid <= 0;
            bn_in_valid   <= 0;
            relu_in_valid <= 0;
            out_valid     <= 0;
            out_data      <= 0;
        end else begin
            // feed conv when window ready
            conv_in_valid <= lb_valid;

            // conv -> bn handshake (assumes 1-cycle latency)
            bn_in_valid <= conv_out_valid;

            // bn -> relu handshake
            relu_in_valid <= bn_out_valid;

            // relu -> output
            if (relu_out_valid) begin
                out_valid <= 1'b1;
                out_data  <= relu_out_data;
            end else begin
                out_valid <= 1'b0;
            end
        end
    end

endmodule
