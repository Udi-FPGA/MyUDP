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
wire [31:0] local_ip    = {8'd192, 8'd168, 8'd1,   8'd128};
wire [15:0] local_port  = 16'd1234;

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
.des_port  (des_port  )
    );

reg [1:0] Devrx_dv;
always @(posedge phy_tx_clk or negedge rstn)
    if (!rstn) Devrx_dv <= 2'b00;
     else Devrx_dv <= {Devrx_dv[0],phy_rx_dv};
MyUDP_tx MyUDP_tx_inst(
.clk  (clk  ),
.rstn (rstn ),

.StartUDP  (Devrx_dv == 2'b01),
.phy_tx_clk(phy_tx_clk),
.phy_txd   (phy_txd),
.phy_tx_en (phy_tx_en),
.local_mac (local_mac ),
.local_ip  (local_ip  ),
.local_port(local_port),
.des_mac   (des_mac   ),
.des_ip    (des_ip    ),
.des_port  (des_port  )
    );
    
endmodule
