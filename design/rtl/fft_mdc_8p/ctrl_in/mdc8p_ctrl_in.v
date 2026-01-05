module mdc8p_ctrl_in #(
    parameter NB = 8
) (
    input                         i_clk,
    input                         i_rst,
    ///////////////////// AXIS SLAVE /////////////////////
    input                         s_axis_data_tvalid,
    input      [(2 * NB) - 1 : 0] s_axis_data_tdata,
    input                         s_axis_data_tlast,
    output reg                    s_axis_data_tready,
    //-------------------------------------------
    output reg [      NB - 1 : 0] o_data0_r,
    output reg [      NB - 1 : 0] o_data0_i,
    output reg [      NB - 1 : 0] o_data1_r,
    output reg [      NB - 1 : 0] o_data1_i,
    output reg                    o_valid
);

  /////////////////////////////////////////////////////////
  // WIRE AND REGISTER
  /////////////////////////////////////////////////////////
  localparam STATE_INIT = 1'b0;
  localparam STATE_COUN = 1'b1;
  localparam N_POINT = 8;

  reg               current_state;
  reg               next_state;
  reg               state_signal;
  reg               bandera;
  reg  [     1 : 0] counter;
  //---------------------------------------------
  reg               r_valid;
  wire [NB - 1 : 0] w_data0_r;
  wire [NB - 1 : 0] w_data0_i;
  wire [NB - 1 : 0] w_data1_r;
  wire [NB - 1 : 0] w_data1_i;


  /////////////////////////////////////////////////////////
  // STORE THE INPUT DATA
  /////////////////////////////////////////////////////////
  reg  [NB - 1 : 0] r_data_r      [N_POINT - 1 : 0];
  reg  [NB - 1 : 0] r_data_i      [N_POINT - 1 : 0];
  reg  [     2 : 0] counter_init;
  reg               valid_init;

  always @(posedge i_clk) begin
    s_axis_data_tready <= 1'b1;
    if (s_axis_data_tvalid) begin
      {r_data_r[counter_init], r_data_i[counter_init]} <= s_axis_data_tdata;
      if (s_axis_data_tlast) begin
        valid_init   <= 1'b1;
        counter_init <= 3'b000;
      end else begin
        valid_init   <= 1'b0;
        counter_init <= counter_init + 3'b001;
      end
    end else begin
      valid_init   <= 1'b0;
      counter_init <= 3'b000;
    end
  end


  /////////////////////////////////////////////////////////
  // FSM
  /////////////////////////////////////////////////////////

  always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
      current_state <= STATE_INIT;
      counter <= 2'b00;
      state_signal <= 1'b0;
    end else begin
      current_state <= next_state;
      state_signal  <= valid_init;
      if (bandera) counter <= counter + 1;
      else counter <= 0;
    end
  end

  always @(*) begin
    case (current_state)
      STATE_INIT: begin
        if (!state_signal && valid_init) begin
          next_state = STATE_COUN;
          bandera = 1'b1;
          r_valid = 1'b1;
        end else begin
          next_state = STATE_INIT;
          bandera = 1'b0;
          r_valid = 1'b0;
        end
      end
      STATE_COUN: begin
        r_valid = 1'b1;
        if (counter == 2'b11) begin
          next_state = STATE_INIT;
          bandera = 1'b0;
        end else begin
          next_state = STATE_COUN;
          bandera = 1'b1;
        end
      end
      default: begin
        next_state = STATE_INIT;
        bandera = 1'b0;
      end
    endcase
  end

  /////////////////////////////////////////////////////////
  // OUTPUTS
  /////////////////////////////////////////////////////////

  assign w_data0_r = (r_valid) ? (counter == 2'b00)? r_data_r[0] :
                                 (counter == 2'b01)? r_data_r[1] :
                                 (counter == 2'b10)? r_data_r[2] : r_data_r[3] : {NB{1'b0}};
  assign w_data0_i = (r_valid) ? (counter == 2'b00)? r_data_i[0] :
                                 (counter == 2'b01)? r_data_i[1] :
                                 (counter == 2'b10)? r_data_i[2] : r_data_i[3] : {NB{1'b0}};

  assign w_data1_r = (r_valid) ? (counter == 2'b00)? r_data_r[4] :
                                 (counter == 2'b01)? r_data_r[5] :
                                 (counter == 2'b10)? r_data_r[6] : r_data_r[7] : {NB{1'b0}};
  assign w_data1_i = (r_valid) ? (counter == 2'b00)? r_data_i[4] :
                                 (counter == 2'b01)? r_data_i[5] :
                                 (counter == 2'b10)? r_data_i[6] : r_data_i[7] : {NB{1'b0}};

  always @(posedge i_clk) begin
    o_data0_r <= w_data0_r;
    o_data0_i <= w_data0_i;
    o_data1_r <= w_data1_r;
    o_data1_i <= w_data1_i;
    o_valid   <= r_valid;
  end


endmodule
