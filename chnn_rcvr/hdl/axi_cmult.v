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
 `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
//      Jackie Wang(falwat@163.com)
// Create Date: 2021/11/14 14:43:32
// Design Name: 
// Module Name: axi_cmult
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Complex multiplier with AXI-Stream interface.
//
// Dependencies: 
//  - common\cmult.v
//  - common\pipe_delay.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
axi_cmult #(
    .C_A_WIDTH(32),
    .C_B_WIDTH(32),
    .C_OUT_WIDTH(64),
    .BITS_TRUNK(31)
    ) u_axi_cmult (
    .aclk(aclk),
    .s_axis_a_tdata(s_axis_a_tdata),
    .s_axis_a_tvalid(s_axis_a_tvalid),
    .s_axis_b_tdata(s_axis_b_tdata),
    .s_axis_b_tvalid(s_axis_b_tvalid),
    .m_axis_dout_tdata(m_axis_dout_tdata),
    .m_axis_dout_tvalid(m_axis_dout_tvalid)
    );
 */

module axi_cmult #(
    parameter C_A_WIDTH = 32,
    parameter C_B_WIDTH = 32,
    parameter C_OUT_WIDTH = 32,
    parameter BITS_TRUNK = 31
)(
    input aclk,
    input [C_A_WIDTH-1:0] s_axis_a_tdata,
    input s_axis_a_tvalid,
    input [C_B_WIDTH-1:0] s_axis_b_tdata,
    input s_axis_b_tvalid,
    output [C_OUT_WIDTH-1:0] m_axis_dout_tdata,
    output  m_axis_dout_tvalid
    );
    
    localparam AWIDTH = C_A_WIDTH / 2;
    localparam BWIDTH = C_B_WIDTH / 2;
    localparam PWIDTH = AWIDTH + BWIDTH - 1;
    wire [AWIDTH - 1 : 0] ar = s_axis_a_tdata[0 +: AWIDTH];
    wire [AWIDTH - 1 : 0] ai = s_axis_a_tdata[AWIDTH +: AWIDTH];
    wire [BWIDTH - 1 : 0] br = s_axis_b_tdata[0 +: BWIDTH];
    wire [BWIDTH - 1 : 0] bi = s_axis_b_tdata[BWIDTH +: BWIDTH];
    wire [PWIDTH - 1 : 0] pr, pi;
    
    cmult # (
        .AWIDTH(AWIDTH),
        .BWIDTH(BWIDTH)
        )
        u_cmult
        (
         .clk(aclk),
         .ar(ar),
         .ai(ai),
         .br(br),
         .bi(bi),
         .pr(pr),
         .pi(pi)
        );
    
    localparam OUT_WIDTH = C_OUT_WIDTH / 2;
    assign m_axis_dout_tdata[0 +: OUT_WIDTH] = pr[BITS_TRUNK +: OUT_WIDTH];
    assign m_axis_dout_tdata[OUT_WIDTH +: OUT_WIDTH] = pi[BITS_TRUNK +: OUT_WIDTH];
    
    pipe_delay #(
        .DATA_WIDTH(1),		// DATA_WIDTH = 1,2...
        .DELAY_CLKS(6)		// DELAY_CLKS = 0,1,...
        ) u_pipe_delay (
        .rst(1'b0), 			// input wire rst;    
        .clk(aclk), 			// input wire clk;    
        .clk_en(1'b1), 	// input wire clk_en;
        .din(s_axis_a_tvalid & s_axis_b_tvalid), 			// input wire [DATA_WIDTH-1:0] din;
        .dout(m_axis_dout_tvalid)			// output wire [DATA_WIDTH-1:0] dout;
        );
    
endmodule
