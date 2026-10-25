`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2026 03:35:49 PM
// Design Name: 
// Module Name: MyUDP_top
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


module MyUDP_top(
    input Clk,
    input Rst_n,
    input [1:0] key_in,
    output [1:0] Led,

  //eth_rx
  input         rgmii_rx_clk_i,
  input  [3:0]  rgmii_rxd     ,
  input         rgmii_rxdv    ,
  //eth_tx
  output        rgmii_tx_clk,
  output  [3:0] rgmii_txd   ,
  output        rgmii_txen  ,

  output        eth_rstn,  
  output        eth_mdc,
  output        eth_mdio
    );

// Configuration
wire [47:0] local_mac   = 48'h02_00_00_00_00_00;
wire [31:0] local_ip    = {8'd192, 8'd168, 8'd1,8'd128};
wire [15:0] local_port  = 16'd1234;

wire    gmii_rx_clk;// = rgmii_rx_clk_i;
wire    gmii_tx_clk;// = rgmii_rx_clk_i;
wire   rgmii_rx_clk;// = rgmii_rx_clk_i;
//wire   rgmii_tx_clk;// = rgmii_rx_clk_i;
wire   clk125m;
wire   locked;
//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
  clk_wiz_0 clk_wiz_0
   (
    // Clock out ports
    .clk_out1(rgmii_rx_clk),     // output clk_out1
    // Status and control signals
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(rgmii_rx_clk_i)      // input clk_in1
);

  BUFG BUFG_pclk (
    .O(clk125m        ), // 1-bit output: Clock output
    .I(rgmii_rx_clk    )  // 1-bit input: Clock input
  ); 

//assign rgmii_tx_clk = rgmii_rx_clk_i;

 assign eth_rstn = 1;
 assign eth_mdc  = 1;
 assign eth_mdio = 1;
 
wire [7:0] gmii_rxd;
wire       gmii_rxdv;
wire       gmii_rxer;
wire [7:0] gmii_txd ;  
wire       gmii_txen;  
wire       gmii_txer;  

gmii_inter gmii_inter_inst(
  .reset       (!Rst_n),                 //input reset,               

  .rgmii_rx_clk(rgmii_rx_clk),  //input         rgmii_rx_clk,
  .rgmii_rxd   (rgmii_rxd),  //input  [3:0]  rgmii_rxd   ,
  .rgmii_rxdv  (rgmii_rxdv),  //input         rgmii_rxdv  ,

//  .gmii_rx_clk (),   //output        gmii_rx_clk, 
  .gmii_rxd    (gmii_rxd),    //output [7:0]  gmii_rxd   , 
  .gmii_rxdv   (gmii_rxdv),   //output        gmii_rxdv  , 
  .gmii_rxer   (gmii_rxer),   //output        gmii_rxer  , 

  .gmii_tx_clk (clk125m),    //input        gmii_tx_clk,  
  .gmii_txd    (gmii_txd ),    //input  [7:0] gmii_txd   ,  
  .gmii_txen   (gmii_txen),    //input        gmii_txen  ,  
  .gmii_txer   (1'b0),    //input        gmii_txer  ,  

  .rgmii_tx_clk(rgmii_tx_clk),   //output       rgmii_tx_clk, 
  .rgmii_txd   (rgmii_txd   ),   //output [3:0] rgmii_txd   , 
  .rgmii_txen  (rgmii_txen  )    //output       rgmii_txen    
    );

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
ila_0 ila_0_inst (
	.clk(clk125m), // input wire clk

	.probe0(Rst_n), // input wire [0:0]  probe0  
	.probe1(gmii_rxd), // input wire [7:0]  probe1 
	.probe2(gmii_rxdv), // input wire [0:0]  probe2 
	.probe3(gmii_rxer), // input wire [0:0]  probe3 
	.probe4(gmii_txd), // input wire [7:0]  probe4 
	.probe5(gmii_txen) // input wire [0:0]  probe5
);

wire [47:0] desMAC ; //   output [47:0] desMAC ,             
wire [47:0] srcMAC ; //   output [47:0] srcMAC ,  
wire [31:0] desIP  ; //   output [31:0] desIP  ,             
wire [31:0] srcIP  ; //   output [31:0] srcIP  ,  
wire [15:0] desPORT; //   output [15:0] desPORT,             
wire [15:0] srcPORT; //   output [15:0] srcPORT,  
wire [15:0] EthType; //   output [15:0] EthType,             
wire [15:0] Length ; //   output [15:0] Length 

wire SendARP;
wire SendUDP;

MyUDP_rx MyUDP_rx_inst(
  .clk125(clk125m),
  .rstn  (Rst_n),
  
  .local_mac (local_mac ),
  .local_ip  (local_ip  ),
  .local_port(local_port), 
  
  .gmii_rxd (gmii_rxd   ),  
  .gmii_rxdv(gmii_rxdv  ),  

  .desMAC (desMAC ),             
  .srcMAC (srcMAC ),  
  .desIP  (desIP  ),             
  .srcIP  (srcIP  ),  
  .desPORT(desPORT),             
  .srcPORT(srcPORT),  
  .EthType(EthType),             
  .Length (Length ),

  .SendARP(SendARP),
  .SendUDP(SendUDP)
    );

reg [7:0] DelSendARP;
always @(posedge clk125m) DelSendARP <= {DelSendARP[6:0],SendARP}; 
MyUDP_tx MyUDP_tx_inst(
  .clk125(clk125m),
  .rstn  (Rst_n),
  
  .local_mac (local_mac ),
  .local_ip  (local_ip  ),
  .local_port(local_port), 
  
  .gmii_txd (gmii_txd   ),  
  .gmii_txen(gmii_txen  ),  

  .desMAC (srcMAC ),             
  .srcMAC (desMAC ),  
  .desIP  (srcIP  ),             
  .srcIP  (desIP  ),  
  .desPORT(srcPORT),             
  .srcPORT(desPORT),  
  .EthType(EthType),             
  .Length (Length ),

  .SendARP(SendARP),
//  .SendARP(DelSendARP[7]),
  .SendUDP(SendUDP)  
    );

endmodule
