`timescale 1ns/1ps
module tb_cnn_top;
    parameter DATA_W = 8;
    parameter FRAC = 4;
    parameter IMG_W = 4;

    reg clk, rst;
    reg in_valid;
    reg signed [DATA_W-1:0] pixel_in;
    wire out_valid;
    wire signed [DATA_W-1:0] out_data;

    cnn_top #(.DATA_W(DATA_W), .FRAC(FRAC), .IMG_W(IMG_W)) dut (
        .clk(clk), .rst(rst),
        .in_valid(in_valid), .pixel_in(pixel_in),
        .out_valid(out_valid), .out_data(out_data)
    );

    initial begin
        $dumpfile("wave_cnn_top.vcd");
        $dumpvars(0, tb_cnn_top);
        clk = 0; rst = 1; in_valid = 0; pixel_in = 0;
        #20 rst = 0;

        // Feed pixels (two rows of 4 pixels each). Values in Q4 (scale*16).
        // Row0: 10,20,30,40
        // Row1: 50,60,70,80
        in_valid = 1;
        pixel_in = 8'd10; #10;  // col 0
        pixel_in = 8'd20; #10;  // col 1
        pixel_in = 8'd30; #10;  // col 2 (first valid window appears here)
        pixel_in = 8'd40; #10;  // col 3
        pixel_in = 8'd50; #10;  // next row col 0
        pixel_in = 8'd60; #10;  // row1 col1
        pixel_in = 8'd70; #10;  // row1 col2
        pixel_in = 8'd80; #10;  // row1 col3
        in_valid = 0;

        #100 $finish;
    end

    always #5 clk = ~clk;
endmodule
