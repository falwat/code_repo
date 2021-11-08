`timescale 1ns / 1ps
/*
 * This module was copied from the Vivado language template.
 */
 
//  Complex Multiplier
//  The following code implements a parameterizable complex multiplier
//  The style described uses 3 DSP's to implement the complex multiplier
//  taking advantage of the pre-adder, so widths chosen should be less than what the architecture supports or else extra-logic/extra DSPs will be inferred
module cmult # (
                parameter AWIDTH = 16, // size of 1st input of multiplier
                          BWIDTH = 18  // size of 2nd input of multiplier
               )
               (
                input clk,
                input signed [AWIDTH-1:0] 	    ar, ai,
                input signed [BWIDTH-1:0] 	    br, bi,
                output signed [AWIDTH+BWIDTH:0] pr, pi
                );

reg signed [AWIDTH-1:0]	ai_d, ai_dd, ai_ddd, ai_dddd;
reg signed [AWIDTH-1:0]	ar_d, ar_dd, ar_ddd, ar_dddd;
reg signed [BWIDTH-1:0]	bi_d, bi_dd, bi_ddd, br_d, br_dd, br_ddd;
reg signed [AWIDTH:0]		addcommon;
reg signed [BWIDTH:0]		addr, addi;
reg signed [AWIDTH+BWIDTH:0]	mult0, multr, multi, pr_int, pi_int;
reg signed [AWIDTH+BWIDTH:0]	common, commonr1, commonr2;

always @(posedge clk)
  begin
    ar_d   <= ar;
    ar_dd  <= ar_d;
    ai_d   <= ai;
    ai_dd  <= ai_d;
    br_d   <= br;
    br_dd  <= br_d;
    br_ddd <= br_dd;
    bi_d   <= bi;
    bi_dd  <= bi_d;
    bi_ddd <= bi_dd;
  end

   // Common factor (ar ai) x bi, shared for the calculations of the real and imaginary final products
   //
always @(posedge clk)
  begin
    addcommon <= ar_d - ai_d;
    mult0     <= addcommon * bi_dd;
    common    <= mult0;
  end

   // Real product
   //
always @(posedge clk)
  begin
    ar_ddd   <= ar_dd;
    ar_dddd  <= ar_ddd;
    addr     <= br_ddd - bi_ddd;
    multr    <= addr * ar_dddd;
    commonr1 <= common;
    pr_int   <= multr + commonr1;
  end

   // Imaginary product
   //
always @(posedge clk)
  begin
    ai_ddd   <= ai_dd;
    ai_dddd  <= ai_ddd;
    addi     <= br_ddd + bi_ddd;
    multi    <= addi * ai_dddd;
    commonr2 <= common;
    pi_int   <= multi + commonr2;
  end

assign pr = pr_int;
assign pi = pi_int;

endmodule // cmult
// The following is an instantiation template for cmult
/*
cmult # (.AWIDTH(16),
         .BWIDTH(18)
        )
your_instance_name
        (
         .clk(clk),
         .ar(ar),
         .ai(ai),
         .br(br),
         .bi(bi),
         .pr(pr),
         .pi(pi)
        );
*/

				
				