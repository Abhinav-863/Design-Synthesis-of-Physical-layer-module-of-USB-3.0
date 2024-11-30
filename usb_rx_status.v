//This module is used to generate appropriate RxStatus according to received parallel data
`timescale 1ns/100ps
module usb_rx_status(
    input clk,rst,BUFF_full,BUFF_empty,
    input [9:0]DataBuffer,
    output wire RxValid,
    output reg [2:0]RxStatus
    );

    reg Valid,Disp_error,SKP_add,SKP_remove;

    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            Valid<=1'b0;
        end
        else if(DataBuffer==10'b1010111100) begin
            Valid<=1'b1;
        end
        else begin
            Valid<=1'b0;
        end
    end

    assign RxValid=Valid;

    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            Disp_error<=1'b0;
        end
        else if(^DataBuffer==1'b1) begin
            Disp_error<=1'b0;
        end
        else begin
            Disp_error<=1'b1;
        end
    end

    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            RxStatus<=3'b000;
        end
        else if(Valid) begin
            RxStatus<=3'b011;
        end
        else if(Disp_error) begin
            RxStatus<=3'b100;
        end
        else if(BUFF_full) begin
            RxStatus<=3'b101;
        end
        else if(BUFF_empty) begin
            RxStatus<=3'b110;
        end
        else begin
            RxStatus<=3'b000;
        end
    end

endmodule
