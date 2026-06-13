`timescale 1ns / 1ps

module mac_tb;
    logic clk;
    logic rst;
    logic [31:0] a, b;
    logic [31:0] mult_out;
    logic [31:0] mult_out_id [4];
    logic [31:0] add_in;
    logic [31:0] result;
    logic [31:0] result_id [4];

    new_mult #(
        .EXP_BITS(8),
        .MANT_BITS(23)
    ) mult (
        .i_clk(clk),
        .i_rst(rst),
        .i_a(a),
        .i_b(b),
        .o_c(mult_out)
    );

    always_ff @(posedge clk) add_in <= rst? 0 : mult_out;

    new_adder #(
        .EXP_BITS(8),
        .MANT_BITS(23)
    ) adder (
        .i_clk(clk),
        .i_rst(rst),
        .a(add_in),
        .b(result),
        .c(result)
    );

    always_ff @(posedge clk) for (int i = 0; i < 4; i++) mult_out_id[i] <= rst? 0 : (i? mult_out_id[i-1] : $shortrealtobits($bitstoshortreal(a) * $bitstoshortreal(b)));

    always_ff @(posedge clk) for (int i = 0; i < 4; i++) result_id[i] <= rst? 0 : (i? result_id[i-1] : $shortrealtobits($bitstoshortreal(mult_out_id[3]) + $bitstoshortreal(result_id[3])));

    initial clk <= 0;
    always #5 clk <= ~clk;

localparam shortreal wt_arr [32] = '{0.076052255929, -0.035930603743, 0.141532585025, 0.258624762297, 0.067935362458, -0.082801833749, -0.175906926394, -0.039734888822, -0.128790453076, 0.007115692366, 0.009712615050, 0.071617588401, 0.081238918006, 0.057765491307, 0.109296664596, 0.056321371347, -0.143605053425, 0.062957085669, 0.129513487220, 0.040467333049, -0.125606477261, 0.191378980875, 0.178689867258, 0.164247795939, 0.018591282889, 0.208242163062, 0.074161499739, -0.061187759042, -0.009034615941, -0.057726085186, 0.090619236231, -0.023138327524};

    initial begin
        rst <= 1;
        a <= 0;
        b <= 0;
        repeat(40) @(posedge clk);
        rst <= 0;
        a <= $shortrealtobits(wt_arr[0]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[1]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[2]);
        b <= 32'h3ddce984;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[3]);
        b <= 32'h3fcb592d;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[4]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[5]);
        b <= 32'h401ddec4;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[6]);
        b <= 32'h403be023;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[7]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[8]);
        b <= 32'h3fa0ce08;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[9]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[10]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[11]);
        b <= 32'h3ea3086e;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[12]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[13]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[14]);
        b <= 32'h3f827fd1;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[15]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[16]);
        b <= 32'h3fe651b4;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[17]);
        b <= 32'h3fbaf47f;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[18]);
        b <= 32'h3f980904;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[19]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[20]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[21]);
        b <= 32'h3f41ea7c;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[22]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[23]);
        b <= 32'h3e84ae88;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[24]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[25]);
        b <= 32'h3fa08eb3;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[26]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[27]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[28]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[29]);
        b <= 32'h3fba6561;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[30]);
        b <= 32'h00000000;
        repeat(4) @(posedge clk);
        a <= $shortrealtobits(wt_arr[31]);
        b <= 32'h3fa5f7d7;
        repeat(4) @(posedge clk);
        a <= 32'h00000000;
        b <= 32'h00000000;
        repeat(12) @(posedge clk);
        $finish;
    end

endmodule
