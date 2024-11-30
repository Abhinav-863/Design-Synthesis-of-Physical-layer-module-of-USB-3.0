/* This module will generate 10bit of DC balance code from 8bit of data.  The purpose is to generate DC balanced code with +ve and -ve disparity */
`timescale 1ns/100ps
module usb_encoder(
    input ENC_CLK,ENC_RST,KI,
    input [7:0]ENC_IN,
    output reg [9:0]ENC_OUT
    );

    wire ai,bi,ci,di,ei;
    reg fi,gi,hi,k;
    wire aeqb,ceqd,L22,L13,L31,L40,L04;
    wire PDL6,PDL4,NDL6;
    wire PD1S6,ND1S6,PD0S6,ND0S6;
    wire PD1S4,ND1S4,PD0S4,ND0S4;
    wire FNEG;
    reg S;
    reg LPDL6,LPDL4;
    wire COMPLS4,COMPLS6;
    wire SINT,NFO,NGO,NHO,NJO;
    wire NAO,NBO,NCO,NDO,NEO,NIO;
    
    assign ai= ENC_IN[0];
    assign bi= ENC_IN[1];
    assign ci= ENC_IN[2];
    assign di= ENC_IN[3];
    assign ei= ENC_IN[4];

    always@(posedge ENC_CLK or negedge ENC_RST) begin
        if(!ENC_RST) begin
            fi<= 0;
            gi<= 0;
            hi<= 0;
            k<=0;
        end
        else begin
            fi<= ENC_IN[5];
            gi<= ENC_IN[6];
            hi<= ENC_IN[7];
            k<=KI;
        end
    end

    assign aeqb= (ai & bi)|(!ai & !bi);
    assign ceqd= (ci & di)|(!ci & !di);
    assign L22 = (ai & bi & !ci & !di)|(ci & di & !ai &!bi)|(!aeqb & !ceqd);
    assign L13 = (!aeqb & !ci & !di)|(!ceqd & !ai & !bi);
    assign L31 = (!aeqb & ci & di)|(!ceqd & ai & bi); 
    assign L40 = (ai & bi & ci & di); 
    assign L04 = (!ai & !bi & !ci & !di); 


    assign PD1S6= (!L22 & !L31 & !ei)|(L13 & di & ei);
    assign ND1S6= (L31 & !di & !ei)|(ei & !L22 & !L13)|k;
    assign PD0S6= (!L22 & !L13 & ei)|k;
    assign ND0S6= PD1S6;
    assign FNEG= fi ^ gi;


    always@(posedge ENC_CLK or negedge ENC_RST)begin 
        if(!ENC_RST) begin
            S<=0;
        end
        else begin
            S<=(PDL6 & L31 & di & !ei)|(NDL6 & L13 & ei & !di);
        end
    end

    assign ND1S4 = (fi & gi);
    assign ND0S4 = (!fi & !gi);
    assign PD1S4 = (!fi & !gi) | (FNEG & k);
    assign PD0S4 = (fi & gi & hi);
    assign NDL6=!PDL6;
    assign PDL6=(PD0S6 & !COMPLS6)|(COMPLS6 & ND0S6)|(!ND0S6 & !PD0S6 & LPDL4);
    assign NDL6=!PDL6;
    assign PDL4=(LPDL6 & !PD0S4 & ! ND0S4)|(ND0S4 & COMPLS4)|(!COMPLS4 & PD0S4);


    always@(posedge ENC_CLK or negedge ENC_RST) begin
        if(!ENC_RST) begin
            LPDL6<= 0;
        end
        else begin
            LPDL6<=PDL6;
        end
    end


    always@(posedge ENC_CLK or negedge ENC_RST) begin
        if(!ENC_RST) begin
            LPDL4<=0;
        end
        else begin
            LPDL4<=~PDL4;
        end
    end
    assign COMPLS4= (PD1S4 & !LPDL6) ^ (ND1S4 & LPDL6);
    assign COMPLS6= (ND1S6 & LPDL4) ^ (PD1S6 & !LPDL4);

    assign NAO= ai;
    assign NBO= L04|(bi & !L40);
    assign NCO= ci | L04 | (L13 & di & ei);
    assign NDO= di & !L40;
    assign NEO= (ei & !(ei & di & L13))|(L13 & !ei);
    assign NIO= (L22 & !ei)|(ei & L04)|(ei & L40)|(k & L22)|(ei & !di & L13);
    
    always@(posedge ENC_CLK or negedge ENC_RST) begin
        if(!ENC_RST) begin
            ENC_OUT[5:0]<=6'b0;
        end
        else begin
            ENC_OUT[0]<= COMPLS6 ^ NAO;
            ENC_OUT[1]<= COMPLS6 ^ NBO;
            ENC_OUT[2]<= COMPLS6 ^ NCO;
            ENC_OUT[3]<= COMPLS6 ^ NDO;
            ENC_OUT[4]<= COMPLS6 ^ NEO;
            ENC_OUT[5]<= COMPLS6 ^ NIO;
        end
    end

    assign SINT= (S & fi & gi & hi)|(k & fi & gi & hi);
    assign NFO= (fi & !SINT);
    assign NGO= gi | (!fi & !gi & !hi);
    assign NHO= hi;
    assign NJO= SINT|(FNEG & !hi);
    always@(posedge ENC_CLK or negedge ENC_RST) begin 
        if(!ENC_RST) begin
            ENC_OUT[9:6]<=3'b0;
        end
        else begin
            ENC_OUT[6]<= COMPLS4 ^ NFO;
            ENC_OUT[7]<= COMPLS4 ^ NGO;
            ENC_OUT[8]<= COMPLS4 ^ NHO;
            ENC_OUT[9]<= COMPLS4 ^ NJO;
        end
    end

endmodule

