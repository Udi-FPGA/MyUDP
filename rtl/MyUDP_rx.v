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
output [15:0] des_port,

output UDPDATAread,
output [7:0] UDPDATA,
output UDPDATAempty,
output [9:0] UDPDATArdcount,

output SendARP,
output SendUDP
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

//reg [63:0] Reg_ARPparm ;//          8 octets
reg [31:0] Reg_SHAIP ;//          4octets
reg [31:0] Reg_THAIP ;//          4octets
reg [15:0] Reg_SHAport ;//          4octets
reg [15:0] Reg_THAport ;//          4octets
always @(posedge phy_rx_clk or negedge rstn)
    if (!rstn) begin
           Reg_SHAIP   <= 32'h00000000;//          4octets
           Reg_THAIP   <= 32'h00000000;//          4octets
           Reg_SHAport <= 16'h0000;//          4octets
           Reg_THAport <= 16'h0000;//          4octets
                end
     else if (Reg_Ethertype == 16'h0806) begin 
                  if(MainCount == 16'h0051)Reg_SHAIP <= Main_DATA[31:0];
                  if(MainCount == 16'h0065)Reg_THAIP <= Main_DATA[31:0];
                           end
     else if (Reg_Ethertype == 16'h0800) begin 
                  if(MainCount == 16'h004d)Reg_SHAIP <= Main_DATA[31:0];
                  if(MainCount == 16'h0055)Reg_THAIP <= Main_DATA[31:0];
                  if(MainCount == 16'h0059)Reg_SHAport <= Main_DATA[15:0];
                  if(MainCount == 16'h005d)Reg_THAport <= Main_DATA[15:0];
                           end
     
assign des_mac  = Reg_SrcMACadd;
assign des_ip   = Reg_SHAIP ;
assign des_port = Reg_SHAport;

reg [15:0] IPlength ;                            
reg [15:0] UDPlength; 
always @(posedge phy_rx_clk or negedge rstn)
    if (!rstn) begin
           IPlength  <= 16'h0000;                            
           UDPlength <= 16'h0000; 
               end
     else if (Reg_Ethertype == 16'h0800) begin
           if(MainCount == 16'h0035) IPlength  <= Main_DATA[15:0];                            
           if(MainCount == 16'h0061) UDPlength <= Main_DATA[15:0]; 
               end
wire [15:0] UIPlength  = IPlength  - 28;                            
wire [15:0] UUDPlength = UDPlength - 8; 

wire MyMAC_ok = ((Reg_DesMACadd == local_mac) || (Reg_DesMACadd == 48'hFFFFFFFFFFFF)) ? 1'b1 : 1'b0;
wire MyIP_ok = (Reg_THAIP == local_ip) ? 1'b1 : 1'b0;
reg        DATAcountOn;
reg [15:0] DATAcount  ;
always @(posedge phy_rx_clk or negedge rstn)
    if (!rstn) begin
            DATAcountOn <= 1'b0;
            DATAcount   <= 16'h0000;
                end
     else if (Reg_Ethertype == 16'h0800) begin
             if (DATAcountOn && MainCount[0]) begin
                if (DATAcount == UUDPlength-1)DATAcountOn <= 1'b0;
                DATAcount   <= DATAcount + 1;
                    end
              else if (MyMAC_ok && MyIP_ok && (MainCount == 16'h0063)) begin
                      DATAcountOn <= 1'b1;
                      DATAcount   <= 16'h0000;
                          end
                           end
     else begin
            DATAcountOn <= 1'b0;
            DATAcount   <= 16'h0000;
                end
wire empty                 ;
wire wr_en = (DATAcountOn) ? MainCount[0] : 1'b0;
wire rd_en = ~empty;
wire [7 : 0] dout          ;
wire full                  ;
wire [9 : 0] rd_data_count ;
wire [9 : 0] wr_data_count ;
reg Reg_DATAout;
always @(posedge clk or negedge rstn)
    if (!rstn) Reg_DATAout <= 1'b0;
     else Reg_DATAout <= rd_en;
assign UDPDATAread = Reg_DATAout;
assign UDPDATA      = dout;
assign UDPDATAempty = empty;
assign UDPDATArdcount = rd_data_count;

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
fifo_generator_0 fifo_generator_0_inst (
  .rst(!rstn),                      // input wire rst
  .wr_clk(phy_rx_clk),                // input wire wr_clk
  .rd_clk(clk),                // input wire rd_clk
  .din(RX_DATA_d0),                      // input wire [7 : 0] din
  .wr_en(wr_en),                  // input wire wr_en
  .rd_en(~empty),                  // input wire rd_en
  .dout(dout),                    // output wire [7 : 0] dout
  .full(full),                    // output wire full
  .empty(empty),                  // output wire empty
  .rd_data_count(rd_data_count),  // output wire [9 : 0] rd_data_count
  .wr_data_count(wr_data_count)  // output wire [9 : 0] wr_data_count
);
                           
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
reg PKTCRC_ok;
always @(posedge phy_rx_clk or negedge rstn)
    if (!rstn) PKTCRC_ok <= 1'b0;
     else if (DelRXcrc32[1] == {RX_DATA_d0,Main_DATA[7:0],Main_DATA[15:8],Main_DATA[23:16]}) PKTCRC_ok <= 1'b1;
      else PKTCRC_ok <= 1'b0;
              
assign SendARP = (Reg_Ethertype == 16'h0806) && MyMAC_ok && MyIP_ok && PKTCRC_ok;
assign SendUDP = (Reg_Ethertype == 16'h0800) && MyMAC_ok && MyIP_ok && PKTCRC_ok;
        
endmodule
