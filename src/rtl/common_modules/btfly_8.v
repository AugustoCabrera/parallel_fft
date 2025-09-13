module btfly_8 #(
    parameter NB_INPUT  = 8,
    parameter NB_OUTPUT = 9
) (
    input signed [NB_INPUT - 1 : 0] i_data0_r,
    input signed [NB_INPUT - 1 : 0] i_data1_r,
    input signed [NB_INPUT - 1 : 0] i_data2_r,
    input signed [NB_INPUT - 1 : 0] i_data3_r,
    input signed [NB_INPUT - 1 : 0] i_data4_r,
    input signed [NB_INPUT - 1 : 0] i_data5_r,
    input signed [NB_INPUT - 1 : 0] i_data6_r,
    input signed [NB_INPUT - 1 : 0] i_data7_r,

    input signed [NB_INPUT - 1 : 0] i_data0_i,
    input signed [NB_INPUT - 1 : 0] i_data1_i,
    input signed [NB_INPUT - 1 : 0] i_data2_i,
    input signed [NB_INPUT - 1 : 0] i_data3_i,
    input signed [NB_INPUT - 1 : 0] i_data4_i,
    input signed [NB_INPUT - 1 : 0] i_data5_i,
    input signed [NB_INPUT - 1 : 0] i_data6_i,
    input signed [NB_INPUT - 1 : 0] i_data7_i,

    // OUTPUT
    output signed [NB_OUTPUT - 1 : 0] o_data0_r,
    output signed [NB_OUTPUT - 1 : 0] o_data1_r,
    output signed [NB_OUTPUT - 1 : 0] o_data2_r,
    output signed [NB_OUTPUT - 1 : 0] o_data3_r,
    output signed [NB_OUTPUT - 1 : 0] o_data4_r,
    output signed [NB_OUTPUT - 1 : 0] o_data5_r,
    output signed [NB_OUTPUT - 1 : 0] o_data6_r,
    output signed [NB_OUTPUT - 1 : 0] o_data7_r,

    output signed [NB_OUTPUT - 1 : 0] o_data0_i,
    output signed [NB_OUTPUT - 1 : 0] o_data1_i,
    output signed [NB_OUTPUT - 1 : 0] o_data2_i,
    output signed [NB_OUTPUT - 1 : 0] o_data3_i,
    output signed [NB_OUTPUT - 1 : 0] o_data4_i,
    output signed [NB_OUTPUT - 1 : 0] o_data5_i,
    output signed [NB_OUTPUT - 1 : 0] o_data6_i,
    output signed [NB_OUTPUT - 1 : 0] o_data7_i
);

  /////////////////////////////////////////////////////////////////
  // MODULES
  /////////////////////////////////////////////////////////////////

  btfly_4 #(
      .NB_INPUT (NB_INPUT),
      .NB_OUTPUT(NB_OUTPUT)
  ) butterfly_0y1 (
      .i_data0_r(i_data0_r),
      .i_data1_r(i_data1_r),
      .i_data2_r(i_data4_r),
      .i_data3_r(i_data5_r),

      .i_data0_i(i_data0_i),
      .i_data1_i(i_data1_i),
      .i_data2_i(i_data4_i),
      .i_data3_i(i_data5_i),

      // OUTPUT
      .o_data0_r(o_data0_r),
      .o_data1_r(o_data1_r),
      .o_data2_r(o_data4_r),
      .o_data3_r(o_data5_r),

      .o_data0_i(o_data0_i),
      .o_data1_i(o_data1_i),
      .o_data2_i(o_data4_i),
      .o_data3_i(o_data5_i)
  );

  btfly_4 #(
      .NB_INPUT (NB_INPUT),
      .NB_OUTPUT(NB_OUTPUT)
  ) butterfly_2y3 (
      .i_data0_r(i_data2_r),
      .i_data1_r(i_data3_r),
      .i_data2_r(i_data6_r),
      .i_data3_r(i_data7_r),

      .i_data0_i(i_data2_i),
      .i_data1_i(i_data3_i),
      .i_data2_i(i_data6_i),
      .i_data3_i(i_data7_i),

      // OUTPUT
      .o_data0_r(o_data2_r),
      .o_data1_r(o_data3_r),
      .o_data2_r(o_data6_r),
      .o_data3_r(o_data7_r),

      .o_data0_i(o_data2_i),
      .o_data1_i(o_data3_i),
      .o_data2_i(o_data6_i),
      .o_data3_i(o_data7_i)
  );
endmodule
