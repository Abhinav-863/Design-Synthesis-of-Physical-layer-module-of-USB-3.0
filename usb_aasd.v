`timescale 1ns/100ps
module usb_aasd(
    input rst,clk,
    output reg rst_out
    );

    reg temp;

    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            rst_out <=1'b0;
        end
        else begin
            temp <=rst;
            rst_out <= temp;
        end
    end
endmodule


