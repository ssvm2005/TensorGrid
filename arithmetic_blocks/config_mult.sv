`timescale 1ns / 1ps
//`define TIMING

module config_mult (
    input i_clk,
    input i_rst,
    `ifdef TIMING
        input [31:0] i_a_in,  // Floating-point operand 1
        input [31:0] i_b_in,  // Floating-point operand 2
        input [1:0]  i_config_in, // Configuration input: 00 for INT32, 01 for BF16, 10 for FP32
    `endif
    `ifndef TIMING
        input [31:0] i_a,  // Floating-point operand 1
        input [31:0] i_b,  // Floating-point operand 2
        input [1:0]  i_config, // Configuration input: 00 for INT32, 01 for BF16, 10 for FP32
    `endif
    output logic [31:0] o_c // Floating-point result
);
`ifdef TIMING
    logic [31:0] i_a;
    logic [31:0] i_b;
    logic [1:0] i_config;

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            i_a <= 'd0;
            i_b <= 'd0;
            i_config <= 'd0;
        end else begin
            i_a <= i_a_in;
            i_b <= i_b_in;
            i_config <= i_config_in;
        end
    end
`endif
localparam EXP_BITS = 8;
localparam MANT_BITS_FP32 = 23;
localparam MANT_BITS_BF16 = 7;

logic [1:0] config_curr;
logic signed [63:0] mant_1;
logic [1:0] is_nan;
logic [1:0] is_inf;
logic [1:0] is_zero;

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        config_curr <= 2'd0;
        mant_1  <= 64'd0;
        is_nan  <= 2'd0;
        is_inf  <= 2'd0;
        is_zero <= 2'd0;
    end else begin
        config_curr <= i_config;
        if (!i_config) begin
            is_nan  <= 2'd0;
            is_inf  <= 2'd0;
            is_zero <= 2'd0;
            mant_1  <= $signed(i_a) * $signed(i_b);
        end else begin
            is_nan[0]  <= (&i_a[30:23]) && (|i_a[22:0]);
            is_nan[1]  <= (&i_b[30:23]) && (|i_b[22:0]);
            is_inf[0]  <= (&i_a[30:23]) && ~(|i_a[22:0]);
            is_inf[1]  <= (&i_b[30:23]) && ~(|i_b[22:0]);
            is_zero[0] <= ~(|i_a[30:0]);
            is_zero[1] <= ~(|i_b[30:0]);
            mant_1[47:0]  <= {(|i_a[30:23]), i_a[22:0]} * {(|i_b[30:23]), i_b[22:0]};
            mant_1[63]    <= i_a[31] ^ i_b[31];
            mant_1[56:48] <= i_a[30:23] + i_b[30:23] + {{7{1'b0}}, (!i_a[30:23])} + {{7{1'b0}}, (!i_b[30:23])};
        end
    end
end

logic [47:0] inter_mantissa;
logic [5:0] shifts_iter;
logic [5:0] shifts_final;
logic [8:0] expon_stored;
logic [5:0] shifts_stored;
logic signed [63:0] mant_stored;
logic [1:0] config_curr_stored;
logic [47:0] mant_proc;
logic [8:0] expon_prod_pre;
logic [24:0] mant_prod_pre;
logic [1:0] is_nan_1;
logic [1:0] is_inf_1;
logic [1:0] is_zero_1;
logic sign_2;

always_comb begin
    if (config_curr) begin
        inter_mantissa = mant_1[47:0];
        shifts_final = 47;
        for (shifts_iter = 48; shifts_iter > 1; shifts_iter = (shifts_iter >> 1) + shifts_iter[0]) begin
            shifts_final = shifts_final;
            inter_mantissa = inter_mantissa;
            if (inter_mantissa >> ((shifts_iter >> 1) + shifts_iter[0])) inter_mantissa >>= (shifts_iter >> 1);
            else shifts_final -= (shifts_iter >> 1);
        end
    end else begin
        inter_mantissa = 48'd0;
        shifts_final = 6'd0;
    end
    if (config_curr_stored) begin
        if (expon_stored < 128 + 46 - shifts_stored) begin
            if (expon_stored < 127)
                mant_proc = mant_stored[47:0] >> (127 - expon_stored);
            else mant_proc = mant_stored[47:0] << (expon_stored - 127);
        end
        else mant_proc = mant_stored[47:0] << (47 - shifts_stored);
        if (expon_stored < 128 + 46 - shifts_stored) 
            expon_prod_pre = {2'd0, {7{1'b1}}};
        else expon_prod_pre = expon_stored - 46 - 'd1 + shifts_stored;
        if (config_curr_stored[0]) 
            mant_prod_pre = {mant_proc[47:40], 16'd0} + ((mant_proc[40]? (mant_proc[39:32] >= {1'b1,{7{1'b0}}}): (mant_proc[39:32] > {1'b1,{7{1'b0}}})) << 16);
        else mant_prod_pre = mant_proc[47:24] + (mant_proc[24]? (mant_proc[23:0] >= {1'b1,{23{1'b0}}}): (mant_proc[23:0] > {1'b1,{23{1'b0}}}));
    end else begin
        mant_proc = 64'd0;
        expon_prod_pre = 9'd0;
        mant_prod_pre = 25'd0;
    end
end

always_ff @(posedge i_clk) begin
    mant_stored <= mant_1;
    shifts_stored <= shifts_final;
    expon_stored <= mant_1[56:48];
    config_curr_stored <= config_curr;
    is_nan_1 <= is_nan;
    is_inf_1 <= is_inf;
    is_zero_1 <= is_zero;
    sign_2 <= mant_1[63];
    if (i_rst) begin
        mant_stored <= 64'd0;
        shifts_stored <= 6'd0;
        expon_stored <= 9'd0;
        config_curr_stored <= 2'd0;
        is_nan_1 <= 2'd0;
        is_inf_1 <= 2'd0;
        is_zero_1 <= 2'd0;
        sign_2 <= 1'b0;
    end
end

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        o_c <= 32'd0;
    end else begin
        if (config_curr_stored == 2'b00) o_c <= mant_stored[31:0];
        else begin
            if (is_nan_1) o_c <= {sign_2, {31{1'b1}}};
            else if (|is_zero_1 && !is_inf_1) o_c <= {sign_2, {31{1'b0}}};
            else if ((&(is_inf_1^is_zero_1)) && (^is_zero_1)) o_c <= {1'b0, {31{1'b1}}};
            else if (is_inf_1) o_c <= {sign_2, {8{1'b1}}, {23{1'b0}}};
            else begin
                if (expon_prod_pre >= {2'd2, {5{1'b1}}, 2'd1}) o_c <= {sign_2, {8{1'b1}}, {23{1'b0}}};
                else begin
                    o_c[31] <= sign_2;
                    o_c[30:23] <= expon_prod_pre - {1'b0, {7{1'b1}}} + {{6{1'b0}}, mant_prod_pre[24:23]};
                    o_c[22:0] <= mant_prod_pre[22:0];
                end
            end
        end
    end
end

endmodule