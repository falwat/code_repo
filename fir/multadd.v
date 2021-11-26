
// This can be packed into 1 DSP block (Ultrascale architecture)
// Make sure the widths are less than what is supported by the architecture
// p_out = p_in + a_in * b_in
module multadd #(
    parameter AWIDTH = 16,      // Width of multiplier's 1st input
              BWIDTH = 16,      // Width of multiplier's 2nd input
              PIN_WIDTH = 32,      // Width of Adder input    
              POUT_WIDTH = 33       // Output width
    )(
    input clk,      // Clock
    input ce,       // Clock enable  
    input rst,      // Reset
    input signed [AWIDTH-1:0] a_in,  // Multipler input
    input signed [BWIDTH-1:0] b_in,  // Multiplier input
    input signed [PIN_WIDTH-1:0] p_in,  // Adder input
    output signed [POUT_WIDTH-1:0] p_out  // p_out(n) = p_in(n-1) + a_in(n-1) * b_in
    );

    reg signed [POUT_WIDTH-1:0] p_out_r;

    always @ (posedge clk) begin
        if(rst) begin
            p_out_r <= 0;
        end else begin
            if(ce) begin
                p_out_r   <= a_in * b_in + p_in; 
            end
        end
    end
assign p_out = p_out_r;

endmodule                   
/* 
 The following is an instantation template for  mult_add_3 
 
 multadd # (
               .AWIDTH(AWIDTH),
               .BWIDTH(BWIDTH),
               .PIN_WIDTH(PIN_WIDTH),
               .POUT_WIDTH(POUT_WIDTH)
              )
your_instance_name 
             (
              .clk(clk),
              .ce(ce),
              .rst(rst),
              .a_in(a),
              .b_in(b),
              .p_in(c),
              .a_out(a_out),
              .p_out(p)
             );
*/
				
				