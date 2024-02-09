`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2023 07:28:40 AM
// Design Name: 
// Module Name: top_mux_if
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

`include "Rx_Tx_Axis_Parmeters.vh"

interface top_mux_if ();

    logic    [NUM_RX_LANES-1:0] rx_clk;   // input to DUT
    logic    [NUM_RX_LANES-1:0] rx_rst;   // input to DUT

    logic            rx_axis_tvalid [NUM_RX_LANES-1:0];  // input to DUT
    logic     [31:0] rx_axis_tdata  [NUM_RX_LANES-1:0];  // input to DUT
    logic            rx_axis_tlast  [NUM_RX_LANES-1:0];  // input to DUT
    logic     [3:0]  rx_axis_tkeep  [NUM_RX_LANES-1:0];  // input to DUT
    //logic            rx_axis_tready [NUM_RX_LANES-1:0];  // output from DUT - evidently no push back, hence the FIFO

    logic    [NUM_TX_LANES-1:0] tx_clk;  // input to DUT
    logic    [NUM_TX_LANES-1:0] tx_rst;  // input to DUT

    logic            tx_axis_tready [NUM_TX_LANES-1:0];  // input to DUT
    logic            tx_axis_tvalid [NUM_TX_LANES-1:0];  // output from DUT
    logic     [31:0] tx_axis_tdata  [NUM_TX_LANES-1:0];  // output from DUT
    logic            tx_axis_tlast  [NUM_TX_LANES-1:0];  // output from DUT
    logic     [3:0]  tx_axis_tkeep  [NUM_TX_LANES-1:0];  // output from DUT
 
endinterface
