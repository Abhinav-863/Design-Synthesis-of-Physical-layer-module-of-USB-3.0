/*This module is used to do Parallel to Serial conversion by accepting 10bit parallel data on BIT_CLK/10 and do the serial Conversion on BIT_CLK */
`timescale 1ns/100ps
module usb_partoserial(
    input Serialclk,SerialRST,SerialBit,
    input [9:0]Parin,
    output wire SerialOut
    );

    reg [9:0]temp_reg;

    always@(posedge Serialclk or negedge SerialRST) begin
        if(!SerialRST) begin 
            temp_reg<=0;
        end
        else begin
            temp_reg<=Parin;
        end
    end

    always@(posedge SerialBit or negedge SerialRST) begin
        if(!SerialRST) begin
            temp_reg<=0;
        end
        else begin
            temp_reg<={1'b0,temp_reg[9:1]};
        end
    end

    assign SerialOut=temp_reg[0];

endmodule

