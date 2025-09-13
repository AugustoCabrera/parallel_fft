`timescale 1ns/1ps

module tb_stride_8;

    parameter NB_DATA = 16;
    parameter N_INPUTS = 32;
    parameter N_OUTPUTS_PER_PORT = 8;
    parameter N_OUTPUT_PORTS = 4;

    reg clk;
    reg rst;
    reg i_valid;
    reg i_enable;
    reg [NB_DATA-1:0] i_data [0:N_INPUTS-1];

    wire [NB_DATA-1:0] o_data_0, o_data_1, o_data_2, o_data_3;
    wire o_valid;
    wire o_ready;

    reg [NB_DATA-1:0] input_vectors [0:N_INPUTS-1];
    reg [NB_DATA-1:0] expected_o0 [0:N_OUTPUTS_PER_PORT-1];
    reg [NB_DATA-1:0] expected_o1 [0:N_OUTPUTS_PER_PORT-1];
    reg [NB_DATA-1:0] expected_o2 [0:N_OUTPUTS_PER_PORT-1];
    reg [NB_DATA-1:0] expected_o3 [0:N_OUTPUTS_PER_PORT-1];

    stride_8 #(.NB_DATA(NB_DATA)) dut (
        .o_data_0(o_data_0), 
        .o_data_1(o_data_1), 
        .o_data_2(o_data_2), 
        .o_data_3(o_data_3),
        .o_valid(o_valid), 
        .o_ready(o_ready),
        .i_data_0(i_data[0]), 
        .i_data_1(i_data[1]), 
        .i_data_2(i_data[2]), 
        .i_data_3(i_data[3]),
        .i_data_4(i_data[4]), 
        .i_data_5(i_data[5]), 
        .i_data_6(i_data[6]), 
        .i_data_7(i_data[7]),
        .i_data_8(i_data[8]), 
        .i_data_9(i_data[9]), 
        .i_data_10(i_data[10]), 
        .i_data_11(i_data[11]),
        .i_data_12(i_data[12]), 
        .i_data_13(i_data[13]), 
        .i_data_14(i_data[14]), 
        .i_data_15(i_data[15]),
        .i_data_16(i_data[16]), 
        .i_data_17(i_data[17]), 
        .i_data_18(i_data[18]), 
        .i_data_19(i_data[19]),
        .i_data_20(i_data[20]), 
        .i_data_21(i_data[21]), 
        .i_data_22(i_data[22]), 
        .i_data_23(i_data[23]),
        .i_data_24(i_data[24]), 
        .i_data_25(i_data[25]), 
        .i_data_26(i_data[26]), 
        .i_data_27(i_data[27]),
        .i_data_28(i_data[28]), 
        .i_data_29(i_data[29]), 
        .i_data_30(i_data[30]), 
        .i_data_31(i_data[31]),
        .i_enable(i_enable), 
        .i_valid(i_valid), 
        .i_clk(clk), 
        .i_rst(rst)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("tb_stride_8.vcd");
        $dumpvars(0, tb_stride_8);
    end

    integer i;
    integer error_count;
    integer expected_idx;
    initial begin
        $readmemb("input_vectors.txt", input_vectors);
        $readmemb("output_0.txt", expected_o0);
        $readmemb("output_1.txt", expected_o1);
        $readmemb("output_2.txt", expected_o2);
        $readmemb("output_3.txt", expected_o3);

        rst = 1;
        i_valid = 0;
        i_enable = 0;
        error_count = 0;
        expected_idx = 0;
        for (i=0; i<N_INPUTS; i=i+1) i_data[i] = 0;
        #20;
        rst = 0;

        @(posedge clk);
        for (i=0; i<N_INPUTS; i=i+1) i_data[i] <= input_vectors[i];
        i_valid <= 1;

        @(posedge clk);
        i_valid <= 0;
        
        repeat (N_OUTPUTS_PER_PORT + 1) begin
            @(posedge clk);
            if (o_valid) begin
                if (expected_idx < N_OUTPUTS_PER_PORT) begin
                    if (o_data_0 !== expected_o0[expected_idx]) begin
                        error_count = error_count + 1;
                    end
                    if (o_data_1 !== expected_o1[expected_idx]) begin
                        error_count = error_count + 1;
                    end
                    if (o_data_2 !== expected_o2[expected_idx]) begin
                        error_count = error_count + 1;
                    end
                    if (o_data_3 !== expected_o3[expected_idx]) begin
                        error_count = error_count + 1;
                    end
                    expected_idx = expected_idx + 1;
                end
            end
        end

        #10;
        if (error_count == 0 && expected_idx == N_OUTPUTS_PER_PORT) begin
            $display(">>> TEST PASSED <<<");
        end else begin
            $display(">>> TEST FAILED: %0d errors found. <<<", error_count);
        end

        #20;
        $finish;
    end

endmodule
