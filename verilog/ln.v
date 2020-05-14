//*********************************************************
// IEEE STD 1364-2001 Verilog file: ln.v 
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module ln #(parameter N = 5, // -- Number of coeffcients-1
            parameter W= 17) // -- Bitwidth -1                         
       (input clk,
        input signed [W:0] x_in,
        output reg signed [W:0] f_out);

  reg signed [W:0] x, f;   // Auxilary register
  wire signed [W:0] p [0:5];  
  reg signed [W:0] s [0:5];           
  
// Polynomial coefficients for 16-bit precision: 
// f(x) = (1  + 65481 x -32093 x^2 + 18601 x^3 
//                      -8517 x^4 + 1954 x^5)/65536  
  assign p[0] = 18'sd1;
  assign p[1] = 18'sd65481;
  assign p[2] = -18'sd32093;
  assign p[3] = 18'sd18601;
  assign p[4] = -18'sd8517;
  assign p[5] = 18'sd1954;
  
  always @(posedge clk) 
  begin : Store
    x <= x_in;     // Store input in register
  end 
  
  always @(posedge clk)        // Compute sum-of-products
  begin :  SOP
    integer k; // define the loop variable
    reg signed [35:0] slv;  

    s[N] = p[N];  
// Polynomial Approximation from Chebyshev coefficients
    for (k=N-1; k>=0; k=k-1)
    begin
      slv   = x * s[k+1]; // no FFs for slv
      s[k]  = (slv >>> 16) + p[k];
    end     // x*s/65536 problem 32 bits
    f_out  <= s[0];      // make visable outside  
  end

endmodule