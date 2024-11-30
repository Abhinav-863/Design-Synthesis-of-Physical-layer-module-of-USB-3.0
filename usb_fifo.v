/*This module is used for data bursting. Will indicates read and write level so that SKP symbol can be add or removed.*/
`timescale 1ns/100ps

module usb_fifo #(
        parameter DSIZE = 10,
        parameter ASIZE = 8
    )(
    output [DSIZE-1:0] rdata,       
    output wfull,                   
    output rempty,                  
    input [DSIZE-1:0] wdata,        
    input winc, wclk, wrst_n,       
    input rinc, rclk, rrst_n        
    );

    wire [ASIZE-1:0] waddr, raddr;
    wire [ASIZE:0] wptr, rptr, wq2_rptr, rq2_wptr;

    two_ff_sync #(ASIZE+1) sync_r2w (       
        .q2(wq2_rptr), 
        .din(rptr),
        .clk(wclk), 
        .rst_n(wrst_n)
    );

    two_ff_sync #(ASIZE+1) sync_w2r (       
        .q2(rq2_wptr), 
        .din(wptr),
        .clk(rclk), 
        .rst_n(rrst_n)
    );

    FIFO_memory #(DSIZE, ASIZE) fifomem(   
        .rdata(rdata), 
        .wdata(wdata),
        .waddr(waddr), 
        .raddr(raddr),
        .wclk_en(winc), 
        .wfull(wfull),
        .wclk(wclk)
    );

    rptr_empty #(ASIZE) rptr_empty(         
        .rempty(rempty),
        .raddr(raddr),
        .rptr(rptr), 
        .rq2_wptr(rq2_wptr),
        .rinc(rinc), 
        .rclk(rclk),
        .rrst_n(rrst_n)
    );

    wptr_full #(ASIZE) wptr_full(           
        .wfull(wfull), 
        .waddr(waddr),
        .wptr(wptr), 
        .wq2_rptr(wq2_rptr),
        .winc(winc), 
        .wclk(wclk),
        .wrst_n(wrst_n)
    );

endmodule

module FIFO_memory #(
        parameter DATA_SIZE = 10,
        parameter ADDR_SIZE = 8
    )(
        output [DATA_SIZE-1:0] rdata,        
        input [DATA_SIZE-1:0] wdata,         
        input [ADDR_SIZE-1:0] waddr, raddr,  
        input wclk_en, wfull, wclk          
    );

    localparam DEPTH = 1<<ADDR_SIZE;     
    reg [DATA_SIZE-1:0] mem [0:DEPTH-1];

    assign rdata = mem[raddr];          

    always @(posedge wclk) begin
        if (wclk_en && !wfull) begin 
            mem[waddr] <= wdata; 
        end
    end

endmodule

module rptr_empty #(
    parameter ADDR_SIZE = 8
    )(
    output reg rempty,                  
    output [ADDR_SIZE-1:0] raddr,       
    output reg [ADDR_SIZE :0] rptr,     
    input [ADDR_SIZE :0] rq2_wptr,      
    input rinc, rclk, rrst_n            
    );

    reg [ADDR_SIZE:0] rbin;                     
    wire [ADDR_SIZE:0] rgray_next, rbin_next;   
    wire rempty_val;                            
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin                
            {rbin, rptr} <= 0;
        end
        else begin
            {rbin, rptr} <= {rbin_next, rgray_next};  
        end
    end

    assign raddr = rbin[ADDR_SIZE-1:0];                 
    assign rbin_next = rbin + (rinc & ~rempty);         
    assign rgray_next = (rbin_next>>1) ^ rbin_next;     
    assign rempty_val = (rgray_next == rq2_wptr);       

    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin               
            rempty <= 1'b1;
        end
        else begin
            rempty <= rempty_val;  
        end
    end
endmodule

module two_ff_sync #(parameter SIZE = 10)( 
    output reg [SIZE-1:0] q2,   
    input [SIZE-1:0] din,       
    input clk, rst_n            
    );

    reg [SIZE-1:0] q1; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin 
            {q2, q1} <= 0;          
        end
        else begin 
            {q2, q1} <= {q1, din};  
        end
    end 

endmodule

module wptr_full #(parameter ADDR_SIZE = 8)(
    output reg wfull,                   
    output [ADDR_SIZE-1:0] waddr,       
    output reg [ADDR_SIZE :0] wptr,    
    input [ADDR_SIZE :0] wq2_rptr,      
    input winc, wclk, wrst_n            
    );

    reg [ADDR_SIZE:0] wbin;                   
    wire [ADDR_SIZE:0] wgray_next, wbin_next;   
    wire wfull_val;                             

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin            
            {wbin, wptr} <= 0;
        end
        else begin 
            {wbin, wptr} <= {wbin_next, wgray_next}; 
        end
    end

    assign waddr = wbin[ADDR_SIZE-1:0];             
    assign wbin_next = wbin + (winc & ~wfull);       
    assign wgray_next = (wbin_next>>1) ^ wbin_next;    

    assign wfull_val = (wgray_next=={~wq2_rptr[ADDR_SIZE:ADDR_SIZE-1], wq2_rptr[ADDR_SIZE-2:0]});

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin            
            wfull <= 1'b0;
        end
        else begin
            wfull <= wfull_val; 
        end
    end
endmodule
