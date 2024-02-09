`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2023 11:08:02 PM
// Design Name: 
// Module Name: ethernet_header_pkg
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


package ethernet_frame_pkg;

   // Number of bytes transferred in each stage
   localparam ETH_FULL_FRAME_BYTE_CNT_BYTES = 2;
   localparam SWHWM_HEADER_BYTES = 16;
   localparam SESSION_REG_MSG_BYTES = 6;
   localparam TCP_IP_ETH_HEADER_BYTES = 54;
   localparam APPL_DATA_BYTES = 32;  // range = 6 to 1500 - 40; setting const for now
   localparam FCS_BYTES = 4;
   localparam PACKET_PAYLOAD_BYTES = //ETH_FULL_FRAME_BYTE_CNT_BYTES +
                                     SWHWM_HEADER_BYTES +
                                     SESSION_REG_MSG_BYTES +
                                     TCP_IP_ETH_HEADER_BYTES +
                                     APPL_DATA_BYTES + // Range = 6 to 1500 - 40 ; Set to a constant for now
                                     FCS_BYTES;
   localparam MIN_APPL_DATA_BYTES = 6;
   localparam MAX_APPL_DATA_BYTES = (1500 - 40);
   
/*
   // Full Ethernet Frame 
   
   // Order matters
   // Must be defined in the decoder (e.g., mux) before use.

  typedef struct      packed {
  //---------------------------------------------
  // User Defined Data. Not part of MAC Header 
  // protocol nor IPv4
  //---------------------------------------------
     logic  [15:0] fullFrameByteCount;  // 2 bytes
     // struct SWHWMessageHeader  
     logic  [47:0] SWHWMH_destMAC;     // 6 bytes
     logic  [47:0] SWHWMH_sourceMAC;   // 6 bytes
     logic  [15:0] SWHWMH_etherType;   // 2 bytes
     logic  [15:0] SWHWMH_msgType;     // 2 byte
   
     //struct SessionRegistrationMsg
     //     SWWMessageHeader msgHeader; //Above fields 
     //     uint32_t requestID;
     //     uint8_t sessionID;
     //     uint8_t exchangeCode;
     //     TCPIPEthHeader sessionBoundHeader;
     logic  [31:0] SRM_requestID;      // 4 bytes
     logic   [7:0] SRM_sessionID;      // 1 byte
     logic   [7:0] SRM_exchangeCode;   // 1 byte
     //     TCPIPEthHeader sessionBoundHeader; // below fields
  //---------------------------------------------
  // End User Defined Data
  //---------------------------------------------

  //----------------------------------------------------
  // Start of Full Ethernet Frame
  //----------------------------------------------------
     // ---------- struct TCPIPEthHeader --------------
     // struct EthernetHeader
     logic   [47:0] EthH_destMAC;        // 6 bytes
     logic   [47:0] EthH_sourceMAC;      // 6 bytes
     logic   [15:0] EthH_etherType; // = htons(IP_ETHERTYPE);  // 2 bytes
   
     // struct IPHeader {
     logic   [7:0] IPH_versionAndIHL; // = (IPV4_VERSION << 4) | MIN_IP_IHL_VALUE;  // 1 byte
     logic   [7:0] IPH_dscpAndECN;                               // 1 byte
     logic  [15:0] IPH_totalLength;                              // 2 bytes
     logic  [15:0] IPH_identification;                           // 2 bytes
     logic  [15:0] IPH_flagsAndFragmentOffset;                   // 2 bytes
     logic   [7:0] IPH_ttl;                                      // 1 byte
     logic   [7:0] IPH_protocol; // = TCP_IP_PROTOCOL_NUM;       // 1 byte
     logic  [15:0] IPH_headerChecksum;                           // 2 bytes
     logic  [31:0] IPH_sourceIP;                                 // 4 bytes
     logic  [31:0] IPH_destIP;                                   // 4 bytes
   
     // struct TCPHeader {
     logic  [15:0]  TCPH_sourcePort;                             // 2 bytes
     logic  [15:0]  TCPH_destPort;                               // 2 bytes
     logic  [31:0]  TCPH_seqNum;                                 // 4 bytes
     logic  [31:0]  TCPH_ackNum;                                 // 4 bytes
     logic   [7:0]  TCPH_dataOffsetRsv;  //TCP_DATA_OFFSET << 4; // 1 byte
     logic   [7:0]  TCPH_Flags;                                  // 1 byte
     logic  [15:0]  TCPH_windowSize;                             // 2 bytes
     logic  [15:0]  TCPH_checksum;                               // 2 bytes
     logic  [15:0]  TCPH_urgentPointer;                          // 2 bytes
     //----------------------------------------------------
   
     logic  [41:0]   APL_data;  //setting max num of data bytes to 32, 
                                   //true range = [6 bytes to (1500 - 40) bytes]
     logic  [31:0]   EthH_fcs;    //Ethernet frame check sequence (CRC-32)
   
   //----------------------------------------------------
   // End of Full Ethernet Frame
   //----------------------------------------------------
   } ethernet_frame;

*/

/*
    // Acknowledgement frame sent on TX axis data path on the `LANE_CONTROLLER` lane
    // if SessionRegistrationMsg was parsed and complete:
    //
    // struct SessionRegistrationAcceptedMsg
    // {
    // 	SWHMessageHeader msgHeader;	uint32_t requestID;
    // } __attribute__((packed));
   
*/

/*
    // else if the sessionID is too large (e.g., sessionID > 63), then 
    // send back a SessionRegistrationRejectedMsg: 
    //
    // struct SessionRegistrationRejectedMsg
    // {
    // 	SWHMessageHeader msgHeader;	uint32_t requestID;
    // 	uint8_t internalRejectReason;
    // } __attribute__((packed));
    
*/
endpackage
