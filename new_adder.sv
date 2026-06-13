`timescale 1ns / 1ps
//`define TIMING

module new_adder #(
    parameter EXP_BITS = 8,
    parameter MANT_BITS = 23,
    parameter BF16_MANT_BITS = 7, 
    parameter INT_BITS = 32
)(
    `ifdef TIMING
        input logic [EXP_BITS + MANT_BITS:0] a_in,
        input logic [EXP_BITS + MANT_BITS:0] b_in,
        input logic [1:0] type_sel_in,  
    `endif
    `ifndef TIMING
        input logic [EXP_BITS + MANT_BITS:0] a,
        input logic [EXP_BITS + MANT_BITS:0] b,
        input logic [1:0] type_sel,
    `endif
    input logic i_clk,
    input logic i_rst,
    output logic [EXP_BITS + MANT_BITS:0] c
);
parameter FP_32=0 , BF_16=1, INT=2;

logic [EXP_BITS + MANT_BITS:0] greater_num;
logic [EXP_BITS + MANT_BITS:0] lesser_num;
logic [EXP_BITS - 1:0] expon_g;
logic [EXP_BITS - 1:0] expon_l;
logic [EXP_BITS - 1:0] expon_g_d;
logic [EXP_BITS - 1:0] expon_l_d;
logic [1:0] data_type; 
logic [MANT_BITS*2 + 1:0] mant_g;
logic [MANT_BITS*2 + 1:0] mant_l;
logic [EXP_BITS - 1:0] expon_sum_pre;
logic [EXP_BITS - 1:0] expon_sum_post_1;
logic [EXP_BITS - 1:0] expon_sum_post_2;
logic [MANT_BITS*2 + 2:0] mant_sum_pre;
logic [MANT_BITS+1 :0] mant_sum_post;
logic [BF16_MANT_BITS+1 :0] bf16_mant_sum_post;
logic sign_sum;
logic sign_sum_d;
logic sign_sum_d2;
logic nan_flag;
logic nan_flag_d;
logic inf_flag;
logic inf_flag_d;
logic nan_flag_g;
logic nan_flag_l;
logic inf_flag_g;
logic inf_flag_l;
logic sign_unequal;
logic [MANT_BITS*2 + 2:0] inter_mantissa;
logic [$clog2(MANT_BITS*2 + 4) - 1:0] shifts_iter;
logic [$clog2(MANT_BITS*2 + 4) - 1:0] shifts_final;
logic [EXP_BITS - 1:0] expon_stored;
logic [$clog2(MANT_BITS*2 + 4) - 1:0] shifts_stored;
logic [MANT_BITS*2 + 2:0] mant_stored;
logic [MANT_BITS*2 + 2:0] mant_proc;
logic shift_fac_stored;
logic shift_fac_stored_d;
logic [MANT_BITS*2 + 2:0] mant_sum_st;
logic [INT_BITS-1:0] mant_sum_st_int;
logic [1:0] data_type_st; 
logic [EXP_BITS - 1:0] expon_sum_st;
`ifdef TIMING
    logic [EXP_BITS + MANT_BITS:0] a;
    logic [EXP_BITS + MANT_BITS:0] b;
    logic [1:0] type_sel; 
`endif

always_ff @(posedge i_clk) begin
    `ifdef TIMING
        a <= a_in;
        b <= b_in;
        type_sel <= type_sel_in; 
    `endif
    sign_unequal <= a[EXP_BITS + MANT_BITS] ^ b[EXP_BITS + MANT_BITS];
    expon_g <= greater_num[MANT_BITS +: EXP_BITS];
    sign_sum <= greater_num[EXP_BITS + MANT_BITS];
    expon_l <= lesser_num[MANT_BITS +: EXP_BITS];
    data_type <= type_sel; 
    mant_g <= (type_sel == INT) ? greater_num[INT_BITS-2:0] : {(|greater_num[MANT_BITS +: EXP_BITS]), greater_num[MANT_BITS - 1:0], {(MANT_BITS+1){1'b0}}};

    mant_l <= (type_sel == INT) ? lesser_num[INT_BITS-2:0] : ({(|lesser_num[MANT_BITS +: EXP_BITS]), lesser_num[MANT_BITS - 1:0], {(MANT_BITS+1){1'b0}}} >> 
              (greater_num[MANT_BITS +: EXP_BITS] - (|greater_num[MANT_BITS +: EXP_BITS]) - 
               lesser_num[MANT_BITS +: EXP_BITS] + (|lesser_num[MANT_BITS +: EXP_BITS])));

    sign_sum_d <= ((inf_flag_g && inf_flag_l && sign_unequal) || nan_flag_g) ? 1'b0 : sign_sum;
    sign_sum_d2 <= sign_sum_d;
    expon_g_d <= expon_g;
    expon_l_d <= expon_l;
    nan_flag <= (nan_flag_g) || (inf_flag_g && inf_flag_l && sign_unequal);
    nan_flag_d <= nan_flag;
    inf_flag <= inf_flag_g && ((!inf_flag_l) || (inf_flag_l && (!sign_unequal)));
    inf_flag_d <= inf_flag;
    c <= (data_type_st == INT) ? {sign_sum_d2, mant_sum_st_int} : (data_type_st == FP32) ? {sign_sum_d2, expon_sum_post_2, mant_sum_post[MANT_BITS-1:0]} 
    : {sign_sum_d2, expon_sum_post_2, bf16_mant_sum_post[BF16_MANT_BITS-1:0], {(INT_BITS - BF16_MANT_BITS - EXP_BITS -1){1'b0}}} ;
    if(!mant_sum_post) c<= {(EXP_BITS + MANT_BITS + 1){1'b0}};
    if(inf_flag_d || &expon_sum_post_2) c[EXP_BITS + MANT_BITS - 1:0] <= {{EXP_BITS{1'b1}}, {MANT_BITS{1'b0}}};
    if(nan_flag_d) c[EXP_BITS + MANT_BITS - 1:0] <= {(EXP_BITS+MANT_BITS){1'b1}};
    if (i_rst) begin
        sign_unequal <= 1'b0;
        expon_g <= {EXP_BITS{1'b0}};
        sign_sum <= 1'b0;
        sign_sum_d2 <= 1'b0;
        expon_l <= {EXP_BITS{1'b0}};
        mant_g <= {MANT_BITS{1'b0}};
        mant_l <= {MANT_BITS{1'b0}};
        sign_sum_d <= 1'b0;
        c <= {(EXP_BITS + MANT_BITS + 1){1'b0}};
        expon_g_d <= {EXP_BITS{1'b0}};
        expon_l_d <= {EXP_BITS{1'b0}};
        nan_flag <= 1'b0;
        inf_flag <= 1'b0;
        nan_flag_d <= 1'b0;
        inf_flag_d <= 1'b0;
    end
end

always_comb begin
    greater_num = (a[EXP_BITS + MANT_BITS - 1:0] >= b[EXP_BITS + MANT_BITS - 1:0])? a: b;
    lesser_num = (a[EXP_BITS + MANT_BITS - 1:0] >= b[EXP_BITS + MANT_BITS - 1:0])? b: a;
    nan_flag_g = (&expon_g) && (|mant_g[MANT_BITS*2 -: MANT_BITS]);
    nan_flag_l = (&expon_l) && (|mant_l[MANT_BITS*2 -: MANT_BITS]);
    inf_flag_g = (&expon_g) && (!(|mant_g[MANT_BITS*2 -: MANT_BITS]));
    inf_flag_l = (&expon_l) && (!(|mant_l[MANT_BITS*2 -: MANT_BITS]));
    expon_sum_post_2 = expon_sum_st + (mant_sum_post[MANT_BITS+:2]);
end

always_comb begin
    expon_sum_pre = expon_g;
    if (sign_unequal) mant_sum_pre = mant_g - mant_l;
    else mant_sum_pre = mant_g + mant_l;
    inter_mantissa = mant_sum_pre;
    shifts_final = MANT_BITS*2 + 2;
    for (shifts_iter = MANT_BITS*2 + 3; shifts_iter > 1; shifts_iter = (shifts_iter >> 1) + shifts_iter[0]) begin
        shifts_final = shifts_final;
        inter_mantissa = inter_mantissa;
        if (inter_mantissa >> ((shifts_iter >> 1) + shifts_iter[0])) inter_mantissa >>= (shifts_iter >> 1);
        else shifts_final -= (shifts_iter >> 1);
    end
    if (expon_stored < MANT_BITS*2 + 2 - shifts_stored) mant_proc = mant_stored << expon_stored;
    else mant_proc = mant_stored << (MANT_BITS*2 + 2- shifts_stored);
    if (expon_stored < MANT_BITS*2 + 2 - shifts_stored) expon_sum_post_1 = 0;
    else expon_sum_post_1 = expon_stored - MANT_BITS*2 - 2 + shifts_stored;

    mant_sum_post = {1'b0, mant_sum_st[MANT_BITS*2 + 2 : MANT_BITS + 2]} + (
        mant_sum_st[MANT_BITS+2]? (mant_sum_st[MANT_BITS+1:0]>={1'b1,{(MANT_BITS+1){1'b0}}}): 
        (mant_sum_st[MANT_BITS+1:0]>{1'b1,{(MANT_BITS+1){1'b0}}}));
    if (shift_fac_stored_d) mant_sum_post = mant_sum_st[MANT_BITS*2 + 1 : MANT_BITS + 1] + 
        (mant_sum_st[MANT_BITS+1]? (mant_sum_st[MANT_BITS:0]>={1'b1,{(MANT_BITS){1'b0}}}): 
        (mant_sum_st[MANT_BITS:0]>{1'b1,{(MANT_BITS){1'b0}}}));

    bf16_mant_sum_post = {1'b0, mant_sum_st[MANT_BITS*2 + 2 : (MANT_BITS*2 + 2) - BF16_MANT_BITS]} + (
        mant_sum_st[(MANT_BITS*2 + 2) - BF16_MANT_BITS]? (mant_sum_st[(MANT_BITS*2 + 2) - BF16_MANT_BITS -1:0]>={1'b1,{((MANT_BITS*2 + 2) - BF16_MANT_BITS -1){1'b0}}}): 
        (mant_sum_st[(MANT_BITS*2 + 2) - BF16_MANT_BITS -1:0]>{1'b1,{((MANT_BITS*2 + 2) - BF16_MANT_BITS -1){1'b0}}}));
    if (shift_fac_stored_d) bf16_mant_sum_post = mant_sum_st[MANT_BITS*2 + 1 : (MANT_BITS*2 + 2) - BF16_MANT_BITS -1] + 
        (mant_sum_st[(MANT_BITS*2 + 2) - BF16_MANT_BITS -1]? (mant_sum_st[(MANT_BITS*2 + 2) - BF16_MANT_BITS - 2:0]>={1'b1,{((MANT_BITS*2 + 2) - BF16_MANT_BITS - 2){1'b0}}}): 
        (mant_sum_st[(MANT_BITS*2 + 2) - BF16_MANT_BITS - 2 :0]>{1'b1,{((MANT_BITS*2 + 2) - BF16_MANT_BITS - 2){1'b0}}}));
end

always_ff @(posedge i_clk) begin
    data_type_stored <= data_type; 
    mant_stored <= mant_sum_pre;
    shifts_stored <= shifts_final;
    expon_stored <= expon_sum_pre;
    shift_fac_stored <= (!expon_g) && (!expon_l);
    shift_fac_stored_d <= shift_fac_stored;
    mant_sum_st <= mant_proc;
    mant_sum_st_int <= mant_stored;
    data_type_st <= data_type_stored;  
    expon_sum_st <= expon_sum_post_1;
    if (i_rst) begin
        mant_stored <= {(2*MANT_BITS + 3){1'b0}};
        shifts_stored <= {$clog2(MANT_BITS*2 + 3){1'b0}};
        expon_stored <= {EXP_BITS{1'b0}};
        shift_fac_stored <= 1'b0;
        shift_fac_stored_d <= 1'b0;
        mant_sum_st <= {(2*MANT_BITS + 3){1'b0}};
        expon_sum_st <= {EXP_BITS{1'b0}};
    end
end

endmodule