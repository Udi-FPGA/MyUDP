`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2026 05:21:54 PM
// Design Name: 
// Module Name: MyUDP_tb
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


module MyUDP_tb();
reg clk ;
reg rstn;
initial begin 
clk = 1'b0;
rstn = 1'b0;
#100;
rstn = 1'b1;
end
always #5 clk = ~clk;

wire  phy_ref_clk ;
wire  phy_reset_n ;
wire  phy_rx_clk  = phy_ref_clk;
reg [3:0] phy_rxd;
reg phy_rx_dv    ;
wire phy_rx_er     = 0;
wire phy_tx_clk   = phy_ref_clk;
wire [3:0] phy_txd;
wire  phy_tx_en   ;

reg [3:0] PCarpMem [0:144];
integer i;
initial begin 
phy_rxd   = 4'h0;
phy_rx_dv = 1'b0;
@(posedge rstn);
@(posedge phy_reset_n);
#100;
$readmemh("ARP_rx.hex",PCarpMem);
i=0;
@(posedge phy_rx_clk);#1;
phy_rx_dv = 1'b1;
   repeat (144) begin
       phy_rxd   = PCarpMem[i];
       i=i+1;
       @(posedge phy_rx_clk);#1;
   end
phy_rx_dv = 1'b0;
#10000;
$readmemh("UDP_rx.hex",PCarpMem);
i=0;
@(posedge phy_rx_clk);#1;
phy_rx_dv = 1'b1;
   repeat (144) begin
       phy_rxd   = PCarpMem[i];
       i=i+1;
       @(posedge phy_rx_clk);#1;
   end
phy_rx_dv = 1'b0;
#10000;
phy_rxd   = 4'h0;
phy_rx_dv = 1'b0;
#100;
$readmemh("ARP_rx.hex",PCarpMem);
i=0;
@(posedge phy_rx_clk);#1;
phy_rx_dv = 1'b1;
   repeat (144) begin
       phy_rxd   = PCarpMem[i];
       i=i+1;
       @(posedge phy_rx_clk);#1;
   end
phy_rx_dv = 1'b0;
#10000;
$readmemh("UDP_rx.hex",PCarpMem);
i=0;
@(posedge phy_rx_clk);#1;
phy_rx_dv = 1'b1;
   repeat (144) begin
       phy_rxd   = PCarpMem[i];
       i=i+1;
       @(posedge phy_rx_clk);#1;
   end
phy_rx_dv = 1'b0;
#10000;
end


reg [3:0] chPCarpMem [0:144];
reg [3:0] chphy_txd;
reg       chphy_tx_en   ;

initial begin
chphy_txd = 4'h0;
chphy_tx_en = 1'b0;
@(negedge phy_rx_dv);
$readmemh("ARP_tx.hex",chPCarpMem);
i=0;
@(posedge phy_rx_clk);#1;
@(posedge phy_rx_clk);#1;
@(posedge phy_rx_clk);#1;
chphy_tx_en = 1'b1;
   repeat (144) begin
       chphy_txd   = chPCarpMem[i];
       i=i+1;
       @(posedge phy_rx_clk);#1;
   end
chphy_tx_en = 1'b0;
@(negedge phy_rx_dv);
$readmemh("UDP_tx.hex",chPCarpMem);
i=0;
@(posedge phy_rx_clk);#1;
@(posedge phy_rx_clk);#1;
@(posedge phy_rx_clk);#1;
chphy_tx_en = 1'b1;
   repeat (144) begin
       chphy_txd   = chPCarpMem[i];
       i=i+1;
       @(posedge phy_rx_clk);#1;
   end
chphy_tx_en = 1'b0;
#10000;
chphy_txd = 4'h0;
chphy_tx_en = 1'b0;
@(negedge phy_rx_dv);
$readmemh("ARP_tx.hex",chPCarpMem);
i=0;
@(posedge phy_rx_clk);#1;
@(posedge phy_rx_clk);#1;
@(posedge phy_rx_clk);#1;
chphy_tx_en = 1'b1;
   repeat (144) begin
       chphy_txd   = chPCarpMem[i];
       i=i+1;
       @(posedge phy_rx_clk);#1;
   end
chphy_tx_en = 1'b0;
@(negedge phy_rx_dv);

end

MyUDP_Top MyUDP_Top_inst(
.clk    (clk),
.reset_n(rstn),
.btn      (0),
.sw       (0),
.phy_ref_clk(phy_ref_clk),
.phy_reset_n(phy_reset_n),
.phy_rx_clk (phy_rx_clk ),
.phy_rxd    (phy_rxd    ),
.phy_rx_dv  (phy_rx_dv  ),
.phy_rx_er  (phy_rx_er  ),
.phy_tx_clk (phy_tx_clk ),
.phy_txd    (phy_txd    ),
.phy_tx_en  (phy_tx_en  )
    );

endmodule
