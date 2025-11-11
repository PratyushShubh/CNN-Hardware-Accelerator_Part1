`timescale 1ns/1ps
module tb_leaky_relu;
    reg clk, rst;
    reg signed [7:0] in_data;
    reg in_valid;
    wire signed [7:0] out_data;
    wire out_valid;

    leaky_relu #(.DATA_W(8), .FRAC(4), .A_NUM(1), .A_DEN(4)) dut (
        .clk(clk), .rst(rst),
        .in_data(in_data), .in_valid(in_valid),
        .out_data(out_data), .out_valid(out_valid)
    );

    initial begin
        $dumpfile("wave_leaky_relu.vcd");
        $dumpvars(0, tb_leaky_relu);
        clk = 0; rst = 1; in_valid = 0; in_data = 0;
        #20 rst = 0;

        in_valid = 1;
        in_data = 8'd16; #10;   // +1.0
        in_data = 8'd24; #10;   // +1.5
        in_data = -8'd16; #10;  // -1.0
        in_data = -8'd24; #10;  // -1.5
        in_valid = 0;

        #50 $finish;
    end

    always #5 clk = ~clk;
endmodule
