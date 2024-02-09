`timescale 1ns / 1ps

//`include "top_mux_if.sv"
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"

      
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2023 07:25:11 AM
// Design Name: 
// Module Name: testbench_sv_env
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
 
module testbench_sv_env;
    logic clock;
    generator gen;
    driver drv;
    event next;
    
    mailbox #(transaction) mbx;
    
    top_mux_if tmuxIF();    // Interface to top_mux_if
    
    toplevel_mux dut (
       .rx_clk(tmuxIF.rx_clk),
       .rx_rst(tmuxIF.rx_rst),

       .rx_axis_tvalid(tmuxIF.rx_axis_tvalid),
       .rx_axis_tdata(tmuxIF.rx_axis_tdata),
       .rx_axis_tlast(tmuxIF.rx_axis_tlast),
       .rx_axis_tkeep(tmuxIF.rx_axis_tkeep),

       .tx_clk(tmuxIF.tx_clk),
       .tx_rst(tmuxIF.tx_rst),

       .tx_axis_tready(tmuxIF.tx_axis_tready),
       .tx_axis_tvalid(tmuxIF.tx_axis_tvalid),
       .tx_axis_tdata(tmuxIF.tx_axis_tdata),
       .tx_axis_tlast(tmuxIF.tx_axis_tlast),
       .tx_axis_tkeep(tmuxIF.tx_axis_tkeep)
    );
        
        initial begin
          clock <= 0;
        end
        
        always #5 clock <= ~clock;
        
        initial begin
          mbx = new();
          
          gen = new(mbx);
          
          gen.packet_count = 2;
          
          drv = new(mbx);
          
          drv.tmuxIF = tmuxIF;
          gen.drvnext = next;
          drv.drvnext = next;
          
        end
        
        initial begin
          drv.reset();
          fork
            gen.run();
            drv.run();
          join
          wait(gen.gendone.triggered);
          #200;
          $finish();  
        end
        
        initial begin
          $dumpfile("dump.vcd");
          $dumpvars;
        end
        
        assign tmuxIF.rx_clk[0] = clock;
        assign tmuxIF.rx_clk[1] = clock;
        assign tmuxIF.tx_clk[0] = clock;
        assign tmuxIF.tx_clk[1] = clock;
        
endmodule
     
    /////////////////////////////////////////////////////
  /*   
    class scoreboard;
      
      mailbox #(transaction) mbx;  // Mailbox for communication
      transaction tr;          // Transaction object for monitoring
      event next;
      bit [7:0] din[$];       // Array to store written data
      bit [7:0] temp;         // Temporary data storage
      int err = 0;            // Error count
      
      function new(mailbox #(transaction) mbx);
        this.mbx = mbx;     
      endfunction;
     
      task run();
        forever begin
          mbx.get(tr);
          $display("[SCO] : Wr:%0d rd:%0d din:%0d dout:%0d full:%0d empty:%0d", tr.wr, tr.rd, tr.data_in, tr.data_out, tr.full, tr.empty);
          
          if (tr.wr == 1'b1) begin
            if (tr.full == 1'b0) begin
              din.push_front(tr.data_in);
              $display("[SCO] : DATA STORED IN QUEUE :%0d", tr.data_in);
            end
            else begin
              $display("[SCO] : FIFO is full");
            end
            $display("--------------------------------------"); 
          end
        
          if (tr.rd == 1'b1) begin
            if (tr.empty == 1'b0) begin  
              temp = din.pop_back();
              
              if (tr.data_out == temp)
                $display("[SCO] : DATA MATCH");
              else begin
                $error("[SCO] : DATA MISMATCH");
                err++;
              end
            end
            else begin
              $display("[SCO] : FIFO IS EMPTY");
            end
            
            $display("--------------------------------------"); 
          end
          
          -> next;
        end
      endtask
      
    endclass
     
    ///////////////////////////////////////////////////////
     
    class environment;
     
      generator gen;
      driver drv;
      monitor mon;
      scoreboard sco;
      mailbox #(transaction) gdmbx;  // Generator + Driver mailbox
      mailbox #(transaction) msmbx;  // Monitor + Scoreboard mailbox
      event nextgs;
      virtual top_mux_if tmuxIF;
      
      function new(virtual top_mux_if tmuxIF);
        gdmbx = new();
        gen = new(gdmbx);
        drv = new(gdmbx);
        msmbx = new();
        mon = new(msmbx);
        sco = new(msmbx);
        this.tmuxIF = tmuxIF;
        drv.tmuxIF = this.tmuxIF;
        mon.tmuxIF = this.tmuxIF;
        gen.next = nextgs;
        sco.next = nextgs;
      endfunction
      
      task pre_test();
        drv.reset();
      endtask
      
      task test();
        fork
          gen.run();
          drv.run();
          mon.run();
          sco.run();
        join_any
      endtask
      
      task post_test();
        wait(gen.done.triggered);  
        $display("---------------------------------------------");
        $display("Error Count :%0d", sco.err);
        $display("---------------------------------------------");
        $finish();
      endtask
      
      task run();
        pre_test();
        test();
        post_test();
      endtask
      
    endclass
     
    ///////////////////////////////////////////////////////    
//----------------------------------------------------------------//
*/

