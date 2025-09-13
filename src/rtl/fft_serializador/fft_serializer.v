module fft_serializer #(
    parameter NB_DATA = 12
)(
    input                        i_clk,
    input                        i_rst,
    input                        i_enable,
    input                        i_valid,
    input  [2*NB_DATA - 1 : 0]   i_din_ch0,
    input  [2*NB_DATA - 1 : 0]   i_din_ch1,
    input  [2*NB_DATA - 1 : 0]   i_din_ch2,
    input  [2*NB_DATA - 1 : 0]   i_din_ch3,
    output [2*NB_DATA - 1 : 0]   o_dout,
    output                       o_valid
);

////////////////////////////////////////////////////////////////////////////////////////////////
//  WIRES AND REGISTERS
////////////////////////////////////////////////////////////////////////////////////////////////

reg   [2*NB_DATA - 1 : 0]   din_ch0;
reg   [2*NB_DATA - 1 : 0]   din_ch1;
reg   [2*NB_DATA - 1 : 0]   din_ch2;
reg   [2*NB_DATA - 1 : 0]   din_ch3;
reg   [        2 - 1 : 0]   valid_q;
wire                        ctrl_flag;

reg                         ctrl_save_state;
reg                         ctrl_save_state_next;
reg   [        3 - 1 : 0]   ctrl_save_ptr;
reg   [        5 - 1 : 0]   ctrl_save_counter;

reg   [        3 - 1 : 0]   ctrl_buff;
reg   [        3 - 1 : 0]   ctrl_buff_q;
reg   [        2 - 1 : 0]   ctrl_sample;
reg   [        2 - 1 : 0]   ctrl_sample_q;
reg   [2*NB_DATA - 0 : 0]   mem [8-1:0][4-1:0];

////////////////////////////////////////////////////////////////////////////////////////////////
//  INPUT STORAGE
////////////////////////////////////////////////////////////////////////////////////////////////

assign ctrl_flag = valid_q[0] && !valid_q[1];

always @(posedge i_clk) begin
    din_ch0    <= i_din_ch0;
    din_ch1    <= i_din_ch1;
    din_ch2    <= i_din_ch2;
    din_ch3    <= i_din_ch3;
    valid_q[0] <= i_valid;
    valid_q[1] <= valid_q[0];

    if(ctrl_save_state || ctrl_flag) begin
        mem[ctrl_save_ptr][0] <= {din_ch0,valid_q[0]};
        mem[ctrl_save_ptr][1] <= {din_ch1,valid_q[0]};
        mem[ctrl_save_ptr][2] <= {din_ch2,valid_q[0]};
        mem[ctrl_save_ptr][3] <= {din_ch3,valid_q[0]};  
    end

end

////////////////////////////////////////////////////////////////////////////////////////////////
//  INPUT CONTROL
////////////////////////////////////////////////////////////////////////////////////////////////

always @(*) begin
    case (ctrl_save_state)
        0:          ctrl_save_state_next = ctrl_flag ? 1'b1 : (ctrl_save_counter > 5'd22) ? 1'b1 : 1'b0;
        1:          ctrl_save_state_next = (ctrl_save_ptr == 3'd7) ? 1'd0 : 1'd1; 
        default:    ctrl_save_state_next = 1'b0;
    endcase
end

always @(posedge i_clk) begin
    if(i_rst) begin
        ctrl_save_state   <= 1'b1;
        ctrl_save_ptr     <= 3'd0;
        ctrl_save_counter <= 5'd0;
    end else begin
        ctrl_save_state <= ctrl_save_state_next;
        if(ctrl_flag || ctrl_save_state) begin
            ctrl_save_ptr <= ctrl_save_ptr + 3'd1;
            ctrl_save_counter <= 5'd0;
        end else begin
            ctrl_save_ptr <= 3'd0;
            ctrl_save_counter <= ctrl_save_counter + 5'd1;
        end
    end
end


////////////////////////////////////////////////////////////////////////////////////////////////
//  OUTPUTS CONTROL
////////////////////////////////////////////////////////////////////////////////////////////////

always @(posedge i_clk) begin
    ctrl_buff_q     <= ctrl_buff;
    ctrl_sample_q   <= ctrl_sample;
end

always @(*) begin
    if(i_rst || ctrl_flag) begin
        ctrl_buff   = 3'd0;
        ctrl_sample = 2'd0;
    end else if (ctrl_sample_q < 2'd3) begin
        ctrl_buff   = ctrl_buff_q;
        ctrl_sample = ctrl_sample_q + 2'd1;
    end else begin
        ctrl_sample = 2'd0; 
        ctrl_buff   = (ctrl_buff_q < 3'd7) ? ctrl_buff_q + 3'd1 : 3'd0;
    end
end

////////////////////////////////////////////////////////////////////////////////////////////////
//  OUTPUTS
////////////////////////////////////////////////////////////////////////////////////////////////

assign {o_dout, o_valid} = mem[ctrl_buff_q][ctrl_sample_q];

endmodule