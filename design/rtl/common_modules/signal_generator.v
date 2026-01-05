module signal_generator #(
    parameter NB_OUTPUT = 8,
    parameter NB_COUNT  = 4,
    parameter N_POINT   = 16
) (
    input                                i_clk,
    input                                i_rst,
    input                                i_valid,
    ///////////////////// AXIS MASTER /////////////////////
    output reg                           m_axis_data_tvalid,
    output reg [(2 * NB_OUTPUT) - 1 : 0] m_axis_data_tdata,
    output reg                           m_axis_data_tlast,
    input                                m_axis_data_tready
);

  /////////////////////////////////////////////////////////
  // WIRE AND REGISTER
  /////////////////////////////////////////////////////////
  localparam R_FILE = "input_r.mem";
  localparam I_FILE = "input_i.mem";

  localparam STATE_OFF = 1'b0;
  localparam STATE_ON = 1'b1;

  reg                      state_valid;
  reg [NB_OUTPUT  - 1 : 0] r_data_r      [N_POINT - 1 : 0];
  reg [NB_OUTPUT  - 1 : 0] r_data_i      [N_POINT - 1 : 0];
  reg                      current_state;
  reg                      next_state;
  reg [  NB_COUNT - 1 : 0] counter;

  /////////////////////////////////////////////////////////
  // INIT MEM
  /////////////////////////////////////////////////////////

  initial begin
    if (R_FILE != "") begin
      $readmemh(R_FILE, r_data_r, 0, N_POINT - 1);
    end
    if (I_FILE != "") begin
      $readmemh(I_FILE, r_data_i, 0, N_POINT - 1);
    end
  end

  /////////////////////////////////////////////////////////
  // OUTPUTS
  /////////////////////////////////////////////////////////
  always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
      state_valid   <= 1'b0;
      current_state <= STATE_OFF;
    end else begin
      state_valid   <= i_valid;
      current_state <= next_state;
    end
  end

  always @(*) begin
    case (current_state)
      STATE_OFF: begin
        if (i_valid && !state_valid) begin
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
        counter            <= {NB_COUNT{1'b0}};
        m_axis_data_tdata  <= {2 * NB_OUTPUT{1'b0}};
        m_axis_data_tlast  <= 1'b0;
        m_axis_data_tvalid <= 1'b0;
      end
      STATE_ON: begin
        m_axis_data_tdata  <= {r_data_r[counter], r_data_i[counter]};
        m_axis_data_tvalid <= 1'b1;
        if (counter == (N_POINT - 1)) begin
          counter           <= {NB_COUNT{1'b0}};
          m_axis_data_tlast <= 1'b1;
        end else begin
          counter           <= counter + {{NB_COUNT - 1{1'b0}}, 1'b1};
          m_axis_data_tlast <= 1'b0;
        end
      end
      default: begin
        counter <= {NB_COUNT{1'b0}};
      end
    endcase
  end

endmodule
