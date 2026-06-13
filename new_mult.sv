`timescale 1ns / 1ps
//`define TIMING

module new_mult#(
    parameter EXP_BITS = 8,         // Number of exponent bits for FP32 and BF16
    parameter MANT_BITS = 23,        // Number of mantissa bits for FP32
    parameter INT_BITS = 32,        // Number of bits for INT32 Data Type
    parameter BF16_MANT_BITS = 7    // Number of mantissa bits for BF16 Data Type
)(
    input i_clk,
    input i_rst,
    `ifdef TIMING
        input  [(EXP_BITS + MANT_BITS):0] i_a_in,  // Floating-point operand 1
        input  [(EXP_BITS + MANT_BITS):0] i_b_in,  // Floating-point operand 2
        input  [1:0] type_sel_in, // Data Type Selector 
    `endif
    `ifndef TIMING
        input  [(EXP_BITS + MANT_BITS):0] i_a,  // Floating-point operand 1
        input  [(EXP_BITS + MANT_BITS):0] i_b,  // Floating-point operand 2
        input  [1:0] type_sel, // Data Type Selector 
    `endif
    output logic [(EXP_BITS + MANT_BITS):0] o_c, // FP32 result
    output logic [INT_BITS-1:0] o_c_int,         // INT32 result
    output logic [(EXP_BITS + BF16_MANT_BITS):0] o_c_bf16 // BF16 result 
);
`ifdef TIMING
    logic [(EXP_BITS + MANT_BITS):0] i_a;
    logic [(EXP_BITS + MANT_BITS):0] i_b;
    logic [1:0] type_sel; 

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            i_a <= 'd0;
            i_b <= 'd0;
            type_sel <= 'd0;
        end else begin
            i_a <= i_a_in;
            i_b <= i_b_in;
            type_sel <= type_sel_in; 
        end
    end
`endif

parameter FP_32=0 , BF_16=1, INT=2;

logic [1:0] d_type; 
logic [2*(INT_BITS-1) - 1:0] mant_1;
logic [1:0] is_nan;
logic [1:0] is_inf;
logic [1:0] is_zero;
logic [EXP_BITS:0] exp_1; // Adjust bias
logic sign_1;
logic [INT_BITS-2:0] operand_1; 
logic [INT_BITS-2:0] operand_2; 

always_comb begin
    unique case(type_sel)
        
        FP_32: begin
            operand_1 = {(|i_a[MANT_BITS +: EXP_BITS]), i_a[MANT_BITS - 1:0],((INT_BITS-1)-(MANT_BITS+1)){1'b0}}; 
            operand_2 = {(|i_b[MANT_BITS +: EXP_BITS]), i_b[MANT_BITS - 1:0],((INT_BITS-1)-(MANT_BITS+1)){1'b0}};  
        end

        BF_16: begin
            operand_1 = {(|i_a[MANT_BITS +: EXP_BITS]), i_a[MANT_BITS - 1:0],((INT_BITS-1)-(MANT_BITS+1)){1'b0}}; 
            operand_2 = {(|i_b[MANT_BITS +: EXP_BITS]), i_b[MANT_BITS - 1:0],((INT_BITS-1)-(MANT_BITS+1)){1'b0}};  
        end

        INT: begin
            operand_1 = i_a[INT_BITS-2:0];
            operand_2 = i_b[INT_BITS-2:0];  
        end

    endcase
end

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        mant_1 <= {(2*MANT_BITS + 2){1'b0}};
        is_nan <= 2'd0;
        is_inf <= 2'd0;
        is_zero <= 2'd0;
        exp_1 <= {(EXP_BITS+1){1'b0}};
        sign_1 <= 1'b0;
        d_type <= 2'd0; 
    end else begin
        is_nan[0] <= (&i_a[MANT_BITS +: EXP_BITS]) && (|i_a[0 +: MANT_BITS]);
        is_nan[1] <= (&i_b[MANT_BITS +: EXP_BITS]) && (|i_b[0 +: MANT_BITS]);
        is_inf[0] <= (&i_a[MANT_BITS +: EXP_BITS]) && ~(|i_a[0 +: MANT_BITS]);
        is_inf[1] <= (&i_b[MANT_BITS +: EXP_BITS]) && ~(|i_b[0 +: MANT_BITS]);
        is_zero[0] <= ~(|i_a[0 +: (MANT_BITS+EXP_BITS)]);
        is_zero[1] <= ~(|i_b[0 +: (MANT_BITS+EXP_BITS)]);
        d_type <= type_sel; 
        mant_1 <= operand_1 * operand_2;
        sign_1 <= i_a[(EXP_BITS + MANT_BITS)] ^ i_b[(EXP_BITS + MANT_BITS)];
        exp_1 <= i_a[MANT_BITS +: EXP_BITS] + i_b[MANT_BITS +: EXP_BITS] + 
            {{(EXP_BITS-1){1'b0}}, (!i_a[MANT_BITS +: EXP_BITS])} + {{(EXP_BITS-1){1'b0}}, (!i_b[MANT_BITS +: EXP_BITS])};
    end
end

logic [2*(MANT_BITS + 1) - 1:0] inter_mantissa;
logic [$clog2(MANT_BITS*2 + 3) - 1:0] shifts_iter;
logic [$clog2(MANT_BITS*2 + 3) - 1:0] shifts_final;
logic [EXP_BITS:0] expon_stored;
logic [$clog2(MANT_BITS*2 + 3) - 1:0] shifts_stored;
logic [MANT_BITS*2 + 1:0] mant_stored;
logic [MANT_BITS*2 + 1:0] mant_proc;
logic [EXP_BITS:0] expon_prod_pre;
logic [MANT_BITS + 1: 0] mant_prod_pre;
logic [BF16_MANT_BITS + 1 : 0] bf16_mant_prod_pre; 
logic [1:0] is_nan_1;
logic [1:0] is_inf_1;
logic [1:0] is_zero_1;
logic sign_2;
logic [1:0] d_type_stored; 

always_comb begin
    inter_mantissa = mant_1[63:16];
    shifts_final = MANT_BITS*2 + 1;
    for (shifts_iter = MANT_BITS*2 + 2; shifts_iter > 1; shifts_iter = (shifts_iter >> 1) + shifts_iter[0]) begin
        shifts_final = shifts_final;
        inter_mantissa = inter_mantissa;
        if (inter_mantissa >> ((shifts_iter >> 1) + shifts_iter[0])) inter_mantissa >>= (shifts_iter >> 1);
        else shifts_final -= (shifts_iter >> 1);
    end
    mant_fp32_stored = mant_stored[63:16]; 
    if (expon_stored < (2**(EXP_BITS-1)) + MANT_BITS*2 - shifts_stored) begin
        if (expon_stored < (2**(EXP_BITS-1)) - 1)
            mant_proc = mant_fp32_stored >> ((2**(EXP_BITS-1)) - 1 - expon_stored);
        else mant_proc = mant_fp32_stored << (expon_stored - (2**(EXP_BITS-1)) + 1);
    end 
    else mant_proc = mant_fp32_stored << (MANT_BITS*2 + 1 - shifts_stored);


    if (expon_stored < (2**(EXP_BITS-1)) + MANT_BITS*2 - shifts_stored) 
        expon_prod_pre = {2'd0, {(EXP_BITS-1){1'b1}}};
    else expon_prod_pre = expon_stored - MANT_BITS*2 - 'd1 + shifts_stored;

    mant_prod_pre = mant_proc[MANT_BITS*2 + 1 : MANT_BITS + 1] + 
        (mant_proc[MANT_BITS+1]? (mant_proc[MANT_BITS:0] >= {1'b1,{(MANT_BITS){1'b0}}}): 
                                 (mant_proc[MANT_BITS:0] >  {1'b1,{(MANT_BITS){1'b0}}}));
                                 
    bf_16_mant_prod_pre = mant_proc[MANT_BITS*2 + 1 : ((MANT_BITS*2 + 1) - BF16_MANT_BITS)] + 
        (mant_proc[((MANT_BITS*2 + 1) - BF16_MANT_BITS)]? (mant_proc[((MANT_BITS*2) - BF16_MANT_BITS):0] >= {1'b1,{(((MANT_BITS*2) - BF16_MANT_BITS)){1'b0}}}): 
                                 (mant_proc[((MANT_BITS*2) - BF16_MANT_BITS):0] >  {1'b1,{(((MANT_BITS*2) - BF16_MANT_BITS)){1'b0}}}));
end

always_ff @(posedge i_clk) begin
    d_type_stored <= d_type; 
    mant_stored <= mant_1;
    shifts_stored <= shifts_final;
    expon_stored <= exp_1;
    is_nan_1 <= is_nan;
    is_inf_1 <= is_inf;
    is_zero_1 <= is_zero;
    sign_2 <= sign_1;
    if (i_rst) begin
        mant_stored <= {(2*MANT_BITS + 2){1'b0}};
        shifts_stored <= {$clog2(MANT_BITS*2 + 3){1'b0}};
        expon_stored <= {(EXP_BITS+1){1'b0}};
        is_nan_1 <= 2'd0;
        is_inf_1 <= 2'd0;
        is_zero_1 <= 2'd0;
        sign_2 <= 1'b0;
        d_type_stored <= d_type; 
    end
end

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        o_c <= {(EXP_BITS + MANT_BITS + 1){1'b0}};
    end else begin
        if (is_nan_1) o_c <= {sign_2, {(EXP_BITS + MANT_BITS){1'b1}}};
        else if (|is_zero_1 && !is_inf_1) o_c <= {sign_2, {(EXP_BITS + MANT_BITS){1'b0}}};
        else if ((&(is_inf_1^is_zero_1)) && (^is_zero_1)) o_c <= {1'b0, {(EXP_BITS + MANT_BITS){1'b1}}};
        else if (is_inf_1) o_c <= {sign_2, {EXP_BITS{1'b1}}, {(MANT_BITS){1'b0}}};
        else begin
            if (expon_prod_pre >= {2'd2, {(EXP_BITS-3){1'b1}}, 2'd1}) o_c <= {sign_2, {EXP_BITS{1'b1}}, {(MANT_BITS){1'b0}}};
            else begin
                o_c[EXP_BITS + MANT_BITS] <= sign_2;
                o_c[MANT_BITS +: EXP_BITS] <= expon_prod_pre - {1'b0, {(EXP_BITS-1){1'b1}}} + 
                {{(EXP_BITS-2){1'b0}}, mant_prod_pre[MANT_BITS +: 2]};
                o_c[MANT_BITS - 1 : 0] <= mant_prod_pre[MANT_BITS - 1:0];

                o_c_bf16[EXP_BITS + BF16_MANT_BITS] <= sign_2;
                o_c_bf16[BF16_MANT_BITS +: EXP_BITS] <= expon_prod_pre - {1'b0, {(EXP_BITS-1){1'b1}}} + 
                {{(EXP_BITS-2){1'b0}}, bf16_mant_prod_pre[BF16_MANT_BITS +: 2]};
                o_c_bf16[MANT_BITS - 1 : 0] <= bf16_mant_prod_pre[BF_MANT_BITS - 1:0];
            end
        end
        o_c_int <= (d_type_stored == INT) ? {sign_2 , mant_stored} : 32'd0; 

    end
end

endmodule