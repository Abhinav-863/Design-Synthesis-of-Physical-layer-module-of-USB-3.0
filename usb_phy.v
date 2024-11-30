/*USB3.0 Physical Layer consist of two main block transmitter and receiver. It uses 8b/10b Encoder and Decoder for data integrity
it uses DPLL and data recovery on receiver side to synchronized data to the local clock. It uses the FIFO for data bursting on
the receiver side.*/
`timescale 1ns/100ps

module usb_phy (
    input [7:0] TX_DATA,
    input TX_DATAK,
    input [1:0] PHY_POWERDOWN,
    input [1:0] PHY_MODE,
    input PHY_CLK, 
    input PHY_RST, 
    input TX_ELECIDLE, 
    input PHY_CLR, 
    input RX_POLARITY,
    input PHY_RATE, 
    input RX_RINC, 
    input RX_WINC,
    output [7:0] RX_DATA,
    output RX_DATAK,
    output [2:0] RX_STATUS,
    output wire RX_VALID,
    output wire PHY_PCLK, 
    output wire PHY_STATUS
);

    wire TX_125, TX_250, BIT_CLK, DIV_CLK, DIV_CLK2;
    wire [9:0] temp_out;
    wire DP;
    wire rec_clk;
    wire sync_data;
    wire [9:0] parallel_data;
    wire [1:0] Rx_wr_status, Rx_rd_status;
    wire [9:0] temp_rdata, temp_data_buf, encode_data, TEMP_ENC, w_data;
    wire status_full, status_empty, fifowfull, fiforempty;

    usb_aasd phy_aasd (
        .rst_out(RST),
        .rst(PHY_RST),
        .clk(PHY_CLK)
    );

    // Transmitter

    // Clock generator to generate 125MHz, 250MHz, and 2.5GHz clock
    usb_clock_gen phy_clock_gen (
        .pclk_125(TX_125),
        .pclk_250(TX_250),
        .bit_rate_clk(BIT_CLK),
        .clk(PHY_CLK),
        .rst(RST)
    );

    // Determines PCLK frequency based on PHY mode and rate
    usb_data_rate phy_data_rate (
        .PCLK(PHY_PCLK),
        .DATA_STATUS(PHY_STATUS),
        .DATA_CLK_125(TX_125),
        .DATA_CLK_250(TX_250),
        .DATA_BIT_CLK(BIT_CLK),
        .DATA_RST(RST),
        .DATA_POWER(PHY_POWERDOWN),
        .TXELECIDLE(TX_ELECIDLE),
        .DATA_MODE(PHY_MODE),
        .DATA_RATE(PHY_RATE)
    );

    // 8b/10b encoder for 10b DC balanced encoded data
    usb_encoder phy_encoder (
        .ENC_OUT(temp_out),
        .ENC_CLK(DIV_CLK),
        .ENC_RST(RST),
        .KI(TX_DATAK), 
        .ENC_IN(TX_DATA)
    );

    assign TEMP_ENC = temp_out;

    usb_clock_div phy_clock_div (
        .BITCLK_10(DIV_CLK),
        .CLK(BIT_CLK),
        .RST(RST)
    );

    // Converts 10b parallel data to serial data
    usb_partoserial phy_partoserial (
        .SerialOut(DP),
        .Serialclk(DIV_CLK),
        .SerialBit(BIT_CLK),
        .SerialRST(RST),
        .Parin(TEMP_ENC)
    );

    // Receiver

    // Clock and Data Recovery
    usb_dpll_2 phy_dpll (
        .DPLL_OUT(rec_clk),
        .REF_IN(DP),
        .SYS_CLK(PHY_CLK),
        .DPLL_RESET(RST)
    );

    // Serial to Parallel conversion
    usb_sertopar phy_sertopar (
        .Parout(parallel_data),
        .clk(rec_clk),
        .rst(RST),
        .Serialin(DP)
    );

    // Captures 10-bit data
    usb_clock_div phy_clock_div2 (
        .BITCLK_10(DIV_CLK2),
        .CLK(rec_clk),
        .RST(RST)
    );

    // Performs RX polarity inversion
    usb_dff phy_dff (
        .out(w_data),
        .clk(DIV_CLK2),
        .rst(RST),
        .in(parallel_data),
        .inv(RX_POLARITY)
    );

    // For data bursting
    usb_fifo #(
        .DSIZE(10), 
        .ASIZE(8)
    ) phy_fifo (
        .rdata(temp_rdata),
        .wfull(fifowfull),
        .rempty(fiforempty),
        .wdata(w_data),
        .winc(RX_WINC),
        .wclk(DIV_CLK2),
        .wrst_n(~RST),
        .rinc(RX_RINC),
        .rclk(TX_125),
        .rrst_n(~RST)
    );

    assign temp_data_buf = temp_rdata;
    assign status_full = fifowfull;
    assign status_empty = fiforempty;

    // Generates appropriate RxStatus
    usb_rx_status phy_rx_status (
        .RxStatus(RX_STATUS),
        .RxValid(RX_VALID),
        .clk(TX_125),
        .rst(RST),
        .BUFF_full(status_full),
        .BUFF_empty(status_empty),
        .DataBuffer(temp_data_buf)
    );

    // Decodes 10b data into 8-bit data
    assign encode_data = temp_data_buf;
    usb_decode rx_decode (
        .DECODE_OUT(RX_DATA),
        .KO(RX_DATAK),
        .DEC_CLK(TX_125),
        .DEC_RST(RST),
        .DATA_IN(encode_data)
    );

endmodule
