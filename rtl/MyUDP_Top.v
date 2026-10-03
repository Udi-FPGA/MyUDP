`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2026 12:36:27 PM
// Design Name: 
// Module Name: MyUDP_Top
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


module MyUDP_Top(
input clk    ,
input reset_n,
input [3:0] btn,
input [3:0] sw ,
output phy_ref_clk,
output phy_reset_n,
input phy_rx_clk,
input [3:0] phy_rxd,
input phy_rx_dv,
input phy_rx_er,
input phy_tx_clk,
output [3:0] phy_txd,
output phy_tx_en
    );

// Clock and reset

wire clk_ibufg;

// Internal 125 MHz clock
wire clk_mmcm_out;
wire clk_int;
//wire rst_int;

wire mmcm_rst = ~reset_n;
wire mmcm_locked;
wire mmcm_clkfb;

IBUFG
clk_ibufg_inst(
    .I(clk),
    .O(clk_ibufg)
);

wire clk_25mhz_mmcm_out;
wire clk_25mhz_int;

// MMCM instance
// 100 MHz in, 125 MHz out
// PFD range: 10 MHz to 550 MHz
// VCO range: 600 MHz to 1200 MHz
// M = 10, D = 1 sets Fvco = 1000 MHz (in range)
// Divide by 8 to get output frequency of 125 MHz
// Divide by 40 to get output frequency of 25 MHz
// 1000 / 5 = 200 MHz
MMCME2_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(8),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0),
    .CLKOUT1_DIVIDE(40),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT1_PHASE(0),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT2_PHASE(0),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT3_PHASE(0),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT4_PHASE(0),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT5_PHASE(0),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT6_DUTY_CYCLE(0.5),
    .CLKOUT6_PHASE(0),
    .CLKFBOUT_MULT_F(10),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(10.0),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_ibufg),
    .CLKFBIN(mmcm_clkfb),
    .RST(mmcm_rst),
    .PWRDWN(1'b0),
    .CLKOUT0(clk_mmcm_out),
    .CLKOUT0B(),
    .CLKOUT1(clk_25mhz_mmcm_out),
    .CLKOUT1B(),
    .CLKOUT2(),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .CLKFBOUT(mmcm_clkfb),
    .CLKFBOUTB(),
    .LOCKED(mmcm_locked)
);

BUFG
clk_bufg_inst (
    .I(clk_mmcm_out),
    .O(clk_int)
);

BUFG
clk_25mhz_bufg_inst (
    .I(clk_25mhz_mmcm_out),
    .O(clk_25mhz_int)
);

assign phy_ref_clk = clk_25mhz_int;
assign phy_reset_n = mmcm_locked && reset_n;
wire       BUF_rx_clk;
wire       BUF_tx_clk;
    BUFG
    mii_rx_bufg_inst (
        .I(phy_rx_clk),
        .O(BUF_rx_clk)
    );
    BUFG
    mii_tx_bufg_inst (
        .I(phy_tx_clk),
        .O(BUF_tx_clk)
    );

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
ila_0 ila_0_inst (
	.clk(clk_ibufg), // input wire clk

	.probe0(reset_n), // input wire [0:0]  probe0  
	.probe1(btn), // input wire [3:0]  probe1 
	.probe2(sw ), // input wire [3:0]  probe2 
	.probe3(phy_rx_clk), // input wire [0:0]  probe3 
	.probe4(phy_rxd), // input wire [3:0]  probe4 
	.probe5(phy_rx_dv), // input wire [0:0]  probe5 
	.probe6(phy_rx_er), // input wire [0:0]  probe6 
	.probe7(phy_tx_clk) // input wire [0:0]  probe7
);


wire [3:0] txd;
wire tx_en;
MyUDP MyUDP_inst(
.clk (clk_int) ,
.rstn(reset_n) ,

.phy_rx_clk(BUF_rx_clk),
.phy_rxd   (phy_rxd),
.phy_rx_dv (phy_rx_dv),
.phy_rx_er (phy_rx_er),
.phy_tx_clk(BUF_tx_clk),
.phy_txd   (txd),
.phy_tx_en (tx_en)
    );





reg [3:0] UDPmem [0:143];
initial $readmemh("UDP_tx.hex",UDPmem);
reg [7:0] txCount;
reg [3:0] outtxd;
//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
ila_1 ila_1_inst (
	.clk(clk_25mhz_int), // input wire clk

	.probe0(phy_rxd), // input wire [3:0]  probe0  
	.probe1(phy_rx_dv), // input wire [0:0]  probe1 
	.probe2(phy_rx_er), // input wire [0:0]  probe2 
	.probe3(txCount), // input wire [7:0]  probe3 
	.probe4(txd), // input wire [3:0]  probe4 
	.probe5(tx_en) // input wire [0:0]  probe5
);


//always @(posedge BUF_tx_clk or negedge reset_n)
//    if (!reset_n) txCount <= 8'h91;
//     else if (txCount != 8'h91) txCount <= txCount + 1;
//     else if (phy_rx_dv == 1'b1) txCount <= 8'h00;   

//always @(posedge BUF_tx_clk) outtxd <= UDPmem[txCount];

//always @(posedge BUF_tx_clk or negedge reset_n)
//    if (!reset_n) begin 
//            txd <= 4'h0;
//            tx_en <= 1'b0;
//               end
//     else if (txCount != 8'h91) begin 
//           txd <= outtxd;
//           tx_en <= 1'b1;
//              end
//     else tx_en <= 1'b0;

assign phy_txd   = txd;
assign phy_tx_en = tx_en;
 
endmodule
