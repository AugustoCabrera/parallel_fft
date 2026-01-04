module mdc8p_stage3 #(
    parameter NB_INPUT  = 11,
    parameter NB_OUTPUT = 12
) (
    input                                 i_clk,
    input                                 i_inverse,
    //----------------------------------------
    input                                 i_valid,
    input  signed     [ NB_INPUT - 1 : 0] i_data1_r,
    input  signed     [ NB_INPUT - 1 : 0] i_data1_i,
    input  signed     [ NB_INPUT - 1 : 0] i_data2_r,
    input  signed     [ NB_INPUT - 1 : 0] i_data2_i,
    //----------------------------------------
    output reg                            o_valid,
    output reg signed [NB_OUTPUT - 1 : 0] o_data1_r,
    output reg signed [NB_OUTPUT - 1 : 0] o_data1_i,
    output reg signed [NB_OUTPUT - 1 : 0] o_data2_r,
    output reg signed [NB_OUTPUT - 1 : 0] o_data2_i
);

  //////////////////////////////////////////////////////////////////////////////////
  // WIRE AND REGISTER
  //////////////////////////////////////////////////////////////////////////////////

  localparam NB_FLY = NB_INPUT + 1;
  //--- -------------------------------------------
  wire signed [NB_FLY - 1 : 0] w_bt0_r;
  wire signed [NB_FLY - 1 : 0] w_bt0_i;
  wire signed [NB_FLY - 1 : 0] w_bt1_r;
  wire signed [NB_FLY - 1 : 0] w_bt1_i;
  //--- -------------------------------------------
  wire signed [NB_OUTPUT - 1 : 0] w_data0_r;
  wire signed [NB_OUTPUT - 1 : 0] w_data0_i;
  wire signed [NB_OUTPUT - 1 : 0] w_data1_r;
  wire signed [NB_OUTPUT - 1 : 0] w_data1_i;
  //--- -------------------------------------------

  //////////////////////////////////////////////////////////////////////////////////
  // MODULE
  //////////////////////////////////////////////////////////////////////////////////


  btfly_2 #(
      .NB_INPUT (NB_INPUT),
      .NB_OUTPUT(NB_FLY)
  ) u_btfly2 (
      .i_data0_r(i_data1_r),
      .i_data0_i(i_data1_i),
      .i_data1_r(i_data2_r),
      .i_data1_i(i_data2_i),
      .o_data0_r(w_bt0_r),
      .o_data0_i(w_bt0_i),
      .o_data1_r(w_bt1_r),
      .o_data1_i(w_bt1_i)
  );

  assign w_data0_r = (i_inverse)? {{3{w_bt0_r[NB_OUTPUT-1]}}, w_bt0_r[NB_OUTPUT-1 -: (NB_OUTPUT-3)]} : w_bt0_r;
  assign w_data0_i = (i_inverse)? {{3{w_bt0_i[NB_OUTPUT-1]}}, w_bt0_i[NB_OUTPUT-1 -: (NB_OUTPUT-3)]} : w_bt0_i;
  assign w_data1_r = (i_inverse)? {{3{w_bt1_r[NB_OUTPUT-1]}}, w_bt1_r[NB_OUTPUT-1 -: (NB_OUTPUT-3)]} : w_bt1_r;
  assign w_data1_i = (i_inverse)? {{3{w_bt1_i[NB_OUTPUT-1]}}, w_bt1_i[NB_OUTPUT-1 -: (NB_OUTPUT-3)]} : w_bt1_i;

  always @(posedge i_clk) begin
    o_data1_r <= w_data0_r;
    o_data1_i <= w_data0_i;
    o_data2_r <= w_data1_r;
    o_data2_i <= w_data1_i;
    o_valid   <= i_valid;
  end

endmodule
