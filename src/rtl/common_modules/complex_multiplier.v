module complex_multiplier 
#(
    parameter NB_INPUT = 17,
    parameter NBF_INPUT = 7,
    parameter NB_OUTPUT = 17,
    parameter NBF_OUTPUT = 7
) (
    output reg signed [NB_OUTPUT - 1 : 0] o_real,
    output reg signed [NB_OUTPUT - 1 : 0] o_imag,
    input signed [NB_INPUT - 1 : 0] i_real_A,
    input signed [NB_INPUT - 1 : 0] i_imag_A,
    input signed [NB_INPUT - 1 : 0] i_real_B,
    input signed [NB_INPUT - 1 : 0] i_imag_B,
    input i_rst,
    input i_clk
);


// A = x + jy ; B = u + jv; AB = (xu - yv) + j(xv + yu)

localparam NB_PROD = NB_INPUT*2;
localparam NBF_PROD = NBF_INPUT*2;
localparam NB_PROD_SUM = NB_PROD+1;
localparam NBF_PROD_SUM = NBF_PROD;

wire signed [NB_PROD - 1 : 0] partial_prods [3 : 0];
wire signed [NB_PROD_SUM - 1 : 0] sums [1 : 0];
wire signed [NB_OUTPUT - 1 : 0] sums_adj [1 : 0];

assign partial_prods[0] = i_real_A*i_real_B; // xu
assign partial_prods[1] = i_imag_A*i_imag_B; // yv
assign partial_prods[2] = i_real_A*i_imag_B; // xv
assign partial_prods[3] = i_imag_A*i_real_B; // yu

assign sums[0] = partial_prods[0]+(-1)*partial_prods[1]; // (xu - yv)
assign sums[1] = partial_prods[2]+partial_prods[3]; // (xv + yu)

SatTruncFP
#(
    .NB_XI(NB_PROD_SUM),
    .NBF_XI(NBF_PROD_SUM),
    .NB_XO(NB_OUTPUT),
    .NBF_XO(NBF_OUTPUT)
)
SatTrunc_sum_0
(
    .i_data(sums[0]),
    .o_data(sums_adj[0])
);

SatTruncFP
#(
    .NB_XI(NB_PROD_SUM),
    .NBF_XI(NBF_PROD_SUM),
    .NB_XO(NB_OUTPUT),
    .NBF_XO(NBF_OUTPUT)
)
SatTrunc_sum_1
(
    .i_data(sums[1]),
    .o_data(sums_adj[1])
);

always @(posedge i_clk) begin
    if(i_rst) begin
        o_real <= {NB_OUTPUT{1'b0}};
        o_imag <= {NB_OUTPUT{1'b0}};
    end
    else begin
        o_real <= sums_adj[0];
        o_imag <= sums_adj[1];
    end
end
    
endmodule