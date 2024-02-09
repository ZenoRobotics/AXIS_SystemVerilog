`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2023 10:41:38 AM
// Design Name: 
// Module Name: async_fifox32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module async_fifox32    
  #(
        parameter DSIZE = 32,
        parameter ASIZE = 4,
        parameter FALLTHROUGH = "TRUE" // First word fall-through without latency
    )(/*
        input  wire             wclk,
        input  wire             wrst_n,
        input  wire             winc,
        input  wire [DSIZE-1:0] wdata,
        output wire             wfull,
        output wire             awfull,
        input  wire             rclk,
        input  wire             rrst_n,
        input  wire             rinc,
        output wire [DSIZE-1:0] rdata,
        output wire             rempty,
        output wire             arempty,
        */
        input  wire              rx_clk,    //write clk
        input  wire              tx_clk,    //read clk
        input  wire              rx_reset,
        input  wire              tx_reset,

        input  wire              rx_axis_tvalid,
        input  wire [DSIZE-1:0]  rx_axis_tdata,
        input  wire [ASIZE-1:0]  rx_axis_tkeep,
        input  wire              rx_axis_tlast,
        
        // Make the tx path here instead be a new set of signals
        // that are prefixed with 'preprocess_axis_t..'
        input  wire              tx_axis_tready, 
        output wire              tx_axis_tvalid,
        output wire [DSIZE-1:0]  tx_axis_tdata,
        output wire [ASIZE-1:0]  tx_axis_tkeep,
        output wire              tx_axis_tlast
    );

    wire [ASIZE-1:0] waddr, raddr;
    wire [ASIZE  :0] wptr, rptr, wq2_rptr, rq2_wptr;

    // The module synchronizing the read point
    // from read to write domain
    sync_r2w
    #(ASIZE)
    sync_r2w (
    .wq2_rptr (wq2_rptr),
    .rptr     (rptr),
    .wclk     (rx_clk),
    .wrst_n   (~rx_reset)
    );

    // The module synchronizing the write point
    // from write to read domain
    sync_w2r
    #(ASIZE)
    sync_w2r (
    .rq2_wptr (rq2_wptr),
    .wptr     (wptr),
    .rclk     (tx_clk),
    .rrst_n   (~tx_reset)
    );

    // The module handling the write requests
    wptr_full
    #(ASIZE)
    wptr_full (
    .awfull   (awfull),
    .wfull    (wfull),
    .waddr    (waddr),
    .wptr     (wptr),
    .wq2_rptr (wq2_rptr),
    .winc     (winc),
    .wclk     (wclk),
    .wrst_n   (wrst_n)
    );

    // The DC-RAM
    fifomem
    #(DSIZE, ASIZE, FALLTHROUGH)
    fifomem (
    .rclken (rinc),
    .rclk   (rclk),
    .rdata  (rdata),
    .wdata  (wdata),
    .waddr  (waddr),
    .raddr  (raddr),
    .wclken (winc),
    .wfull  (wfull),
    .wclk   (wclk)
    );

    // The module handling read requests
    rptr_empty
    #(ASIZE)
    rptr_empty (
    .arempty  (arempty),
    .rempty   (rempty),
    .raddr    (raddr),
    .rptr     (rptr),
    .rq2_wptr (rq2_wptr),
    .rinc     (rinc),
    .rclk     (rclk),
    .rrst_n   (rrst_n)
    );
endmodule
