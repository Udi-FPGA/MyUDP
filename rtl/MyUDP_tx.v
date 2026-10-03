`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2026 04:57:24 PM
// Design Name: 
// Module Name: MyUDP_tx
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


module MyUDP_tx(
input clk  ,
input rstn ,

input phy_tx_clk,
output [3:0] phy_txd,
output phy_tx_en,

input StartUDP,
input [47:0] local_mac ,
input [31:0] local_ip  ,
input [15:0] local_port,
input [47:0] des_mac ,
input [31:0] des_ip  ,
input [15:0] des_port
    );

wire [47:0] Wdes_mac  = 48'h10ffe06f5e3e;
wire [31:0] Wdes_ip   = 32'hc0a80127;
wire [15:0] Wdes_port = 16'h162e;

wire [15:0] UDPtype = 16'h0800;
wire [15:0] UDPlength = 16'h0019;
wire [63:0] WUDPhead1  = 64'h08004500002d0000;
wire [63:0] WUDPhead2  = 64'h40004011b6c80000;
wire [63:0] WUDPhead3  = {local_port,Wdes_port,32'h00191073};
wire [63:0] Wdata1     = 64'h4650474120554450;
wire [63:0] Wdata2     = 64'h2054657374203132;
wire [63:0] Wdata3     = 64'h3300000000000000;
reg [3:0] CRCcount;
reg  MainOn;
reg [15:0] MainCount;
always @(posedge phy_tx_clk or negedge rstn)
    if (!rstn) begin 
         MainOn <= 1'b0;
         MainCount <= 16'h0000;
              end
     else if (MainOn) begin 
               MainCount <= MainCount + 1;
               if (CRCcount == 4'h6) MainOn <= 1'b0;
                    end
     else if (StartUDP) MainOn <= 1'b1;
     else MainCount <= 16'h0000;

wire TXreset_crc = (MainCount[15:1] == 15'h0007) ? 1'b1 : 1'b0;
wire TXupdate_crc = (MainCount[0]) ? 1'b1 : 1'b0;
wire [31:0] TXcrc32;
wire [31:0] RETXcrc32 = {TXcrc32[7:0],TXcrc32[15:8],TXcrc32[23:16],TXcrc32[31:24]};
reg [63:0] OutShift;
always @(posedge phy_tx_clk or negedge rstn)
    if (!rstn) OutShift <= 64'h0000000000000000;
     else if (MainCount == 16'h0000) OutShift <= 64'h55555555555555d5;
     else if (MainCount == 16'h000f) OutShift[63:16] <= Wdes_mac;
     else if (MainCount == 16'h001b) OutShift[63:16] <= local_mac;
     else if (MainCount == 16'h0027) OutShift <= WUDPhead1;
     else if (MainCount == 16'h0037) OutShift <= WUDPhead2;
     else if (MainCount == 16'h0043) OutShift[63:32] <= local_ip;
     else if (MainCount == 16'h004b) OutShift[63:32] <= Wdes_ip;
     else if (MainCount == 16'h0053) OutShift <= WUDPhead3;
     else if (MainCount == 16'h0063) OutShift <= Wdata1;
     else if (MainCount == 16'h0073) OutShift <= Wdata2;
     else if (MainCount == 16'h0083) OutShift <= Wdata3;
     else if (MainCount == 16'h0088) OutShift[63:32] <= RETXcrc32;
     else if (MainCount[0]) OutShift <= {OutShift[55:0],8'h00};

crc32_d8 TXcrc32_d8_inst
(
  .clk       (phy_tx_clk)  ,
  .reset_p   (!rstn)  ,
             
  .data      (OutShift[63:56])  ,
  .crc_init  (TXreset_crc)  ,
  .crc_en    (TXupdate_crc)  ,
  .crc_result(TXcrc32)
);
reg DATAon;
reg [7:0] DATAcount;
always @(posedge phy_tx_clk or negedge rstn)
    if (!rstn) begin 
            DATAon    <= 1'b0;
            DATAcount <= 8'h00;
                end
     else if (DATAon) begin 
              if (MainCount[0]) begin 
                    DATAcount <= DATAcount - 1;
                    if (DATAcount == 8'h00) DATAon <= 1'b0;
                         end
                  end
     else if (MainCount == 16'h0063)begin 
//              DATAcount <= UDPlength - 8;
              DATAcount <= 8'h12;
              DATAon <= 1'b1;
                 end
     else begin 
            DATAon    <= 1'b0;
            DATAcount <= 8'h00;
                end
always @(posedge phy_tx_clk or negedge rstn)
    if (!rstn) CRCcount = 4'hF;
     else if (CRCcount != 4'hF) CRCcount <= CRCcount + 1;
     else if (DATAon && MainCount[0] && (DATAcount == 8'h00)) CRCcount = 4'h0; 
    
//wire [7:0] data = 8'hd5;
reg [3:0] OutTx;
always @(posedge phy_tx_clk or negedge rstn)
    if (!rstn) OutTx <= 4'h0;
     else if (MainCount == 16'h0088) OutTx <= TXcrc32[7:0];
     else if (MainCount[0]) OutTx <= OutShift[63:60];
     else OutTx <= OutShift[59:56];

assign phy_txd = OutTx;
assign phy_tx_en = MainOn;
         
endmodule
