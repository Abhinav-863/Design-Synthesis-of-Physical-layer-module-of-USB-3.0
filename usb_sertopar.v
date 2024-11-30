//This module converts single bit serial data into 10bit parallel data
`timescale 1ns/100ps
module usb_sertopar(
    input Serialin,
    input clk,rst,
    output reg [9:0]Parout
    );

    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            Parout<=0;
        end
        else begin
            Parout<= {Serialin,Parout[9:1]};
        end
    end

endmodule