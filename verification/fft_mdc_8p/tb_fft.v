`timescale 1ns / 1ps

module tb_fft ();


  /////////////////////////////////////////////////////////////////
  // WIRE AND REGISTERS
  /////////////////////////////////////////////////////////////////
  localparam T_CLK = 10;
  localparam NB_INPUT = 8;
  localparam NBF_INPUT = 7;
  localparam NB_FFT = 12;
  localparam NBF_FFT = 7;
  localparam NB_IFFT = 16;
  localparam NBF_IFFT = 7;
  //------------------------------------------------------------
  localparam L = 2;
  localparam N_POINT = 8;
  //------------------------------------------------------------
  localparam NB_GEN = 8;
  localparam NBF_GEN = 7;

  reg                        r_clk;
  reg                        r_rst;
  reg                        r_valid;
  //-----------------------------------------------------
  wire [ (2*NB_GEN) - 1 : 0] w_axis_idata_tdata;
  wire                       w_axis_idata_tvalid;
  wire                       w_axis_idata_tlast;
  wire                       w_axis_idata_tready;
  //------------------------------------------------------------
  wire                       w_axis_fft_tready;
  wire                       w_axis_fft_tvalid;
  wire [ (2*NB_FFT) - 1 : 0] w_axis_fft_tdata;
  wire                       w_axis_fft_tlast;
  //------------------------------------------------------------
  reg                        r_axis_ifft_tready;
  wire                       w_axis_ifft_tvalid;
  wire [(2*NB_IFFT) - 1 : 0] w_axis_ifft_tdata;
  wire                       w_axis_ifft_tlast;

  wire [     NB_FFT - 1 : 0] w_fft_r;
  wire [     NB_FFT - 1 : 0] w_fft_i;
  wire [    NB_IFFT - 1 : 0] w_ifft_r;
  wire [    NB_IFFT - 1 : 0] w_ifft_i;
  /////////////////////////////////////////////////////////////////
  // MODULES
  /////////////////////////////////////////////////////////////////

  signal_generator #(
      .NB_OUTPUT(NB_GEN),
      .NB_COUNT (3),
      .N_POINT  (8)
  ) generator (
      .i_clk             (r_clk),
      .i_rst             (r_rst),
      .i_valid           (r_valid),
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
      .i_clk             (r_clk),
      .i_rst             (r_rst),
      .i_inverse         (1'b0),
      ///////////////////// AXIS SLAVE /////////////////////
      .s_axis_data_tvalid(w_axis_idata_tvalid),
      .s_axis_data_tdata (w_axis_idata_tdata),
      .s_axis_data_tlast (w_axis_idata_tlast),
      .s_axis_data_tready(w_axis_idata_tready),
      ///////////////////// AXIS MASTER /////////////////////
      .m_axis_data_tvalid(w_axis_fft_tvalid),
      .m_axis_data_tdata (w_axis_fft_tdata),
      .m_axis_data_tlast (w_axis_fft_tlast),
      .m_axis_data_tready(w_axis_fft_tready)
  );

  assign {w_fft_r, w_fft_i} = w_axis_fft_tdata;

  fft_mdc #(
      .NB_INPUT (NB_FFT),
      .NBF_INPUT(NBF_FFT)
  ) ifft_mdc_8p (
      .i_clk             (r_clk),
      .i_rst             (r_rst),
      .i_inverse         (1'b1),
      ///////////////////// AXIS SLAVE /////////////////////
      .s_axis_data_tvalid(w_axis_fft_tvalid),
      .s_axis_data_tdata (w_axis_fft_tdata),
      .s_axis_data_tlast (w_axis_fft_tlast),
      .s_axis_data_tready(w_axis_fft_tready),
      ///////////////////// AXIS MASTER /////////////////////
      .m_axis_data_tvalid(w_axis_ifft_tvalid),
      .m_axis_data_tdata (w_axis_ifft_tdata),
      .m_axis_data_tlast (w_axis_ifft_tlast),
      .m_axis_data_tready(r_axis_ifft_tready)
  );

  assign {w_ifft_r, w_ifft_i} = w_axis_ifft_tdata;

/////////////////////////////////////////////////////////////////
// SIMULATION
/////////////////////////////////////////////////////////////////

always #(T_CLK / 2) r_clk = ~r_clk;

integer file_fft;
integer file_ifft;
initial begin
    file_fft  = $fopen("fft_output.txt", "w");
    file_ifft = $fopen("ifft_output.txt", "w");
end

always @(posedge r_clk) begin
	if (w_axis_fft_tvalid) begin
      $fwrite(file_fft, "%h %h\n", $signed(w_fft_r), $signed(w_fft_i));
    end
    if (w_axis_ifft_tvalid) begin
      $fwrite(file_ifft, "%h %h\n", $signed(w_ifft_r), $signed(w_ifft_i));
	end
end



initial begin
    $display("");
    $display("Simulation Started");
    $dumpfile("tb_fft.vcd");
    $dumpvars(0, tb_fft);
    
    r_clk              = 0;
    r_rst              = 0;
    r_valid            = 0;
    // r_axis_odata_tready = 1;
    r_axis_ifft_tready = 1;
    
    #(T_CLK + T_CLK / 2);
    r_rst = 1;
    #T_CLK;
    r_rst = 0;
    
    #(3 * T_CLK);
    r_valid = 1;
    #(2 * T_CLK);
    r_valid = 0;
    
    #(70 * T_CLK);
    
    $fclose(file_fft);
    $fclose(file_ifft);
    $display("Simulation Finished");
    $display("");
    $finish;
end




endmodule
