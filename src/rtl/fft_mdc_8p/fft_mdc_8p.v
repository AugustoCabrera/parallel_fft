module fft_mdc #(
    parameter NB_INPUT  = 8,
    parameter NBF_INPUT = 7
) (
    input                                 i_clk,
    input                                 i_rst,
    input                                 i_inverse,
    ///////////////////// AXIS SLAVE /////////////////////
    input                                 s_axis_data_tvalid,
    input  [      (2 * NB_INPUT) - 1 : 0] s_axis_data_tdata,
    input                                 s_axis_data_tlast,
    output                                s_axis_data_tready,
    ///////////////////// AXIS MASTER /////////////////////
    output                                m_axis_data_tvalid,
    output [(2 * (NB_INPUT + 4)) - 1 : 0] m_axis_data_tdata,
    output                                m_axis_data_tlast,
    input                                 m_axis_data_tready
);


  ///////////////////////////////////////////////////////////////////////////////
  // WIRE AND REGISTER
  ///////////////////////////////////////////////////////////////////////////////

  localparam NB_TW = 10;
  localparam NBF_TW = 9;
  //-----------------------------------------
  localparam NB_STAGE1 = NB_INPUT + 2;
  localparam NBF_STAGE1 = NBF_INPUT;
  localparam NB_STAGE2 = NB_STAGE1 + 1;
  localparam NBF_STAGE2 = NBF_STAGE1;
  localparam NB_STAGE3 = NB_STAGE2 + 1;
  localparam NBF_STAGE3 = NBF_STAGE2;


  wire [ NB_INPUT - 1 : 0] w_data0_r;
  wire [ NB_INPUT - 1 : 0] w_data0_i;
  wire [ NB_INPUT - 1 : 0] w_data1_r;
  wire [ NB_INPUT - 1 : 0] w_data1_i;
  wire                     w_valid;
  //------------------------------------------------
  wire [NB_STAGE1 - 1 : 0] w_st1_1r;
  wire [NB_STAGE1 - 1 : 0] w_st1_1i;
  wire [NB_STAGE1 - 1 : 0] w_st1_2r;
  wire [NB_STAGE1 - 1 : 0] w_st1_2i;
  wire                     w_st1_valid;
  //------------------------------------------------
  wire [NB_STAGE2 - 1 : 0] w_st2_1r;
  wire [NB_STAGE2 - 1 : 0] w_st2_1i;
  wire [NB_STAGE2 - 1 : 0] w_st2_2r;
  wire [NB_STAGE2 - 1 : 0] w_st2_2i;
  wire                     w_st2_valid;
  //------------------------------------------------
  wire [NB_STAGE3 - 1 : 0] w_st3_1r;
  wire [NB_STAGE3 - 1 : 0] w_st3_1i;
  wire [NB_STAGE3 - 1 : 0] w_st3_2r;
  wire [NB_STAGE3 - 1 : 0] w_st3_2i;


  ///////////////////////////////////////////////////////////////////////////////
  // MODULES
  ///////////////////////////////////////////////////////////////////////////////

  // CTRL INPUT
  mdc8p_ctrl_in #(
      .NB(NB_INPUT)
  ) control_input (
      .i_clk(i_clk),
      .i_rst(i_rst),
      ///////////////////// AXIS SLAVE /////////////////////
      .s_axis_data_tvalid(s_axis_data_tvalid),
      .s_axis_data_tdata(s_axis_data_tdata),
      .s_axis_data_tlast(s_axis_data_tlast),
      .s_axis_data_tready(s_axis_data_tready),
      //-------------------------------------------
      .o_data0_r(w_data0_r),
      .o_data0_i(w_data0_i),
      .o_data1_r(w_data1_r),
      .o_data1_i(w_data1_i),
      .o_valid(w_valid)
  );

  // STAGE 1
  mdc8p_stage1 #(
      .NB_INPUT  (NB_INPUT),
      .NBF_INPUT (NBF_INPUT),
      .NB_OUTPUT (NB_STAGE1),
      .NBF_OUTPUT(NBF_STAGE1),
      .NB_TW     (NB_TW),
      .NBF_TW    (NBF_TW)
  ) u_mdc8p_stage1 (
      .i_clk    (i_clk),
      .i_rst    (i_rst),
      .i_inverse(i_inverse),
      //----------------------------------------
      .i_valid  (w_valid),
      .i_data1_r(w_data0_r),
      .i_data1_i(w_data0_i),
      .i_data2_r(w_data1_r),
      .i_data2_i(w_data1_i),
      //----------------------------------------
      .o_valid  (w_st1_valid),
      .o_data1_r(w_st1_1r),
      .o_data1_i(w_st1_1i),
      .o_data2_r(w_st1_2r),
      .o_data2_i(w_st1_2i)
  );

  ////////////////////////////////////////////////////////////////
  // STAGE 2

  mdc8p_stage2 #(
      .NB_INPUT (NB_STAGE1),
      .NB_OUTPUT(NB_STAGE2)
  ) u_mdc8p_stage2 (
      .i_clk    (i_clk),
      .i_rst    (i_rst),
      .i_inverse(i_inverse),
      //----------------------------------------
      .i_valid  (w_st1_valid),
      .i_data1_r(w_st1_1r),
      .i_data1_i(w_st1_1i),
      .i_data2_r(w_st1_2r),
      .i_data2_i(w_st1_2i),
      //----------------------------------------
      .o_valid  (w_st2_valid),
      .o_data1_r(w_st2_1r),
      .o_data1_i(w_st2_1i),
      .o_data2_r(w_st2_2r),
      .o_data2_i(w_st2_2i)
  );


  // STAGE 3
  mdc8p_stage3 #(
      .NB_INPUT (NB_STAGE2),
      .NB_OUTPUT(NB_STAGE3)
  ) u_mdc8p_stage3 (
      .i_clk    (i_clk),
      .i_inverse(i_inverse),
      //----------------------------------------
      .i_valid  (w_st2_valid),
      .i_data1_r(w_st2_1r),
      .i_data1_i(w_st2_1i),
      .i_data2_r(w_st2_2r),
      .i_data2_i(w_st2_2i),
      //----------------------------------------
      .o_valid  (w_st3_valid),
      .o_data1_r(w_st3_1r),
      .o_data1_i(w_st3_1i),
      .o_data2_r(w_st3_2r),
      .o_data2_i(w_st3_2i)
  );

  ////////////////////////////////////////////////////////////////
  // CTRL OUT
  mdc8p_ctrl_out #(
      .NB(NB_STAGE3)
  ) control_output (
      .i_clk(i_clk),
      .i_rst(i_rst),
      //-------------------------------------------
      .i_valid(w_st3_valid),
      .i_data0_r(w_st3_1r),
      .i_data0_i(w_st3_1i),
      .i_data1_r(w_st3_2r),
      .i_data1_i(w_st3_2i),
      ///////////////////// AXIS MASTER /////////////////////
      .m_axis_data_tvalid(m_axis_data_tvalid),
      .m_axis_data_tdata(m_axis_data_tdata),
      .m_axis_data_tlast(m_axis_data_tlast),
      .m_axis_data_tready(m_axis_data_tready)
  );

endmodule
