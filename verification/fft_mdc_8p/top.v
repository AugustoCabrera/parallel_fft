module top (
    input i_clk
);

  /////////////////////////////////////////////////////////////////
  // WIRE AND REGISTERS
  /////////////////////////////////////////////////////////////////
  localparam NB_GEN = 8;
  localparam NBF_GEN = 7;
  localparam NB_FFT = 12;
  localparam NBF_FFT = 7;
  localparam N_POINT = 8;

  wire [(2*NB_GEN) - 1 : 0] w_axis_idata_tdata;
  wire                      w_axis_idata_tvalid;
  wire                      w_axis_idata_tlast;
  wire                      w_axis_idata_tready;
  //------------------------------------------------------------
  wire                      w_axis_odata_tready;
  wire                      w_axis_odata_tvalid;
  wire [(2*NB_FFT) - 1 : 0] w_axis_odata_tdata;
  wire                      w_axis_odata_tlast;
  //------------------------------------------------------------
  wire [    NB_FFT - 1 : 0] w_fft_r;
  wire [    NB_FFT - 1 : 0] w_fft_i;
  // VIO E ILA
  wire                      i_rst;
  wire                      i_valid;
  //------------------------------------------------------------
  localparam NB_COUNT = 12;
  localparam COUNT_MAX = 500;
  reg  [NB_COUNT - 1 : 0] r_counter;
  reg                     r_valid;
  wire                    w_valid;

  /////////////////////////////////////////////////////////////////
  // MODULES
  /////////////////////////////////////////////////////////////////

  signal_generator #(
      .NB_OUTPUT(NB_GEN),
      .NB_COUNT (3),
      .N_POINT  (8)
  ) generator (
      .i_clk             (i_clk),
      .i_rst             (i_rst),
      .i_valid           (w_valid),
      ///////////////////// AXIS MASTER /////////////////////
      .m_axis_data_tvalid(w_axis_idata_tvalid),
      .m_axis_data_tdata (w_axis_idata_tdata),
      .m_axis_data_tlast (w_axis_idata_tlast),
      .m_axis_data_tready(w_axis_idata_tready)
  );

  fft_mdc #(
      .NB_INPUT (NB_GEN),
      .NBF_INPUT(NBF_GEN)
  ) fft_mdc_8p (
      .i_clk             (i_clk),
      .i_rst             (i_rst),
      .i_inverse         (1'b0),
      ///////////////////// AXIS SLAVE /////////////////////
      .s_axis_data_tvalid(w_axis_idata_tvalid),
      .s_axis_data_tdata (w_axis_idata_tdata),
      .s_axis_data_tlast (w_axis_idata_tlast),
      .s_axis_data_tready(w_axis_idata_tready),
      ///////////////////// AXIS MASTER /////////////////////
      .m_axis_data_tvalid(w_axis_odata_tvalid),
      .m_axis_data_tdata (w_axis_odata_tdata),
      .m_axis_data_tlast (w_axis_odata_tlast),
      .m_axis_data_tready(1'b1)
  );

  assign {w_fft_r, w_fft_i} = w_axis_odata_tdata;


  always @(posedge i_clk) begin
    if (i_valid) begin
      if (r_counter < COUNT_MAX) begin
        r_counter <= r_counter + {{NB_COUNT - 1{1'b0}}, 1'b1};
        r_valid   <= 1'b0;
      end else begin
        r_counter <= {NB_COUNT{1'b0}};
        r_valid   <= 1'b1;
      end
    end else begin
      r_counter <= {NB_COUNT{1'b0}};
      r_valid   <= 1'b0;
    end
  end
  assign w_valid = r_valid;

  /////////////////////////////////////////////////////////////////
  // OUTPUT
  /////////////////////////////////////////////////////////////////

  ilafft ila_fft_v0 (
      .clk   (i_clk),                // input wire clk
      .probe0(w_axis_odata_tdata),   // input wire [23:0]  probe0  
      .probe1(w_axis_odata_tvalid),  // input wire [0:0]  probe1 
      .probe2(w_axis_odata_tlast),   // input wire [0:0]  probe2 
      .probe3(w_axis_idata_tdata),   // input wire [15:0]  probe3
      .probe4(w_axis_idata_tvalid),  // input wire [0:0]  probe1 
      .probe5(w_axis_idata_tlast)    // input wire [0:0]  probe2
  );

  vio_fft vio_fft (
      .clk       (i_clk),                // input wire clk
      .probe_in0 (w_axis_odata_tdata),   // input wire [23 : 0] probe_in0
      .probe_in1 (w_axis_odata_tvalid),  // input wire [0 : 0] probe_in1
      .probe_in2 (w_axis_odata_tlast),   // input wire [0 : 0] probe_in2
      .probe_in3 (w_axis_idata_tdata),   // input wire [15 : 0] probe_in3
      .probe_in4 (w_axis_idata_tvalid),  // input wire [0 : 0] probe_in4
      .probe_in5 (w_axis_idata_tlast),   // input wire [0 : 0] probe_in5
      .probe_out0(i_rst),                // output wire [0 : 0] probe_out0
      .probe_out1(i_valid)               // output wire [0 : 0] probe_out1
  );

endmodule
