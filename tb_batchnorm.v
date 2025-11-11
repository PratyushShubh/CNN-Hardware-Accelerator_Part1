`timescale 1ns/1ps
module tb_batchnorm;
    reg clk, rst;
    reg signed [7:0] in_data;
    reg in_valid;
    wire signed [7:0] out_data;
    wire out_valid;

    // gamma=1.5→24, beta=0.25→4
    batchnorm_scale_shift #(.DATA_W(8), .FRAC(4), .GAMMA(24), .BETA(4)) dut (
        .clk(clk), .rst(rst),
        .in_data(in_data), .in_valid(in_valid),
        .out_data(out_data), .out_valid(out_valid)
    );

    initial begin
        $dumpfile("wave_batchnorm.vcd");
        $dumpvars(0, tb_batchnorm);
        clk=0; rst=1; in_valid=0; in_data=0;
        #20 rst=0;

        in_valid=1; in_data=8'd16; #10;
        in_data=-8'd16; #10; in_valid=0;
        #40 $finish;
    end
    always #5 clk=~clk;
endmodule
