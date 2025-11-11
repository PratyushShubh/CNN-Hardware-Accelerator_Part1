`timescale 1ns/1ps
module tb_cnn_top_with_pool;

    parameter DATA_W = 8;
    parameter FRAC   = 4;
    parameter IMG_W  = 4;

    reg clk, rst;
    reg in_valid;
    reg signed [DATA_W-1:0] pixel_in;
    wire out_valid;
    wire signed [DATA_W-1:0] out_data;

    cnn_top_with_pool #(.DATA_W(DATA_W), .FRAC(FRAC), .IMG_W(IMG_W)) dut (
        .clk(clk), .rst(rst),
        .in_valid(in_valid),
        .pixel_in(pixel_in),
        .out_valid(out_valid),
        .out_data(out_data)
    );

    initial begin
        $dumpfile("wave_cnn_with_pool.vcd");
        $dumpvars(0, tb_cnn_top_with_pool);
        clk=0; rst=1; in_valid=0; pixel_in=0;
        #20 rst=0;

        // Feed small 2x4 image (Q4 scaled)
        in_valid=1;
        pixel_in=8'd10; #10;
        pixel_in=8'd20; #10;
        pixel_in=8'd30; #10;
        pixel_in=8'd40; #10;
        pixel_in=8'd50; #10;
        pixel_in=8'd60; #10;
        pixel_in=8'd70; #10;
        pixel_in=8'd80; #10;
        in_valid=0;
        #100 $finish;
    end

    always #5 clk = ~clk;
endmodule
