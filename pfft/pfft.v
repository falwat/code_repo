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
// Create Date: 2021/11/05 15:01:02
// Design Name: 
// Module Name: pfft
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
//      Parallel FFT processing Module(PFFT).
// 
//      The PFFT module uses the Radix-2 decimation-in-time(DIT) decomposition method 
//   for computing the DFT.
// 
//      The PFFT module computes an N-Point forward DFT where N is 2^FFT_ORDER, 
//   the value of parameter FFT_ORDER can be 1,2,..,6. For larger N, you need to modify 
//   the source code appropriately.
//
//      The main difference with Xilinx FFT LogiCORE IP is that PFFT can perform 
//   one FFT operation per clock, but Xilinx FFT LogiCORE IP need N+1 clocks.
//      
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pfft #(
    parameter FFT_ORDER = 4, // {1:2, 2:4,3:8,4:16,5:32,6:64} FFT_ORDER = log2(N)
    parameter COMPLEX_DWIDTH = 32
)(
    // Positive edge trigger
    input aclk,
    // Active Low 
    input aresetn, 
    // Scaling schedule. Each bit control one stage
    input [FFT_ORDER - 1 : 0]scale_sch, 
    // AXI4-Stream Slave Interface for Data Input Channel.
    input s_axis_tvalid,
    // {x[N-1].imag, x[N-1].real, ..., x[1].imag, x[1].real, x[0].imag, x[0].real}
    input [2 ** FFT_ORDER * COMPLEX_DWIDTH - 1 : 0] s_axis_tdata,
    // AXI4-Stream Master Interface for Data Output Channel.
    output m_axis_tvalid,
    // {X[N-1].imag, X[N-1].real, ..., X[1].imag, X[1].real, X[0].imag, X[0].real}
    output [2 ** FFT_ORDER * COMPLEX_DWIDTH - 1 : 0] m_axis_tdata
    );
    
    
    localparam COMPLEX_B_DWIDTH = 48;
    localparam COE_NUM = 2 ** (FFT_ORDER - 1);
    wire [COE_NUM * COMPLEX_B_DWIDTH - 1 : 0] b;
    // wn[k] = exp(-j*2*pi*k/N)
    wire [32 * COMPLEX_B_DWIDTH - 1 : 0] wn;
    initial begin
        if(FFT_ORDER > 6) 
            $error("For the configure of FFT_ORDER > 6, please modify the value of wn!!");
    end
    assign wn = {
        48'hf9ba17_c04ee5, 48'hf383a4_c13ad1, 48'hed6bfa_c2c17e, 48'he7821e_c4df29, 
        48'he1d4a3_c78e9b, 48'hdc718a_cac934, 48'hd7661a_ce8700, 48'hd2bec4_d2bec4, 
        48'hce8700_d7661a, 48'hcac934_dc718a, 48'hc78e9b_e1d4a3, 48'hc4df29_e7821e, 
        48'hc2c17e_ed6bfa, 48'hc13ad1_f383a4, 48'hc04ee5_f9ba17, 48'hc00000_000000, 
        48'hc04ee5_0645e9, 48'hc13ad1_0c7c5c, 48'hc2c17e_129406, 48'hc4df29_187de2, 
        48'hc78e9b_1e2b5d, 48'hcac934_238e76, 48'hce8700_2899e6, 48'hd2bec4_2d413c, 
        48'hd7661a_317900, 48'hdc718a_3536cc, 48'he1d4a3_387165, 48'he7821e_3b20d7, 
        48'hed6bfa_3d3e82, 48'hf383a4_3ec52f, 48'hf9ba17_3fb11b, 48'h000000_400000
    };
    
    genvar i;
    generate
        for (i=0; i < COE_NUM; i=i+1) begin: gen_b
            assign b[i * COMPLEX_B_DWIDTH +: COMPLEX_B_DWIDTH] = wn[i * (32 / COE_NUM) * COMPLEX_B_DWIDTH +: COMPLEX_B_DWIDTH];
        end   
    endgenerate
    
    butterfly_block #(
        .FFT_ORDER(FFT_ORDER),
        .COMPLEX_A_DWIDTH(COMPLEX_DWIDTH),
        .COMPLEX_B_DWIDTH(COMPLEX_B_DWIDTH)
    ) u_bfb_1 (
        .aclk(aclk),
        .aresetn(aresetn),
        .scale_sch(scale_sch),
        .din_valid(s_axis_tvalid),
        .din_a(s_axis_tdata),
        .din_b(b),
        .dout_valid(m_axis_tvalid),
        .dout_p(m_axis_tdata)
    );
            
endmodule
