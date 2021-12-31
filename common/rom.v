`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/26 17:46:11
// Design Name: 
// Module Name: rom
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


/* instance template
rom #(
		.ROM_TYPE("block"),		// ROM_TYPE = "block" or "distributed"
		.ROM_WIDTH(32),				// data out width
        .ROM_DEPTH(256),
		.ROM_ADDR_BITS(8),		// address bit width
		.DATA_FILE("")				// please assign a data file
	) instance_name (
    .clk(clk), 
    .clk_en(clk_en), 
    .addr(addr), 		// wire [ROM_ADDR_BITS-1:0] addr;
    .dout(dout)		// wire [ROM_WIDTH-1:0] 		dout;
    );
*/


module rom #(
	parameter ROM_TYPE = "block",	// ROM_TYPE = "block" or "distributed"
	parameter ROM_WIDTH = 32,		// data out width;
	parameter ROM_DEPTH = 64,
    parameter ROM_ADDR_BITS = 6,
	parameter DATA_FILE = ""		// please assign a data file
)
(
    input 							clk,
    input 							clk_en,
    input [ROM_ADDR_BITS-1:0] 		addr,
    output reg [ROM_WIDTH-1:0] 		dout
    );

    
	(* rom_style= ROM_TYPE *)
	reg [ROM_WIDTH-1:0] mems [ROM_DEPTH-1:0];
	
	initial
		$readmemh(DATA_FILE, mems, 0, ROM_DEPTH-1);
	
	always @(posedge clk)
		if (clk_en)
			dout <= mems[addr];
	
endmodule
