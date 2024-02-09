`include "Rx_Tx_Axis_Parmeters.vh"
       
   class driver;
      virtual top_mux_if tmuxIF;    // Virtual interface to top_mux_if
      mailbox #(transaction) mbx;   // Mailbox for communication
      int fullFrameCount32 = 0;       // Number of 32 bit words in entire packet in transaction
      logic [31:0] ethWordPacket[];  // Normally would be a Dynamic array of bytes for communication
      int idx = 0;                  // index counter for for-loop
      int numWordsSent = 0;         // 32 bit word sending loop 
      transaction  tr;              // Transaction object to receive from gen and send to interface
      
      event drvnext;
      event monnext;
     
      function new(mailbox #(transaction) mbx);
        this.mbx = mbx;
      endfunction; 
      //---------------------------------------------------------------//
      // Reset the DUT - Start
      //---------------------------------------------------------------//
      task reset();
        for (idx = 0; idx < NUM_RX_LANES; idx = idx + 1) begin
          tmuxIF.rx_rst[idx]  <= 1'b1;
          tmuxIF.rx_axis_tvalid[idx]  <= 1'b0;
          tmuxIF.rx_axis_tdata[idx]   <= 32'h00000000;
          tmuxIF.rx_axis_tlast[idx]   <= 1'b0;
          tmuxIF.rx_axis_tkeep[idx]   <= 4'h0;   
        end 
        
        for (idx = 0; idx < NUM_TX_LANES; idx = idx + 1) begin
           tmuxIF.tx_rst[idx]  <= 1'b1;
           tmuxIF.tx_axis_tready[idx]  <= 1'b0;
        end
        repeat (5) @(posedge tmuxIF.rx_clk[0]);
        
        //Remove resets
        for (idx = 0; idx < NUM_RX_LANES; idx = idx + 1) 
          tmuxIF.rx_rst[idx]  <= 1'b0;
           
        for (idx = 0; idx < NUM_TX_LANES; idx = idx + 1)
          tmuxIF.tx_rst[idx]  <= 1'b0;
         
        $display("[DRV] : DUT Reset Done");
        $display("------------------------------------------");
      endtask
      //---------------------------------------------------------------//
      // Reset the DUT - End
      //---------------------------------------------------------------//
       
      // Write full ethernet packet data to the FIFO (rx channel)
      task send_rx_channel_data(transaction  tr);
        //Compact transaction data into array of bytes
        //Retrieve predefine (for now) overall byte count
        //if(tr.fullFrameByteCount%4 == 0)
           //fullFrameCount32 = (tr.fullFrameByteCount/4); 
           fullFrameCount32 = PACKET_PAYLOAD_BYTES/4;
        //else  begin
          //Pad appl data if needed (packet byte count mod 4 == 0?)
          //Would have to add tkeep = 4'b.... to math padded bytes
          //Recale fullFrameCount32 after padding bytes added
        //end
        ethWordPacket = new [fullFrameCount32];  //Made constant length for now
        
        ethWordPacket = {tr.SWHWMH_destMAC,tr.SWHWMH_sourceMAC,
                       tr.SWHWMH_etherType,tr.SWHWMH_msgType,tr.SRM_requestID,tr.SRM_sessionID,
                       tr.SRM_exchangeCode,tr.EthH_destMAC,tr.EthH_sourceMAC,tr.EthH_etherType,
                       tr.IPH_versionAndIHL,tr.IPH_dscpAndECN,tr.IPH_totalLength,tr.IPH_identification,
                       tr.IPH_flagsAndFragmentOffset,tr.IPH_ttl,tr.IPH_protocol,tr.IPH_headerChecksum,
                       tr.IPH_sourceIP,tr.IPH_destIP,tr.TCPH_sourcePort,tr.TCPH_destPort,tr.TCPH_seqNum,
                       tr.TCPH_ackNum,tr.TCPH_dataOffsetRsv,tr.TCPH_Flags,tr.TCPH_windowSize,tr.TCPH_checksum,
                       tr.TCPH_urgentPointer,tr.APPL_data,tr.EthH_fcs};
        /*
        for(idx=0; idx < fullFrameCount; idx = idx+1)
          ethBytePacket[idx] = 32'h0;
        */
        //loop through settting rx axis signals and sending out data to interface
        for (numWordsSent = 0; numWordsSent < fullFrameCount32; numWordsSent++) begin
          @(posedge tmuxIF.rx_clk[LANE_CONTROLLER]);
          for (idx = 0; idx < NUM_RX_LANES; idx = idx + 1) begin
            tmuxIF.rx_rst[idx]            <= 1'b0;
            if(numWordsSent == (fullFrameCount32-1))
              tmuxIF.rx_axis_tlast[idx]   <= 1'b1;
            else
              tmuxIF.rx_axis_tlast[idx]   <= 1'b0;
            tmuxIF.rx_axis_tkeep[idx]     <= 4'h7;   //keep all bytes for now
          end 
          //Note: Sending valid data out on only one lane for now
          tmuxIF.rx_axis_tvalid[LANE_CONTROLLER]  <= 1'b1;
          tmuxIF.rx_axis_tdata[LANE_CONTROLLER]   <= ethWordPacket[numWordsSent];
          @(posedge tmuxIF.rx_clk[LANE_CONTROLLER]);
          //while(!tmuxIF.rx_axis_tready[`LANE_CONTROLLER]);
          $display("[DRV] : Num of Words Sent = %d",numWordsSent);  
        end
        $display("[DRV] : Rx Packet Sent");  
        @(posedge tmuxIF.rx_clk[LANE_CONTROLLER]);
        for (idx = 0; idx < NUM_RX_LANES; idx = idx + 1) begin
          tmuxIF.rx_axis_tlast[idx]   <= 1'b0;
          tmuxIF.rx_axis_tkeep[idx]   <= 4'h0;   
          tmuxIF.tx_axis_tready[idx]  <= 4'h0;
          tmuxIF.rx_axis_tvalid[idx]  <= 1'b0;
        end 
        @(posedge tmuxIF.rx_clk[LANE_CONTROLLER]);
        ->drvnext;
      endtask
      
      // Read data from the the mux (tx channel)
      task request_tx_channel_data();  
        @(posedge tmuxIF.tx_clk[LANE_OUTBOUND]);
        tmuxIF.tx_axis_tready[0] <= 1'b1;
        tmuxIF.tx_axis_tready[1] <= 1'b1;
        @(posedge tmuxIF.tx_clk[LANE_OUTBOUND]);
        $display("[DRV] : Tx Channel Ready");  
      endtask
      
      // Apply random stimulus to the DUT
      task run();
        forever begin
          mbx.get(tr);  
          request_tx_channel_data();
          send_rx_channel_data(tr);
        end
      endtask
      
    endclass
     