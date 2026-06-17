module spi_controller #(
    parameter SPI_MODE = 0,
    parameter CLKS_PER_HALF = 2; 
    
)(
    // Control Signals
    input logic clk,
    input logic rst,   

    // TX (PICO) Signals 
    input logic tx_dv_in, 
    input logic [7:0] tx_data_in, 
    output logic tx_ready, 

    // RX (POCI) Signals 
    output logic rx_dv, 
    output logic [7:0] rx_data_out, 

    // SPI Signals
    input logic poci_bit_in, 
    output logic pico_bit_out, 
    output logic spi_clk_out  

);

// Wires and Interfaces 

// SPI Clock Polarity and Phase based on SPI mode 
logic CPOL; 
logic CPHA;

// SPI Clock generation signals 
logic [4:0] spi_clk_edges;  
logic spi_clk; 
logic [($clog2(CLKS_PER_HALF)*2)-1:0] clk_count; 
logic leading_edge; 
logic trailing_edge; 

// Registering TX Data
logic [7:0] tx_data; 
logic tx_dv; 

// PICO Generation Signals 
logic [2:0] tx_bit_count; 

// POCI Generation Signals
logic [2:0] rx_bit_count; 


assign CPOL = (SPI_MODE == 2) | (SPI_MODE == 3);

assign CPHA = (SPI_MODE == 1) | (SPI_MODE == 3);

// Generating SPI Clock Signal
always_ff @(posedge clk or negedge rst) begin 
    if (~rst) begin 
        spi_clk <= CPOL; 
        spi_clk_edges <= 0; 
        clk_count <= 0;
        tx_ready <= 1;  

    end 
    else begin 

        if (tx_dv) begin 
            tx_ready <= 0; 
            spi_clk_edges <= 16; // 16 edges for byte 
        end

        // Default Assignments 
        trailing_edge <= 0; 
        leading_edge <= 0; 

        else if (spi_clk_edges>0) begin 
            tx_ready <= 0; 

            if (clk_count == (CLKS_PER_HALF*2) -1)
            begin 
                spi_clk_edges <= spi_clk_edges - 1; 
                clk_count <= 0; 
                trailing_edge <= 1; 
                spi_clk <= ~spi_clk;
            end

            else if (clk_count == (CLKS_PER_HALF) -1)
            begin 
                spi_clk_edges <= spi_clk_edges - 1; 
                clk_count <= clk_count + 1;  
                leading_edge <= 1; 
                spi_clk <= ~spi_clk;
            end

            else clk_count <= clk_count +1; 

        end 

        else tx_ready <= 1; 

    end     

end  

// Register TX Data Input on TX_DV pulse 
always_ff @(posedge clk or negedge rst) begin 
    if (~rst) begin
        tx_data <= 0; 
        tx_dv <= 0; 
    end

    else begin
        tx_dv <= tx_dv_in; 
        if (tx_dv_in) begin
            tx_data <= tx_data_in; 
        end
    end
end

// TX (PICO) 
always_ff @(posedge clk or negedge rst) begin 
    if (~rst) begin 
        tx_bit_count <= 3'b111; 
        pico_bit_out <= 0; 
    end

    else begin 
        if (tx_ready) begin
            tx_bit_count <= 3'b111; 
        end

        else if (tx_dv && ~CPHA) begin
            pico_bit_out <= tx_data[3'b111]; 
            tx_bit_count <= 3'b110; 
        end
        else if ((leading_edge && CPHA) | (trailing_edge && ~CPHA)) begin
            pico_bit_out <= tx_data[tx_bit_count]; 
            tx_bit_count <= tx_bit_count -1 ; 
        end
    end

end


// RX (POCI)
always_ff @(posedge clk or negedge rst) begin
    if (~rst) begin
        rx_bit_count <= 3'b111; 
        rx_data_out <= 0; 
        rx_dv <= 0; 
    end
    else begin
        // default assignments 
        rx_dv <= 0;  

        if (tx_ready) begin
            rx_bit_count <= 3'b111; 
        end
        else if ((leading_edge && ~CPHA) | (trailing_edge && CPHA)) begin
            rx_data_out[rx_bit_count] <= poci_bit_in; 
            rx_bit_count <= rx_bit_count -1 ; 
            if (rx_bit_count == 3'b000) begin
                rx_dv <= 0; // pulse valid when sample done 
            end
        end
    end
end

// Delay clock for alignment 
always_ff @(posedge clk or negedge rst) begin
    if (~rst) begin
        spi_clk_out <= CPOL; 
    end
    else begin
        spi_clk_out <= spi_clk; 
    end
end

endmodule : spi_controller 