`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2026 10:22:00 AM
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
  input clk125,
  input rstn  ,
  
  input [47:0] local_mac ,
  input [31:0] local_ip  ,
  input [15:0] local_port, 
  
  output [7:0] gmii_txd   ,  
  output       gmii_txen  ,  
  
  input [47:0] desMAC ,             
  input [47:0] srcMAC ,  
  input [31:0] desIP  ,             
  input [31:0] srcIP  ,  
  input [15:0] desPORT,             
  input [15:0] srcPORT,  
  input [15:0] EthType,             
  input [15:0] Length ,
  
  output reg PayLoadRd,
  input  PayLoadEmpty, 
  input [7:0] PayLoad, 
  
  input SendARP,
  input SendUDP
   );

  parameter IDEL    = 4'b0000;    
  parameter PREAMBL = 4'b0010;    
  parameter ADDRESS = 4'b0011;    
  parameter HEADER  = 4'b0100;    
  parameter DATA    = 4'b0101;    
  parameter CRC     = 4'b0110; 

wire [15:0] IPSize = Length + 28;
wire [15:0] UDPSize = Length + 8;
reg [15:0] ETHtype;
always @(posedge clk125 or negedge rstn)
    if (!rstn) ETHtype <= 16'h0000;
     else if (SendARP) ETHtype <= 16'h0806;
     else if (SendUDP) ETHtype <= 16'h0800;
reg  [15:0] Reg_Length;
always @(posedge clk125 or negedge rstn)
    if (!rstn) Reg_Length <= 16'h0000;
     else if (ETHtype == 16'h0806) Reg_Length <= 16'h0012;
     else if (Length <= 16'h0012) Reg_Length <= 16'h0012;
     else Reg_Length <= Length;

wire [63:0] ARPhead1  = 64'h0001080006040002;
wire [63:0] ARPhead2  = {local_mac,local_ip[31:16]};
wire [63:0] ARPhead3  = {local_ip[15:0],desMAC};
wire [31:0] ARPhead4  = desIP;

reg  [15:0] IPcheckSum;
wire [15:0] UDPcheckSum = 16'h0000;
//wire [15:0] UDPcheckSum = 16'h1073;

wire [63:0] UDPhead1  = {16'h4500,IPSize,32'h00004000};
wire [63:0] UDPhead2  = {16'h4011,IPcheckSum,local_ip};
wire [63:0] UDPhead3  = {desIP,local_port,desPORT};
wire [31:0] UDPhead4  = {UDPSize,UDPcheckSum};
wire [31:0] IPcheckSum1 = UDPhead1[63:48] + UDPhead1[47:32] + UDPhead1[31:16] + UDPhead1[15:0] + UDPhead2[63:48];
wire [31:0] IPcheckSum2 = local_ip[31:16] + local_ip[15:0] + desIP[31:16] + desIP[15:0];
reg [32:0] IP_CS2;
reg [16:0] IP_CS1;
always @(posedge clk125 or negedge rstn)
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
wire [63:0] head1  = (ETHtype == 16'h0806) ? ARPhead1 : UDPhead1;
wire [63:0] head2  = (ETHtype == 16'h0806) ? ARPhead2 : UDPhead2;
wire [63:0] head3  = (ETHtype == 16'h0806) ? ARPhead3 : UDPhead3;
wire [31:0] head4  = (ETHtype == 16'h0806) ? ARPhead4 : UDPhead4;
  
  reg [3:0] State;
  reg [3:0] nextState;
  
  reg  [7:0] PREcount;   
  reg  [7:0] ADDcount;   
  reg  [7:0] HEAcount;   
  reg [15:0] DATcount;   
  reg  [7:0] CRCcount;

 always @(posedge clk125 or negedge rstn)
    if (!rstn) begin 
          PREcount <= 8'h00;   
          ADDcount <= 8'h00;   
          HEAcount <= 8'h00;   
          DATcount <= 16'h0000;   
          CRCcount <= 8'h00;
             end
     else begin 
          if (State==PREAMBL) PREcount <= PREcount + 1;
           else PREcount <= 8'h00;   
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
               if (SendARP||SendUDP) nextState <= PREAMBL;
                else  nextState <= IDEL;
           PREAMBL:
               if (PREcount == 8'h07) nextState <= ADDRESS;               
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
               if (CRCcount == 8'h05) nextState <= IDEL;               
                else  nextState <= CRC;
           default : nextState <= IDEL;
         endcase
       end
 always @(posedge clk125 or negedge rstn)
    if (!rstn) State <= IDEL;
     else State <= nextState;

  reg [63:0] ADDout;   
  reg [63:0] HEAout;   
  reg [31:0] CRCout;
  reg  [7:0] CRCin;
  reg        CRCen;
  reg        PKTen;
  wire [31:0] CRCcalc;
 always @(posedge clk125 or negedge rstn)
    if (!rstn) begin
          ADDout <= {desMAC,16'h0000};   
          HEAout <= head1;   
          CRCout <= 32'h00000000;
          CRCin  <= 8'h00;
          CRCen  <= 1'b0;
          PKTen  <= 1'b0;
          end 
    else case (State) 
	       IDEL    : begin
                     ADDout <= {desMAC,16'h0000};   
                     HEAout <= head1;   
                     CRCin  <= 8'h00;
                     CRCen  <= 1'b0;
					   end
           PREAMBL : begin
                     HEAout <= head1;   
                     if (PREcount == 8'h07) CRCin <= 8'hd5;
                      else CRCin <= 8'h55;
                     PKTen  <= 1'b1;
					   end
           ADDRESS : begin 
                     if (ADDcount == 8'h05) ADDout <= {local_mac,ETHtype};           
                      else ADDout <= {ADDout[55:0],8'h00};    
                     CRCin <= ADDout[63:56];
                     CRCen  <= 1'b1;
                       end       
           HEADER  : begin
                     if (HEAcount == 8'h07) HEAout <= head2;  
                      else if (HEAcount == 8'h0f) HEAout <= head3;           
                      else if (HEAcount == 8'h17) HEAout <= {head4,32'h00000000};
                      else HEAout <= {HEAout[55:0],8'h00};  
                     CRCin <= HEAout[63:56];
                       end       
           DATA    : if ((ETHtype == 16'h0800)&&(PayLoadRd)) CRCin <= PayLoad;   
                      else CRCin <= 8'h00;   
           CRC     : begin
                     if (CRCcount == 8'h01) begin
		                 CRCout <= {CRCcalc[23:16],CRCcalc[31:24],8'h00,8'h00};   
                         CRCin <= CRCcalc[15:8];
						      end
		              else begin
		                 CRCout <= {CRCout[23:0],8'h00};
                         CRCin <= CRCout[31:24];
                            end       
                     if (CRCcount == 8'h04) PKTen  <= 1'b0;
                       end       
           default : CRCin <= 8'h00;
         endcase   

wire rstCRC = ((State == IDEL)||(State == PREAMBL)) ? 1'b1 : 1'b0;
MyCRC MyCRC_inst(
  .clk       (clk125)   ,
  .rstn      (rstn)     ,
             
  .data      (CRCin) ,
  .crc_init  (!CRCen)   ,
  .crc_en    (CRCen),
  .crc_result(CRCcalc)
    );
	 
reg [7:0] OutTx  ;  
reg       OutTxen;  
always @(posedge clk125 or negedge rstn)
   if (!rstn) begin
          OutTx   <= 8'h00;  
          OutTxen <= 1'b0;  
		        end
    else  begin
          if (CRCcount == 8'h01) OutTx   <= CRCcalc[7:0];  
		   else OutTx  <= CRCin;
          OutTxen <= PKTen;  
		        end
		        
always @(posedge clk125 or negedge rstn)
   if (!rstn) PayLoadRd <= 1'b0;
    else if (PayLoadEmpty)PayLoadRd <= 1'b0;
    else if ((ETHtype == 16'h0800)&&(HEAcount == 8'h1a))PayLoadRd <= 1'b1;
				
//assign PayLoadRd = (nextState == DATA) ? 1'b1 : 1'b0;
        

assign gmii_txd  = OutTx  ;  
assign gmii_txen = OutTxen;  
    
endmodule
