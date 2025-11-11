`timescale 1ns/1ps
module tb_linebuffer;

    reg clk, rst, in_valid;
    reg signed [7:0] pixel_in;
    wire out_valid;
    wire signed [7:0] p00,p01,p02,p10,p11,p12,p20,p21,p22;

    // Instantiate DUT
    linebuffer_3x3 #(.DATA_W(8), .IMG_W(4)) dut (
        .clk(clk), .rst(rst),
        .in_valid(in_valid),
        .pixel_in(pixel_in),
        .out_valid(out_valid),
        .p00(p00),.p01(p01),.p02(p02),
        .p10(p10),.p11(p11),.p12(p12),
        .p20(p20),.p21(p21),.p22(p22)
    );

    initial begin
        $dumpfile("wave_linebuffer.vcd");
        $dumpvars(0, tb_linebuffer);

        clk=0; rst=1; in_valid=0; pixel_in=0;
        #20 rst=0;

        // Feed 8 pixels
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

        #40 $finish;
    end

    always #5 clk=~clk;
endmodule
