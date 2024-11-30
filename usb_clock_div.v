/*This module will generate clk for Parrallel to Serial conversion, As 10bit data are generated from 8b/10b encoder*/
`timescale 1ns/100ps
module usb_clock_div(
    input CLK,RST,
    output reg BITCLK_10
    );

    reg BITCLK;
    reg [2:0]temp_reg;

    always@(posedge CLK or negedge RST) begin
        if(!RST) begin
            BITCLK_10<=1'b0;
            temp_reg<=3'b0;
        end
        else begin
            if(temp_reg==3'b100) begin
                BITCLK_10<=~BITCLK_10;
                temp_reg<=3'b0;
            end
            else begin
                temp_reg<=temp_reg+1;
            end
        end
    end

endmodule

