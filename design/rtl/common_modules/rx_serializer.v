// ----------------------------------------------------------------------------------------------------------------------------
// Module Name: rx_serializer.v
// ----------------------------------------------------------------------------------------------------------------------------
// Description:
//
// ----------------------------------------------------------------------------------------------------------------------------
// Revision History:
//      Date:         2026-01-15
//      Author:       F. Villar
//      Organization: Fundación Fulgor
// ----------------------------------------------------------------------------------------------------------------------------

module rx_serializer #(
    parameter NB_DATA = 8
)(
    input                           i_clk,
    input                           i_rst_n,
    input                           i_data,
    output reg signed [NB_DATA-1:0] o_data_re,
    output reg signed [NB_DATA-1:0] o_data_im,
    output reg                      o_valid
);

localparam TOTAL_BITS = 2 * NB_DATA; // total bits to receive (real + imag)
localparam CNT_W      = 5;

// FSM states
localparam STATE_IDLE  = 0;
localparam STATE_RECV  = 1;
localparam STATE_VALID = 2;

// State registers
reg [1:0] current_state;
reg [1:0] next_state;

reg [CNT_W-1:0] current_cnt;
reg [CNT_W-1:0] next_cnt;

reg [TOTAL_BITS-1:0] current_shift;
reg [TOTAL_BITS-1:0] next_shift;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        current_state <= STATE_IDLE;
        current_cnt   <= '0;
        current_shift <= '0;
        o_valid       <= 1'b0;
    end 
    else begin
        current_state <= next_state;
        current_cnt   <= next_cnt;
        current_shift <= next_shift;
        // update outputs only when the FSM is in the VALID state
        if (current_state == STATE_VALID) begin
            o_data_re <= current_shift[TOTAL_BITS-1 -: NB_DATA];
            o_data_im <= current_shift[NB_DATA-1    -: NB_DATA];
            o_valid   <= 1'b1;
        end 
        else begin
            o_valid <= 1'b0;
        end
    end
end

always @(*) begin
    next_state = current_state;
    next_cnt   = current_cnt;
    next_shift = current_shift;
    case (current_state)
        STATE_IDLE: begin
            next_cnt = 0;
            // wait for start bit (i_data: 0 -> 1)
            if (i_data) begin
                next_state = STATE_RECV;
            end
        end
        STATE_RECV: begin
            // shift in the new bit coming from i_data into the LSB, builds the word from MSB to LSB as time passes
            next_shift = {current_shift[TOTAL_BITS-2:0], i_data};
            if (current_cnt == TOTAL_BITS - 1) begin
                next_state = STATE_VALID;
            end 
            else begin
                next_cnt = current_cnt + '1;
            end
        end
        STATE_VALID: begin
            next_state = STATE_IDLE;
        end
        default: begin
            next_state = STATE_IDLE;
        end
    endcase
end

endmodule