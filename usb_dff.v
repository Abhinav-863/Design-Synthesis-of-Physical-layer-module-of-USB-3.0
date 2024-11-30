`timescale 1ns/100ps
module usb_dff (
    input [9:0] in,      
    input clk,           
    input rst,           
    input inv,           // Inversion control (RX_POLARITY)
    output reg [9:0] out      
);

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            out <= 10'b0;
        end 
        else begin
            if (inv) begin
                out <= ~in;
            end 
            else begin
                out <= in;
            end
        end
    end

endmodule
