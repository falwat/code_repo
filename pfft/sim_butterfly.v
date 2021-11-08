`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/05 15:59:46
// Design Name: 
// Module Name: sim_butterfly
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


module sim_butterfly;

    parameter COMPLEX_A_DWIDTH = 32;
    parameter COMPLEX_B_DWIDTH = 32;
    
    reg aclk;
    reg aresetn;
    reg [COMPLEX_A_DWIDTH - 1 : 0] din_a0;
    reg [COMPLEX_A_DWIDTH - 1 : 0] din_a1;
    reg [COMPLEX_B_DWIDTH - 1 : 0] din_b;
                        
    wire [COMPLEX_A_DWIDTH + 1: 0] dout_p0;
    wire [COMPLEX_A_DWIDTH + 1: 0] dout_p1;
    
    butterfly #(
        .COMPLEX_A_DWIDTH(COMPLEX_A_DWIDTH),
        .COMPLEX_B_DWIDTH(COMPLEX_B_DWIDTH)
    ) u_bf (
        .aclk (aclk),
        .aresetn (aresetn),
        .din_a0 (din_a0),
        .din_a1 (din_a1),
        .din_b (din_b),
        .dout_p0 (dout_p0),
        .dout_p1 (dout_p1)
        );

   // Define integers for file handling
   integer number_file;
   integer i=1;

   initial begin
        aresetn = 0;
        aclk = 0;
        din_a0 = 0;
        din_a1 = 0;
        din_b = 0;
        
      // Open file numbers.txt for reading
      number_file = $fopen("D:/numbers.txt", "r");
      // Produce error and exit if file could not be opened
      if (number_file == 0) begin
         $display("Error: Failed to open file, numbers.txt\nExiting Simulation.");
         $finish;
      end
      
      #100 aresetn = 1;
      #100;
      // Loop while data is being read from file
      //    (i will be -1 when end of file or 0 for blank line)
      while (i>0) begin
            @(posedge aclk);
         $display("i = %d", i);
         i=$fscanf(number_file, "%h, %h, %h", din_a0, din_a1, din_b);
         $display("a0 : %h, a1 : %h, b : %h", din_a0, din_a1, din_b);
      end
      // Close out file when finished reading
      $fclose(number_file);
      #200;
      $display("Simulation ended normally");
      $stop;
   end
   

    always #5 aclk = ~aclk;
    
    
endmodule
