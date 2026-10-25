`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2026 11:53:44 AM
// Design Name: 
// Module Name: MyCRC
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
//   * polynomial: x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x^1 + 1
//   * data width: 8
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MyCRC(
  input           clk       ,
  input           rstn      ,

  input    [7:0]  data      ,
  input           crc_init  ,
  input           crc_en    ,
  output   [31:0] crc_result
    );

wire [7:0] d = data;
reg [31:0] c;
wire [31:0] NextCRC;

assign NextCRC[00] = c[30]^c[24]^d[1]^d[7]                                                       ;
assign NextCRC[01] = c[31]^c[30]^c[25]^c[24]^d[0]^d[1]^d[6]^d[7]                                 ;
assign NextCRC[02] = c[31]^c[30]^c[26]^c[25]^c[24]^d[0]^d[1]^d[5]^d[6]^d[7]                      ;
assign NextCRC[03] = c[31]^c[27]^c[26]^c[25]^d[0]^d[4]^d[5]^d[6]                                 ;
assign NextCRC[04] = c[30]^c[28]^c[27]^c[26]^c[24]^d[1]^d[3]^d[4]^d[5]^d[7]                      ;
assign NextCRC[05] = c[31]^c[30]^c[29]^c[28]^c[27]^c[25]^c[24]^d[0]^d[1]^d[2]^d[3]^d[4]^d[6]^d[7];
assign NextCRC[06] = c[31]^c[30]^c[29]^c[28]^c[26]^c[25]^d[0]^d[1]^d[2]^d[3]^d[5]^d[6]           ;
assign NextCRC[07] = c[31]^c[29]^c[27]^c[26]^c[24]^d[0]^d[2]^d[4]^d[5]^d[7]                      ;
assign NextCRC[08] = c[28]^c[27]^c[25]^c[24]^c[0]^d[3]^d[4]^d[6]^d[7]                            ;
assign NextCRC[09] = c[29]^c[28]^c[26]^c[25]^c[1]^d[2]^d[3]^d[5]^d[6]                            ;
assign NextCRC[10] = c[29]^c[27]^c[26]^c[24]^c[2]^d[2]^d[4]^d[5]^d[7]                            ;
assign NextCRC[11] = c[28]^c[27]^c[25]^c[24]^c[3]^d[3]^d[4]^d[6]^d[7]                            ;
assign NextCRC[12] = c[30]^c[29]^c[28]^c[26]^c[25]^c[24]^c[4]^d[1]^d[2]^d[3]^d[5]^d[6]^d[7]      ;
assign NextCRC[13] = c[31]^c[30]^c[29]^c[27]^c[26]^c[25]^c[5]^d[0]^d[1]^d[2]^d[4]^d[5]^d[6]      ;
assign NextCRC[14] = c[31]^c[30]^c[28]^c[27]^c[26]^c[6]^d[0]^d[1]^d[3]^d[4]^d[5]                 ;
assign NextCRC[15] = c[31]^c[29]^c[28]^c[27]^c[7]^d[0]^d[2]^d[3]^d[4]                            ;
assign NextCRC[16] = c[29]^c[28]^c[24]^c[8]^d[2]^d[3]^d[7]                                       ;
assign NextCRC[17] = c[30]^c[29]^c[25]^c[9]^d[1]^d[2]^d[6]                                       ;
assign NextCRC[18] = c[31]^c[30]^c[26]^c[10]^d[0]^d[1]^d[5]                                      ;
assign NextCRC[19] = c[31]^c[27]^c[11]^d[0]^d[4]                                                 ;
assign NextCRC[20] = c[28]^c[12]^d[3]                                                            ;
assign NextCRC[21] = c[29]^c[13]^d[2]                                                            ;
assign NextCRC[22] = c[24]^c[14]^d[7]                                                            ;
assign NextCRC[23] = c[30]^c[25]^c[24]^c[15]^d[1]^d[6]^d[7]                                      ;
assign NextCRC[24] = c[31]^c[26]^c[25]^c[16]^d[0]^d[5]^d[6]                                      ;
assign NextCRC[25] = c[27]^c[26]^c[17]^d[4]^d[5]                                                 ;
assign NextCRC[26] = c[30]^c[28]^c[27]^c[24]^c[18]^d[1]^d[3]^d[4]^d[7]                           ;
assign NextCRC[27] = c[31]^c[29]^c[28]^c[25]^c[19]^d[0]^d[2]^d[3]^d[6]                           ;
assign NextCRC[28] = c[30]^c[29]^c[26]^c[20]^d[1]^d[2]^d[5]                                      ;
assign NextCRC[29] = c[31]^c[30]^c[27]^c[21]^d[0]^d[1]^d[4]                                      ;
assign NextCRC[30] = c[31]^c[28]^c[22]^d[0]^d[3]                                                 ;
assign NextCRC[31] = c[29]^c[23]^d[2]                                                            ;
                                                                                               
always @(posedge clk or negedge rstn)
    if (!rstn) c <= 32'hFFFFFFFF;
     else if (crc_init) c <= 32'hFFFFFFFF;
     else if (crc_en) c <= NextCRC;

genvar i;
generate 
for (i=0;i<32;i=i+1) begin 
   assign crc_result[31-i] = !c[i];
end      
endgenerate
endmodule
