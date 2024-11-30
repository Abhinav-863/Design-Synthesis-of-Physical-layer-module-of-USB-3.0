//This module will conver 10bit dc balanced data into 8bit data
`timescale 1ns/100ps

module usb_decode(
    input [9:0]DATA_IN,
    input DEC_CLK,DEC_RST,
    output reg KO,
    output reg [7:0]DECODE_OUT
    );

    wire aneb,cned,eei,p13,p22,p31;
    wire ika,ikb,ikc;
    wire xa,xb,xc,xd,xe,xf,xg,xh;
    wire or121,or122,or123,or124,or125,or126,or127;
    wire or131,or132,or133,or134;
    reg ior134;
    wire ai,bi,ci,di,ei,fi,gi,hi,ii,ji;

    assign ai=DATA_IN[0];
    assign bi=DATA_IN[1];
    assign ci=DATA_IN[2];
    assign di=DATA_IN[3];
    assign ei=DATA_IN[4];
    assign ii=DATA_IN[5];
    assign fi=DATA_IN[6];
    assign gi=DATA_IN[7];
    assign hi=DATA_IN[8];
    assign ji=DATA_IN[9];


    assign p13=(aneb & (!ci & !di)) | (cned & (!ai & !bi));
    assign p31=(aneb & ci & di) | (cned & ai & bi);
    assign p22=(ai & bi & (!ci & !di)) | (ci & di & (!ai & !bi)) | (aneb &cned);
    assign aneb= ai ^ bi;
    assign cned= ci ^ di;
    assign eei= ei ^! ii;


    assign ika=(ci & di & ei & ii) | (!ci & !di & !ei & !ii);
    assign ikb=p13 & (!ei & ii & gi & hi & ji);
    assign ikc=p31 & (ei & !ii & !gi & !hi & !ji);

    always@(posedge DEC_CLK or negedge DEC_RST) begin
        if(!DEC_RST) begin
            KO<=1'b0;
            ior134<=1'b0;
        end
        else begin
            KO<= ika | ikb | ikc;
            ior134<= (!(hi & ji)) & (!(!hi & !ji)) & (!ci & !di & !ei & !ii);
        end
    end

    //5b Decoder
    //logic to determine compliementing A,B,C,D,E,I inputs
    assign or121=(p22 & (!ai & !ci & eei)) | (p13 & !ei);
    assign or123=(p31 & ii) | (p22 & bi & ci & eei) | (p13 & di & ei &ii);
    assign or122=(ai & bi & ei & ii) | (!ci & !di & !ei & !ii) | (p31 &ii);
    assign or124=(p22 & ai & ci & eei) | (p13 & !ei);
    assign or125=(p13 & !ei) | (!ci & !di & !ei & !ii) | (!ai & !bi & !ei& !ii);
    assign or126=(p22 & !ai & !ci & eei) | (p13 & !ii);
    assign or127=(p13 & di & ei & ii) | (p22 & !bi & !ci & eei);
    assign xa= or127 | or121 | or122;
    assign xb= or122 | or123 | or124;
    assign xc= or121 | or123 | or125;
    assign xd= or122 | or124 | or127;
    assign xe= or125 | or126 | or127;

    always@(posedge DEC_CLK or negedge DEC_RST) begin
        if(!DEC_RST)begin
            DECODE_OUT[0]<=1'b0;
            DECODE_OUT[1]<=1'b0;
            DECODE_OUT[2]<=1'b0;
            DECODE_OUT[3]<=1'b0;
            DECODE_OUT[4]<=1'b0;
        end
        else begin
            DECODE_OUT[0]<=xa ^ ai;
            DECODE_OUT[1]<=xb ^ bi;
            DECODE_OUT[2]<=xc ^ ci;
            DECODE_OUT[3]<=xd ^ di;
            DECODE_OUT[4]<=xe ^ ei;
        end
    end
    
    //3b Decoder
    assign or131= (gi & hi & ji) | (fi & hi & ji) | ior134;
    assign or132= (fi & gi & ji) | (!fi & !gi & !hi) | (!fi & !gi & hi &ji);
    assign or133=(!fi & !hi & !ji) | (ior134) | (!gi & !hi & !ji);
    assign or134= (!gi & !hi & !ji) | (fi & hi &ji) | (ior134);
    assign xf= or131 | or132;
    assign xg= or132 | or133;
    assign xh= or132 | or134;
    
    always@(negedge DEC_CLK or negedge DEC_RST) begin
        if(!DEC_RST)begin
            DECODE_OUT[5]<=1'b0;
            DECODE_OUT[6]<=1'b0;
            DECODE_OUT[7]<=1'b0;
        end
        else begin
            DECODE_OUT[5]<=xf ^ fi;
            DECODE_OUT[6]<=xg ^ gi;
            DECODE_OUT[7]<=xh ^ hi;
        end
    end

endmodule

