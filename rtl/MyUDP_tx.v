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

input StartARP,
input StartUDP,
input [47:0] local_mac ,
input [31:0] local_ip  ,
input [15:0] local_port,
input [47:0] des_mac ,
input [31:0] des_ip  ,
input [15:0] des_port,

input UDPDATAread,
input [7:0] UDPDATA,
input UDPDATAempty,
input [9:0] UDPDATArdcount
);
reg [15:0] DataSize;
wire [9 : 0] rd_data_count ;

wire [15:0] IPSize = rd_data_count + 28;
wire [15:0] UDPSize = rd_data_count + 8;
wire [31:0] IPcheckSum1 = 16'h4500 + IPSize + 16'h0000 + 16'h4000 + 16'h4011;
wire [31:0] IPcheckSum2 = local_ip[31:16] + local_ip[15:0] + des_ip[31:16] + des_ip[15:0];
reg [15:0] IPcheckSum;
//wire [15:0] UDPcheckSum = 16'h1073;
wire [15:0] UDPcheckSum = 16'h0000;
wire [15:0] UDPtype = 16'h0800;
wire [15:0] UDPlength = 16'h0019;
wire [63:0] ARPhead1  = 64'h0001080006040002;
wire [63:0] ARPhead2  = {local_mac,local_ip[31:16]};
wire [63:0] ARPhead3  = {local_ip[15:0],des_mac};
wire [31:0] ARPhead4  = des_ip;
wire [63:0] UDPhead1  = {16'h4500,IPSize,32'h00004000};
wire [63:0] UDPhead2  = {16'h4011,IPcheckSum,local_ip};
wire [63:0] UDPhead3  = {des_ip,local_port,des_port};
wire [31:0] UDPhead4  = {UDPSize,UDPcheckSum};
wire [63:0] Wdata1     = 64'h4650474120554450;
wire [63:0] Wdata2     = 64'h2054657374203132;
wire [63:0] Wdata3     = 64'h3300000000000000;
reg [3:0] CRCcount;
reg  MainOn;
reg  UDPARPn;
reg [15:0] MainCount;
always @(posedge phy_tx_clk or negedge rstn)
    if (!rstn) begin 
         MainOn <= 1'b0;
         MainCount <= 16'h0000;
		 UDPARPn   <= 1'b0;
              end
     else if (MainOn) begin 
               MainCount <= MainCount + 1;
               if (CRCcount == 4'h8) MainOn <= 1'b0;
                    end
     else if (StartARP) begin 
	             MainOn  <= 1'b1;
	             UDPARPn <= 1'b0;
				   end
     else if (StartUDP) begin 
	             MainOn  <= 1'b1;
	             UDPARPn <= 1'b1;
				   end
     else begin
        MainOn <= 1'b0;
        MainCount <= 16'h0000;
            end
            
reg [32:0] IP_CS2;
reg [16:0] IP_CS1;
always @(posedge phy_tx_clk or negedge rstn)
    if (!rstn) begin 
           IP_CS2     <= 32'h00000000;
           IP_CS1     <= 17'h00000;
           IPcheckSum <= 16'h0000;
		        end
     else  begin 
           IP_CS2     <= IPcheckSum1+IPcheckSum2;
           IP_CS1     <= IP_CS2[15:0]+IP_CS2[31:16];
           IPcheckSum <= ~(IP_CS1[16]+IP_CS1[15:0]);
		        end
	 
wire [15:0] PKTtype  = (UDPARPn) ? 16'h0800 : 16'h0806;
wire [63:0] PKThead1 = (UDPARPn) ? UDPhead1 : ARPhead1;
wire [63:0] PKThead2 = (UDPARPn) ? UDPhead2 : ARPhead2;
wire [63:0] PKThead3 = (UDPARPn) ? UDPhead3 : ARPhead3;
wire [31:0] PKThead4 = (UDPARPn) ? UDPhead4 : ARPhead4;

//wire wr_en ;
reg DATAon;
reg [7:0] DATAcount;
wire empty                 ;
//wire rd_en = UDPDATAread;
wire rd_en = (DATAon &&~ MainCount[0]) ? 1'b1 : 1'b0;
wire [7 : 0] dout          ;
wire full                  ;
//wire [9 : 0] rd_data_count ;
wire [9 : 0] wr_data_count ;
always @(posedge clk or negedge rstn)
    if (!rstn) DataSize <= 16'h0000;
    else if (StartARP) DataSize <= 16'h0012;
    else if (StartUDP) if (rd_data_count < 10'h012 )DataSize <= 16'h0012;
                        else DataSize <= {6'h00,rd_data_count};

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
fifo_generator_0 fifo_generator_0_inst (
  .rst(!rstn),                      // input wire rst
  .wr_clk(clk),                // input wire wr_clk
  .rd_clk(phy_tx_clk),                // input wire rd_clk
  .din(UDPDATA),                      // input wire [7 : 0] din
  .wr_en(UDPDATAread),                  // input wire wr_en
  .rd_en(rd_en),                  // input wire rd_en
  .dout(dout),                    // output wire [7 : 0] dout
  .full(full),                    // output wire full
  .empty(empty),                  // output wire empty
  .rd_data_count(rd_data_count),  // output wire [9 : 0] rd_data_count
  .wr_data_count(wr_data_count)  // output wire [9 : 0] wr_data_count
);

wire TXreset_crc = (MainCount[15:1] == 15'h0007) ? 1'b1 : 1'b0;
wire TXupdate_crc = (MainCount[0]) ? 1'b1 : 1'b0;
wire [31:0] TXcrc32;
wire [31:0] RETXcrc32 = {TXcrc32[7:0],TXcrc32[15:8],TXcrc32[23:16],TXcrc32[31:24]};
reg [63:0] OutShift;
always @(posedge phy_tx_clk or negedge rstn)
    if (!rstn) OutShift <= 64'h0000000000000000;
     else if (MainCount == 16'h0000) OutShift <= 64'h55555555555555d5;
     else if (MainCount == 16'h000f) OutShift[63:16] <= des_mac;
     else if (MainCount == 16'h001b) OutShift[63:16] <= local_mac;
     else if (MainCount == 16'h0027) OutShift[63:48] <= PKTtype;
     else if (MainCount == 16'h002b) OutShift <= PKThead1;
     else if (MainCount == 16'h003b) OutShift <= PKThead2;
     else if (MainCount == 16'h004b) OutShift <= PKThead3;
     else if (MainCount == 16'h005b) OutShift[63:32] <= PKThead4;
     else if (MainCount[0] && DATAon) begin 
                                    if ((rd_data_count == 10'h000)||(~UDPARPn))OutShift[63:56] <= 8'h00; 
                                     else OutShift[63:56] <= dout;
                                        end 
     else if (DATAcount == DataSize+1) OutShift[63:32] <= RETXcrc32;
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
always @(posedge phy_tx_clk or negedge rstn)
    if (!rstn) begin 
            DATAon    <= 1'b0;
            DATAcount <= 8'h00;
                end
     else if (DATAon) begin 
              if (MainCount[0]) begin 
                    DATAcount <= DATAcount + 1;
                    if (DATAcount == DataSize) DATAon <= 1'b0;     
                         end
                  end
     else if (MainCount == 16'h0061)begin 
              DATAcount <= 8'h00;
              DATAon <= 1'b1;
                 end
     else begin 
            DATAon    <= 1'b0;
            DATAcount <= 8'h00;
                end
always @(posedge phy_tx_clk or negedge rstn)
    if (!rstn) CRCcount = 4'hF;
     else if (CRCcount != 4'hF) CRCcount <= CRCcount + 1;
     else if (DATAon && MainCount[0] && (DATAcount == DataSize)) CRCcount = 4'h0; 
    
//wire [7:0] data = 8'hd5;
reg [3:0] OutTx;
always @(posedge phy_tx_clk or negedge rstn)
    if (!rstn) OutTx <= 4'h0;
     else if (DATAcount == DataSize+1) OutTx <= TXcrc32[7:0];
     else if (MainCount[0]) OutTx <= OutShift[63:60];
     else OutTx <= OutShift[59:56];

assign phy_txd = OutTx;
assign phy_tx_en = MainOn;

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
ila_3 ila_3_inst (
	.clk(phy_tx_clk), // input wire clk

	.probe0(StartARP), // input wire [0:0]  probe0  
	.probe1(StartUDP), // input wire [0:0]  probe1 
	.probe2(MainOn   ), // input wire [0:0]  probe2 
	.probe3(MainCount), // input wire [15:0]  probe3 
	.probe4(UDPARPn  ), // input wire [0:0]  probe4 
	.probe5(DATAon   ), // input wire [0:0]  probe5 
	.probe6(DATAcount), // // input wire [7:0]  probe6
	.probe7(rd_data_count), // input wire [9:0]  probe7 
	.probe8(DataSize) // input wire [15:0]  probe8
);
         
endmodule
