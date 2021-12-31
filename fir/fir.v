`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/08 09:52:43
// Design Name: 
// Module Name: fir
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

/**
fir #(
    .C_S_DATA_TDATA_WIDTH(16),
    .C_M_DATA_TDATA_WIDTH(16),
    .C_RELOAD_TDATA_WIDTH(16),
    .DATA_PATH(DATA_PATH),
    .C_COEF_FILE(""),
    .C_NUM_TAPS(4)
    ) instance_name (
    .aclk(aclk),
    .aresetn(aresetn),
    .s_axis_reload_tvalid(s_axis_reload_tvalid),
    .s_axis_reload_tlast(s_axis_reload_tlast),
    .s_axis_reload_tdata(s_axis_reload_tdata),
    .s_axis_data_tvalid(s_axis_data_tvalid),
    .s_axis_data_tdata(s_axis_data_tdata),
    .m_axis_data_tvalid(m_axis_data_tvalid),
    .m_axis_data_tdata(m_axis_data_tdata)
);
 */

module fir #(
    parameter C_S_DATA_TDATA_WIDTH = 16,
    parameter C_M_DATA_TDATA_WIDTH = 16,
    parameter C_RELOAD_TDATA_WIDTH = 16,
    parameter DATA_PATH = 1,
    parameter C_COEF_FILE = "",
//    parameter C_SYMMETRY = 0,   // 0: non-symmetry, 1: symmetry. 
//    parameter C_NUM_FILTS = 1,  
    parameter C_NUM_TAPS = 4
    )(
    input aclk,
    input aresetn,
    input s_axis_reload_tvalid,
    input s_axis_reload_tlast,
    input [C_RELOAD_TDATA_WIDTH - 1 : 0] s_axis_reload_tdata, // fix{N}_{N-1}
    input s_axis_data_tvalid,
    input [C_S_DATA_TDATA_WIDTH * DATA_PATH - 1 : 0] s_axis_data_tdata,
    output m_axis_data_tvalid,
    output [C_M_DATA_TDATA_WIDTH * DATA_PATH - 1 : 0]m_axis_data_tdata
    );
    
    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
            depth = depth >> 1;
    endfunction
  
    localparam P_WIDTH = C_S_DATA_TDATA_WIDTH + C_RELOAD_TDATA_WIDTH;
    reg [clogb2(C_RELOAD_TDATA_WIDTH - 1) - 1 : 0] coe_idxr;
    reg [C_RELOAD_TDATA_WIDTH - 1 :0] coe_vector[C_NUM_TAPS - 1 : 0];
    always @(posedge aclk) begin
        if(~aresetn) begin
            coe_idxr <= 0;
        end else if(s_axis_reload_tvalid) begin
            if(s_axis_reload_tlast) begin
                coe_idxr <= 0;
            end else begin
                coe_idxr <= coe_idxr + 1;
            end
        end else begin
            coe_idxr <= coe_idxr;
        end
    end
    
    // The following code either initializes the memory values to a specified file or to all zeros to match hardware
    generate
        if (C_COEF_FILE != "") begin: use_coef_file
            initial begin
                $readmemh(C_COEF_FILE, coe_vector, 0, C_NUM_TAPS-1);
            end
        end else begin: init_bram_to_zero
            integer ram_index;
            initial begin
                for (ram_index = 0; ram_index < C_NUM_TAPS; ram_index = ram_index + 1) begin
                    coe_vector[ram_index] = {C_RELOAD_TDATA_WIDTH{1'b0}};
                end
            end
        end
    endgenerate
    
    always @(posedge aclk) begin
        if(s_axis_reload_tvalid && coe_idxr < C_NUM_TAPS) begin
            coe_vector[coe_idxr] <= s_axis_reload_tdata;
        end
    end
    
    wire rst = ~aresetn;
    
    genvar i, k;
    generate
        for(k = 0; k < DATA_PATH; k = k + 1) begin: gen_dpath
            wire [P_WIDTH - 1 : 0] p[C_NUM_TAPS : 0];
            assign p[0] = 0;
            for(i = 0; i < C_NUM_TAPS; i = i + 1) begin: gen_node
                multadd # (
                   .AWIDTH(C_S_DATA_TDATA_WIDTH),
                   .BWIDTH(C_RELOAD_TDATA_WIDTH),
                   .PIN_WIDTH(P_WIDTH),
                   .POUT_WIDTH(P_WIDTH)
                  )
                u_multadd 
                 (
                  .clk(aclk),
                  .ce(s_axis_data_tvalid),
                  .rst(rst),
                  .a_in(s_axis_data_tdata[k * C_S_DATA_TDATA_WIDTH +: C_S_DATA_TDATA_WIDTH]),
                  .b_in(coe_vector[C_NUM_TAPS - 1 - i]),
                  .p_in(p[i]),
                  .p_out(p[i+1])
                 );
            end
            assign m_axis_data_tdata[k * C_M_DATA_TDATA_WIDTH +: C_M_DATA_TDATA_WIDTH] = 
                            p[C_NUM_TAPS][P_WIDTH-2 -: C_M_DATA_TDATA_WIDTH];
        end
    endgenerate
    
     pipe_delay #(
        .DATA_WIDTH(1),		// DATA_WIDTH = 1,2...
        .DELAY_CLKS(1)		// DELAY_CLKS = 0,1,...
    ) u_pipe_delay (
        .rst(rst), 			// input wire rst;    
        .clk(aclk), 			// input wire clk;    
        .clk_en(1'b1), 	// input wire clk_en;
        .din(s_axis_data_tvalid), 			// input wire [DATA_WIDTH-1:0] din;
        .dout(m_axis_data_tvalid)			// output wire [DATA_WIDTH-1:0] dout;
        );
    
endmodule
