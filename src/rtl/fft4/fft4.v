module fft4 #(
    parameter NB_INPUT  = 8,
    parameter NBF_INPUT = 7,
    parameter NB_OUTPUT = 10,
    parameter NBF_OUTPUT = 7
)(
    output reg [2*NB_OUTPUT-1:0] o_x0,
    output reg [2*NB_OUTPUT-1:0] o_x1,
    output reg [2*NB_OUTPUT-1:0] o_x2,
    output reg [2*NB_OUTPUT-1:0] o_x3,
    output                       o_valid,
    output                       o_ready,
    input [2*NB_INPUT-1:0]       i_x0,
    input [2*NB_INPUT-1:0]       i_x1,
    input [2*NB_INPUT-1:0]       i_x2,
    input [2*NB_INPUT-1:0]       i_x3,
    input                        i_enable,
    input                        i_valid,
    input                        i_rst,
    input                        i_clk
);

reg valid_d;
reg valid_2d;
reg valid_3d;
reg valid_4d;

reg [2*NB_INPUT-1:0] x0;
reg [2*NB_INPUT-1:0] x1;
reg [2*NB_INPUT-1:0] x2;
reg [2*NB_INPUT-1:0] x3;

always @(posedge i_clk) begin
    if(i_rst) begin
        valid_d  <= 1'b0;
        valid_2d <= 1'b0;
        valid_3d <= 1'b0;
        valid_4d <= 1'b0;
    end
    else begin
        valid_4d <= valid_3d;
        valid_3d <= valid_2d;
        valid_2d <= valid_d;
        valid_d  <= i_valid;
    end
end

always @(posedge i_clk) begin
    if(i_valid) begin
        x0 <= i_x0;
        x1 <= i_x1;
        x2 <= i_x2;
        x3 <= i_x3;
    end
end

wire signed [NB_INPUT-1:0] i_real [3:0];
wire signed [NB_INPUT-1:0] i_imag [3:0];

assign {i_real[0], i_imag[0]} = x0;
assign {i_real[1], i_imag[1]} = x1;
assign {i_real[2], i_imag[2]} = x2;
assign {i_real[3], i_imag[3]} = x3;

reg signed [NB_INPUT-1:0] stage1_real [3:0];
reg signed [NB_INPUT-1:0] stage1_imag [3:0];

always @(posedge i_clk) begin
    if (i_rst) begin
        stage1_real[0] <= 0;
        stage1_real[1] <= 0;
        stage1_real[2] <= 0;
        stage1_real[3] <= 0;
        stage1_imag[0] <= 0;
        stage1_imag[1] <= 0;
        stage1_imag[2] <= 0;
        stage1_imag[3] <= 0;
    end 
    else begin
        stage1_real[0] <= i_real[0];
        stage1_real[1] <= i_real[1];
        stage1_real[2] <= i_real[2];
        stage1_real[3] <= i_real[3];
        stage1_imag[0] <= i_imag[0];
        stage1_imag[1] <= i_imag[1];
        stage1_imag[2] <= i_imag[2];
        stage1_imag[3] <= i_imag[3];
    end
end

wire signed [NB_INPUT:0] X_even_real [1:0];
wire signed [NB_INPUT:0] X_odd_real  [1:0];
wire signed [NB_INPUT:0] X_even_imag [1:0];
wire signed [NB_INPUT:0] X_odd_imag  [1:0];

assign X_even_real[0] = stage1_real[0] + stage1_real[2];
assign X_even_real[1] = stage1_real[0] - stage1_real[2];
assign X_even_imag[0] = stage1_imag[0] + stage1_imag[2];
assign X_even_imag[1] = stage1_imag[0] - stage1_imag[2];
assign X_odd_real[0]  = stage1_real[1] + stage1_real[3];
assign X_odd_real[1]  = stage1_imag[1] - stage1_imag[3];
assign X_odd_imag[0]  = stage1_imag[1] + stage1_imag[3];
assign X_odd_imag[1]  = stage1_real[3] - stage1_real[1];

reg signed [NB_INPUT+1:0] X_real [3:0];
reg signed [NB_INPUT+1:0] X_imag [3:0];

always @(posedge i_clk) begin
    if (i_rst) begin
        X_real[0] <= 0; X_real[1] <= 0; X_real[2] <= 0; X_real[3] <= 0;
        X_imag[0] <= 0; X_imag[1] <= 0; X_imag[2] <= 0; X_imag[3] <= 0;
    end 
    else begin
        X_real[0] <= X_even_real[0] + X_odd_real[0];
        X_real[1] <= X_even_real[1] + X_odd_real[1];
        X_real[2] <= X_even_real[0] - X_odd_real[0];
        X_real[3] <= X_even_real[1] - X_odd_real[1];
        X_imag[0] <= X_even_imag[0] + X_odd_imag[0];
        X_imag[1] <= X_even_imag[1] + X_odd_imag[1];
        X_imag[2] <= X_even_imag[0] - X_odd_imag[0];
        X_imag[3] <= X_even_imag[1] - X_odd_imag[1];
    end
end

wire signed [NB_OUTPUT-1:0] real_adj [3:0];
wire signed [NB_OUTPUT-1:0] imag_adj [3:0];

genvar i;
generate
    for (i = 0; i < 4; i = i + 1) begin
        SatTruncFP #(
            .NB_XI(NB_INPUT + 2),
            .NBF_XI(NBF_INPUT),
            .NB_XO(NB_OUTPUT),
            .NBF_XO(NBF_OUTPUT)
        ) trunc_real (
            .i_data(X_real[i]),
            .o_data(real_adj[i])
        );
        SatTruncFP #(
            .NB_XI(NB_INPUT + 2),
            .NBF_XI(NBF_INPUT),
            .NB_XO(NB_OUTPUT),
            .NBF_XO(NBF_OUTPUT)
        ) trunc_imag (
            .i_data(X_imag[i]),
            .o_data(imag_adj[i])
        );
    end
endgenerate

always @(posedge i_clk) begin
    if (i_rst) begin
        o_x0 <= 0; o_x1 <= 0; o_x2 <= 0; o_x3 <= 0;
    end else begin
        o_x0 <= {real_adj[0], imag_adj[0]};
        o_x1 <= {real_adj[1], imag_adj[1]};
        o_x2 <= {real_adj[2], imag_adj[2]};
        o_x3 <= {real_adj[3], imag_adj[3]};
    end
end

assign o_valid = valid_4d;

endmodule