`timescale 1ns/1ps

module tb_cnn;
    parameter DATA_W = 8;
    parameter FRAC   = 4;

    reg clk, rst;
    reg in_valid;
    reg signed [DATA_W-1:0] pixel_in;

    wire out_valid;
    wire signed [DATA_W-1:0] out_data;

    // instantiate top module
    cnn_top_with_pool #(
        .DATA_W(DATA_W),
        .FRAC(FRAC),
        .IMG_W(8)
    ) uut (
        .clk(clk),
        .rst(rst),
        .in_valid(in_valid),
        .pixel_in(pixel_in),
        .out_valid(out_valid),
        .out_data(out_data)
    );

    // clock generation
    always #5 clk = ~clk;  // 100 MHz clock

    // test sequence
    integer i, j;
    reg signed [DATA_W-1:0] image [0:7][0:7];
    initial begin
        // initialize image with pattern
        for (i = 0; i < 8; i = i + 1)
            for (j = 0; j < 8; j = j + 1)
                image[i][j] = i * 8 + j;

        // initial values
        clk = 0;
        rst = 1;
        in_valid = 0;
        pixel_in = 0;

        // apply reset
        #20;
        rst = 0;

        // feed image pixels
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin
                @(posedge clk);
                in_valid = 1;
                pixel_in = image[i][j];
            end
        end

        // stop sending
        @(posedge clk);
        in_valid = 0;
        pixel_in = 0;

        // wait for pipeline flush
        repeat (200) @(posedge clk);

        $display("Simulation finished");
        $finish;
    end

    // monitor output
    always @(posedge clk)
        if (out_valid)
            $display("[%0t ns] out_data = %0d", $time, out_data);

    // generate VCD for GTKWave
    initial begin
        $dumpfile("cnn_wave.vcd");
        $dumpvars(0, tb_cnn);
    end
endmodule
