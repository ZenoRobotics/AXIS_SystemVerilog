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
    
   localparam [31:0] ETH_TYPE_SWHW_MESSAGE = 16'h88_B5;
   
   //---------------------------------------------
// Extra user Data. Not part of MAC Header 
// protocol nor IPv4
//---------------------------------------------
   // struct SWHWMessageHeader  
   reg  [47:0] SWHWMH_destMAC;
   reg  [47:0] SWHWMH_sourceMAC;
   reg  [15:0] SWHWMH_etherType;
   reg   [7:0] SWHWMH_msgType;        
   
   //struct SessionRegistrationMsg
   //     SWWMessageHeader msgHeader; //Above fields 
   //     uint32_t requestID;
   //     uint8_t sessionID;
   //     uint8_t exchangeCode;
   //     TCPIPEthHeader sessionBoundHeader;
   reg  [31:0] SRM_requestID;
   reg   [7:0] SRM_sessionID;
   reg   [7:0] SRM_exchangeCode;
   //     TCPIPEthHeader sessionBoundHeader; // below fields
//---------------------------------------------
// End extra
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
   reg  [15:0]  TCPH_seqNum;
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
   
   
    // 1. If the raw Ethernet frame has an Ethertype of  ETH_TYPE_SWHW_MESSAGE (i.e., 0x88B5), then
    //   parse it against this below struct as efficiently as possible:
    //
    // struct SWHWMessageHeader {
    //     uint8_t destMAC[6];
    //     uint8_t sourceMAC[6];
    //     uint16_t ethertype;
    //     uint8_t msgType;
    //  } __attribute__((packed));;
    //  1.1. If msgType == SWHW_MSG_TYPE_SESSION_REGISTRATION, then parse the following struct from the raw Ethernet frame
    //       via its subsequent bytes:
    //          struct SessionRegistrationMsg
    //          {
    //          	    SWWMessageHeader msgHeader;
    //          	    uint32_t requestID;
    //          	    uint8_t sessionID;
    //          	    uint8_t exchangeCode;
    //          	    TCPIPEthHeader sessionBoundHeader;
    //          } __attribute__((packed));
    // Save the contents of the sessionBoundHeader (a combination of the Ethernet, IP and TCP headers as shown below) into distributed RAM
    // to be later fetched if we wish to do a lookup based on this 8-bit sessionID
    // (for now, just assume the sessionID can go from 0-63 (i.e., only its low order 6 bits are used)
    // It should be possible to query the distributed memory on the chip to ensure that the TCPIPEthHeader is stored in the correct location 
    // Additionally, we should have a writeback ability to 'update' the TCP seqnum that goes into the TCPIPEthHeader stored for a given
    // sessionID.  This should be done in a way that is as efficient as possible (i.e., no need to read the entire TCPIPEthHeader, just
    // the 32-bit seqnum field, and then write it back to the same location)
    // We should also simultaneously update the TCP checksum field in the TCPIPEthHeader, and this should be done in a way that is as efficient
    // as possible as well, reflecting the newly updated seqnum field
    //
    // 1.1.1. Furthermore on the TX axis data path on the `LANE_CONTROLLER` lane, we should also be able to write back an acknowledgement frame
    // indicating that this SessionRegistrationMsg was parsed and complete
    // Please refer to this below struct for the format of the acknowledgement frame:
    // struct SessionRegistrationAcceptedMsg
    // {
    // 	SWHMessageHeader msgHeader;	uint32_t requestID;
    // } __attribute__((packed));
    // 
    // 1.1.2. If the sessionID is too large (e.g., sessionID > 63), then we should send back a SessionRegistrationRejectedMsg 
    // of the below format:
    // struct SessionRegistrationRejectedMsg
    // {
    // 	SWHMessageHeader msgHeader;	uint32_t requestID;
    // 	uint8_t internalRejectReason;
    // } __attribute__((packed));


    // 1.2. If msgtype == SWHW_MSG_TYPE_VENUE_BOUND_WRAPPED, then parse the following struct from the raw Ethernet frame:
    //
    //      struct VenueBoundWrappedMsg
    //      {
    //           SWWMessageHeader msgHeader:
    //           uint8_t sessionID;
    //           TCPIPEthHeader packetHeaders;
    //           uint8_t dataBytes [TCIPEthHeader::MAX_TCP_DATA_LENGTH];
    //           VenueBoundWrappedMsg() : msgHeader(), packetHeaders () 
    //      } __attribute__((packed));
    // 
    // Also, you should extract and generate a tx stream of the same axis interface as was used for rx_ and pre_processed_axis_t..., 
    // and send it to a final FIFO+MUX as its first 'lane' (i.e., index 0) to be sent out on the final tx_signals...
    // sessionID should be used to look up into the distributed RAM above to find the right TCPIPEthHeader to use for the outgoing packet headers
    // but we will largely use the same packet headers as were used for the incoming packet, except for the following:
    //
    // 1.2.1. The tcp seqnum should be overwritten with the value in the TCPIPEthHeader stored in the distributed RAM for this sessionID
    // 1.2.2 The tcp checksum should be updated to reflect the new seqnum (the rest of the checksum as it was provided should be kept the same, 
    // only the delta from this tcp checksum should be applied)

    // 2. If the ethertype is not ETH_TYPE_SWHW_MESSAGE, then just pass the raw Ethernet frame through to the tx path
    // The way this should be done is not as a direct dataflow straight to TX (so as to accommodate the MUX'ing of traffic from 
    // the VenueBoundWrappedMsg, for instance), but rather as the second 'lane' input to a FIFO+MUX that arbitrates & queues traffic
    // to the final tx_axis `LANE_OUTBOUND` lane 


    // NOTE: We do not process (we can safely discard and not connect) rx_data from the outbound lane (i.e., any of 
    // the rx_axis_tdata, rx_axis_tvalid, rx_axis_tlast, rx_axis_tkeep signals on index `LANE_OUTBOUND`)
    
    
endmodule
