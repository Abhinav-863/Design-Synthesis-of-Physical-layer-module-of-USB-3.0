/*This module will generate PCLK depends upon DATA_RATE and DATA_POWER*/ 
`timescale 1ns/100ps
module usb_data_rate(
    input DATA_CLK_125,DATA_CLK_250,DATA_BIT_CLK,
    input DATA_RST,
    input [1:0]DATA_POWER,
    input TXELECIDLE,
    input [1:0]DATA_MODE,
    input DATA_RATE,
    output reg PCLK,
    output reg DATA_STATUS
    );

    always@(DATA_BIT_CLK or DATA_MODE or TXELECIDLE or DATA_POWER or DATA_RST or DATA_CLK_125 or DATA_CLK_250) begin
        if(!DATA_RST) begin
            PCLK=0;
            DATA_STATUS=0;
        end
        else if((DATA_POWER==2'b00) && (TXELECIDLE==1'b1) && (DATA_MODE==2'b00)) begin 
            if(!DATA_RATE) begin//2.5GT/s
                PCLK=DATA_CLK_125;
                DATA_STATUS=1'b1;
            end
            else if(DATA_RATE) begin//5.0GT/s
                PCLK=DATA_CLK_250;
                DATA_STATUS=1'b1;
            end
        end
        else if((DATA_POWER==2'b11) && (TXELECIDLE==1'b0)) begin
            PCLK=1'b0;
            DATA_STATUS=1'b1;
        end
        else begin 
            PCLK=DATA_BIT_CLK;
            DATA_STATUS=1'b0;
        end
    end

endmodule






