`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2023 08:07:22 PM
// Design Name: 
// Module Name: monitor
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
import ethernet_frame_pkg::*;

class monitor;
 /*  
  virtual top_mux_if tmuxIF;
 
  transaction tr;
  logic [31:0] ethWordPacket[];  // Normally would be a Dynamic array of bytes for communication
 
  event sconext;
  int packetWordCnt = 0;
  bit doneRcvPkt = 1'b0; //False = 1'b0, True = 1'b1
  
  mailbox #(transaction) mbxms;
 
 
  function new( mailbox #(transaction) mbxms );
    this.mbxms = mbxms;
  endfunction
  
  
  task run();
    
    tr = new();
    ethWordPacket = new [PACKET_PAYLOAD_BYTES/4];  //Made constant length for now
    
    forever 
      begin
        
      @(posedge tmuxIF.rx_clk[LANE_CONTROLLER]);
        
      //////////////////////////Rx Axis Data To DUT logic  
      if(!tmuxIF.rx_rst[LANE_CONTROLLER]) 
        begin
          if(tmuxIF.rx_axis_tvalid[LANE_CONTROLLER] && !doneRcvPkt) begin 
            if(tmuxIF.rx_axis_tkeep[LANE_CONTROLLER] == 4'h7) begin
              ethWordPacket[packetWordCnt] = tmuxIF.rx_axis_tdata;
              packetWordCnt = packetWordCnt + 1;  
            
              if(tmuxIF.rx_axis_tlast[LANE_CONTROLLER] == 1'b1)
                doneRcvPkt = 1'b1;
                
            end
            
          else if (doneRcvPkt)   //assuming there is at least one clock space between end of packet and start of new
            begin
              //copy 
              packetWordCnt = 0;
              doneRcvPkt = 1'b0;
            end    
          
        end
         
         tr.awvalid = tmuxIFawvalid;
         tr.arvalid = tmuxIF.arvalid;
         
         for(int i = 0; i< len; i++) begin
           @(posedge vif.wready); 
           @(posedge vif.clk);
           tr.awaddr = vif.awaddr;
           tr.wdata  = vif.wdata;
           tr.awburst = vif.awburst;   
           mbxms.put(tr);
           $display("[MON] : ADDR : %0x DATA : %0x BURST TYPE : %0d",tr.awaddr, tr.wdata, tr.awburst);    
         end
       
         @(posedge vif.clk);
         @(negedge vif.bvalid);
         @(posedge vif.clk);
         $display("[MON] : Transaction Complete");  
      end
 
     /////////////////////Tx Axis Data From DUT logic   
        
       if(vif.arvalid == 1'b1)
        begin
         len = vif.arlen + 1;    
         tr.awvalid = vif.awvalid;
         tr.arvalid = vif.arvalid;
         
     
      for(int i = 0; i< len; i++) begin  
       @(posedge  vif.rvalid);
       @(posedge vif.clk);
       tr.rdata  = vif.rdata;
       tr.arburst = vif.arburst;
       tr.araddr = vif.araddr;
       mbxms.put(tr); 
       $display("[MON] : ADDR : %0x DATA : %0x BURST TYPE : %0d",tr.araddr, tr.rdata, tr.arburst);
       end
       
      @(posedge vif.clk);
      @(negedge vif.rlast);
      @(posedge vif.clk);
      $display("[MON] : Transaction Complete");
      end
       ->sconext; 
      end 
  endtask
 */
endclass