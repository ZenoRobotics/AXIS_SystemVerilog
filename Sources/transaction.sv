`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2023 12:01:31 PM
// Design Name: 
// Module Name: transaction
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

////// Transaction Class

class transaction;
  
   //defines in logic format   
   logic [15:0]  IP_ETHERTYPE = 16'h0800;
   logic  [7:0]  TCP_IP_PROTOCOL_NUM = 8'h06;
   logic  [7:0]  IPV4_VERSION = 8'h04;
   logic  [7:0]  MIN_IP_IHL_VALUE = 8'h05;
   logic  [7:0]  TCP_DATA_OFFSET = 8'h05;
  
//---------------------------------------------
// Extra user Data. Not part of MAC Header 
// protocol nor IPv4
//---------------------------------------------

   bit  [15:0]  fullFrameByteCount =  PACKET_PAYLOAD_BYTES;
   /// struct SWHWMessageHeader {
   ///     uint8_t destMAC[6];
   ///     uint8_t sourceMAC[6];
   ///     uint16_t ethertype;
   ///     uint8_t msgType; }
   rand bit [47:0] SWHWMH_destMAC;    // 6 bytes
   rand bit [47:0] SWHWMH_sourceMAC;  // 6 bytes
   bit [15:0] SWHWMH_etherType;       // 2 bytes
   bit [15:0] SWHWMH_msgType;        // was defined as 1 byte, but making it 2 bytes for even packet size of 32 bits
   
   ///struct SessionRegistrationMsg
   ///     SWWMessageHeader msgHeader; //Above fields 
   ///     uint32_t requestID;
   ///     uint8_t sessionID;
   ///     uint8_t exchangeCode;
   ///     TCPIPEthHeader sessionBoundHeader;
   rand bit [31:0] SRM_requestID;
   rand bit  [7:0] SRM_sessionID;
   rand bit  [7:0] SRM_exchangeCode;
  ///     TCPIPEthHeader sessionBoundHeader; // below fields
 //---------------------------------------------
 // End extra
 //---------------------------------------------
 
//----------------------------------------------------
// Start of Full Ethernet Frame
//----------------------------------------------------
  
   // ---------- struct TCPIPEthHeader --------------
   /// Also, for additional reference, please see the standard TCPIPEthHeader struct defined below:
   /// struct EthernetHeader {
   ///     uint8_t destMAC[6];
   ///     uint8_t sourceMAC[6];
   ///     uint16_t ethertype;
   /// } __attribute__((packed));
   rand bit  [47:0] EthH_destMAC ;  // 6 bytes or 48 bits
   rand bit  [47:0] EthH_sourceMAC; // 6 bytes or 48 bits
   bit  [15:0] EthH_etherType = IP_ETHERTYPE; ////htons(IP_ETHERTYPE); //length of eth payload or type 
   /// struct IPHeader {
   ///     uint8_t versionAndIHL;
   ///     uint8_t dscpAndECN;
   ///     uint16_t totalLength;
   ///     uint16_t identification;
   ///     uint16_t flagsAndFragmentOffset;
   ///     uint8_t ttl;
   ///     uint8_t protocol;
   ///     uint16_t headerChecksum;
   ///     uint8_t sourceIP[4];
   ///     uint8_t destIP[4];
   /// } __attribute__((packed));
   bit  [7:0] IPH_versionAndIHL = (IPV4_VERSION << 4) | MIN_IP_IHL_VALUE;
   rand bit  [7:0] IPH_dscpAndECN;
   bit  [15:0] IPH_totalLength =  APPL_DATA_BYTES + {8'h00,MIN_IP_IHL_VALUE};     //Number of total data in bytes in IP packet header + data (20 to 2^16).
                                                                  //20 bytes = no data (&TCP header).  Set to Constant for now
   bit  [15:0] IPH_identification;
   bit  [15:0] IPH_flagsAndFragmentOffset;
   bit   [7:0] IPH_ttl;
   bit   [7:0] IPH_protocol = TCP_IP_PROTOCOL_NUM;
   bit  [15:0] IPH_headerChecksum = 0;  //will need to calculate
   rand bit  [31:0] IPH_sourceIP;
   rand bit  [31:0] IPH_destIP;
   
   /// struct TCPHeader {
   ///     uint16_t sourcePort;
   ///     uint16_t destPort;
   ///     uint32_t seqNum;
   ///     uint32_t ackNum;
   ///     uint16_t dataOffsetAndFlags;
   ///     uint16_t windowSize;
   ///     uint16_t checksum;
   ///     uint16_t urgentPointer;
   /// } __attribute__((packed));
   rand bit  [15:0]  TCPH_sourcePort; 
   rand bit  [15:0]  TCPH_destPort;
   rand bit  [31:0]  TCPH_seqNum;
   rand bit  [31:0]  TCPH_ackNum;
   bit  [7:0]  TCPH_dataOffsetRsv = TCP_DATA_OFFSET << 4;
   bit  [7:0]  TCPH_Flags = 8'h00;
   bit  [15:0]  TCPH_windowSize;
   bit  [15:0]  TCPH_checksum = 0;  
   bit  [15:0]  TCPH_urgentPointer;
  
   rand  bit  [7:0] APPL_data [4:0];  //setting max num of data bytes to 32
   bit [31:0] EthH_fcs = 0;    //Ethernet frame check sequence (CRC-32)
   
 //----------------------------------------------------
 // End of Full Ethernet Frame
 //----------------------------------------------------

   constraint sessionID_range {SRM_sessionID inside {[0:63]};}

     
   function transaction copy();
       copy = new();
       copy.fullFrameByteCount = this.fullFrameByteCount;
       copy.SWHWMH_destMAC = this.SWHWMH_destMAC;
       copy.SWHWMH_sourceMAC = this.SWHWMH_sourceMAC;
       copy.SWHWMH_etherType = this.SWHWMH_etherType;
       copy.SWHWMH_msgType = this.SWHWMH_msgType;
       copy.SRM_requestID = this.SRM_requestID;
       copy.SRM_sessionID = this.SRM_sessionID;
       copy.SRM_exchangeCode = this.SRM_exchangeCode;
       copy.EthH_destMAC = this.EthH_destMAC;
       copy.EthH_sourceMAC = this.EthH_sourceMAC;
       copy.EthH_etherType = this.EthH_etherType;
       copy.IPH_versionAndIHL = this.IPH_versionAndIHL;
       copy.IPH_dscpAndECN = this.IPH_dscpAndECN;
       copy.IPH_totalLength = this.IPH_totalLength;
       copy.IPH_identification = this.IPH_identification;
       copy.IPH_flagsAndFragmentOffset = this.IPH_flagsAndFragmentOffset;
       copy.IPH_ttl = this.IPH_ttl;
       copy.IPH_protocol = this.IPH_protocol;
       copy.IPH_headerChecksum = this.IPH_headerChecksum;
       copy.IPH_sourceIP = this.IPH_sourceIP;
       copy.IPH_destIP = this.IPH_destIP;
       copy.TCPH_sourcePort = this.TCPH_sourcePort; 
       copy.TCPH_destPort = this.TCPH_destPort;
       copy.TCPH_seqNum = this.TCPH_seqNum;
       copy.TCPH_ackNum = this.TCPH_ackNum;
       copy.TCPH_dataOffsetRsv = this.TCPH_dataOffsetRsv;
       copy.TCPH_Flags = this.TCPH_Flags;
       copy.TCPH_windowSize = this.TCPH_windowSize;
       copy.TCPH_checksum = this.TCPH_checksum;
       copy.TCPH_urgentPointer = this.TCPH_urgentPointer;
       copy.APPL_data = this.APPL_data;  //setting max num of data bytes to 32
       copy.EthH_fcs = this.EthH_fcs;  
   endfunction
      
endclass
 
