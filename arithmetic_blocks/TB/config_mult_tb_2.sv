`timescale 1ns / 1ps

module config_mult_tb_2;
    logic i_clk;
    logic i_rst;
    logic [1:0] i_config;
    logic [31:0] i_a;
    logic [31:0] i_b;
    logic [31:0] o_c;
    localparam realtime PERIOD = 10;

    config_mult uut (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_a(i_a),
        .i_b(i_b),
        .i_config(i_config),
        .o_c(o_c)
    );

    initial i_clk <= 0;
    always #(PERIOD / 2) i_clk <= ~i_clk;

    int fd;

    initial begin
        fd = $fopen("/home/iitg/TPU/TB/stimuli.txt", "r");
        if (fd == 0) begin
            $display("Failed to open stimuli file.");
            $finish;
        end
    end

    logic [31:0] a, b, c;
    logic [31:0] golden_result;

    initial begin
        i_rst <= 1;
        i_a <= 0;
        i_b <= 0;
        golden_result <= 0;
        i_config <= 2'b10; // FP32
        repeat(2) @(posedge i_clk);
        i_rst <= 0;
        for (int i = 0; i < 5000; i++) begin
            $fscanf(fd, "%h %h %h\n", a, b, c);
            i_a <= a;
            i_b <= b;
            golden_result <= c;
            @(posedge i_clk);
        end
        i_rst <= 1;
        i_a <= 0;
        i_b <= 0;
        golden_result <= 0;
        i_config <= 2'b01; // BF16
        repeat(2) @(posedge i_clk);
        i_rst <= 0;
        for (int i = 5000; i < 10000; i++) begin
            $fscanf(fd, "%h %h %h\n", a, b, c);
            i_a <= a;
            i_b <= b;
            golden_result <= c;
            @(posedge i_clk);
        end
        i_rst <= 1;
        i_a <= 0;
        i_b <= 0;
        golden_result <= 0;
        i_config <= 2'b00; // INT32
        repeat(2) @(posedge i_clk);
        i_rst <= 0;
        for (int i = 10000; i < 10000 + (32*32*10); i++) begin
            $fscanf(fd, "%h %h %h\n", a, b, c);
            i_a <= a;
            i_b <= b;
            golden_result <= c;
            @(posedge i_clk);
        end
        repeat(30) @(posedge i_clk);
        $fclose(fd);
        $finish;
    end

    localparam LAT = 3;

    logic [31:0] golden_result_d [LAT];
    logic [1:0] config_d [LAT];

    always @(posedge i_clk) begin
        for (int i = 0; i < LAT; i++) begin
            golden_result_d[i] <= i_rst ? 32'd0 : ((i == 0) ? golden_result : golden_result_d[i-1]);
            config_d[i] <= i_rst ? 2'b00 : ((i == 0) ? i_config : config_d[i-1]);
        end
    end

    logic match;

    always_comb begin
        if (config_d[LAT-1]) begin
            match = $bitstoshortreal(golden_result_d[LAT-1]) == $bitstoshortreal(o_c);
            if ((golden_result_d[LAT-1][30:0] > {{8{1'b1}}, {23{1'b0}}}) && (o_c[30:0] > {{8{1'b1}}, {23{1'b0}}})) match = 1'b1;
        end else begin
            match = golden_result_d[LAT-1] == o_c;
        end
    end

    initial begin
        $dumpfile("config_mult_tb_2.vcd");
        $dumpvars(0, config_mult_tb_2);
    end

endmodule
