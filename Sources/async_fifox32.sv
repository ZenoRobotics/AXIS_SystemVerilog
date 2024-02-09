`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2023 06:11:01 PM
// Design Name: 
// Module Name: async_fifox32
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


module async_fifox32#( 
     parameter DATA_DEPTH = 16, DATA_WIDTH = 32, ADDR_SIZE = $clog2(DATA_DEPTH) 
 )
 (    
    input  wire                   s_axis_aclk,
    input  wire                   m_axis_aclk,
    input  wire                   s_axis_aresetn,
    input  wire                   s_axis_tvalid,
    input  wire [DATA_WIDTH-1:0]  s_axis_tdata,
    input  wire  [ADDR_SIZE-1:0]  s_axis_tkeep,
    input  wire                   s_axis_tlast,
    
    output reg                    m_axis_tvalid,  // output to mux
    output reg  [DATA_WIDTH-1:0]  m_axis_tdata,   // output to mux
    output reg   [ADDR_SIZE-1:0]  m_axis_tkeep,   // output to mux
    output reg                    m_axis_tlast,   // output to mux
    input  wire                   m_axis_tready   // input from mux
); 


// Fifo Memory
reg  [DATA_WIDTH-1:0] mem_data [DATA_DEPTH-1:0];
reg   [ADDR_SIZE-1:0] mem_keep [DATA_DEPTH-1:0];
reg                   mem_last [DATA_DEPTH-1:0];

reg  [ADDR_SIZE-1:0] wr_ptr = 0;
reg  [ADDR_SIZE-1:0] rd_ptr = 0;

reg  full  = 1'b0;
reg  empty = 1'b1;
reg  [ADDR_SIZE:0] data_count = 0;

int idx = 0;

always @(posedge s_axis_aclk) begin
  if(!s_axis_aresetn) begin
    empty  <= 1'b1;
    full   <= 1'b0;
    wr_ptr <= 0;
    rd_ptr <= 0;
    data_count <= 0;
    m_axis_tvalid <= 1'b0;
    //Zero out memory
    for (idx = 0; idx < DATA_DEPTH; idx=idx+1) begin
       mem_data[idx]  <= {DATA_WIDTH{1'b0}};
       mem_keep[idx]  <= {ADDR_SIZE{1'b0}};
       mem_last[idx]  <= 1'b0;
    end
  end
  //save write to memory if it's not full && data_in is valid
  else if (s_axis_tvalid && (data_count < ADDR_SIZE)) begin
    mem_data[wr_ptr]   <= s_axis_tdata;
    mem_keep[wr_ptr]   <= s_axis_tkeep;
    mem_last[wr_ptr]   <= s_axis_tlast;
    wr_ptr     <= wr_ptr + 1;
    data_count <= data_count + 1;
    m_axis_tvalid  <= 1'b0;
  end  
  // Read data from the FIFO if it's not empty and mux is ready
  else if (m_axis_tready && (data_count > 0)) begin
    m_axis_tdata   <= mem_data[rd_ptr] ;
    m_axis_tkeep   <= mem_keep[rd_ptr];
    m_axis_tlast   <= mem_last[rd_ptr];
    m_axis_tvalid  <= 1'b1;
    rd_ptr     <= rd_ptr + 1;
    data_count <= data_count - 1;
  end  
  else if (data_count == 0) begin 
    m_axis_tvalid <= 1'b0;
    empty  <= 1'b1;
    full   <= 1'b0;
    wr_ptr <= 0;
    rd_ptr <= 0;
  end
end

endmodule
