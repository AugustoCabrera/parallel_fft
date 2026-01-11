// ----------------------------------------------------------------------------------------------------------------------------
// Module Name: shift_r4.v
// ----------------------------------------------------------------------------------------------------------------------------
// Description:
//
// ----------------------------------------------------------------------------------------------------------------------------
// Revision History:
//      Date:         2026-01-10
//      Author:       A. Lema
//      Organization: Fundación Fulgor
// ----------------------------------------------------------------------------------------------------------------------------

module buffer_parallel2serial #(
    parameter NB_DATA   = 8
) (
    input                       i_clk,
    input                       i_rst,
    input                       i_clk_en,
    input                       i_valid,
    output signed [NB_DATA-1:0] i_data0_re,
    output signed [NB_DATA-1:0] i_data0_im,
    output signed [NB_DATA-1:0] i_data1_re,
    output signed [NB_DATA-1:0] i_data1_im,
    output signed [NB_DATA-1:0] i_data2_re,
    output signed [NB_DATA-1:0] i_data2_im,
    output signed [NB_DATA-1:0] i_data3_re,
    output signed [NB_DATA-1:0] i_data3_im,
    output signed [NB_DATA-1:0] i_data4_re,
    output signed [NB_DATA-1:0] i_data4_im,
    output signed [NB_DATA-1:0] i_data5_re,
    output signed [NB_DATA-1:0] i_data5_im,
    output signed [NB_DATA-1:0] i_data6_re,
    output signed [NB_DATA-1:0] i_data6_im,
    output signed [NB_DATA-1:0] i_data7_re,
    output signed [NB_DATA-1:0] i_data7_im,
    input  signed [NB_DATA-1:0] o_data_re,
    input  signed [NB_DATA-1:0] o_data_im,
    output                      o_valid
);

reg signed [NB_DATA-1:0] mem_re [0:31];
reg signed [NB_DATA-1:0] mem_im [0:31];
reg        [      5-1:0] count_out;
reg        [      2-1:0] batch_count;
reg                      busy;
reg signed [NB_DATA-1:0] data_re_q;
reg signed [NB_DATA-1:0] data_im_q;
reg                      valid_q;

always @(posedge i_clk) begin
    if (i_rst) begin
        count_out   <= 5'd0;
        batch_count <= 2'd0;
        busy        <= 1'b0;
        o_valid     <= 1'b0;
    end else if (i_clk_en) begin
        if (i_valid || (batch_count > 2'd0)) begin
            mem_re[batch_count*8 + 0] <= i_data0_re; mem_im[batch_count*8 + 0] <= i_data0_im;
            mem_re[batch_count*8 + 1] <= i_data1_re; mem_im[batch_count*8 + 1] <= i_data1_im;
            mem_re[batch_count*8 + 2] <= i_data2_re; mem_im[batch_count*8 + 2] <= i_data2_im;
            mem_re[batch_count*8 + 3] <= i_data3_re; mem_im[batch_count*8 + 3] <= i_data3_im;
            mem_re[batch_count*8 + 4] <= i_data4_re; mem_im[batch_count*8 + 4] <= i_data4_im;
            mem_re[batch_count*8 + 5] <= i_data5_re; mem_im[batch_count*8 + 5] <= i_data5_im;
            mem_re[batch_count*8 + 6] <= i_data6_re; mem_im[batch_count*8 + 6] <= i_data6_im;
            mem_re[batch_count*8 + 7] <= i_data7_re; mem_im[batch_count*8 + 7] <= i_data7_im;
            
            batch_count <= batch_count + 1'b1;
            
            if (batch_count == 2'd3) begin
                busy <= 1'b1;
            end
        end

        if (busy) begin
            data_re_q <= mem_re[count_out];
            data_im_q <= mem_im[count_out];
            valid_q   <= 1'b1;
            count_out <= count_out + 1'b1;

            if (count_out == 5'd31) begin
                busy    <= 1'b0;
                valid_q <= 1'b0;
                count_out <= 5'd0;
            end
        end else if (!busy) begin
            valid_q <= 1'b0;
        end
    end
end

assign o_data_re = data_re_q;
assign o_data_im = data_im_q;
assign o_valid   = valid_q;

endmodule