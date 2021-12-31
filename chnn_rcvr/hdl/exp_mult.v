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
// 
// Create Date: 2020/02/26 11:17:19
// Design Name: 
// Module Name: exp_mult
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 实现滤波器前指数相乘，输入数据乘以-1的n次
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module exp_mult #(
    parameter DATA_WIDTH = 16,  
    parameter DATA_PATH = 2                        // 数据路径 
)(
    input                               rst,
    input                               clk,
    input [DATA_WIDTH*DATA_PATH-1:0]    din, 
    input                               din_valid,
    output [DATA_WIDTH*DATA_PATH-1:0]   dout,
    output reg                          dout_valid
    );
    
    reg sgn;
    
    always @(posedge clk) begin
        if(rst) begin
            sgn <= 1'b0;
        end else if(din_valid) begin
            sgn <= ~sgn;
        end else begin
            sgn <= sgn;
        end
    end
    
    genvar var0;
    generate 
        for(var0=0;var0<DATA_PATH;var0=var0+1) begin : gen_exp_mult    
            wire signed [DATA_WIDTH - 1 : 0] din_data;
            assign din_data = din[var0 * DATA_WIDTH +: DATA_WIDTH];
            reg signed [DATA_WIDTH - 1 : 0] dout_data; 
                  
            always @(posedge clk) begin
                if(rst) begin
                    dout_data <= {DATA_WIDTH{1'b0}};
                end
                else if(din_valid) begin
                    if(sgn==1'b0) begin
                        dout_data <= din_data;
                    end 
                    else begin
                        dout_data <= -din_data;
                    end      
                end
            end

            assign dout[DATA_WIDTH*var0 +: DATA_WIDTH] = dout_data; 
        end
    endgenerate
    
    always @(posedge clk) begin
        if(rst) begin
            dout_valid <= 0;
        end
        else begin
            dout_valid <= din_valid;
        end
    end
endmodule

