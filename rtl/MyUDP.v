`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2026 04:52:12 PM
// Design Name: 
// Module Name: MyUDP
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


module MyUDP(
input clk  ,
input rstn ,

input phy_rx_clk,
input [3:0] phy_rxd,
input phy_rx_dv,
input phy_rx_er,
input phy_tx_clk,
output [3:0] phy_txd,
output phy_tx_en
    );

// Configuration
wire [47:0] local_mac   = 48'h02_00_00_00_00_00;
wire [31:0] local_ip    = {8'd192, 8'd168, 8'd1,8'd128};
wire [15:0] local_port  = 16'd1234;

wire SendARP;
wire SendUDP;
wire [47:0] des_mac ;
wire [31:0] des_ip  ;
wire [15:0] des_port;

wire UDPDATAread  ;
wire [7:0] UDPDATA;
wire UDPDATAempty ;
wire [9:0] UDPDATArdcount;

MyUDP_rx MyUDP_rx_inst(
.clk (clk )   ,
.rstn(rstn)   ,
.phy_rx_clk(phy_rx_clk),
.phy_rxd   (phy_rxd   ),
.phy_rx_dv (phy_rx_dv ),
.phy_rx_er (phy_rx_er ),
.local_mac (local_mac ),
.local_ip  (local_ip  ),
.local_port(local_port),
.des_mac   (des_mac   ),
.des_ip    (des_ip    ),
.des_port  (des_port  ),
.UDPDATAread (UDPDATAread ),
.UDPDATA     (UDPDATA     ),
.UDPDATAempty(UDPDATAempty),
.UDPDATArdcount(UDPDATArdcount),
.SendARP   (SendARP   ),
.SendUDP   (SendUDP   )
    );

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
ila_2 ila_2_inst (
	.clk(clk), // input wire clk

	.probe0(phy_rx_clk), // input wire [0:0]  probe0  
	.probe1(phy_rxd), // input wire [3:0]  probe1 
	.probe2(phy_rx_dv), // input wire [0:0]  probe2 
	.probe3(phy_rx_er), // input wire [0:0]  probe3 
	.probe4(phy_tx_clk), // input wire [0:0]  probe4 
	.probe5(phy_txd), // input wire [3:0]  probe5 
	.probe6(phy_tx_en), // input wire [0:0]  probe6 
	.probe7(SendARP), // input wire [0:0]  probe7 
	.probe8(SendUDP), // input wire [0:0]  probe8
	.probe9(UDPDATAread), // input wire [0:0]  probe9 
	.probe10(UDPDATA), // input wire [7:0]  probe10 
	.probe11(UDPDATAempty), // input wire [0:0]  probe11 
	.probe12(UDPDATArdcount) // input wire [9:0]  probe12
);

//reg [1:0] Devrx_dv;
//always @(posedge phy_tx_clk or negedge rstn)
//    if (!rstn) Devrx_dv <= 2'b00;
//     else Devrx_dv <= {Devrx_dv[0],phy_rx_dv};
MyUDP_tx MyUDP_tx_inst(
.clk  (clk  ),
.rstn (rstn ),

.StartARP  (SendARP),//Devrx_dv == 2'b01),
.StartUDP  (SendUDP),//Devrx_dv == 2'b01),
.phy_tx_clk(phy_tx_clk),
.phy_txd   (phy_txd),
.phy_tx_en (phy_tx_en),
.local_mac (local_mac ),
.local_ip  (local_ip  ),
.local_port(local_port),
.des_mac   (des_mac   ),
.des_ip    (des_ip    ),
.des_port  (des_port  ),
.UDPDATAread (UDPDATAread ),
.UDPDATA     (UDPDATA     ),
.UDPDATAempty(UDPDATAempty),
.UDPDATArdcount(UDPDATArdcount)
    );
    
endmodule
