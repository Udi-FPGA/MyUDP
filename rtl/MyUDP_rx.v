`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2026 09:56:29 AM
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
  input clk125,
  input rstn  ,
  
  input [47:0] local_mac ,
  input [31:0] local_ip  ,
  input [15:0] local_port, 
  
  input [7:0]  gmii_rxd   ,   
  input        gmii_rxdv  ,

  output [47:0] desMAC ,             
  output [47:0] srcMAC ,  
  output [31:0] desIP  ,             
  output [31:0] srcIP  ,  
  output [15:0] desPORT,             
  output [15:0] srcPORT,  
  output [15:0] EthType,             
  output [15:0] Length ,
  
  output SendARP,
  output SendUDP
    );
  parameter IDEL    = 4'b0000;    
  parameter PREAMBL = 4'b0010;    
  parameter ADDRESS = 4'b0011;    
  parameter HEADER  = 4'b0100;    
  parameter DATA    = 4'b0101;    
  parameter CRC     = 4'b0110; 
  
  reg [3:0] State;
  reg [3:0] nextState;

  reg [7:0] ADDcount;   
  reg [7:0] HEAcount;   
  reg [15:0] DATcount;   
  reg [7:0] CRCcount;
  
  reg [47:0] Reg_desMAC;             
  reg [47:0] Reg_srcMAC;  
  reg [31:0] Reg_desIP;             
  reg [31:0] Reg_srcIP;  
  reg [15:0] Reg_desPORT;             
  reg [15:0] Reg_srcPORT;  
  reg [15:0] Reg_EthType;             
  reg [15:0] Reg_Length ;             
  
  reg [63:0] DataShift;
  always @(posedge clk125 or negedge rstn)
    if (!rstn) DataShift <= 64'h0000000000000000;
     else DataShift <= {DataShift[55:0],gmii_rxd};
     
 always @(posedge clk125 or negedge rstn)
    if (!rstn) begin 
          ADDcount <= 8'h00;   
          HEAcount <= 8'h00;   
          DATcount <= 16'h0000;   
          CRCcount <= 8'h00;
             end
     else begin 
          if (State==ADDRESS) ADDcount <= ADDcount + 1;
           else ADDcount <= 8'h00;   
          if (State==HEADER) HEAcount <= HEAcount + 1;
           else HEAcount <= 8'h00;   
          if (State==DATA) DATcount <= DATcount + 1;
           else DATcount <= 16'h0000;   
          if (State==CRC) CRCcount <= CRCcount + 1;
           else CRCcount <= 8'h00;      
            end 
  always @(*)
       begin
         case (State) 
           IDEL : 
               if (gmii_rxdv) nextState <= PREAMBL;
                else  nextState <= IDEL;
           PREAMBL:
               if (gmii_rxdv && (gmii_rxd == 8'hd5)) nextState <= ADDRESS;               
                else  nextState <= PREAMBL;
           ADDRESS:
               if (ADDcount == 8'h0d) nextState <= HEADER;               
                else  nextState <= ADDRESS;
           HEADER:
               if (HEAcount == 8'h1b) nextState <= DATA;               
                else  nextState <= HEADER;
           DATA:
               if (DATcount == Reg_Length-1) nextState <= CRC;               
                else  nextState <= DATA;
           CRC:
               if (CRCcount == 8'h04) nextState <= IDEL;               
                else  nextState <= CRC;
           default : nextState <= IDEL;
         endcase
       end
 always @(posedge clk125 or negedge rstn)
    if (!rstn) State <= IDEL;
     else State <= nextState;
	 
 always @(posedge clk125 or negedge rstn)
    if (!rstn) begin 
          Reg_desMAC  <= 48'h000000000000;             
          Reg_srcMAC  <= 48'h000000000000;  
          Reg_EthType <= 16'h0000; 
          Reg_desIP <= 31'h00000000;             
          Reg_srcIP <= 31'h00000000;  
          Reg_desPORT <= 16'h0000  ;             
          Reg_srcPORT <= 16'h0000  ;  
          Reg_Length  <= 16'h0000  ;             
             end
     else if (ADDcount==8'h06) Reg_desMAC  <= DataShift[47:0];
     else if (ADDcount==8'h0c) Reg_srcMAC  <= DataShift[47:0];
     else if (ADDcount==8'h0e) Reg_EthType <= DataShift[15:0];
	 else if (Reg_EthType == 16'h0806) begin 
             if (HEAcount == 8'h1c) Reg_desIP <= DataShift[31:0];             
             if (HEAcount == 8'h12) Reg_srcIP <= DataShift[31:0]; 
             Reg_Length <= 16'h0012;             
                       end
	 else if (Reg_EthType == 16'h0800) begin 
             if (HEAcount == 8'h10) Reg_desIP   <= DataShift[31:0];             
              else if (HEAcount == 8'h14) Reg_srcIP   <= DataShift[31:0]; 
              else if (HEAcount == 8'h16) Reg_desPORT <= DataShift[15:0];             
              else if (HEAcount == 8'h18) Reg_srcPORT <= DataShift[15:0];  
              else if ((HEAcount == 8'h1a)&&(DataShift[15:0] >16'h001a)) Reg_Length  <= DataShift[15:0]-8;
              else if ((HEAcount == 8'h1a)&&(DataShift[15:0]<=16'h001a)) Reg_Length  <= 16'h0012;
                       end        

	 
wire [31:0] CRCcalc;
wire rstCRC = ((State == IDEL)||(State == PREAMBL)) ? 1'b1 : 1'b0;
MyCRC MyCRC_inst(
  .clk       (clk125)   ,
  .rstn      (rstn)     ,
             
  .data      (gmii_rxd) ,
  .crc_init  (rstCRC)   ,
  .crc_en    (gmii_rxdv),
  .crc_result(CRCcalc)
    );
reg [31:0] MyCRC;
 always @(posedge clk125 or negedge rstn)
    if (!rstn) MyCRC <= 32'h00000000;
     else if (DATcount == Reg_Length) MyCRC <= {CRCcalc[7:0],CRCcalc[15:8],CRCcalc[23:16],CRCcalc[31:24]};	
	
reg GetMyMAC;
reg GetMyIP;
reg CRC_ok;
 always @(posedge clk125 or negedge rstn)
    if (!rstn) begin 
          GetMyMAC <= 1'b0;
          GetMyIP  <= 1'b0;
          CRC_ok   <= 1'b0;
		        end
     else if (State == IDEL) begin 
          GetMyMAC <= 1'b0;
          GetMyIP  <= 1'b0;
          CRC_ok   <= 1'b0;
		        end
     else if ((CRCcount == 8'h04)&&(DataShift[31:0] == MyCRC)) CRC_ok <= 1'b1; 
     else if (State == CRC) begin 
          if (Reg_desIP == local_ip) GetMyIP  <= 1'b1;
          if ((Reg_desMAC == local_mac)||(Reg_desMAC == 48'hFFFFFFFFFFFF)) GetMyMAC  <= 1'b1;
                end	                            

assign desMAC  = Reg_desMAC  ;            
assign srcMAC  = Reg_srcMAC  ; 
assign desIP   = Reg_desIP   ;            
assign srcIP   = Reg_srcIP   ; 
assign desPORT = Reg_desPORT ;            
assign srcPORT = Reg_srcPORT ; 
assign EthType = Reg_EthType ;            
assign Length  = Reg_Length  ;

assign SendARP = (GetMyIP && GetMyMAC && CRC_ok && (Reg_EthType == 16'h0806)) ? 1'b1 : 1'b0; 
endmodule
