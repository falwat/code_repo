`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/08 11:08:21
// Design Name: 
// Module Name: sim_fir
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


module sim_fir;

    parameter C_S_DATA_TDATA_WIDTH = 16;
    parameter C_M_DATA_TDATA_WIDTH = 16;
    parameter C_RELOAD_TDATA_WIDTH = 24;
    parameter C_NUM_TAPS = 63;
    // !!!Please use "/" not "\" for filepath!!!
    parameter C_COEF_FILE = "D:/fir.coe"; 
    
    reg aclk;
    reg aresetn;
    reg s_axis_reload_tvalid;
    reg s_axis_reload_tlast;
    reg [C_RELOAD_TDATA_WIDTH - 1 : 0] s_axis_reload_tdata;
    reg s_axis_data_tvalid;
    reg [C_S_DATA_TDATA_WIDTH - 1 : 0] s_axis_data_tdata;
    wire m_axis_data_tvalid;
    wire [C_M_DATA_TDATA_WIDTH - 1 : 0]m_axis_data_tdata;
    
    fir #(
        .C_S_DATA_TDATA_WIDTH (C_S_DATA_TDATA_WIDTH),
        .C_M_DATA_TDATA_WIDTH (C_M_DATA_TDATA_WIDTH),
        .C_RELOAD_TDATA_WIDTH (C_RELOAD_TDATA_WIDTH),
        .C_NUM_TAPS (C_NUM_TAPS),
        .C_COEF_FILE (C_COEF_FILE)
    ) u_fir (
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
    
    initial begin
        aclk = 0;
        aresetn = 0;
        s_axis_data_tvalid = 0;
        s_axis_data_tdata <= 0;
        
        #100 aresetn = 1;
        
        #200 s_axis_data_tvalid = 1;
        s_axis_data_tdata = 16'h0100;
        
    end
    
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
    end
    
       // Define integers for file handling
    integer number_file;
    integer i=1;
    reg [C_S_DATA_TDATA_WIDTH - 1 : 0] data;
    initial begin
        aclk = 0;
        aresetn = 0;
        s_axis_reload_tvalid = 0;
        s_axis_reload_tlast = 0;
        s_axis_reload_tdata = 0;
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
            s_axis_data_tdata = data;
            s_axis_data_tvalid = 1;
      end
      // Close out file when finished reading
      $fclose(number_file);
      s_axis_data_tvalid = 0;
      #200;
      $display("Simulation ended normally");
      $stop;
   end

    
    always #5 aclk = ~aclk;

endmodule
