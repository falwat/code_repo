`timescale 1ns / 1ps
/*
 * Copyright (C) 2021 Jackie Wang(falwat@163.com).  All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
 
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
//      Jackie Wang(falwat@163.com)
//
// Create Date: 2016/01/03 08:32:36
// Design Name: 
// Module Name: pipe_delay
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      This module realizes the data from inport `din` to outport `dout` after
// `DELAY_CLKS` clock delay.
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/* instance template
pipe_delay #(
	.DATA_WIDTH(16),		// DATA_WIDTH = 1,2...
	.DELAY_CLKS(2)		// DELAY_CLKS = 0,1,...
) instance_name (
    .rst(rst), 			// input wire rst;    
    .clk(clk), 			// input wire clk;    
    .clk_en(clk_en), 	// input wire clk_en;
    .din(din), 			// input wire [DATA_WIDTH-1:0] din;
    .dout(dout)			// output wire [DATA_WIDTH-1:0] dout;
    );

*/
module pipe_delay #(
	parameter DATA_WIDTH = 16,			// DATA_WIDTH = 1,2...
	parameter integer DELAY_CLKS = 2	// DELAY_CLKS = 0,1,...
)
(
    input 						rst,
    input 						clk,
    input 						clk_en,
    input [DATA_WIDTH-1:0] 		din,
    output [DATA_WIDTH-1:0] 	dout
    );
    
    genvar iter;
    generate 
    	if(DELAY_CLKS==0) begin: clk0_gen
    		assign dout = din;
    	end else if(DELAY_CLKS==1) begin: clk1_gen
    		reg [DATA_WIDTH-1:0] reg_tmp;
    		assign dout = reg_tmp;
    		always @(posedge clk)
    			if(rst)
    				reg_tmp <= {DATA_WIDTH{1'b0}};
    			else if(clk_en)
    				reg_tmp <= din;
    	end else begin: clkm_gen
    		reg [DATA_WIDTH-1:0] reg_tmp[0:DELAY_CLKS-1];
    		assign dout = reg_tmp[DELAY_CLKS-1];
			for (iter=0; iter < DELAY_CLKS; iter=iter+1) 
    		begin: loop_gen
    			always @(posedge clk)
    				if(rst)
    					reg_tmp[iter] <= {DATA_WIDTH{1'b0}};
    				else if(clk_en)
    					if(iter==0)
    						reg_tmp[iter] <= din;
    					else
    						reg_tmp[iter] <= reg_tmp[iter-1];					
    		end
    	end
    endgenerate
        
endmodule

			
			
