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
// Create Date: 2021/11/14 10:00:15
// Design Name: 
// Module Name: chnn_rcvr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Digital channelized receiver based on polyphase filters.
//      
// Dependencies: 
//  - chnn_rcvr\hdl\exp_mult.v
//  - chnn_rcvr\hdl\axi_cmult.v
//  - fir\fir.v
//  - pfft\pfft.v
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*
chnn_rcvr #(
    .CHN_NUM(4),
    .DATA_WIDTH(32),
    .C_COEF_FILE("D:/fir.coe"),
    .C_COEF_WIDTH(24),
    .C_NUM_TAPS(32)
    ) instance_name (
    .aclk(aclk),
    .aresetn(aresetn),
    .s_axis_data_tvalid(s_axis_data_tvalid),
    .s_axis_data_tdata(s_axis_data_tdata),
    .m_axis_data_tvalid(m_axis_data_tvalid),
    .m_axis_data_tdata(m_axis_data_tdata)
    );
*/

module chnn_rcvr #(
    parameter CHN_NUM = 4,
    parameter DATA_WIDTH = 32, // complex data width
    parameter C_COEF_FILE = "D:/fir.coe",
    parameter C_COEF_WIDTH = 24,
    parameter C_NUM_TAPS = 32
    )(
    input aclk,
    input aresetn,
    input s_axis_data_tvalid,
    input [(CHN_NUM * DATA_WIDTH - 1) : 0] s_axis_data_tdata,
    output m_axis_data_tvalid,
    // {X[N-1].imag, X[-1].real,..., X[1].imag, X[1].real, X[0].imag, X[0].real}
    output [(CHN_NUM * DATA_WIDTH - 1) : 0] m_axis_data_tdata 
    );
    
    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
            depth = depth >> 1;
    endfunction
    
    wire [DATA_WIDTH * CHN_NUM - 1 : 0] fft_din; // ¸´Êý
    wire [CHN_NUM - 1 : 0] fft_din_valid;
    wire [DATA_WIDTH * CHN_NUM - 1 : 0] fft_dout; // ¸´Êý
    
    wire [47 : 0] rotate_factor[CHN_NUM - 1 : 0];
    wire [32 * 48 - 1 : 0] wn;
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
        for (i=0; i < CHN_NUM; i=i+1) begin: gen_b
            assign rotate_factor[i] = wn[i * (32 / CHN_NUM) * 48 +: 48];
        end   
    endgenerate
    
    localparam ROM_WIDTH = C_COEF_WIDTH * CHN_NUM;
    localparam ROM_DEPTH = C_NUM_TAPS / CHN_NUM;
    localparam ROM_ADDR_BITS = clogb2(ROM_DEPTH - 1);
    localparam HALF_DATA_WIDTH = DATA_WIDTH / 2;
    
    reg [ROM_ADDR_BITS - 1 : 0] reload_index;
    reg reload_done;
    reg s_axis_reload_tvalid;
    reg s_axis_reload_tlast;
    reg [ROM_WIDTH - 1 : 0] s_axis_reload_tdata;
    (* rom_style= "block" *)
    reg [ROM_WIDTH-1:0] coe_vector[ROM_DEPTH-1:0];
    initial
		$readmemh(C_COEF_FILE, coe_vector, 0, ROM_DEPTH-1);
    
    always @(posedge aclk) begin
        s_axis_reload_tdata <= coe_vector[reload_index];
    end
    
    
    always @(posedge aclk) begin
        if(~aresetn) begin
            reload_done <= 0;
            reload_index <= 0;
            s_axis_reload_tvalid <= 0;
            s_axis_reload_tlast <= 0;
        end else if(reload_index < ROM_DEPTH - 1) begin
            reload_done <= 0;
            reload_index <= reload_index + 1;
            s_axis_reload_tvalid <= 1;
            s_axis_reload_tlast <= 0;
        end else if(reload_index == ROM_DEPTH - 1 && reload_done == 0) begin
            reload_done <= 1;
            reload_index <= reload_index;
            s_axis_reload_tvalid <= 1;
            s_axis_reload_tlast <= 1;
        end else begin
            reload_done <= 1;
            reload_index <= reload_index;
            s_axis_reload_tvalid <= 0;
            s_axis_reload_tlast <= 0;
        end
    end
    
    genvar var0;
    generate
        for (var0=0; var0 < CHN_NUM; var0=var0+1)
        begin: gen_fir
            wire signed [DATA_WIDTH - 1 : 0] exp_mult_din;
            assign exp_mult_din = s_axis_data_tdata[DATA_WIDTH * var0 +: DATA_WIDTH];
            wire [DATA_WIDTH - 1 : 0] exp_mult_dout;
            wire exp_mult_dout_valid;
            
            exp_mult #(
                .DATA_WIDTH(HALF_DATA_WIDTH),
                .DATA_PATH(2)
                ) u_exp_mult_pre_fir (
                .rst(~aresetn), 
                .clk(aclk), 
                .din(exp_mult_din),
                .din_valid(s_axis_data_tvalid), 
                .dout(exp_mult_dout),
                .dout_valid(exp_mult_dout_valid)
            );
            
            wire dout_val_fir;
            wire [DATA_WIDTH - 1 : 0] dout_fir;
            
            fir #(
                .C_S_DATA_TDATA_WIDTH(HALF_DATA_WIDTH),
                .C_M_DATA_TDATA_WIDTH(HALF_DATA_WIDTH),
                .C_RELOAD_TDATA_WIDTH(C_COEF_WIDTH),
                .DATA_PATH(2),
                .C_COEF_FILE(""),
                .C_NUM_TAPS(ROM_DEPTH)
                ) u_fir (
                .aclk(aclk),
                .aresetn(aresetn),
                .s_axis_reload_tvalid(s_axis_reload_tvalid),
                .s_axis_reload_tlast(s_axis_reload_tlast),
                .s_axis_reload_tdata(s_axis_reload_tdata[var0 * C_COEF_WIDTH +: C_COEF_WIDTH]),
                .s_axis_data_tvalid(exp_mult_dout_valid),
                .s_axis_data_tdata(exp_mult_dout),
                .m_axis_data_tvalid(dout_val_fir),
                .m_axis_data_tdata(dout_fir)
            );
        
            axi_cmult #(
                .C_A_WIDTH(DATA_WIDTH),
                .C_B_WIDTH(48),
                .C_OUT_WIDTH(DATA_WIDTH),
                .BITS_TRUNK(22)
                ) u_axi_cmult (
                .aclk(aclk),
                .s_axis_a_tdata(dout_fir),
                .s_axis_a_tvalid(dout_val_fir),
                .s_axis_b_tdata(rotate_factor[CHN_NUM - 1 - var0]),
                .s_axis_b_tvalid(1'b1),
                .m_axis_dout_tdata(fft_din[32*var0+:32]),
                .m_axis_dout_tvalid(fft_din_valid[var0])
                );
        end
    endgenerate
    
    localparam FFT_ORDER = clogb2(CHN_NUM - 1);
    
    pfft #(
        .FFT_ORDER(FFT_ORDER), // {1:2, 2:4,3:8,4:16,5:32,6:64} FFT_ORDER = log2(N)
        .COMPLEX_DWIDTH(DATA_WIDTH)
        ) u_pfft (
        .aclk(aclk),                    // input wire aclk
        .aresetn(aresetn),              // input wire aresetn
        .scale_sch(4'b1111),
        .s_axis_tvalid(fft_din_valid[0]),  // input wire s_axis_tvalid
        .s_axis_tdata(fft_din),    // input wire [511 : 0] s_axis_tdata
        .m_axis_tvalid(m_axis_data_tvalid),  // output wire m_axis_tvalid
        .m_axis_tdata(fft_dout)    // output wire [511 : 0] m_axis_tdata
    );
    
    assign m_axis_data_tdata = fft_dout;

endmodule
