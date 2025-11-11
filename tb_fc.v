`timescale 1ns/1ps
module tb_fc;
    reg clk,rst,in_valid;
    reg signed [7:0] in_data;
    wire signed [7:0] out_data;
    wire out_valid;

    fc_dotprod dut(.clk(clk),.rst(rst),.in_valid(in_valid),
                   .in_data(in_data),.out_data(out_data),.out_valid(out_valid));

    integer i;
    initial begin
        $dumpfile("wave_fc.vcd");
        $dumpvars(0,tb_fc);
        clk=0;rst=1;in_valid=0;in_data=0;
        #20 rst=0;
        for(i=0;i<8;i=i+1) begin
            in_data=8'd16;in_valid=1;#10;
        end
        in_valid=0;#40;$finish;
    end
    always #5 clk=~clk;
endmodule
