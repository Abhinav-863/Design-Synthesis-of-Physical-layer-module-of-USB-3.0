/* This module will generate PCLK with freqency 125MHz and 250MHz and generate BIT_CLK with 2.5GHz of frequency from 5.0GHz Sys_CLK.*/
`timescale 1ns/100ps
module usb_clock_gen(
    input clk,rst,
    output reg pclk_125,pclk_250,bit_rate_clk
    );

    reg [2:0]count_250;
    reg bist_2,bit_4,bit_6,bit_8;

    // to generate BIT_CLK with 2.5GHz
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            bit_rate_clk<=1'b0;
        end
        else begin 
            bit_rate_clk<=~bit_rate_clk;
        end
    end

    always@(posedge bit_rate_clk or negedge rst) begin
        if(!rst) begin
            count_250<=0;
        end
        else if(count_250==3'b100) begin
            count_250<=0;
        end
        else begin
            count_250<=count_250+1;
        end
    end

    // to generate PCLK with 250MHz
    always@(posedge bit_rate_clk or negedge rst)begin
        if(!rst) begin
            pclk_250<=1'b0;
        end
        else if (count_250==3'b100) begin
            pclk_250<=~pclk_250;
        end
        else begin
            pclk_250<=pclk_250;
        end
    end

    // to generate PCLK with 125MHz
    always@(posedge pclk_250 or negedge rst) begin
        if(!rst) begin
            pclk_125<=1'b0;
        end
        else begin
            pclk_125<=~pclk_125;
        end
    end

endmodule
