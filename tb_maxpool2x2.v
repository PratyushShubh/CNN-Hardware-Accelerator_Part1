`timescale 1ns/1ps
module tb_maxpool2x2;
    parameter DATA_W = 8;

    reg clk;
    reg rst;
    reg in_valid;
    reg signed [DATA_W-1:0] p00, p01, p10, p11;
    wire signed [DATA_W-1:0] out_data;
    wire out_valid;

    // Instantiate DUT
    maxpool2x2 #(.DATA_W(DATA_W)) dut (
        .clk(clk),
        .rst(rst),
        .in_valid(in_valid),
        .p00(p00), .p01(p01), .p10(p10), .p11(p11),
        .out_data(out_data),
        .out_valid(out_valid)
    );

    initial begin
        $dumpfile("wave_maxpool2x2.vcd");
        $dumpvars(0, tb_maxpool2x2);

        // init
        clk = 0;
        rst = 1;
        in_valid = 0;
        p00 = 0; p01 = 0; p10 = 0; p11 = 0;

        #20 rst = 0;

        // test 1: positives
        p00 = 8'd5;  p01 = 8'd9;  p10 = 8'd2;  p11 = 8'd7;
        in_valid = 1; #10;  // one cycle of valid input
        in_valid = 0; #10;

        // test 2: negatives (signed)
        p00 = -8'd8; p01 = -8'd5; p10 = -8'd10; p11 = -8'd3;
        in_valid = 1; #10;
        in_valid = 0; #10;

        // test 3: equal values
        p00 = 8'd12; p01 = 8'd12; p10 = 8'd11; p11 = 8'd13;
        in_valid = 1; #10;
        in_valid = 0; #20;

        #50 $finish;
    end

    // simple clock
    always #5 clk = ~clk;

endmodule
