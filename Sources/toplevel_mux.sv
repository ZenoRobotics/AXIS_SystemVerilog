`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2023 06:26:51 AM
// Design Name: 
// Module Name: toplevel_mux
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


`timescale 1ps/1fs
`default_nettype none

`include "Rx_Tx_Axis_Parmeters.vh"

// I will move these to a separate file, but they are here for illustration/context
typedef enum logic [7:0]
{
    SWHW_MSG_TYPE_NONE = 8'd0,
    SWHW_MSG_TYPE_SESSION_REGISTRATION = 8'd1,
    SWHW_MSG_TYPE_VENUE_BOUND_WRAPPED = 8'd2,

    NUM_SWHW_MSG_TYPES
} swhw_msg_type_enum_t;

module toplevel_mux //#(parameter int  NUM_RX_LANES=2, parameter int  NUM_TX_LANES=2)
(
    input wire [NUM_RX_LANES-1:0] rx_clk,
    input wire [NUM_RX_LANES-1:0] rx_rst,

    input wire        rx_axis_tvalid [NUM_RX_LANES-1:0],
    input wire [31:0] rx_axis_tdata [NUM_RX_LANES-1:0],
    input wire        rx_axis_tlast [NUM_RX_LANES-1:0],
    input wire [3:0]  rx_axis_tkeep [NUM_RX_LANES-1:0],

    input wire [NUM_TX_LANES-1:0] tx_clk,
    input wire [NUM_TX_LANES-1:0] tx_rst,

    input wire        tx_axis_tready [NUM_TX_LANES-1:0],
    output reg        tx_axis_tvalid [NUM_TX_LANES-1:0],
    output reg [31:0] tx_axis_tdata [NUM_TX_LANES-1:0],
    output reg        tx_axis_tlast [NUM_TX_LANES-1:0],
    output reg [3:0]  tx_axis_tkeep [NUM_TX_LANES-1:0]
);

    wire        pre_processed_axis_tvalid;
    wire [31:0] pre_processed_axis_tdata;
    wire        pre_processed_axis_tlast;
    wire  [3:0] pre_processed_axis_tkeep;
    wire        pre_processed_axis_tready;
    
    wire        tx_axis_tready_1_lane;
    wire        tx_axis_tvalid_1_lane;
    wire [31:0] tx_axis_tdata_1_lane;
    wire        tx_axis_tlast_1_lane;
    wire [3:0]  tx_axis_tkeep_1_lane;
    
    wire almost_empty;
    wire prog_empty;
    
    // Double signals to outputs, which have 2 lanes
    always @(posedge rx_clk[LANE_CONTROLLER]) begin
      tx_axis_tvalid <= {tx_axis_tvalid_1_lane,tx_axis_tvalid_1_lane};
      tx_axis_tdata  <= {tx_axis_tdata_1_lane,tx_axis_tdata_1_lane};
      tx_axis_tlast  <= {tx_axis_tlast_1_lane,tx_axis_tlast_1_lane};
      tx_axis_tkeep  <= {tx_axis_tkeep_1_lane,tx_axis_tkeep_1_lane};
    end
   

    // Assume a fifo exists that can most efficiently change from one clock domain to another
    // (feel free to implement your own, but only behaviorally, and dont worry about synthesis efficiency or absolute correctness
    // in terms of timing, etc.  Just make sure it works for this testbench)
    async_fifox32 // axis_data_fifo_0  
    #(
        //.FIFO_DEPTH(16)
    )
    async_fifo_inst
    ( /*
        .rx_clk(rx_clk[`LANE_CONTROLLER]),
        .tx_clk(tx_clk[`LANE_OUTBOUND]),
        .rx_reset(rx_rst[`LANE_CONTROLLER]),
        .tx_reset(tx_rst[`LANE_OUTBOUND]),

        .rx_axis_tvalid(rx_axis_tvalid[`LANE_CONTROLLER]),
        .rx_axis_tdata(rx_axis_tdata[`LANE_CONTROLLER]),
        .rx_axis_tkeep(rx_axis_tkeep[`LANE_CONTROLLER]),
        .rx_axis_tlast(rx_axis_tlast[`LANE_CONTROLLER]),

        // Make the tx path here instead be a new set of signals
        // that are prefixed with 'preprocess_axis_t..'
        .tx_axis_tvalid(pre_processed_axis_tvalid),
        .tx_axis_tdata(pre_processed_axis_tdata),
        .tx_axis_tkeep(pre_processed_axis_tkeep),
        .tx_axis_tlast(pre_processed_axis_tlast),
        .tx_axis_tready(pre_processed_axis_tready)
        */
        .s_axis_aclk(rx_clk[LANE_CONTROLLER]),
        .m_axis_aclk(tx_clk[LANE_OUTBOUND]),
        .s_axis_aresetn(~rx_rst[LANE_CONTROLLER]),
        //.m_axis_aresetn(~tx_rst[`LANE_OUTBOUND]), //No such animal

        .s_axis_tvalid(rx_axis_tvalid[LANE_CONTROLLER]),
        .s_axis_tdata(rx_axis_tdata[LANE_CONTROLLER]),
        .s_axis_tkeep(rx_axis_tkeep[LANE_CONTROLLER]),
        .s_axis_tlast(rx_axis_tlast[LANE_CONTROLLER]),

        // Make the tx path here instead be a new set of signals
        // that are prefixed with 'preprocess_axis_t..'
        .m_axis_tvalid(pre_processed_axis_tvalid), // output to mux
        .m_axis_tdata(pre_processed_axis_tdata),   // output to mux
        .m_axis_tkeep(pre_processed_axis_tkeep),   // output to mux
        .m_axis_tlast(pre_processed_axis_tlast),   // output to mux
        .m_axis_tready(pre_processed_axis_tready)  // input from mux
        
    );
 
    
    eth_mux
    #(
        //.FIFO_DEPTH(16)
    )
    eth_mux_inst
    (   //Interface to FIFO Tx Ports
        .fifo_rx_tvalid(pre_processed_axis_tvalid),   // input
        .fifo_rx_tdata(pre_processed_axis_tdata),    // input
        .fifo_rx_tkeep(pre_processed_axis_tkeep),     // input
        .fifo_rx_tlast(pre_processed_axis_tlast),     // input
        .fifo_rx_tready(pre_processed_axis_tready),   // output
        //Rx Reset input
        .rx_rst(rx_rst[LANE_CONTROLLER]),
        //Interface to top_mux Tx ports
        .tx_clk(tx_clk[LANE_OUTBOUND]),                  // input
        .tx_rst(tx_rst[LANE_OUTBOUND]),                  // input
        .mux_out_tvalid(tx_axis_tvalid_1_lane),           // output
        .mux_out_tdata(tx_axis_tdata_1_lane),             // output
        .mux_out_tkeep(tx_axis_tkeep_1_lane),             // output
        .mux_out_tlast(tx_axis_tlast_1_lane),             // output
        .mux_in_tready(tx_axis_tready[LANE_OUTBOUND])    // input
        //FIFO flags
    );
     
    
endmodule