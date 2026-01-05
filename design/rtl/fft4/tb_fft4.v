`timescale 1ns/1ps

module tb_fft4;

    parameter NB_INPUT = 8;
    parameter NBF_INPUT = 7;
    parameter NB_OUTPUT = 10;
    parameter NBF_OUTPUT = 7;
    parameter N_POINTS = 4;
    parameter LATENCY = 4;

    reg clk;
    reg rst;
    reg i_valid;
    reg i_enable;
    reg [2*NB_INPUT-1:0] i_x0, i_x1, i_x2, i_x3;

    wire o_valid;
    wire [2*NB_OUTPUT-1:0] o_x0, o_x1, o_x2, o_x3;

    reg [2*NB_INPUT-1:0] input_vectors [0:N_POINTS-1];
    reg [2*NB_OUTPUT-1:0] output_vectors [0:N_POINTS-1];

    fft4 #(
        .NB_INPUT(NB_INPUT), .NBF_INPUT(NBF_INPUT),
        .NB_OUTPUT(NB_OUTPUT), .NBF_OUTPUT(NBF_OUTPUT)
    ) dut (
        .o_x0(o_x0), .o_x1(o_x1), .o_x2(o_x2), .o_x3(o_x3),
        .o_valid(o_valid),
        .i_x0(i_x0), .i_x1(i_x1), .i_x2(i_x2), .i_x3(i_x3),
        .i_enable(i_enable), .i_valid(i_valid),
        .i_rst(rst), .i_clk(clk)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("tb_fft4.vcd");
        $dumpvars(0, tb_fft4);
    end

    initial begin
        $readmemb("input_vectors.txt", input_vectors);
        $readmemb("output_vectors.txt", output_vectors);

        rst = 1;
        i_valid = 0;
        i_enable = 0;
        i_x0 = 0; i_x1 = 0; i_x2 = 0; i_x3 = 0;
        #20;
        rst = 0;

        @(posedge clk);
        i_x0 <= input_vectors[0];
        i_x1 <= input_vectors[1];
        i_x2 <= input_vectors[2];
        i_x3 <= input_vectors[3];
        i_valid <= 1;

        @(posedge clk);
        i_valid <= 0;

        repeat(LATENCY) @(posedge clk);

        if (o_valid) begin
            if (o_x0 == output_vectors[0] &&
                o_x1 == output_vectors[1] &&
                o_x2 == output_vectors[2] &&
                o_x3 == output_vectors[3]) begin
                $display(">>> TEST PASSED <<<");
            end else begin
                $display(">>> TEST FAILED <<<");
                $display("Expected x0: %b, Got: %b", output_vectors[0], o_x0);
                $display("Expected x1: %b, Got: %b", output_vectors[1], o_x1);
                $display("Expected x2: %b, Got: %b", output_vectors[2], o_x2);
                $display("Expected x3: %b, Got: %b", output_vectors[3], o_x3);
            end
        end else begin
            $display(">>> TEST FAILED: o_valid was not high after latency period. <<<");
        end

        #20;
        $finish;
    end

endmodule