`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2023 02:48:01 PM
// Design Name: 
// Module Name: environment
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


`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"

class environment;
  
  //generator and driver instance
  generator gen;
  driver    driv;
  
  //mailbox handle's
  mailbox gen2driv;
  
  //event for synchronization between generator and test
  event gen_ended;
  
  //virtual interface
  virtual mem_intf mem_vif;
  
  //constructor
  function new(virtual mem_intf mem_vif);
    //get the interface from test
    this.mem_vif = mem_vif;
    
    //creating the mailbox (Same handle will be shared across generator and driver)
    gen2driv = new();
    
    //creating generator and driver
    gen = new(gen2driv);
    driv = new(gen2driv);
  endfunction

  task pre_test();
    driv.reset();
  endtask
  
  task test();
    fork 
      gen.run();
      driv.run();
    join_any
  endtask
  
  task post_test();
    wait(gen_ended.triggered);
    wait(gen.repeat_count == driv.no_transactions);
  endtask  
  
  //run task
  task run;
    pre_test();
    test();
    post_test();
    $finish;
  endtask
  
endclass
