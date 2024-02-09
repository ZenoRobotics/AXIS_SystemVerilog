 class generator;
      
      transaction tr;              // Transaction object to generate and send
      mailbox #(transaction) mbx_gen2driv;        // Mailbox for communication -send data to driver through
      int packet_count = 0;        // Number of transaction (packets) to generate
      int i = 0;                   // Iteration counter
      int idx = 0;                 // for loop counter
      //int fullFrameCount = 0;      // Number of bytes in entire packet in transaction
     
      event gendone;            // Event to convey completion of requested number of transactions
      event drvnext;            // Event to signal when to send the next transaction
      event sconext;            // scoreboard complete its work
       
      function new(mailbox #(transaction) mbx_gen2driv);
        this.mbx_gen2driv = mbx_gen2driv;
        tr = new();
      endfunction; 
     
      task run(); 
        for(int i=0; i< packet_count; i++) begin
          assert (tr.randomize) else $error("Randomization failed");
          //Retrieve predefine (for now) overall byte count
          //fullFrameCount = tr.fullFrameByteCount; //Will need to change when Eth data field varies
          //-----------------------------------------
          //Calc TCP, IP and ETH CRCs and assign 
          //------- *To be implemented later --------
          //tr.IPH_headerChecksum;   // 16 bits long
          //tr.TCPH_checksum         // 16 bits long
          //tr.EthH_fcs              // 32 bits long
          //-----------------------------------------
          
          mbx_gen2driv.put(tr);
          $display("[GEN] : Packet # %0d sent out of %0d", i, packet_count);
          @(drvnext);
          //@(sconext);
        end 
        ->gendone;  
      endtask
      
    endclass