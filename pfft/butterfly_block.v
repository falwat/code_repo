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
// Create Date: 2021/11/05 15:04:09
// Design Name: 
// Module Name: butterfly_block
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//
//      This is a nested module using the Radix-2 decimation-in-time(DIT) 
// decomposition method for computing the DFT.
//      
//      The input data is divided into two groups according to odd and even 
// subscripts. And each group is input separately to the butterfly_block 
// submodule. Then these two submodules output data will perform butterfly 
// computation separately.
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module butterfly_block #(
    parameter FFT_ORDER = 3,
    parameter COMPLEX_A_DWIDTH = 32,
    parameter COMPLEX_B_DWIDTH = 32
    )(
    // Positive edge trigger
    input aclk,
    // Active Low 
    input aresetn,
    // Scaling schedule. Each bit control one stage
    input [FFT_ORDER - 1 : 0]scale_sch,
    input din_valid,
    // input data
    input [2 ** FFT_ORDER * COMPLEX_A_DWIDTH - 1 : 0] din_a,
    // input coefficient Wn
    input [2 ** (FFT_ORDER - 1) * COMPLEX_B_DWIDTH - 1 : 0] din_b,
    output dout_valid,
    // output data
    output [2 ** FFT_ORDER * COMPLEX_A_DWIDTH - 1 : 0] dout_p
    );
    
    localparam DATA_WIDTH = COMPLEX_A_DWIDTH / 2;
    localparam CHN_NUM = 2 ** FFT_ORDER;
    
    genvar k,i,m;
    generate
        if(FFT_ORDER == 1) begin: gen_fft_1
            reg din_valid_dly, din_valid_dly_2;
            wire signed [DATA_WIDTH - 1 : 0] a0_r, a0_i, a1_r, a1_i;
            reg signed [DATA_WIDTH : 0] p0_r, p0_i, p1_r, p1_i;
            reg signed [DATA_WIDTH - 1: 0] p0_scale_r, p0_scale_i, p1_scale_r, p1_scale_i;
            assign a0_r = din_a[0 * DATA_WIDTH +: DATA_WIDTH];
            assign a0_i = din_a[1 * DATA_WIDTH +: DATA_WIDTH];
            assign a1_r = din_a[2 * DATA_WIDTH +: DATA_WIDTH];
            assign a1_i = din_a[3 * DATA_WIDTH +: DATA_WIDTH];
            
            always @(posedge aclk) begin
                if(~aresetn) begin
                    din_valid_dly <= 0;
                    din_valid_dly_2 <= 0;
                    p0_r <= 0;
                    p0_i <= 0;
                    p1_r <= 0;
                    p1_i <= 0;
                    p0_scale_r <= 0;
                    p0_scale_i <= 0;
                    p1_scale_r <= 0;
                    p1_scale_i <= 0;
                end else begin
                    din_valid_dly <= din_valid;
                    din_valid_dly_2 <= din_valid_dly;
                    p0_r <= a0_r + a1_r;
                    p0_i <= a0_i + a1_i;
                    p1_r <= a0_r - a1_r;
                    p1_i <= a0_i - a1_i;
                    
                    if(scale_sch[0] == 1) begin
                        p0_scale_r <= p0_r[DATA_WIDTH : 1];
                        p0_scale_i <= p0_i[DATA_WIDTH : 1];
                        p1_scale_r <= p1_r[DATA_WIDTH : 1];
                        p1_scale_i <= p1_i[DATA_WIDTH : 1];
                    end else begin
                        p0_scale_r <= p0_r[DATA_WIDTH - 1 : 0];
                        p0_scale_i <= p0_i[DATA_WIDTH - 1 : 0];
                        p1_scale_r <= p1_r[DATA_WIDTH - 1 : 0];
                        p1_scale_i <= p1_i[DATA_WIDTH - 1 : 0];
                    end
                end
            end
            
            assign dout_valid = din_valid_dly_2;
            assign dout_p = {p1_scale_i, p1_scale_r, p0_scale_i, p0_scale_r};
            
//        end else if(FFT_ORDER == 2) begin: gen_fft_2
        
        end else begin: gen_fft_n
            wire [CHN_NUM / 2 * COMPLEX_A_DWIDTH - 1 : 0]din_a_subset[1:0];
            wire [CHN_NUM / 2 * COMPLEX_B_DWIDTH - 1 : 0]din_b_subset;
            wire dout_valid_0;
            wire [CHN_NUM / 2 * COMPLEX_A_DWIDTH - 1 : 0]dout_p_subset[1:0];
            for(k=0; k < CHN_NUM / 2; k=k+1) begin: gen_din_a
                // Even number part
                assign din_a_subset[0][COMPLEX_A_DWIDTH * k +: COMPLEX_A_DWIDTH] = din_a[(2 * k) * COMPLEX_A_DWIDTH +: COMPLEX_A_DWIDTH];
                // Odd number part
                assign  din_a_subset[1][COMPLEX_A_DWIDTH * k +: COMPLEX_A_DWIDTH] = din_a[(2 * k + 1) * COMPLEX_A_DWIDTH +: COMPLEX_A_DWIDTH];
            end
            
            for(m=0; m < CHN_NUM / 4; m=m+1) begin: gen_din_b
                assign din_b_subset[COMPLEX_B_DWIDTH * m +: COMPLEX_B_DWIDTH] = din_b[(2 * m) * COMPLEX_B_DWIDTH +: COMPLEX_B_DWIDTH];
            end
            
            butterfly_block #(
                .FFT_ORDER(FFT_ORDER - 1),
                .COMPLEX_A_DWIDTH(COMPLEX_A_DWIDTH),
                .COMPLEX_B_DWIDTH(COMPLEX_B_DWIDTH)
            ) u_bfb_0 (
                .aclk(aclk),
                .aresetn(aresetn),
                .scale_sch(scale_sch[FFT_ORDER - 1 : 1]),
                .din_valid(din_valid),
                .din_a(din_a_subset[0]),
                .din_b(din_b_subset),
                .dout_valid(dout_valid_0),
                .dout_p(dout_p_subset[0])
                );
                
            butterfly_block #(
                .FFT_ORDER(FFT_ORDER - 1),
                .COMPLEX_A_DWIDTH(COMPLEX_A_DWIDTH),
                .COMPLEX_B_DWIDTH(COMPLEX_B_DWIDTH)
            ) u_bfb_1 (
                .aclk(aclk),
                .aresetn(aresetn),
                .scale_sch(scale_sch[FFT_ORDER - 1 : 1]),
                .din_valid(din_valid),
                .din_a(din_a_subset[1]),
                .din_b(din_b_subset),
                .dout_valid(),
                .dout_p(dout_p_subset[1])
            );
            
            pipe_delay #(
                .DATA_WIDTH(1),		// DATA_WIDTH = 1,2...
                .DELAY_CLKS(8)		// DELAY_CLKS = 0,1,...
            ) u_pipe_delay_a0 (
                .rst(~aresetn), // input wire rst;    
                .clk(aclk), // input wire clk;    
                .clk_en(1'b1), // input wire clk_en;
                .din(dout_valid_0), // input wire  [DATA_WIDTH-1:0] din;
                .dout(dout_valid) // output wire [DATA_WIDTH-1:0] dout;
                );
                    
            for (i=0; i < CHN_NUM / 2; i=i+1) begin: gen_bf               
                butterfly #(
                    .COMPLEX_A_DWIDTH(COMPLEX_A_DWIDTH),
                    .COMPLEX_B_DWIDTH(COMPLEX_B_DWIDTH)
                ) u_bf (
                    .aclk (aclk),
                    .aresetn (aresetn),
                    .scale_en(scale_sch[0]),
                    .din_a0 (dout_p_subset[0][i * COMPLEX_A_DWIDTH +: COMPLEX_A_DWIDTH]),
                    .din_a1 (dout_p_subset[1][i * COMPLEX_A_DWIDTH +: COMPLEX_A_DWIDTH]),
                    .din_b (din_b[i * COMPLEX_B_DWIDTH +: COMPLEX_B_DWIDTH]),
                    .dout_p0 (dout_p[i * COMPLEX_A_DWIDTH +: COMPLEX_A_DWIDTH]),
                    .dout_p1 (dout_p[(i + CHN_NUM / 2) * COMPLEX_A_DWIDTH +: COMPLEX_A_DWIDTH])
                );
            end
        end
        
    endgenerate
   
endmodule

