`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2023 06:28:12 PM
// Design Name: 
// Module Name: eth_mux
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
import ethernet_frame_pkg::*;

module eth_mux
(
    //Interface to FIFO Tx Ports
    input  wire         fifo_rx_tvalid,                 // input
    input  wire [31:0]  fifo_rx_tdata,                  // input
    input  wire  [3:0]  fifo_rx_tkeep,                  // input
    input  wire         fifo_rx_tlast,                  // input
    output reg          fifo_rx_tready,                 // output
    //Rx IF signals
    input  wire         rx_rst,                         // input
    //Interface to top_mux Tx ports
    input  wire         tx_clk,                         // input clk from tx interface
    input  wire         tx_rst,                         // input
    output wire         mux_out_tvalid,                 // output
    output wire [31:0]  mux_out_tdata,                  // output
    output wire  [3:0]  mux_out_tkeep,                  // output
    output wire         mux_out_tlast,                  // output
    input  wire         mux_in_tready                   // input
);
    
   localparam [15:0] ETH_TYPE_SWHW_MESSAGE = 16'h88_B5;
   
//---------------------------------------------
// User Defined Data. Not part of MAC Header 
// protocol nor IPv4
//---------------------------------------------
   // struct SWHWMessageHeader  
   reg  [47:0] SWHWMH_destMAC;    // 6 bytes
   reg  [47:0] SWHWMH_sourceMAC;  // 6 bytes
   reg  [15:0] SWHWMH_etherType;  // 2 bytes
   reg   [7:0] SWHWMH_msgType;    // 1 byte
  
   reg  [31:0] SRM_requestID;
   reg   [7:0] SRM_sessionID;
   reg   [7:0] SRM_exchangeCode;
   //     TCPIPEthHeader sessionBoundHeader; // below fields
//---------------------------------------------
// End User Defined Data
//---------------------------------------------

//----------------------------------------------------
// Start of Full Ethernet Frame
//----------------------------------------------------
   // ---------- struct TCPIPEthHeader --------------
   // struct EthernetHeader
   reg   [47:0] EthH_destMAC;
   reg   [47:0] EthH_sourceMAC;
   reg   [15:0] EthH_etherType; // = htons(IP_ETHERTYPE);
   
   // struct IPHeader {
   reg   [7:0] IPH_versionAndIHL; // = (IPV4_VERSION << 4) | MIN_IP_IHL_VALUE;
   reg   [7:0] IPH_dscpAndECN;
   reg  [15:0] IPH_totalLength;
   reg  [15:0] IPH_identification;
   reg  [15:0] IPH_flagsAndFragmentOffset;
   reg   [7:0] IPH_ttl;
   reg   [7:0] IPH_protocol; // = TCP_IP_PROTOCOL_NUM;
   reg  [15:0] IPH_headerChecksum;
   reg  [31:0] IPH_sourceIP;
   reg  [31:0] IPH_destIP;
   
   // struct TCPHeader {
   reg  [15:0]  TCPH_sourcePort; 
   reg  [15:0]  TCPH_destPort;
   reg  [31:0]  TCPH_seqNum;
   reg  [31:0]  TCPH_ackNum;
   reg   [7:0]  TCPH_dataOffsetRsv;  //TCP_DATA_OFFSET << 4;
   reg   [7:0]  TCPH_Flags;
   reg  [15:0]  TCPH_windowSize;
   reg  [15:0]  TCPH_checksum;
   reg  [15:0]  TCPH_urgentPointer;
   //----------------------------------------------------
   
   reg  [7:0]   APL_data [5:0];  //setting max num of data bytes to 32
   reg [31:0]   EthH_fcs;    //Ethernet frame check sequence (CRC-32)
   
 //----------------------------------------------------
 // End of Full Ethernet Frame
 //----------------------------------------------------
 
   // State machine
   typedef enum     {IDLE, PREAMBLE, SFD, HEADER, DATA, FCS, WAIT}  state_type;

   state_type current_state = IDLE;
   state_type next_state    = IDLE;
   
   // temp buffers for input data
   
   reg  [31:0]  buf_mux_out_tdata  = 32'h00000000;
   reg          buf_fifo_rx_tready =  1'b0;
   reg          buf_mux_out_tvalid =  1'b0;         
   reg   [3:0]  buf_mux_out_tkeep  =  4'h0;         
   reg          buf_mux_out_tlast  =  1'b0;        
   
   //------------------------------------------------------------------------------------------------
   //Simple passthrough code to test the verification environment and connectivity of the DUT modules
   //------------------------------------------------------------------------------------------------
   /*
   // Reset or Capture Data
   always @(posedge tx_clk) begin
    if (tx_rst == 1'b1)
      begin
        mux_out_tdata  <= 32'h00000000;
        fifo_rx_tready <=  1'b0;
        mux_out_tvalid <=  1'b0;         
        mux_out_tkeep  <=  4'h0;         
        mux_out_tlast  <=  1'b0;        
      end
    else
      begin
        // for this simple passthrouh case, we are sending through all non-keep data, along with keep signals
        if (fifo_rx_tvalid == 1'b1)
          begin
            buf_mux_out_tdata  <= fifo_rx_tdata;
            buf_fifo_rx_tready <=  1'b1;           // tell fifo mux is ready next clk
            buf_mux_out_tvalid <=  1'b1;           // make data available next clk
            mux_out_tkeep  <=  4'h0;         
        mux_out_tlast  <=  1'b0;         
          end
        if (buf_mux_out_tvalid == 1'b1)
          begin
            mux_out_tdata      <=  buf_mux_out_tdata;
            fifo_rx_tready     <=  buf_fifo_rx_tready;   // tell fifo mux is ready
            mux_out_tvalid     <=  buf_mux_out_tvalid;   // make data available 
            mux_out_tkeep      <=  buf_mux_out_tkeep;         
            mux_out_tlast      <=  buf_mux_out_tlast;        
          end
      end
   end
   */
   
   //------- Stream (Skid) Buffer Implementation  -------//
   // Let fifo know mux is ready when ...
   always @(posedge tx_clk)     
     if (tx_rst == 1'b1)
       fifo_rx_tready <= 1'b1;
     else
       fifo_rx_tready <= mux_in_tready || !mux_out_tvalid;  // (tx axis tready input is low) OR !(mux_out_tvalid is high when there is data in the buffer)
       
   // buffer data, keep and last when needed
   always @(posedge tx_clk) begin
     if (tx_rst == 1'b1) 
       begin
         buf_mux_out_tdata  <= 32'h00000000;
         buf_mux_out_tkeep  <=  4'h0;         
         buf_mux_out_tlast  <=  1'b0; 
       end
     else if (!mux_in_tready && fifo_rx_tready && fifo_rx_tvalid)  //(tx axis tready input is low) AND (tready from mux to fifo is set high) AND (fifo data is valid)
       begin
         buf_mux_out_tdata  <= fifo_rx_tdata;
         buf_mux_out_tkeep  <= fifo_rx_tkeep;         
         buf_mux_out_tlast  <= fifo_rx_tlast; 
       end
     end
   assign mux_out_tvalid = fifo_rx_tvalid || !fifo_rx_tready;
   assign mux_out_tdata = !fifo_rx_tready ? buf_mux_out_tdata : fifo_rx_tdata;
   assign mux_out_tkeep = !fifo_rx_tready ? buf_mux_out_tkeep : fifo_rx_tkeep;
   assign mux_out_tlast = !fifo_rx_tready ? buf_mux_out_tlast : fifo_rx_tlast; 
   
   
endmodule
