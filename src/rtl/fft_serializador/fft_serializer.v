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
//  WIRE AND REGISTER
////////////////////////////////////////////////////////////////////////////////////////////////

reg                         valid_q;
wire                        ctrl_flag;

reg   [        3 - 1 : 0]   ctrl_save;
reg   [        3 - 1 : 0]   ctrl_buff;
reg   [        3 - 1 : 0]   ctrl_buff_q;
reg   [        2 - 1 : 0]   ctrl_sample;
reg   [        2 - 1 : 0]   ctrl_sample_q;
reg   [2*NB_DATA - 0 : 0]   mem [8-1:0][4-1:0];

wire  [2*NB_DATA - 1 : 0]   dout;
wire                        dvalid;

////////////////////////////////////////////////////////////////////////////////////////////////
//  CONTROL
////////////////////////////////////////////////////////////////////////////////////////////////

assign ctrl_flag = i_valid && !valid_q;
always @(posedge i_clk) begin
    valid_q         <= i_valid;
    ctrl_buff_q     <= ctrl_buff;
    ctrl_sample_q   <= ctrl_sample;
    if(i_valid) begin
        ctrl_save <= ctrl_save + 3'd1;
    end else begin
        ctrl_save <= 3'd0;
    end
end

always @(posedge i_clk) begin
    if(i_valid && i_enable) begin
        mem[ctrl_save][0] <= {i_din_ch0,i_valid};
        mem[ctrl_save][1] <= {i_din_ch1,i_valid};
        mem[ctrl_save][2] <= {i_din_ch2,i_valid};
        mem[ctrl_save][3] <= {i_din_ch3,i_valid};  
    end
end

always @(*) begin
    if(i_rst) begin
        ctrl_buff   = 3'd0;
        ctrl_sample = 2'd0;
    end else begin
        if(ctrl_flag) begin
            ctrl_buff   = 3'd0;
            ctrl_sample = 2'd0;
        end else begin
            if(ctrl_sample_q < 2'd3) begin
                ctrl_buff   = ctrl_buff_q;
                ctrl_sample = ctrl_sample_q + 2'd1;
            end else begin
                ctrl_sample = 2'd0; 
                ctrl_buff   = (ctrl_buff_q < 3'd7) ? ctrl_buff_q + 3'd1 : 3'd0;
            end
        end
    end
end

////////////////////////////////////////////////////////////////////////////////////////////////
//  OUTPUTS
////////////////////////////////////////////////////////////////////////////////////////////////

assign {dout, dvalid} = mem[ctrl_buff_q][ctrl_sample_q];
assign o_dout   = dout;
assign o_valid  = dvalid;

endmodule