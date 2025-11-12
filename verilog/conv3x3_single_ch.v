module conv3x3_single_ch #
(
    parameter DATA_W = 8,
    parameter FRAC   = 4,
    parameter W00=0,parameter W01=0,parameter W02=0,
    parameter W10=0,parameter W11=0,parameter W12=0,
    parameter W20=0,parameter W21=0,parameter W22=0,
    parameter BIAS=0
)
(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     in_valid,
    input  wire signed [DATA_W-1:0] p00,p01,p02,p10,p11,p12,p20,p21,p22,
    output reg  signed [DATA_W-1:0] out_data,
    output reg                      out_valid
);
    reg signed [DATA_W+12:0] acc;
    reg signed [DATA_W+7:0]  prod;

    always @(posedge clk) begin
        if (rst) begin
            out_valid<=0; out_data<=0;
        end else if (in_valid) begin
            acc=0;
            prod=p00*W00; acc=acc+prod;
            prod=p01*W01; acc=acc+prod;
            prod=p02*W02; acc=acc+prod;
            prod=p10*W10; acc=acc+prod;
            prod=p11*W11; acc=acc+prod;
            prod=p12*W12; acc=acc+prod;
            prod=p20*W20; acc=acc+prod;
            prod=p21*W21; acc=acc+prod;
            prod=p22*W22; acc=acc+prod;
            acc=acc+(BIAS<<<FRAC);
            out_data<=acc>>>FRAC;
            out_valid<=1;
        end else
            out_valid<=0;
    end
endmodule
