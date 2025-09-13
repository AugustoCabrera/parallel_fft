`timescale 1ns/1ps

module tb_fft_serializer;

    localparam NB_DATA      = 12;
    localparam T_CLK        = 10; // 100 MHz
    localparam N_SAMPLES    = 32;

    reg                   clock;
    reg                   i_rst;
    reg                   r_enable;
    reg                   r_valid;
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
        .i_enable(r_enable),
        .i_valid(r_valid),
        .i_din_ch0(r_din_ch0),
        .i_din_ch1(r_din_ch1),
        .i_din_ch2(r_din_ch2),
        .i_din_ch3(r_din_ch3),
        .o_dout(o_dout),
        .o_valid(o_valid)
    );

    initial begin
        clock = 0;
        forever #(T_CLK/2) clock = ~clock;
    end

    integer i;
    initial begin
        $dumpfile("tb_fft_serializer.vcd");
        $dumpvars(0, tb_fft_serializer);
        
        i_rst     = 1;
        r_enable  = 0;
        r_valid   = 0;
        r_din_ch0 = 0;
        r_din_ch1 = 0;
        r_din_ch2 = 0;
        r_din_ch3 = 0;

        #(5*T_CLK + T_CLK/2);
        i_rst = 0;
        #(3*T_CLK);
        r_enable = 1;
        #(20*T_CLK);

        r_valid = 1;
        for (i = 0; i < N_SAMPLES; i = i + 4) begin
            r_din_ch0 = i;
            r_din_ch1 = i+1;
            r_din_ch2 = i+2;
            r_din_ch3 = i+3;
            #(T_CLK);
        end
        r_valid = 0;
        #(100*T_CLK);
        
        r_valid = 1;
        for (i = 0; i < N_SAMPLES; i = i + 4) begin
            r_din_ch0 = i;
            r_din_ch1 = i+1;
            r_din_ch2 = i+2;
            r_din_ch3 = i+3;
            #(T_CLK);
        end
        r_valid = 0;
        #(100*T_CLK);

        $finish;
    end

    always @(posedge clock) begin
        if (o_valid)
            $display("Time %0t ps -> o_dout = %h", $time, o_dout);
    end

endmodule
