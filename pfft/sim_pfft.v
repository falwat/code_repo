`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/06 14:43:47
// Design Name: 
// Module Name: sim_pfft
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


module sim_pfft;
    
    parameter FFT_ORDER = 2;
    parameter COMPLEX_DWIDTH = 32;
    
    reg aclk;
    reg aresetn;
    reg s_axis_tvalid;
    reg [2 ** FFT_ORDER * COMPLEX_DWIDTH - 1 : 0] s_axis_tdata;
    wire m_axis_tvalid;
    wire [2 ** FFT_ORDER * COMPLEX_DWIDTH - 1 : 0] m_axis_tdata;
    reg [2 ** FFT_ORDER * COMPLEX_DWIDTH - 1 : 0] data;
    
    pfft #(
        .FFT_ORDER(FFT_ORDER),
        .COMPLEX_DWIDTH(32)
    ) u_pfft (
        .aclk(aclk),
        .aresetn(aresetn),
        .scale_sch({FFT_ORDER{1'b1}}),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tdata(s_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tdata(m_axis_tdata)
        );
           
    always #5 aclk = ~aclk;
    
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
      
      @(posedge s_axis_tvalid);

      // Write monitor data to a file
      $fmonitor (outfile, "%h", m_axis_tdata);

      // Wait for 1 ms and end monitoring
      @(negedge m_axis_tvalid);
      #100;

      // Close file to end monitoring
      $fclose(outfile);
   end
    
   // Define integers for file handling
   integer number_file;
   integer i=1;

   initial begin
        aclk = 0;
        aresetn = 0;
        s_axis_tvalid = 0;
        s_axis_tdata = 0;
        
      // Open file numbers.txt for reading
      number_file = $fopen("D:/numbers.txt", "r");
      // Produce error and exit if file could not be opened
      if (number_file == 0) begin
         $display("Error: Failed to open file, numbers.txt\nExiting Simulation.");
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
            s_axis_tdata = data;
            s_axis_tvalid = 1;
      end
      // Close out file when finished reading
      $fclose(number_file);
      s_axis_tvalid = 0;
      #200;
      $display("Simulation ended normally");
      $stop;
   end

    
endmodule
