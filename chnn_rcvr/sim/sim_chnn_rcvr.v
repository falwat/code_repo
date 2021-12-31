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
// Create Date: 2021/11/15 20:20:15
// Design Name: 
// Module Name: sim_chnn_rcvr
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


module sim_chnn_rcvr;

    parameter CHN_NUM = 4;
    parameter DATA_WIDTH = 32; // complex data width
    parameter C_COEF_FILE = "D:/fir.coe";
    parameter C_COEF_WIDTH = 24;
    parameter C_NUM_TAPS = 32;
    
    parameter C_S_DATA_TDATA_WIDTH = DATA_WIDTH * CHN_NUM;
    parameter C_M_DATA_TDATA_WIDTH = C_S_DATA_TDATA_WIDTH;
    
    reg aclk;
    reg aresetn;
    reg s_axis_data_tvalid;
    reg [C_S_DATA_TDATA_WIDTH - 1 : 0] s_axis_data_tdata;
    wire m_axis_data_tvalid;
    wire [C_M_DATA_TDATA_WIDTH - 1 : 0] m_axis_data_tdata;
    
    chnn_rcvr #(
    .CHN_NUM(CHN_NUM),
    .DATA_WIDTH(DATA_WIDTH),
    .C_COEF_FILE(C_COEF_FILE),
    .C_COEF_WIDTH(C_COEF_WIDTH),
    .C_NUM_TAPS(C_NUM_TAPS)
    ) u_chnn_rcvr (
    .aclk(aclk),
    .aresetn(aresetn),
    .s_axis_data_tvalid(s_axis_data_tvalid),
    .s_axis_data_tdata(s_axis_data_tdata),
    .m_axis_data_tvalid(m_axis_data_tvalid),
    .m_axis_data_tdata(m_axis_data_tdata)
    );
    
    // Define file handle integer
    integer outfile;

    initial begin
    // Open file output.dat for writing
    outfile = $fopen("D:/output.dat", "w");
    
    // Check if file was properly opened and if not, produce error and exit
    if (outfile == 0) begin
        $display("Error: File, output.dat could not be opened.\nExiting Simulation.");
        $finish;
    end
    
    @(posedge m_axis_data_tvalid);
    
    while(m_axis_data_tvalid == 1) begin
        @(posedge aclk) if(m_axis_data_tvalid == 1) begin
            $fdisplay(outfile, "%h", m_axis_data_tdata);
        end
    end
    #100;
    
    // Close file to end monitoring
    $fclose(outfile);
    
      $display("Simulation ended normally");
      $stop;
    end
    
    // Define integers for file handling
    integer number_file;
    integer i=1;
    reg [C_S_DATA_TDATA_WIDTH - 1 : 0] data;
    initial begin
        aclk = 0;
        aresetn = 0;
        s_axis_data_tvalid = 0;
        s_axis_data_tdata = 0;
        
        // Open file numbers.txt for reading
        number_file = $fopen("D:/data.dat", "r");
        // Produce error and exit if file could not be opened
        if (number_file == 0) begin
            $display("Error: Failed to open file, data.dat\nExiting Simulation.");
            $finish;
        end
      
        #100;
        aresetn = 1;
        #100;
        
        // Loop while data is being read from file
        //    (i will be -1 when end of file or 0 for blank line)
        while (i>0) begin
            i=$fscanf(number_file, "%h", data);
            @(posedge aclk);
            #1;
            s_axis_data_tdata = data;
            s_axis_data_tvalid = 1;
        end
        // Close out file when finished reading
        $fclose(number_file);
        s_axis_data_tvalid = 0;
        #1000;
   end

    
    always #5 aclk = ~aclk;

endmodule
