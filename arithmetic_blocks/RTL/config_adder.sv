`timescale 1ns / 1ps
//`define TIMING

module config_adder (
    `ifdef TIMING
        input logic [31:0] i_a_in,
        input logic [31:0] i_b_in,
        input logic [1:0]  i_config_in,
    `endif
    `ifndef TIMING
        input logic [31:0] i_a,
        input logic [31:0] i_b,
        input logic [1:0]  i_config,
    `endif
    input logic i_clk,
    input logic i_rst,
    output logic [31:0] o_c
);
logic signed [63:0] greater_num;
logic signed [63:0] lesser_num;
logic nan_flag_g;
logic nan_flag_l;
logic inf_flag_g;
logic inf_flag_l;
logic sign_unequal;

logic [1:0] config_d;
logic signed [63:0] greater_num_d;
logic signed [63:0] lesser_num_d;

logic [1:0] config_d2;
logic [7:0] expon_g_d;
logic [7:0] expon_l_d;
logic sign_sum_d;
logic nan_flag;
logic inf_flag;

logic [1:0] config_d3;
logic sign_sum_d2;
logic nan_flag_d;
logic inf_flag_d;

logic [7:0] expon_sum_pre;
logic [7:0] expon_sum_post_1;
logic [7:0] expon_sum_post_2;
logic signed [48:0] mant_sum_pre;
logic [24:0] mant_sum_post;

logic [48:0] inter_mantissa;
logic [5:0] shifts_iter;
logic [5:0] shifts_final;
logic [7:0] expon_stored;
logic [5:0] shifts_stored;
logic signed [48:0] mant_stored;
logic [48:0] mant_proc;
logic shift_fac_stored;
logic shift_fac_stored_d;
logic signed [48:0] mant_sum_st;
logic [7:0] expon_sum_st;
`ifdef TIMING
    logic [31:0] i_a;
    logic [31:0] i_b;
    logic [1:0]  i_config;
`endif

always_ff @(posedge i_clk) begin
    `ifdef TIMING
        i_a      <= i_a_in;
        i_b      <= i_b_in;
        i_config <= i_config_in;
    `endif

    sign_unequal <= i_a[31] ^ i_b[31];

    config_d <= i_config;
    if (!i_config) begin
        greater_num_d <= greater_num;
        lesser_num_d <= lesser_num;
    end else begin
        greater_num_d[63] <= greater_num[31];
        lesser_num_d[63] <= lesser_num[31];
        greater_num_d[62:60] <= 3'd0;
        lesser_num_d[62:60] <= 3'd0;
        greater_num_d[59:52] <= greater_num[30:23];
        lesser_num_d[59:52] <= lesser_num[30:23];
        greater_num_d[51:48] <= 4'd0;
        lesser_num_d[51:48] <= 4'd0;
        greater_num_d[47:0] <= {(|greater_num[30:23]), greater_num[22:0], {24{1'b0}}};
        lesser_num_d[47:0] <= ({(|lesser_num[30:23]), lesser_num[22:0], {24{1'b0}}} >> (greater_num[30:23] - (|greater_num[30:23]) - lesser_num[30:23] + (|lesser_num[30:23])));
    end

    config_d2 <= config_d;
    sign_sum_d <= ((inf_flag_g && inf_flag_l && sign_unequal) || nan_flag_g) ? 1'b0 : greater_num_d[63];
    expon_g_d <= greater_num_d[59:52];
    expon_l_d <= lesser_num_d[59:52];
    nan_flag <= (nan_flag_g) || (inf_flag_g && inf_flag_l && sign_unequal);
    inf_flag <= inf_flag_g && ((!inf_flag_l) || (inf_flag_l && (!sign_unequal)));

    config_d3 <= config_d2;
    sign_sum_d2 <= sign_sum_d;
    nan_flag_d <= nan_flag;
    inf_flag_d <= inf_flag;

    if (config_d3) begin
        o_c <= {sign_sum_d2, expon_sum_post_2, mant_sum_post[22:0]};
        if(!mant_sum_post) o_c <= 32'd0;
        if(inf_flag_d || &expon_sum_post_2) o_c[30:0] <= {{8{1'b1}}, {23{1'b0}}};
        if(nan_flag_d) o_c[30:0] <= {31{1'b1}};
    end else begin
        o_c <= mant_sum_st[31:0];
    end

    if (i_rst) begin
        sign_unequal <= 1'b0;
        config_d <= 2'b00;
        greater_num_d <= 64'd0;
        lesser_num_d <= 64'd0;
        config_d2 <= 2'b00;
        sign_sum_d <= 1'b0;
        expon_g_d <= 8'd0;
        expon_l_d <= 8'd0;
        nan_flag <= 1'b0;
        inf_flag <= 1'b0;
        config_d3 <= 2'b00;
        sign_sum_d2 <= 1'b0;
        nan_flag_d <= 1'b0;
        inf_flag_d <= 1'b0;
        o_c <= 32'd0;
    end
end

always_comb begin
    if (i_config) begin
        greater_num = (i_a[30:0] >= i_b[30:0])? i_a: i_b;
        lesser_num = (i_a[30:0] >= i_b[30:0])? i_b: i_a;
    end else begin
        greater_num = ($signed(i_a) >= $signed(i_b))? $signed(i_a): $signed(i_b);
        lesser_num = ($signed(i_a) >= $signed(i_b))? $signed(i_b): $signed(i_a);
    end
    if (config_d) begin
        nan_flag_g = (&greater_num_d[59:52]) && (|greater_num_d[46:24]);
        nan_flag_l = (&lesser_num_d[59:52]) && (|lesser_num_d[46:24]);
        inf_flag_g = (&greater_num_d[59:52]) && (!(|greater_num_d[46:24]));
        inf_flag_l = (&lesser_num_d[59:52]) && (!(|lesser_num_d[46:24]));
    end else begin
        nan_flag_g = 0;
        nan_flag_l = 0;
        inf_flag_g = 0;
        inf_flag_l = 0;
    end
    if (config_d3) expon_sum_post_2 = expon_sum_st + (mant_sum_post[24:23]);
    else expon_sum_post_2 = 0;
end

always_comb begin
    if (config_d) begin
        expon_sum_pre = greater_num_d[59:52];
        if (sign_unequal) mant_sum_pre = greater_num_d[47:0] - lesser_num_d[47:0];
        else mant_sum_pre = greater_num_d[47:0] + lesser_num_d[47:0];
        inter_mantissa = mant_sum_pre;
        shifts_final = 48;
        for (shifts_iter = 49; shifts_iter > 1; shifts_iter = (shifts_iter >> 1) + shifts_iter[0]) begin
            shifts_final = shifts_final;
            inter_mantissa = inter_mantissa;
            if (inter_mantissa >> ((shifts_iter >> 1) + shifts_iter[0])) inter_mantissa >>= (shifts_iter >> 1);
            else shifts_final -= (shifts_iter >> 1);
        end
    end else begin
        expon_sum_pre = 0;
        mant_sum_pre = $signed(greater_num_d[31:0]) + $signed(lesser_num_d[31:0]);
        inter_mantissa = 0;
        shifts_final = 0;
    end
    if (config_d2) begin
        if (expon_stored < 48 - shifts_stored) mant_proc = mant_stored << expon_stored;
        else mant_proc = mant_stored << (48 - shifts_stored);
        if (expon_stored < 48 - shifts_stored) expon_sum_post_1 = 0;
        else expon_sum_post_1 = expon_stored - 48 + shifts_stored;
    end else begin
        mant_proc = mant_stored;
        expon_sum_post_1 = 0;
    end
    if (config_d3) begin
        if (config_d3[0]) begin
            if (shift_fac_stored_d) mant_sum_post = {mant_sum_st[47:40], 16'd0} + ((mant_sum_st[40]? (mant_sum_st[39:0]>={1'b1,{39{1'b0}}}): (mant_sum_st[39:0]>{1'b1,{39{1'b0}}})) << 16);
            else mant_sum_post = {1'b0, mant_sum_st[48:41], 16'd0} + ((mant_sum_st[41]? (mant_sum_st[40:0]>={1'b1, {40{1'b0}}}): (mant_sum_st[40:0]>{1'b1, {40{1'b0}}})) << 16);
        end else begin
            if (shift_fac_stored_d) mant_sum_post = mant_sum_st[47:24] + (mant_sum_st[24]? (mant_sum_st[23:0]>={1'b1,{23{1'b0}}}): (mant_sum_st[23:0]>{1'b1,{23{1'b0}}}));
            else mant_sum_post = {1'b0, mant_sum_st[48:25]} + (mant_sum_st[25]? (mant_sum_st[24:0]>={1'b1, {24{1'b0}}}): (mant_sum_st[24:0]>{1'b1, {24{1'b0}}}));
        end
    end else begin
        mant_sum_post = 0;
    end
end

always_ff @(posedge i_clk) begin
    mant_stored <= mant_sum_pre;
    shifts_stored <= shifts_final;
    expon_stored <= expon_sum_pre;
    shift_fac_stored <= (!greater_num_d[59:52]) && (!lesser_num_d[59:52]);

    shift_fac_stored_d <= shift_fac_stored;
    mant_sum_st <= mant_proc;
    expon_sum_st <= expon_sum_post_1;
    if (i_rst) begin
        mant_stored <= {49{1'b0}};
        shifts_stored <= {5{1'b0}};
        expon_stored <= {8{1'b0}};
        shift_fac_stored <= 1'b0;

        shift_fac_stored_d <= 1'b0;
        mant_sum_st <= {49{1'b0}};
        expon_sum_st <= {8{1'b0}};
    end
end

endmodule
