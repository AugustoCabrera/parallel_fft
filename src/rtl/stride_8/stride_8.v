module stride_8 #(
    parameter NB_DATA = 2*8
)(
    output reg [NB_DATA-1: 0] o_data_0,
    output reg [NB_DATA-1: 0] o_data_1,
    output reg [NB_DATA-1: 0] o_data_2,
    output reg [NB_DATA-1: 0] o_data_3,
    output reg                o_valid,
    output reg                o_ready,
    input [NB_DATA-1: 0]      i_data_0,
    input [NB_DATA-1: 0]      i_data_1,
    input [NB_DATA-1: 0]      i_data_2,
    input [NB_DATA-1: 0]      i_data_3,
    input [NB_DATA-1: 0]      i_data_4,
    input [NB_DATA-1: 0]      i_data_5,
    input [NB_DATA-1: 0]      i_data_6,
    input [NB_DATA-1: 0]      i_data_7,
    input [NB_DATA-1: 0]      i_data_8,
    input [NB_DATA-1: 0]      i_data_9,
    input [NB_DATA-1: 0]      i_data_10,
    input [NB_DATA-1: 0]      i_data_11,
    input [NB_DATA-1: 0]      i_data_12,
    input [NB_DATA-1: 0]      i_data_13,
    input [NB_DATA-1: 0]      i_data_14,
    input [NB_DATA-1: 0]      i_data_15,
    input [NB_DATA-1: 0]      i_data_16,
    input [NB_DATA-1: 0]      i_data_17,
    input [NB_DATA-1: 0]      i_data_18,
    input [NB_DATA-1: 0]      i_data_19,
    input [NB_DATA-1: 0]      i_data_20,
    input [NB_DATA-1: 0]      i_data_21,
    input [NB_DATA-1: 0]      i_data_22,
    input [NB_DATA-1: 0]      i_data_23,
    input [NB_DATA-1: 0]      i_data_24,
    input [NB_DATA-1: 0]      i_data_25,
    input [NB_DATA-1: 0]      i_data_26,
    input [NB_DATA-1: 0]      i_data_27,
    input [NB_DATA-1: 0]      i_data_28,
    input [NB_DATA-1: 0]      i_data_29,
    input [NB_DATA-1: 0]      i_data_30,
    input [NB_DATA-1: 0]      i_data_31,
    input                     i_enable,
    input                     i_valid,
    input                     i_clk,
    input                     i_rst
);

localparam STRIDE_SIZE = 8;
localparam BUFFER_SIZE = 32;
localparam NB_COUNTER = $clog2(STRIDE_SIZE);

reg [NB_DATA-1:0]    buffer [0:BUFFER_SIZE-1];
reg [NB_COUNTER-1:0] emit_count;
reg                  active_flag;

always @(posedge i_clk) begin
    if (i_valid && !active_flag) begin
        buffer[0] <= i_data_0;
        buffer[1] <= i_data_1;
        buffer[2] <= i_data_2;
        buffer[3] <= i_data_3;
        buffer[4] <= i_data_4;
        buffer[5] <= i_data_5;
        buffer[6] <= i_data_6;
        buffer[7] <= i_data_7;
        buffer[8] <= i_data_8;
        buffer[9] <= i_data_9;
        buffer[10] <= i_data_10;
        buffer[11] <= i_data_11;
        buffer[12] <= i_data_12;
        buffer[13] <= i_data_13;
        buffer[14] <= i_data_14;
        buffer[15] <= i_data_15;
        buffer[16] <= i_data_16;
        buffer[17] <= i_data_17;
        buffer[18] <= i_data_18;
        buffer[19] <= i_data_19;
        buffer[20] <= i_data_20;
        buffer[21] <= i_data_21;
        buffer[22] <= i_data_22;
        buffer[23] <= i_data_23;
        buffer[24] <= i_data_24;
        buffer[25] <= i_data_25;
        buffer[26] <= i_data_26;
        buffer[27] <= i_data_27;
        buffer[28] <= i_data_28;
        buffer[29] <= i_data_29;
        buffer[30] <= i_data_30;
        buffer[31] <= i_data_31;
    end
end

always @(posedge i_clk) begin
    if (i_rst) begin
        emit_count  <= {NB_COUNTER{1'b0}};
        o_valid     <= 1'b0;
        active_flag <= 1'b0;
    end 
    else begin
        o_valid <= 1'b0;
        if (i_valid && !active_flag) begin
            active_flag <= 1'b1;
            o_ready     <= 1'b0;
            emit_count  <= 1'b0;
        end
        if (active_flag) begin
            o_data_0 <= buffer[emit_count];
            o_data_1 <= buffer[emit_count + STRIDE_SIZE];
            o_data_2 <= buffer[emit_count + (2 * STRIDE_SIZE)];
            o_data_3 <= buffer[emit_count + (3 * STRIDE_SIZE)];
            o_valid  <= 1'b1;
            if (emit_count == STRIDE_SIZE - 1) begin
                active_flag <= 1'b0;
                o_ready     <= 1'b1;
                emit_count  <= 1'b0;
            end
            else begin
                emit_count <= emit_count + 1'd1;
            end
        end
    end
end

endmodule
