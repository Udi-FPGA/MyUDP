`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2026 12:29:27 PM
// Design Name: 
// Module Name: MyUDP_rx
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


module MyUDP_rx(
input clk    ,
input rstn,
input phy_rx_clk,
input [3:0] phy_rxd,
input phy_rx_dv,
input phy_rx_er,

input [47:0] local_mac ,
input [31:0] local_ip  ,
input [15:0] local_port,
output [47:0] des_mac ,
output [31:0] des_ip  ,
output [15:0] des_port
    );
reg MainCountOn;
reg [15:0] MainCount;
reg [7:0] RX_DATA_d0;
reg [63:0] Main_DATA;
always @(posedge phy_rx_clk or negedge rstn)
    if (!rstn) begin
         MainCountOn <= 1'b0;
         MainCount   <= 16'h0000;
         RX_DATA_d0  <= 8'h00;
         Main_DATA   <= 63'h0000000000000000;
              end
     else begin 
         MainCountOn <= phy_rx_dv;
         RX_DATA_d0  <= {phy_rxd,RX_DATA_d0[7:4]};     
         if (MainCountOn) begin 
              MainCount   <= MainCount + 1;
              if (MainCount[0]) Main_DATA <= {Main_DATA[55:0],RX_DATA_d0};
                   end
          else MainCount <= 16'h0000; 
          end  

reg [47:0] Reg_DesMACadd ;//          6 octets
reg [47:0] Reg_SrcMACadd ;//          6 octets
reg [15:0] Reg_Ethertype ;//(0x0806)  2 octets
always @(posedge phy_rx_clk or negedge rstn)
    if (!rstn) begin 
             Reg_DesMACadd <= 48'h000000000000;
             Reg_SrcMACadd <= 48'h000000000000;
             Reg_Ethertype <= 16'h0000;
                   end
    else case (MainCount)  
         16'h001d : Reg_DesMACadd <= Main_DATA[47:0];
         16'h0029 : Reg_SrcMACadd <= Main_DATA[47:0];
         16'h002d : Reg_Ethertype <= Main_DATA[15:0];
             default : ;
         endcase

reg [63:0] Reg_ARPparm ;//          8 octets
reg [47:0] Reg_SHAmac ;//          6 octets
reg [31:0] Reg_SHAIP ;//          4octets
reg [47:0] Reg_THAmac ;//          6 octets
reg [31:0] Reg_THAIP ;//          4octets
always @(posedge phy_rx_clk or negedge rstn)
    if (!rstn) begin 
             Reg_ARPparm  <= 64'h0000000000000000;//          8 octets
             Reg_SHAmac   <= 48'h000000000000    ;//          6 octets
             Reg_SHAIP    <= 32'h00000000        ;//          4octets
             Reg_THAmac   <= 48'h000000000000    ;//          6 octets
             Reg_THAIP    <= 32'h00000000        ;//          4octets
                   end
    else case (MainCount)  
         16'h003d : Reg_ARPparm <= Main_DATA;
         16'h0049 : Reg_SHAmac  <= Main_DATA[47:0];
         16'h0051 : Reg_SHAIP   <= Main_DATA[31:0];
         16'h005d : Reg_THAmac  <= Main_DATA[47:0];
         16'h0065 : Reg_THAIP   <= Main_DATA[31:0];
             default : ;
         endcase
                            
wire RXreset_crc = (MainCount[15:1] == 15'h0008) ? 1'b1 : 1'b0;
wire RXupdate_crc = (MainCount[0]) ? 1'b1 : 1'b0;
wire [31:0] RXcrc32;
reg [31:0] DelRXcrc32 [0:1];
crc32_d8 TXcrc32_d8_inst
(
  .clk       (phy_rx_clk)  ,
  .reset_p   (!rstn)  ,
             
  .data      (Main_DATA[7:0])  ,
  .crc_init  (RXreset_crc)  ,
  .crc_en    (RXupdate_crc)  ,
  .crc_result(RXcrc32)
);
always @(posedge phy_rx_clk or negedge rstn)
    if (!rstn) begin
         DelRXcrc32[0] <= 32'h00000000;
         DelRXcrc32[1] <= 32'h00000000;
              end
     else if (RXupdate_crc) begin
         DelRXcrc32[0] <= RXcrc32;
         DelRXcrc32[1] <= DelRXcrc32[0];
              end

reg PKT_ok;
always @(posedge phy_rx_clk or negedge rstn)
    if (!rstn) PKT_ok <= 1'b0;
     else if (DelRXcrc32[1] == {RX_DATA_d0,Main_DATA[7:0],Main_DATA[15:8],Main_DATA[23:16]}) PKT_ok <= 1'b1;
      else PKT_ok <= 1'b0;
              
        
endmodule
