`timescale 1ns/1ps
module tb_conv3x3;
    reg clk,rst,in_valid;
    reg signed [7:0] p00,p01,p02,p10,p11,p12,p20,p21,p22;
    wire signed [7:0] out_data; wire out_valid;

    conv3x3_single_ch #(
        .DATA_W(8),.FRAC(4),
        .W00(0),.W01(-16),.W02(0),
        .W10(-16),.W11(64),.W12(-16),
        .W20(0),.W21(-16),.W22(0),
        .BIAS(0)
    ) dut(.clk(clk),.rst(rst),.in_valid(in_valid),
          .p00(p00),.p01(p01),.p02(p02),
          .p10(p10),.p11(p11),.p12(p12),
          .p20(p20),.p21(p21),.p22(p22),
          .out_data(out_data),.out_valid(out_valid));

    initial begin
        $dumpfile("wave_conv.vcd");
        $dumpvars(0,tb_conv3x3);
        clk=0;rst=1;in_valid=0;
        #20 rst=0;
        p00=8'd16;p01=8'd16;p02=8'd16;
        p10=8'd16;p11=8'd16;p12=8'd16;
        p20=8'd16;p21=8'd16;p22=8'd16;
        in_valid=1;#10;
        p11=8'd64;#10;
        in_valid=0;#40;$finish;
    end
    always #5 clk=~clk;
endmodule
