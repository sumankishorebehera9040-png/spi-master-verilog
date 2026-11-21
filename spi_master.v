module spi_master #(
    parameter CLK_DIV = 4 // SPI Clock = System Clock / (2*CLK_DIV)
)(
    input clk,
    input reset,
    input start,
    input [7:0] tx_data,
    output reg [7:0] rx_data,
    output reg sclk,
    output reg cs,
    output reg mosi,
    input miso,
    output reg done
);
    reg [1:0] state;
    reg [2:0] bit_cnt;
    reg [7:0] tx_shift, rx_shift;
    reg [3:0] clk_cnt;
    reg sclk_en;

    localparam IDLE = 0, TRANSFER = 1, FINISH = 2;

    // Clock Divider for SCLK
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_cnt <= 0;
            sclk <= 0;
        end else if (sclk_en) begin
            if (clk_cnt == CLK_DIV-1) begin
                clk_cnt <= 0;
                sclk <= ~sclk;
            end else clk_cnt <= clk_cnt + 1;
        end else begin
            clk_cnt <= 0;
            sclk <= 0;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE; cs <= 1; mosi <= 0; done <= 0; sclk_en <= 0;
        end else begin
            case(state)
                IDLE: begin
                    done <= 0; cs <= 1;
                    if (start) begin
                        tx_shift <= tx_data;
                        state <= TRANSFER; cs <= 0; bit_cnt <= 7; sclk_en <= 1;
                    end
                end
                TRANSFER: begin
                    if (sclk) begin // Falling edge - shift data
                        if (clk_cnt == CLK_DIV-1) begin
                            mosi <= tx_shift[7];
                            tx_shift <= {tx_shift[6:0], 1'b0};
                            rx_shift <= {rx_shift[6:0], miso};
                            if (bit_cnt == 0) begin
                                state <= FINISH; sclk_en <= 0;
                            end else bit_cnt <= bit_cnt - 1;
                        end
                    end
                end
                FINISH: begin
                    cs <= 1; done <= 1; rx_data <= rx_shift; state <= IDLE;
                end
            endcase
        end
    end
endmodule
