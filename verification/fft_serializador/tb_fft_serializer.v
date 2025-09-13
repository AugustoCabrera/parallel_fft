`timescale 1ns/1ps

module tb_fft_serializer;

    // Parámetros
    localparam NB_DATA = 12;
    localparam CLK_PERIOD = 10; // 100 MHz

    // Señales del DUT
    reg                   clock;
    reg                   i_rst;
    reg                   i_enable;
    reg                   i_valid;
    reg  [2*NB_DATA-1:0]  r_din_ch0;
    reg  [2*NB_DATA-1:0]  r_din_ch1;
    reg  [2*NB_DATA-1:0]  r_din_ch2;
    reg  [2*NB_DATA-1:0]  r_din_ch3;
    wire [2*NB_DATA-1:0]  o_dout;
    wire                  o_valid;

    fft_serializer #(
        .NB_DATA(NB_DATA)
    ) u_fft_serializer (
        .i_clk(clock),
        .i_rst(i_rst),
        .i_enable(i_enable),
        .i_valid(i_valid),
        .i_din_ch0(r_din_ch0),
        .i_din_ch1(r_din_ch1),
        .i_din_ch2(r_din_ch2),
        .i_din_ch3(r_din_ch3),
        .o_dout(o_dout),
        .o_valid(o_valid)
    );

    // Generación de clock
    initial begin
        clock = 0;
        forever #(CLK_PERIOD/2) clock = ~clock;
    end

    // Estímulos
    initial begin
        $dumpfile("fft_serializer.vcd");   // nombre del archivo de ondas
        $dumpvars(0, tb_fft_serializer);   // guarda todas las señales del testbench
        
        i_rst     = 1;
        i_enable  = 0;
        i_valid   = 0;
        r_din_ch0 = 0;
        r_din_ch1 = 0;
        r_din_ch2 = 0;
        r_din_ch3 = 0;

        #(5*CLK_PERIOD + CLK_PERIOD/2);
        i_rst = 0;
        i_enable = 1;

        #(3*CLK_PERIOD);
        i_valid = 1;
        r_din_ch0 = 0;
        r_din_ch1 = 1;
        r_din_ch2 = 2;
        r_din_ch3 = 3;
        
        #(CLK_PERIOD);
        r_din_ch0 = 4;
        r_din_ch1 = 5;
        r_din_ch2 = 6;
        r_din_ch3 = 7;
        
        #(CLK_PERIOD);
        r_din_ch0 = 8;
        r_din_ch1 = 9;
        r_din_ch2 = 10;
        r_din_ch3 = 11;

        #(CLK_PERIOD);
        r_din_ch0 = 12;
        r_din_ch1 = 13;
        r_din_ch2 = 14;
        r_din_ch3 = 15;

        #(CLK_PERIOD);
        r_din_ch0 = 16;
        r_din_ch1 = 17;
        r_din_ch2 = 18;
        r_din_ch3 = 19;

        #(CLK_PERIOD);
        r_din_ch0 = 20;
        r_din_ch1 = 21;
        r_din_ch2 = 22;
        r_din_ch3 = 23;

        #(CLK_PERIOD);
        r_din_ch0 = 24;
        r_din_ch1 = 25;
        r_din_ch2 = 26;
        r_din_ch3 = 27;

        #(CLK_PERIOD);
        r_din_ch0 = 28;
        r_din_ch1 = 29;
        r_din_ch2 = 30;
        r_din_ch3 = 31;

        #(CLK_PERIOD);
        i_valid = 0;

        #(30*CLK_PERIOD);
        $finish;
    end

    always @(posedge clock) begin
        if (o_valid)
            $display("Tiempo %0t ns -> o_dout = %h", $time, o_dout);
    end

endmodule
