module twiddle_interface #(
    parameter NB_DATA = 10,
    parameter NBF_DATA = 7
)(
    output reg [2*NB_DATA-1 : 0]  o_signal_0,
    output reg [2*NB_DATA-1 : 0]  o_signal_1,
    output reg [2*NB_DATA-1 : 0]  o_signal_2,
    output reg [2*NB_DATA-1 : 0]  o_signal_3,
    output reg                   o_valid,
    output reg                   o_last,
    input  [2*NB_DATA-1  : 0] i_signal_0,
    input  [2*NB_DATA-1  : 0] i_signal_1,
    input  [2*NB_DATA-1  : 0] i_signal_2,
    input  [2*NB_DATA-1  : 0] i_signal_3,
    input                     i_valid,
    input                     i_rst,
    input                     i_clk
);
 
reg [2:0] valid_counter;
reg [2:0] valid_counter_d;

reg valid_d;
reg valid_2d;
reg last_d;
reg last_2d;

reg [2*NB_DATA-1 : 0] signal_0_d;
reg [2*NB_DATA-1 : 0] signal_1_d;
reg [2*NB_DATA-1 : 0] signal_2_d;
reg [2*NB_DATA-1 : 0] signal_3_d;
reg [2*NB_DATA-1 : 0] signal_0_2d;

reg signed [2*NB_DATA-1 : 0] twiddle_1_mem [0 : 7];
reg signed [2*NB_DATA-1 : 0] twiddle_2_mem [0 : 7];
reg signed [2*NB_DATA-1 : 0] twiddle_3_mem [0 : 7];
wire signed [2*NB_DATA-1 : 0] twiddle_1;
wire signed [2*NB_DATA-1 : 0] twiddle_2;
wire signed [2*NB_DATA-1 : 0] twiddle_3;

wire [2*NB_DATA-1 : 0] product_1;
wire [2*NB_DATA-1 : 0] product_2;
wire [2*NB_DATA-1 : 0] product_3;

initial begin
    $readmemb("twiddle_w1.mem", twiddle_1_mem);
    $readmemb("twiddle_w2.mem", twiddle_2_mem);
    $readmemb("twiddle_w3.mem", twiddle_3_mem);
end

always @(posedge i_clk) begin
    if(i_rst) begin
        valid_counter <= 3'd0;
    end else if(i_valid) begin
        if(valid_counter == 3'd7) begin
            valid_counter <= 3'd0;
        end else begin
            valid_counter <= valid_counter + 1'd1;
        end
    end
end
always @(posedge i_clk) begin
    if (i_valid) begin
        signal_0_d <= i_signal_0;
        signal_1_d <= i_signal_1;
        signal_2_d <= i_signal_2;
        signal_3_d <= i_signal_3;
        valid_counter_d <= valid_counter;
    end
end
always @(posedge i_clk) begin
    signal_0_2d <= signal_0_d;
end

assign twiddle_1 = twiddle_1_mem[valid_counter_d];
assign twiddle_2 = twiddle_2_mem[valid_counter_d];
assign twiddle_3 = twiddle_3_mem[valid_counter_d];

complex_multiplier #(
    .NB_INPUT(NB_DATA), .NBF_INPUT(NBF_DATA),
    .NB_OUTPUT(NB_DATA), .NBF_OUTPUT(NBF_DATA)
) u_multiplier_1 (
    .o_real(product_1[2*NB_DATA-1 : NB_DATA]), .o_imag(product_1[NB_DATA-1 : 0]),
    .i_real_A(signal_1_d[2*NB_DATA-1 : NB_DATA]), .i_imag_A(signal_1_d[NB_DATA-1 : 0]),
    .i_real_B(twiddle_1[2*NB_DATA-1 : NB_DATA]), .i_imag_B(twiddle_1[NB_DATA-1 : 0]),
    .i_clk(i_clk), .i_rst(i_rst)
);

complex_multiplier #(
    .NB_INPUT(NB_DATA), .NBF_INPUT(NBF_DATA),
    .NB_OUTPUT(NB_DATA), .NBF_OUTPUT(NBF_DATA)
) u_multiplier_2 (
    .o_real(product_2[2*NB_DATA-1 : NB_DATA]), .o_imag(product_2[NB_DATA-1 : 0]),
    .i_real_A(signal_2_d[2*NB_DATA-1 : NB_DATA]), .i_imag_A(signal_2_d[NB_DATA-1 : 0]),
    .i_real_B(twiddle_2[2*NB_DATA-1 : NB_DATA]), .i_imag_B(twiddle_2[NB_DATA-1 : 0]),
    .i_clk(i_clk), .i_rst(i_rst)
);

complex_multiplier #(
    .NB_INPUT(NB_DATA), .NBF_INPUT(NBF_DATA),
    .NB_OUTPUT(NB_DATA), .NBF_OUTPUT(NBF_DATA)
) u_multiplier_3 (
    .o_real(product_3[2*NB_DATA-1 : NB_DATA]), .o_imag(product_3[NB_DATA-1 : 0]),
    .i_real_A(signal_3_d[2*NB_DATA-1 : NB_DATA]), .i_imag_A(signal_3_d[NB_DATA-1 : 0]),
    .i_real_B(twiddle_3[2*NB_DATA-1 : NB_DATA]), .i_imag_B(twiddle_3[NB_DATA-1 : 0]),
    .i_clk(i_clk), .i_rst(i_rst)
);

always @(posedge i_clk) begin
    if(i_rst) begin
        o_signal_0 <= 0;
        o_signal_1 <= 0;
        o_signal_2 <= 0;
        o_signal_3 <= 0;
        o_valid <= 1'b0;
        o_last <= 1'b0;
    end else begin
        o_signal_0 <= signal_0_2d;
        o_signal_1 <= product_1;
        o_signal_2 <= product_2;
        o_signal_3 <= product_3;
        o_valid <= valid_2d;
        o_last <= last_2d;
    end
end
always @(posedge i_clk) begin
    if (i_rst) begin
        valid_d <= 1'b0;
        valid_2d <= 1'b0;
        last_d <= 1'b0;
        last_2d <= 1'b0;
    end else begin
        valid_d <= i_valid;
        valid_2d <= valid_d;
        last_d <= (valid_counter == 3'd7) && i_valid;
        last_2d <= last_d;
    end
end
 
endmodule