/*This module is used to generate the local clock for the receiver and lock the phase of the clock with incoming Serial data. */

`timescale 1ns/100ps

module usb_dpll_2(
    input REF_IN,SYS_CLK,DPLL_RESET,
    output reg DPLL_OUT
    );

    parameter filterlength=8;
    parameter filterreset=4;
    parameter filtermax=filterreset;
    parameter filtermin=256-filterreset;
    parameter dividerlength=7;
    parameter dividermaxvalue=48;

    reg lead,lag;
    reg [1:0]signal_edgedetect;
    wire signal_edge;
    reg [filterlength-1:0]filtercount;
    reg positive,negative;
    reg [dividerlength-1:0]dividercount;

    always@(posedge SYS_CLK or negedge DPLL_RESET) begin
        if(DPLL_RESET) begin
            signal_edgedetect<=0;
        end
        else begin
            signal_edgedetect<={signal_edgedetect[0],REF_IN};
        end
    end

    assign signal_edge=(signal_edgedetect==2'b01);
    always@(posedge SYS_CLK or negedge DPLL_RESET) begin
        if(!DPLL_RESET) begin
            {lead,lag}<=2'b00;
        end
        else if((signal_edge==1'b1) && (DPLL_OUT==1'b0)) begin
            lead<=1'b1;
        end
        else if((signal_edge==1'b0) && (DPLL_OUT==1'b1)) begin
            lag<=1'b1;
        end
        else begin
        {lead,lag}<=2'b00;
        end
    end

    always@(posedge SYS_CLK or negedge DPLL_RESET) begin
        if(!DPLL_RESET) begin
            filtercount<=0;
        end
        else if((filtercount==filtermax) || (filtercount==filtermin)) begin
            filtercount<=0;
        end
        else if(lead) begin
            filtercount<=filtercount+1;
        end
        else if(lag) begin
            filtercount<=filtercount-1;
        end
        else begin
            filtercount<=filtercount;
        end
    end

    always@(posedge SYS_CLK or negedge DPLL_RESET) begin
        if(DPLL_RESET) begin
            {positive,negative}<=2'b00;
        end
        else if(filtercount==filtermax) begin
            positive<=1'b1;
        end
        else if(filtercount==filtermin) begin
            negative<=1'b1;
        end
        else begin
            {positive,negative}<=2'b00;
        end
    end

    always@(posedge SYS_CLK or negedge DPLL_RESET) begin
        if(!DPLL_RESET) begin
            dividercount<=0;
        end
        else if(dividercount==dividermaxvalue-1) begin
            dividercount<=0;
        end
        else if(positive) begin
            dividercount<=dividercount;
        end
        else if(negative) begin
            dividercount<=dividercount+1;
        end
        else begin
            dividercount<=dividercount;
        end
    end

    always@(posedge SYS_CLK or negedge DPLL_RESET) begin
        if(!DPLL_RESET) begin
            DPLL_OUT<=1'b0;
        end
        else if(dividercount==0) begin
            DPLL_OUT<=~DPLL_OUT;
        end
        else begin
            DPLL_OUT<=DPLL_OUT;
        end
    end

endmodule
