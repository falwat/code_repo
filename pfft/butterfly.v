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
// Create Date: 2021/11/05 10:57:00
// Design Name: 
// Module Name: butterfly
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      P0 = A0 + B * A1
//      P1 = A0 - B * A1
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module butterfly #(
    parameter COMPLEX_A_DWIDTH = 32,
    parameter COMPLEX_B_DWIDTH = 32
)
(
    input aclk,
    input aresetn,
    input scale_en,
    input [COMPLEX_A_DWIDTH - 1 : 0] din_a0,
    input [COMPLEX_A_DWIDTH - 1 : 0] din_a1,
    input [COMPLEX_B_DWIDTH - 1 : 0] din_b,
    output [COMPLEX_A_DWIDTH - 1: 0] dout_p0,
    output [COMPLEX_A_DWIDTH - 1: 0] dout_p1,
    output event_overflow
    );
    
    localparam CMULT_AWIDTH = COMPLEX_A_DWIDTH / 2;
    localparam CMULT_BWIDTH = COMPLEX_B_DWIDTH / 2;
    localparam DELAY_CLKS = 6;
    
    wire [COMPLEX_A_DWIDTH - 1 : 0] din_a0_dly;
    
    wire signed [CMULT_AWIDTH - 1 : 0] a0_r = din_a0_dly[CMULT_AWIDTH - 1 : 0];
    wire signed [CMULT_AWIDTH - 1 : 0] a0_i = din_a0_dly[COMPLEX_A_DWIDTH - 1 : CMULT_AWIDTH];
    wire signed [CMULT_AWIDTH - 1 : 0] a1_r = din_a1[CMULT_AWIDTH - 1 : 0];
    wire signed [CMULT_AWIDTH - 1 : 0] a1_i = din_a1[COMPLEX_A_DWIDTH - 1 : CMULT_AWIDTH];
    wire signed [CMULT_BWIDTH - 1 : 0] br = din_b[CMULT_BWIDTH - 1 : 0];
    wire signed [CMULT_BWIDTH - 1 : 0] bi = din_b[COMPLEX_B_DWIDTH - 1 : CMULT_BWIDTH];
    
    wire signed [CMULT_AWIDTH + CMULT_BWIDTH - 1 : 0] pr, pi;
    wire signed [CMULT_AWIDTH - 1 : 0] pr_slice, pi_slice;
    assign pr_slice = pr[CMULT_BWIDTH - 2 +: CMULT_AWIDTH];
    assign pi_slice = pi[CMULT_BWIDTH - 2 +: CMULT_AWIDTH];
    wire signed [CMULT_AWIDTH : 0] pmax, pmin;
    assign pmax = 2 ** (CMULT_AWIDTH - 1) - 1;
    assign pmin = -(2 ** (CMULT_AWIDTH - 1));
    
    reg signed [CMULT_AWIDTH : 0] p0_r, p0_i, p1_r, p1_i;
    reg signed [CMULT_AWIDTH - 1 : 0] p0_scale_r, p0_scale_i, p1_scale_r, p1_scale_i;
    reg event_overflow_r;
    
    pipe_delay #(
        .DATA_WIDTH(COMPLEX_A_DWIDTH),		// DATA_WIDTH = 1,2...
        .DELAY_CLKS(DELAY_CLKS)		// DELAY_CLKS = 0,1,...
    ) u_pipe_delay_a0 (
        .rst(~aresetn), 			// input wire						rst;    
        .clk(aclk), 			// input wire						clk;    
        .clk_en(1'b1), 	// input wire						clk_en;
        .din(din_a0), 			// input wire  [DATA_WIDTH-1:0] 	din;
        .dout(din_a0_dly)			// output wire [DATA_WIDTH-1:0] 	dout;
        );
       
        
    always @(posedge aclk) begin
        if(~aresetn) begin
            p0_r <= 0;
            p0_i <= 0;
            p1_r <= 0;
            p1_i <= 0;
            p0_scale_r <= 0;
            p0_scale_i <= 0;
            p1_scale_r <= 0;
            p1_scale_i <= 0;
        end else begin
            p0_r <= a0_r + pr_slice;
            p0_i <= a0_i + pi_slice;
            p1_r <= a0_r - pr_slice;
            p1_i <= a0_i - pi_slice;
            if(scale_en) begin
                p0_scale_r <= p0_r[CMULT_AWIDTH : 1];
                p0_scale_i <= p0_i[CMULT_AWIDTH : 1];
                p1_scale_r <= p1_r[CMULT_AWIDTH : 1];
                p1_scale_i <= p1_i[CMULT_AWIDTH : 1];
            end else begin
                p0_scale_r <= p0_r[CMULT_AWIDTH - 1 : 0];
                p0_scale_i <= p0_i[CMULT_AWIDTH - 1 : 0];
                p1_scale_r <= p1_r[CMULT_AWIDTH - 1 : 0];
                p1_scale_i <= p1_i[CMULT_AWIDTH - 1 : 0];
            end
        end
    end
    
    always @(posedge aclk) begin
        if(~aresetn) begin
            event_overflow_r <= 0;
        end else if(p0_r > pmax || p0_r < pmin || 
                    p0_i > pmax || p0_i < pmin || 
                    p1_r > pmax || p1_r < pmin || 
                    p1_i > pmax || p1_i < pmin) begin
            event_overflow_r <= 1;
        end else begin
            event_overflow_r <= 0;
        end
    end
    
    cmult # (
        .AWIDTH(CMULT_AWIDTH),
        .BWIDTH(CMULT_BWIDTH)
        )
        u_cmult
        (
         .clk(aclk),
         .ar(a1_r),
         .ai(a1_i),
         .br(br),
         .bi(bi),
         .pr(pr),
         .pi(pi)
        );
        
    assign dout_p0 = {p0_scale_i, p0_scale_r};
    assign dout_p1 = {p1_scale_i, p1_scale_r};
    
endmodule
