module top_debug_system (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        ss_n,
    input  wire        sclk,
    input  wire        mosi,
    output wire        miso,
    input  wire [7:0]  monitor_status,
    input  wire [7:0]  fifo_level,
    input  wire [7:0]  tap_0,
    input  wire [7:0]  tap_1,
    output wire [7:0]  sw_reset,
    output wire [7:0]  mode
);

    wire [6:0]  addr_out;
    wire [7:0]  data_to_dut;
    wire        wr_en;
    wire [7:0]  data_from_dut;
    wire        done_unused;
    wire [15:0] frame;

    // SPI Slave
    spi_slave_mode0 #(
        .FRAME_BITS(16),
        .ADDR_BITS(7),
        .DATA_BITS(8)
    ) u_spi_slave (
        .rst_n(rst_n),
        .ss_n(ss_n),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .addr_out(addr_out),
        .data_out(data_to_dut),
        .write_enable(wr_en),
        .data_in(data_from_dut),
        .done(done_unused),
        .rx_frame(frame)
    );

    // Debug Unit
    debug_unit #(
        .NB_ADDR(7),
        .NB_DATA(8)
    ) u_debug_unit (
        .clk(clk),
        .rst_n(rst_n),
        .spi_addr(addr_out),
        .spi_wdata(data_to_dut),
        .spi_wr_en(wr_en),
        .spi_rdata(data_from_dut),
        .spi_ss_n(ss_n),
        .monitor_status(monitor_status),
        .fifo_level(fifo_level),
        .tap_0(tap_0),
        .tap_1(tap_1),
        .sw_reset(sw_reset),
        .mode(mode)
    );

endmodule