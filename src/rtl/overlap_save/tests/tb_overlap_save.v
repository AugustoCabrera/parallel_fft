`timescale 1ns/1ps

module tb_overlap_save;

    parameter NB_DATA = 2*8; // size of input/output samples
    parameter N_OVERLAP = 16; // number of overlaped samples
    localparam N_SAMPLES = 3*32; // number of random samples

    reg i_clk;
    reg i_rst;
    reg i_valid;
    reg i_enable;
    reg [NB_DATA-1:0] i_data;

    wire o_valid;
    wire [NB_DATA-1:0] o_data_0;
    wire [NB_DATA-1:0] o_data_1;
    wire [NB_DATA-1:0] o_data_2;
    wire [NB_DATA-1:0] o_data_3;
    wire [NB_DATA-1:0] o_data_4;
    wire [NB_DATA-1:0] o_data_5;
    wire [NB_DATA-1:0] o_data_6;
    wire [NB_DATA-1:0] o_data_7;
    wire [NB_DATA-1:0] o_data_8;
    wire [NB_DATA-1:0] o_data_9;
    wire [NB_DATA-1:0] o_data_10;
    wire [NB_DATA-1:0] o_data_11;
    wire [NB_DATA-1:0] o_data_12;
    wire [NB_DATA-1:0] o_data_13;
    wire [NB_DATA-1:0] o_data_14;
    wire [NB_DATA-1:0] o_data_15;
    wire [NB_DATA-1:0] o_data_16;
    wire [NB_DATA-1:0] o_data_17;
    wire [NB_DATA-1:0] o_data_18;
    wire [NB_DATA-1:0] o_data_19;
    wire [NB_DATA-1:0] o_data_20;
    wire [NB_DATA-1:0] o_data_21;
    wire [NB_DATA-1:0] o_data_22;
    wire [NB_DATA-1:0] o_data_23;
    wire [NB_DATA-1:0] o_data_24;
    wire [NB_DATA-1:0] o_data_25;
    wire [NB_DATA-1:0] o_data_26;
    wire [NB_DATA-1:0] o_data_27;
    wire [NB_DATA-1:0] o_data_28;
    wire [NB_DATA-1:0] o_data_29;
    wire [NB_DATA-1:0] o_data_30;
    wire [NB_DATA-1:0] o_data_31;

    overlap_save #(
        .NB_DATA(NB_DATA),
        .N_OVERLAP(N_OVERLAP)
    ) dut (
        .o_valid(o_valid),
        .o_data_0(o_data_0), 
        .o_data_1(o_data_1), 
        .o_data_2(o_data_2), 
        .o_data_3(o_data_3),
        .o_data_4(o_data_4), 
        .o_data_5(o_data_5), 
        .o_data_6(o_data_6), 
        .o_data_7(o_data_7),
        .o_data_8(o_data_8), 
        .o_data_9(o_data_9), 
        .o_data_10(o_data_10), 
        .o_data_11(o_data_11),
        .o_data_12(o_data_12), 
        .o_data_13(o_data_13), 
        .o_data_14(o_data_14), 
        .o_data_15(o_data_15),
        .o_data_16(o_data_16), 
        .o_data_17(o_data_17), 
        .o_data_18(o_data_18), 
        .o_data_19(o_data_19),
        .o_data_20(o_data_20), 
        .o_data_21(o_data_21), 
        .o_data_22(o_data_22), 
        .o_data_23(o_data_23),
        .o_data_24(o_data_24), 
        .o_data_25(o_data_25), 
        .o_data_26(o_data_26), 
        .o_data_27(o_data_27),
        .o_data_28(o_data_28), 
        .o_data_29(o_data_29), 
        .o_data_30(o_data_30), 
        .o_data_31(o_data_31),
        .i_data(i_data),
        .i_enable(i_enable),
        .i_valid(i_valid),
        .i_clk(i_clk),
        .i_rst(i_rst)
    );

    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;
    end

    initial begin
        $dumpfile("tb_overlap_save.vcd");
        $dumpvars(0, tb_overlap_save);
    end

    integer i;
    initial begin
        i_rst    = 1'b1;
        i_valid  = 1'b0;
        i_enable = 1'b1;
        i_data   = 1'b0;
        #20;
        i_rst    = 1'b0;
        
        for (i = 0; i < N_SAMPLES; i = i + 1) begin
            @(posedge i_clk);
            i_valid <= 1;
            i_data <= $random;
        end

        @(posedge i_clk);
        i_valid <= 1'b0;
        
        #50;
        $finish;
    end

endmodule