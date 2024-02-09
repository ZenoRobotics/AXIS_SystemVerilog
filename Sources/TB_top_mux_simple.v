`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2023 07:57:47 AM
// Design Name: 
// Module Name: TB_top_mux_simple
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



module TB_top_mux_simple;
    wire  [1:0]  rx_clk;
    wire  [1:0]  rx_rst;

    reg          rx_axis_tvalid [1:0];
    wire [31:0]  rx_axis_tdata  [1:0];
    wire         rx_axis_tlast  [1:0];
    wire  [3:0]  rx_axis_tkeep  [1:0];

    wire  [1:0]  tx_clk;
    wire  [1:0]  tx_rst;

    wire         tx_axis_tready [1:0];
    wire         tx_axis_tvalid [1:0];
    wire  [31:0] tx_axis_tdata  [1:0];
    wire         tx_axis_tlast  [1:0];
    wire  [3:0]  tx_axis_tkeep  [1:0];

  // Singular Versions
  reg tclk = 0;
  reg trst = 0;
  
  reg buf_rx_axis_tlast;
  reg    [3:0] buf_rx_axis_tkeep;
  reg   [31:0] buf_rx_axis_tdata;
  reg          buf_tx_axis_tready;
  
  wire         tx_axis_tvalid_out [1:0];
  wire         tx_axis_tlast_out  [1:0];
  wire  [3:0]  tx_axis_tkeep_out  [1:0];
  wire  [31:0] tx_axis_tdata_out  [1:0];
  
  always begin
    #5 tclk = ~tclk;
  end 
  
  initial begin
    #1;
    trst=1'b1;
    repeat(3)
      @(posedge tclk);
    trst=1'b0;
    repeat(4)
      @(posedge tclk);
    {{rx_axis_tvalid[1],rx_axis_tvalid[0]}, buf_rx_axis_tlast, buf_rx_axis_tkeep, buf_rx_axis_tdata, buf_tx_axis_tready} = {{1'b1,1'b1},1'b0, 4'h2, 32'h00_01_02_03, 1'b1};
    @(posedge tclk);
    {{rx_axis_tvalid[1],rx_axis_tvalid[0]}, buf_rx_axis_tlast, buf_rx_axis_tkeep, buf_rx_axis_tdata, buf_tx_axis_tready} = {{1'b1,1'b1}, 1'b0, 4'h2, 32'h04_05_06_07, 1'b1};
    @(posedge tclk);
    {{rx_axis_tvalid[1],rx_axis_tvalid[0]}, buf_rx_axis_tlast, buf_rx_axis_tkeep, buf_rx_axis_tdata, buf_tx_axis_tready} = {{1'b1,1'b1}, 1'b0, 4'h2, 32'h08_09_0A_0B, 1'b1};
      @(posedge tclk);
    {{rx_axis_tvalid[1],rx_axis_tvalid[0]}, buf_rx_axis_tlast, buf_rx_axis_tkeep, buf_rx_axis_tdata, buf_tx_axis_tready} = {{1'b1,1'b1},1'b0, 4'h2, 32'h0C_0D_0E_0F, 1'b1};
    @(posedge tclk);
    {{rx_axis_tvalid[1],rx_axis_tvalid[0]}, buf_rx_axis_tlast, buf_rx_axis_tkeep, buf_rx_axis_tdata, buf_tx_axis_tready} = {{1'b1,1'b1}, 1'b0, 4'h2, 32'h10_11_12_13, 1'b1};
    @(posedge tclk);
    {{rx_axis_tvalid[1],rx_axis_tvalid[0]}, buf_rx_axis_tlast, buf_rx_axis_tkeep, buf_rx_axis_tdata, buf_tx_axis_tready} = {{1'b1,1'b1}, 1'b1, 4'h2, 32'h14_15_16_17, 1'b1}; 
     @(posedge tclk);
    {{rx_axis_tvalid[1],rx_axis_tvalid[0]}, buf_rx_axis_tlast, buf_rx_axis_tkeep, buf_rx_axis_tdata, buf_tx_axis_tready} = {{1'b0,1'b0}, 1'b0, 4'h0, 32'h00000000, 1'b1};
    repeat(10)
      @(posedge tclk);
    $display("Finishing testbench!");
    $finish;
end

assign tx_clk[1:0] = {tclk,tclk};
assign tx_clk[1:0] = {tclk,tclk};

assign rx_clk[1:0] = {tclk,tclk};
assign rx_clk[1:0] = {tclk,tclk};

assign tx_rst[1:0] = {trst,trst};
assign tx_rst[1:0] = {trst,trst};

assign rx_rst[1:0] = {trst,trst};
assign rx_rst[1:0] = {trst,trst};

assign rx_axis_tlast[0]  = buf_rx_axis_tlast;
assign rx_axis_tlast[1]  = buf_rx_axis_tlast;

assign rx_axis_tkeep[0]  = buf_rx_axis_tkeep;
assign rx_axis_tkeep[1]  = buf_rx_axis_tkeep;
assign rx_axis_tdata[0]  = buf_rx_axis_tdata;
assign rx_axis_tdata[1]  = buf_rx_axis_tdata;

assign tx_axis_tready[0] = buf_tx_axis_tready;
assign tx_axis_tready[1] = buf_tx_axis_tready;

wire temp[1:0];
assign temp[0] = rx_axis_tvalid[0];
assign temp[1] = rx_axis_tvalid[1];
  // Instantiate module here
toplevel_mux
toplevel_mux_i
(
    .rx_clk(rx_clk),
    .rx_rst(rx_rst),

    .rx_axis_tvalid(temp),
    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tkeep(rx_axis_tkeep),

    .tx_clk(tx_clk),
    .tx_rst(tx_rst),

    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tvalid(tx_axis_tvalid_out),
    .tx_axis_tdata(tx_axis_tdata_out),
    .tx_axis_tlast(tx_axis_tlast_out),
    .tx_axis_tkeep(tx_axis_tkeep_out)
);
/*
    input wire [NUM_RX_LANES-1:0] rx_clk,
    input wire [NUM_RX_LANES-1:0] rx_rst,

    input wire        rx_axis_tvalid [NUM_RX_LANES-1:0],
    input wire [31:0] rx_axis_tdata [NUM_RX_LANES-1:0],
    input wire        rx_axis_tlast [NUM_RX_LANES-1:0],
    input wire [3:0]  rx_axis_tkeep [NUM_RX_LANES-1:0],

    input wire [NUM_TX_LANES-1:0] tx_clk,
    input wire [NUM_TX_LANES-1:0] tx_rst,

    input wire         tx_axis_tready [NUM_TX_LANES-1:0],
    output wire        tx_axis_tvalid [NUM_TX_LANES-1:0],
    output wire [31:0] tx_axis_tdata [NUM_TX_LANES-1:0],
    output wire        tx_axis_tlast [NUM_TX_LANES-1:0],
    output wire [3:0]  tx_axis_tkeep [NUM_TX_LANES-1:0]
*/

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule

