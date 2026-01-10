module debug_unit #(
  parameter integer NB_ADDR = 7,
  parameter integer NB_DATA = 8
)(
  input  wire                 clk,
  input  wire                 rst_n,
  // SPI Slave Interface
  input  wire [NB_ADDR-1:0]   spi_addr,
  input  wire [NB_DATA-1:0]   spi_wdata,
  input  wire                 spi_wr_en,
  output reg  [NB_DATA-1:0]   spi_rdata,
  // Probe Inputs
  input  wire [NB_DATA-1:0]   monitor_status,
  input  wire [NB_DATA-1:0]   fifo_level,
  input  wire [NB_DATA-1:0]   tap_0,
  input  wire [NB_DATA-1:0]   tap_1,
  // Control Outputs
  output reg  [NB_DATA-1:0]   sw_reset,
  output reg  [NB_DATA-1:0]   mode
);

// Address Map
localparam [NB_ADDR-1:0] ADDR_MONITOR_STATUS = 'h00;
localparam [NB_ADDR-1:0] ADDR_FIFO_LEVEL = 'h01;
localparam [NB_ADDR-1:0] ADDR_TAP_0 = 'h02;
localparam [NB_ADDR-1:0] ADDR_TAP_1 = 'h03;
localparam [NB_ADDR-1:0] ADDR_SW_RESET = 'h10;
localparam [NB_ADDR-1:0] ADDR_MODE = 'h11;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sw_reset <= {NB_DATA{1'b0}};
    mode <= {NB_DATA{1'b0}};
  end
  else begin
    if (spi_wr_en) begin
      case (spi_addr)
        ADDR_SW_RESET: sw_reset <= spi_wdata;
        ADDR_MODE: mode <= spi_wdata;
      endcase
    end
  end
end

always @(*) begin
  case (spi_addr)
    // Probes
    ADDR_MONITOR_STATUS: spi_rdata = monitor_status;
    ADDR_FIFO_LEVEL: spi_rdata = fifo_level;
    ADDR_TAP_0: spi_rdata = tap_0;
    ADDR_TAP_1: spi_rdata = tap_1;
    // Controls (Readback)
    ADDR_SW_RESET: spi_rdata = sw_reset;
    ADDR_MODE: spi_rdata = mode;
    default:      spi_rdata = {NB_DATA{1'b0}};
  endcase
end

endmodule