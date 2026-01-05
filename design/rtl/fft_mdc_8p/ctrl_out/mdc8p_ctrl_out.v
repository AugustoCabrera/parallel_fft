module mdc8p_ctrl_out #(
    parameter NB = 8
) (
    input                         i_clk,
    input                         i_rst,
    //-------------------------------------------
    input      [      NB - 1 : 0] i_data0_r,
    input      [      NB - 1 : 0] i_data0_i,
    input      [      NB - 1 : 0] i_data1_r,
    input      [      NB - 1 : 0] i_data1_i,
    input                         i_valid,
    ///////////////////// AXIS MASTER /////////////////////
    output reg                    m_axis_data_tvalid,
    output reg [(2 * NB) - 1 : 0] m_axis_data_tdata,
    output reg                    m_axis_data_tlast,
    input                         m_axis_data_tready
);

  /////////////////////////////////////////////////////////
  // WIRE AND REGISTER
  /////////////////////////////////////////////////////////
  localparam N_POINT = 8;
  localparam STATE_OFF = 1'b0;
  localparam STATE_ON = 1'b1;

  reg  [NB - 1 : 0] r_data_r      [N_POINT - 1 : 0];
  reg  [NB - 1 : 0] r_data_i      [N_POINT - 1 : 0];
  reg  [     2 : 0] counter_init;
  reg               valid_init;
  wire [     2 : 0] pre_index1;
  wire [     2 : 0] pre_index2;
  wire [     2 : 0] index1;
  wire [     2 : 0] index2;
  //------------------------------------------------------
  reg               state_valid;
  reg               current_state;
  reg               next_state;
  reg  [     2 : 0] counter;


  /////////////////////////////////////////////////////////
  // STORE THE INPUT DATA
  /////////////////////////////////////////////////////////

  assign pre_index1 = counter_init;
  assign pre_index2 = counter_init + 3'b001;
  assign index1     = {pre_index1[0], pre_index1[1], pre_index1[2]};
  assign index2     = {pre_index2[0], pre_index2[1], pre_index2[2]};

  always @(posedge i_clk) begin
    if (i_rst) begin
      valid_init   <= 1'b0;
      counter_init <= 3'b000;
    end else begin
      if (i_valid) begin
        r_data_r[index1] <= i_data0_r;
        r_data_i[index1] <= i_data0_i;
        r_data_r[index2] <= i_data1_r;
        r_data_i[index2] <= i_data1_i;
        if (counter_init == (N_POINT - 2)) begin
          counter_init <= 3'b000;
          valid_init   <= 1'b1;
        end else begin
          counter_init <= counter_init + 3'b010;
          valid_init   <= 1'b0;
        end
      end else begin
        valid_init   <= 1'b0;
        counter_init <= 3'b000;
      end
    end
  end


  /////////////////////////////////////////////////////////
  // OUTPUTS
  /////////////////////////////////////////////////////////

  always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
      state_valid   <= 1'b0;
      current_state <= STATE_OFF;
      // counter       <= 3'b000;
    end else begin
      state_valid   <= valid_init;
      current_state <= next_state;
    end
  end

  always @(*) begin
    case (current_state)
      STATE_OFF: begin
        if (valid_init && !state_valid) begin
          next_state = STATE_ON;
        end else next_state = STATE_OFF;
      end
      STATE_ON: begin
        if (counter == (N_POINT - 1)) begin
          next_state = STATE_OFF;
        end else next_state = STATE_ON;
      end
      default: begin
        next_state = STATE_OFF;
      end
    endcase
  end

  always @(posedge i_clk) begin
    case (current_state)
      STATE_OFF: begin
        counter            <= 3'b000;
        m_axis_data_tdata  <= {2 * NB{1'b0}};
        m_axis_data_tlast  <= 1'b0;
        m_axis_data_tvalid <= 1'b0;
      end
      STATE_ON: begin
        m_axis_data_tdata  <= {r_data_r[counter], r_data_i[counter]};
        m_axis_data_tvalid <= 1'b1;
        if (counter == (N_POINT - 1)) begin
          counter           <= 3'b000;
          m_axis_data_tlast <= 1'b1;
        end else begin
          counter           <= counter + 3'b001;
          m_axis_data_tlast <= 1'b0;
        end
      end
      default: begin
        counter <= 3'b000;
      end
    endcase
  end

endmodule
