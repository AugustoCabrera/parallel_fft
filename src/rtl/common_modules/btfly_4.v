module btfly_4 #(
    parameter NB_INPUT  = 8,
    parameter NB_OUTPUT = 9
) (
    input signed [NB_INPUT - 1 : 0] i_data0_r,
    input signed [NB_INPUT - 1 : 0] i_data1_r,
    input signed [NB_INPUT - 1 : 0] i_data2_r,
    input signed [NB_INPUT - 1 : 0] i_data3_r,

    input signed [NB_INPUT - 1 : 0] i_data0_i,
    input signed [NB_INPUT - 1 : 0] i_data1_i,
    input signed [NB_INPUT - 1 : 0] i_data2_i,
    input signed [NB_INPUT - 1 : 0] i_data3_i,

    // OUTPUT
    output signed [NB_OUTPUT - 1 : 0] o_data0_r,
    output signed [NB_OUTPUT - 1 : 0] o_data1_r,
    output signed [NB_OUTPUT - 1 : 0] o_data2_r,
    output signed [NB_OUTPUT - 1 : 0] o_data3_r,

    output signed [NB_OUTPUT - 1 : 0] o_data0_i,
    output signed [NB_OUTPUT - 1 : 0] o_data1_i,
    output signed [NB_OUTPUT - 1 : 0] o_data2_i,
    output signed [NB_OUTPUT - 1 : 0] o_data3_i
);

  /////////////////////////////////////////////////////////////////
  // MODULES
  /////////////////////////////////////////////////////////////////

  btfly_2 #(
      .NB_INPUT (NB_INPUT),
      .NB_OUTPUT(NB_OUTPUT)
  ) dut_btfly2_1 (  // BUT 0-2
      .i_data0_r(i_data0_r),
      .i_data1_r(i_data2_r),

      .i_data0_i(i_data0_i),
      .i_data1_i(i_data2_i),

      .o_data0_r(o_data0_r),
      .o_data1_r(o_data2_r),

      .o_data0_i(o_data0_i),
      .o_data1_i(o_data2_i)
  );

  btfly_2 #(
      .NB_INPUT (NB_INPUT),
      .NB_OUTPUT(NB_OUTPUT)
  ) dut_btfly2_2 (  // BUT 1-3
      .i_data0_r(i_data1_r),
      .i_data1_r(i_data3_r),

      .i_data0_i(i_data1_i),
      .i_data1_i(i_data3_i),

      .o_data0_r(o_data1_r),
      .o_data1_r(o_data3_r),

      .o_data0_i(o_data1_i),
      .o_data1_i(o_data3_i)
  );


endmodule
