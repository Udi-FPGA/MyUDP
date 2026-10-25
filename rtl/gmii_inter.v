`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2026 09:11:39 AM
// Design Name: 
// Module Name: gmii_inter
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


module gmii_inter(
  input reset,
  
  input         rgmii_rx_clk,
  input  [3:0]  rgmii_rxd   ,
  input         rgmii_rxdv  ,

//  output        gmii_rx_clk,
  output [7:0]  gmii_rxd   ,
  output        gmii_rxdv  ,
  output        gmii_rxer  ,

  input        gmii_tx_clk,
  input  [7:0] gmii_txd   ,
  input        gmii_txen  ,
  input        gmii_txer  ,
  
  output       rgmii_tx_clk,
  output [3:0] rgmii_txd   ,
  output       rgmii_txen  
    );

    genvar i;
  generate
    for(i=0;i<4;i=i+1)
    begin: rgmii_rxd_i
      IDDR #(
        .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                              // or "SAME_EDGE_PIPELINED" 
        .INIT_Q1(1'b0   ),  // Initial value of Q1: 1'b0 or 1'b1
        .INIT_Q2(1'b0   ),  // Initial value of Q2: 1'b0 or 1'b1
        .SRTYPE ("SYNC" )   // Set/Reset type: "SYNC" or "ASYNC" 
      ) IDDR_rxd (
        .Q1   (gmii_rxd[i]   ), // 1-bit output for positive edge of clock
        .Q2   (gmii_rxd[i+4] ), // 1-bit output for negative edge of clock
        .C    (rgmii_rx_clk  ), // 1-bit clock input
        .CE   (1'b1          ), // 1-breset_nit clock enable input
        .D    (rgmii_rxd[i]  ), // 1-bit DDR data input
        .R    (reset         ), // 1-bit reset
        .S    (1'b0          )  // 1-bit set
      );
    end
  endgenerate
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                          // or "SAME_EDGE_PIPELINED" 
    .INIT_Q1(1'b0   ),  // Initial value of Q1: 1'b0 or 1'b1
    .INIT_Q2(1'b0   ),  // Initial value of Q2: 1'b0 or 1'b1
    .SRTYPE ("SYNC" )   // Set/Reset type: "SYNC" or "ASYNC" 
  ) IDDR_rxdv (
    .Q1   (gmii_rxdv), // 1-bit output for positive edge of clock
    .Q2   (gmii_rxer_r), // 1-bit output for negative edge of clock
    .C    (rgmii_rx_clk ), // 1-bit clock input
    .CE   (1'b1         ), // 1-breset_nit clock enable input
    .D    (rgmii_rxdv   ), // 1-bit DDR data input
    .R    (reset        ), // 1-bit reset
    .S    (1'b0         )  // 1-bit set
  );

    assign gmii_rxer = gmii_rxer_r^gmii_rxdv;
//    assign gmii_rx_clk = rgmii_rx_clk;

//  genvar i;
  generate
    for(i=0;i<4;i=i+1)
    begin: rgmii_txd_o
      ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
        .INIT  (1'b0   ),           // Initial value of Q: 1'b0 or 1'b1
        .SRTYPE("SYNC" )            // Set/Reset type: "SYNC" or "ASYNC" 
      ) ODDR_rgmii_txd (
        .Q   (rgmii_txd[i]     ), // 1-bit DDR output
        .C   (gmii_tx_clk      ), // 1-bit clock input
        .CE  (1'b1             ), // 1-bit clock enable input
        .D1  (gmii_txd[i]      ), // 1-bit data input (positive edge)
        .D2  (gmii_txd[i+4]    ), // 1-bit data input (negative edge)
        .R   (reset         ), // 1-bit reset
        .S   (1'b0             )  // 1-bit set
      );
    end
  endgenerate

  ODDR #(
    .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
    .INIT  (1'b0   ),           // Initial value of Q: 1'b0 or 1'b1
    .SRTYPE("SYNC" )            // Set/Reset type: "SYNC" or "ASYNC" 
  ) ODDR_rgmii_txd (
    .Q   (rgmii_txen          ), // 1-bit DDR output
    .C   (gmii_tx_clk         ), // 1-bit clock input
    .CE  (1'b1                ), // 1-bit clock enable input
    .D1  (gmii_txen           ), // 1-bit data input (positive edge)
    .D2  (gmii_txen^gmii_txer ), // 1-bit data input (negative edge)
    .R   (reset               ), // 1-bit reset
    .S   (1'b0                )  // 1-bit set
  );

  ODDR #(
    .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
    .INIT  (1'b0   ),           // Initial value of Q: 1'b0 or 1'b1
    .SRTYPE("SYNC" )            // Set/Reset type: "SYNC" or "ASYNC" 
  ) ODDR_rgmii_clk (
    .Q   (rgmii_tx_clk  ), // 1-bit DDR output
    .C   (gmii_tx_clk   ), // 1-bit clock input
    .CE  (1'b1          ), // 1-bit clock enable input
    .D1  (1'b1          ), // 1-bit data input (positive edge)
    .D2  (1'b0          ), // 1-bit data input (negative edge)
    .R   (reset         ), // 1-bit reset
    .S   (1'b0          )  // 1-bit set
  );
    
endmodule
