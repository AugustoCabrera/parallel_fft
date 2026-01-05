module overlap_save #(
    parameter NB_DATA = 2*8,
    parameter N_OVERLAP = 16 // by default we use a 50% overlap 
)(
    output reg           o_valid,
    output [NB_DATA-1:0] o_data_0,
    output [NB_DATA-1:0] o_data_1,
    output [NB_DATA-1:0] o_data_2,
    output [NB_DATA-1:0] o_data_3,
    output [NB_DATA-1:0] o_data_4,
    output [NB_DATA-1:0] o_data_5,
    output [NB_DATA-1:0] o_data_6,
    output [NB_DATA-1:0] o_data_7,
    output [NB_DATA-1:0] o_data_8,
    output [NB_DATA-1:0] o_data_9,
    output [NB_DATA-1:0] o_data_10,
    output [NB_DATA-1:0] o_data_11,
    output [NB_DATA-1:0] o_data_12,
    output [NB_DATA-1:0] o_data_13,
    output [NB_DATA-1:0] o_data_14,
    output [NB_DATA-1:0] o_data_15,
    output [NB_DATA-1:0] o_data_16,
    output [NB_DATA-1:0] o_data_17,
    output [NB_DATA-1:0] o_data_18,
    output [NB_DATA-1:0] o_data_19,
    output [NB_DATA-1:0] o_data_20,
    output [NB_DATA-1:0] o_data_21,
    output [NB_DATA-1:0] o_data_22,
    output [NB_DATA-1:0] o_data_23,
    output [NB_DATA-1:0] o_data_24,
    output [NB_DATA-1:0] o_data_25,
    output [NB_DATA-1:0] o_data_26,
    output [NB_DATA-1:0] o_data_27,
    output [NB_DATA-1:0] o_data_28,
    output [NB_DATA-1:0] o_data_29,
    output [NB_DATA-1:0] o_data_30,
    output [NB_DATA-1:0] o_data_31,
    input  [NB_DATA-1:0] i_data,
    //input                i_enable,
    input                i_valid,
    input                i_clk,
    input                i_rst
);

localparam N_DATA = 32;
localparam NB_BLOCK_COUNTER = $clog2(N_DATA);
localparam NB_INPUT_COUNTER = $clog2(N_OVERLAP);

reg [NB_DATA-1:0]          buffer [N_DATA-1:0];
reg [NB_BLOCK_COUNTER-1:0] block_counter;
reg [NB_INPUT_COUNTER-1:0] input_counter;
reg                        buffer_full_flag;

integer i;
always @(posedge i_clk) begin
    if (i_rst) begin
        for (i = 0; i < N_DATA; i = i + 1) begin
            buffer[i] <= {NB_DATA{1'b0}};
        end
    end 
    else if (i_valid) begin
        buffer[N_DATA-1] <= i_data;
        for (i = 0; i < (N_DATA-1); i = i + 1) begin
            buffer[i] <= buffer[i+1];
        end
    end
    else begin
        for (i = 0; i < (N_DATA-1); i = i + 1) begin
            buffer[i] <= buffer[i];
        end
    end
end

always @(posedge i_clk) begin
    if (i_rst) begin
        block_counter    <= 0;
        input_counter    <= 0;
        buffer_full_flag <= 1'b0;
        o_valid          <= 1'b0;
    end else begin
        o_valid <= 1'b0;
        if (i_valid) begin
            if (!buffer_full_flag) begin
                if (block_counter == N_DATA - 1) begin
                    buffer_full_flag <= 1'b1;
                    o_valid          <= 1'b1;
                    input_counter    <= 0;
                end 
                else begin
                    block_counter <= block_counter + 1'd1;
                end
            end 
            else begin
                if (input_counter == N_OVERLAP - 1) begin
                    o_valid       <= 1'b1;
                    input_counter <= 0;
                end 
                else begin
                    input_counter <= input_counter + 1'd1;
                end
            end
        end
    end
end

assign o_data_0  = buffer[0];
assign o_data_1  = buffer[1];
assign o_data_2  = buffer[2];
assign o_data_3  = buffer[3];
assign o_data_4  = buffer[4];
assign o_data_5  = buffer[5];
assign o_data_6  = buffer[6];
assign o_data_7  = buffer[7];
assign o_data_8  = buffer[8];
assign o_data_9  = buffer[9];
assign o_data_10 = buffer[10];
assign o_data_11 = buffer[11];
assign o_data_12 = buffer[12];
assign o_data_13 = buffer[13];
assign o_data_14 = buffer[14];
assign o_data_15 = buffer[15];
assign o_data_16 = buffer[16];
assign o_data_17 = buffer[17];
assign o_data_18 = buffer[18];
assign o_data_19 = buffer[19];
assign o_data_20 = buffer[20];
assign o_data_21 = buffer[21];
assign o_data_22 = buffer[22];
assign o_data_23 = buffer[23];
assign o_data_24 = buffer[24];
assign o_data_25 = buffer[25];
assign o_data_26 = buffer[26];
assign o_data_27 = buffer[27];
assign o_data_28 = buffer[28];
assign o_data_29 = buffer[29];
assign o_data_30 = buffer[30];
assign o_data_31 = buffer[31];

endmodule