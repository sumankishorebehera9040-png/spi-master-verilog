module spi_master_tb;
    reg clk, reset, start;
    reg [7:0] tx_data;
    wire [7:0] rx_data;
    wire sclk, cs, mosi, done;
    reg miso;

    spi_master #(2) uut (clk, reset, start, tx_data, rx_data, sclk, cs, mosi, miso, done);

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; start = 0; tx_data = 8'hA5; miso = 1;
        #10 reset = 0;
        #10 start = 1; #10 start = 0;
        wait(done);
        #20 $finish;
    end
endmodule
