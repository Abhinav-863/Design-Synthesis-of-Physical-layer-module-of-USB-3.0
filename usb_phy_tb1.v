`timescale 1ns/100ps
module usb_phy_tb1();
    wire [7:0] RX_DATA;
    wire RX_DATAK;
    wire [2:0] RX_STATUS;
    wire RX_VALID;
    wire PHY_PCLK, PHY_STATUS;
    reg [7:0] TX_DATA;
    reg TX_DATAK;
    reg [1:0] PHY_POWERDOWN;
    reg [1:0] PHY_MODE;
    reg PHY_CLK, PHY_RST, TX_ELECIDLE, PHY_CLR;
    reg PHY_RATE, RX_POLARITY;
    reg RX_RINC, RX_WINC;

    usb_phy uut(
        .RX_DATA(RX_DATA),
        .RX_DATAK(RX_DATAK),
        .RX_STATUS(RX_STATUS),
        .RX_VALID(RX_VALID),
        .PHY_PCLK(PHY_PCLK),
        .PHY_STATUS(PHY_STATUS),
        .PHY_CLK(PHY_CLK),
        .PHY_POWERDOWN(PHY_POWERDOWN),
        .TX_ELECIDLE(TX_ELECIDLE),
        .PHY_MODE(PHY_MODE),
        .PHY_RATE(PHY_RATE),
        .PHY_RST(PHY_RST),
        .TX_DATA(TX_DATA),
        .TX_DATAK(TX_DATAK),
        .RX_RINC(RX_RINC),
        .RX_WINC(RX_WINC),
        .PHY_CLR(PHY_CLR),
        .RX_POLARITY(RX_POLARITY)
    );

    initial begin
        $monitor ("%d TX_DATA=%h TX_DATAK=%h RX_STATUS=%b RX_VALID=%b RX_DATA=%h RX_DATAK=%h", $time, TX_DATA, TX_DATAK, RX_STATUS, RX_VALID, RX_DATA, RX_DATAK);
    end

    initial begin
        PHY_CLK <= 1'b0;
        forever #0.1 PHY_CLK <= ~PHY_CLK;
    end

    initial begin

        TX_DATA <= 8'h00; TX_DATAK <= 1'b0; RX_WINC <= 1'b0;
        RX_RINC <= 1'b0; PHY_CLR <= 1'b0; RX_POLARITY <= 1'b0;

        PHY_RST <= 1'b0; 
        #4 PHY_RST <= 1'b1;

        #4 PHY_POWERDOWN <= 2'b00; PHY_MODE <= 2'b00; TX_ELECIDLE <= 1'b1;
        PHY_RATE <= 1'b0;


        #20 PHY_RATE <= 1'b1;
        #20 PHY_POWERDOWN <= 2'b11;
        #20 PHY_POWERDOWN <= 2'b00; TX_ELECIDLE <= 1'b0;


        #4 TX_DATA <= 8'hBC; TX_DATAK <= 1'b1; RX_WINC <= 1'b1;
        #10 TX_DATA <= 8'hFF; TX_DATAK <= 1'b0;
        #8 TX_DATA <= 8'h17; TX_DATAK <= 1'b0;
        #8 TX_DATA <= 8'hC0; TX_DATAK <= 1'b0;
        

        #20 RX_POLARITY <= 1'b1;
        #10 TX_DATA <= 8'h14; TX_DATAK <= 1'b0;
        #8 TX_DATA <= 8'hA6; TX_DATAK <= 1'b0;
        #20 RX_POLARITY <= 1'b0;

        #120 $stop;
    end 
endmodule

