`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2026 10:42:38 AM
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
reg clk50;
reg clk125 ;
reg rstn  ;
initial begin 
clk50 = 1'b1;
clk125  = 1'b0;
rstn   = 1'b0;
#100;
rstn   = 1'b1;
end 

always #10 clk50 = ~clk50  ;
always #4  clk125 = ~clk125;

reg [3:0] Mem [0:144];

reg       dv;
reg [3:0] data;
integer i;
initial begin 
dv   = 1'b0;
data = 4'h0;
@(posedge rstn);
#1000;


$readmemh("ARP_rx.hex",Mem);
i=0;
@(posedge clk125);
dv   = 1'b1;
repeat (72) begin 
data = Mem[2*i];
@(negedge clk125);
data = Mem[2*i+1];
i=i+1;
@(posedge clk125);
end
dv   = 1'b0;
#80;
@(posedge clk125);
@(posedge clk125);
//@(posedge clk125);

//force MyUDP_top_inst.MyUDP_rx_inst.gmii_rxd  = 0;
//force MyUDP_top_inst.MyUDP_rx_inst.gmii_rxdv
force MyUDP_top_inst.MyUDP_rx_inst.State = 0;
$readmemh("ARP_tx.hex",Mem);
i=0;
@(posedge clk125);
dv   = 1'b1;
repeat (72) begin 
data = Mem[2*i];
@(negedge clk125);
data = Mem[2*i+1];
i=i+1;
@(posedge clk125);
end
dv   = 1'b0;
#100;

release MyUDP_top_inst.MyUDP_rx_inst.State;

#1000;

$readmemh("UDP_rx.hex",Mem);
i=0;
@(posedge clk125);
dv   = 1'b1;
repeat (72) begin 
data = Mem[2*i];
@(negedge clk125);
data = Mem[2*i+1];
i=i+1;
@(posedge clk125);
end
dv   = 1'b0;
#20;
@(posedge clk125);
//@(posedge clk125);
//@(posedge clk125);

//force MyUDP_top_inst.MyUDP_rx_inst.gmii_rxd  = 0;
//force MyUDP_top_inst.MyUDP_rx_inst.gmii_rxdv
force MyUDP_top_inst.MyUDP_rx_inst.State = 0;
$readmemh("UDP_tx.hex",Mem);
i=0;
@(posedge clk125);
dv   = 1'b1;
repeat (72) begin 
data = Mem[2*i];
@(negedge clk125);
data = Mem[2*i+1];
i=i+1;
@(posedge clk125);
end
dv   = 1'b0;
#1000;
end

MyUDP_top MyUDP_top_inst(
.Clk  (clk50),
.Rst_n(rstn),
.key_in(2'b11),
.Led   (),

//eth_rx
.rgmii_rx_clk_i(clk125),
.rgmii_rxd     (data),
.rgmii_rxdv    (dv),
//eth_tx      
.rgmii_tx_clk  (),
.rgmii_txd     (),
.rgmii_txen    (),
              
.eth_rstn      (),  
.eth_mdc       (),
.eth_mdio      ()
    );


endmodule
