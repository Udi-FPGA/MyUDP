`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2026 10:13:28 AM
// Design Name: 
// Module Name: CRC_tb
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


module CRC_tb();
reg clk200;
reg clk25 ;
reg rstn  ;
initial begin 
clk200 = 1'b1;
clk25  = 1'b0;
rstn   = 1'b0;
#100;
rstn   = 1'b1;
end 

always #2.5 clk200 = ~clk200;
always #20  clk25  = ~clk25 ;

reg [3:0] Mem [0:144];

reg       dv;
reg [7:0] data;
integer i;
initial begin 
dv   = 1'b0;
data = 8'h00;
@(posedge rstn);
#100;


$readmemh("ARP_rx.hex",Mem);
i=0;
@(posedge clk25);#1;
dv   = 1'b1;
repeat (72) begin 
data = {Mem[2*i+1],Mem[2*i]};
i=i+1;
@(posedge clk25);#1;
dv   = 1'b0;
@(posedge clk25);#1;
dv   = 1'b1;
end
dv   = 1'b0;
#1000;

$readmemh("ARP_tx.hex",Mem);
i=0;
@(posedge clk25);#1;
dv   = 1'b1;
repeat (72) begin 
data = {Mem[2*i+1],Mem[2*i]};
i=i+1;
@(posedge clk25);#1;
end
dv   = 1'b0;
#1000;


$readmemh("UDP_rx.hex",Mem);
i=0;
@(posedge clk25);#1;
dv   = 1'b1;
repeat (72) begin 
data = {Mem[2*i+1],Mem[2*i]};
i=i+1;
@(posedge clk25);#1;
end
dv   = 1'b0;
#1000;

$readmemh("UDP_tx.hex",Mem);
i=0;
@(posedge clk25);#1;
dv   = 1'b1;
repeat (72) begin 
data = {Mem[2*i+1],Mem[2*i]};
i=i+1;
@(posedge clk25);#1;
end
dv   = 1'b0;
#1000;
end

reg        RstnCRC;
always @(posedge clk25 or negedge rstn)
    if (!rstn)RstnCRC <= 1'b1;
     else if (dv && data == 8'hd5) RstnCRC <= 1'b0; 
     else if (!dv) RstnCRC <= 1'b1;  

reg [2:0] BC;

always @(posedge clk200 or negedge rstn)
    if (!rstn)BC <= 3'h0;
     else if (!RstnCRC) BC <= BC + 1;
     else BC <= 3'h0; 

reg  [31:0] c;
wire [7:0]  d = data;
wire fb = c[31]^d[BC];
//wire [31:0] nextCRC = {       x^26              + x^23 + x^22 +             x^16 +           x^12 +   x^11 +  x^10 +        x^8 +   x^7 +        x^5 +   x^4 +        x^2 + x^1 + 1;
wire [31:0] nextCRC = {c[30:26],c[25]^fb,c[24:23],c[22]^fb,c[21]^fb,c[20:16],c[15]^fb,c[14:12],c[11]^fb,c[10]^fb,c[9]^fb,c[8],c[7]^fb,c[6]^fb,c[5],c[4]^fb,c[3]^fb,c[2],c[1]^fb,c[0]^fb,fb};
always @(posedge clk200 or negedge rstn)
    if (!rstn)c <= 32'hFFFFFFFF;
     else if (!RstnCRC) c <= nextCRC;
     else c <= 32'hFFFFFFFF;

wire [31:0] RearrCRC;
genvar j;
generate 
for (j=0;j<32;j=j+1)begin 
assign RearrCRC[31-j] = ~nextCRC[j];
end 
endgenerate 

//wire [31:0] OldCRC;
//crc32_d8 crc32_d8_inst
//(
//  .clk         (clk25),
//  .reset_p     (~rstn),

//  .data        (data),
//  .crc_init    (~RstnCRC),
//  .crc_en      (RstnCRC),
//  .crc_result  (OldCRC)
//);

wire [31:0] MyCRC;
MyCRC MyCRC_inst(
  .clk       (clk25),
  .rstn      (rstn),
             
  .data      (data),
  .crc_init  (!RstnCRC),
  .crc_en    (dv),
  .crc_result(MyCRC)
    );
     
endmodule
