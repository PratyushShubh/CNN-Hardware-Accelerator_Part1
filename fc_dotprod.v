module fc_dotprod #
(
    parameter DATA_W=8,
    parameter FRAC=4,
    parameter N=8,
    parameter W0=16,W1=32,W2=48,W3=64,W4=80,W5=96,W6=112,W7=128,
    parameter BIAS=0
)
(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     in_valid,
    input  wire signed [DATA_W-1:0] in_data,
    output reg  signed [DATA_W-1:0] out_data,
    output reg                      out_valid
);
    integer i;
    reg signed [DATA_W+16:0] acc;
    reg signed [DATA_W+7:0]  prod;
    reg [3:0] count;

    function integer get_weight;
        input integer idx;
        begin
            case(idx)
                0:get_weight=W0;1:get_weight=W1;2:get_weight=W2;3:get_weight=W3;
                4:get_weight=W4;5:get_weight=W5;6:get_weight=W6;7:get_weight=W7;
                default:get_weight=0;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if(rst) begin
            acc<=0;count<=0;out_valid<=0;
        end else begin
            if(in_valid) begin
                prod=in_data*get_weight(count);
                acc=acc+prod;
                count<=count+1;
                out_valid<=0;
            end else if(count!=0) begin
                acc=acc+(BIAS<<<FRAC);
                out_data<=acc>>>FRAC;
                out_valid<=1;
                acc<=0;count<=0;
            end else
                out_valid<=0;
        end
    end
endmodule
