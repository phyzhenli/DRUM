/*
Copyright (c) 2015 Soheil Hashemi (soheil_hashemi@brown.edu)
              2018 German Research Center for Artificial Intelligence (DFKI)

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

Approximate Multiplier Design Details Provided in:
Soheil Hashemi, R. Iris Bahar, and Sherief Reda, "DRUM: A Dynamic
Range Unbiased Multiplier for Approximate Applications" In
Proceedings of the IEEE/ACM International Conference on
Computer-Aided Design (ICCAD). 2015. 

*/

// parameter 5;
// parameter 8;
// parameter 8;


module DRUM5_8_8_u (a, b, r);

input [(8-1):0] a;
input [(8-1):0] b;
output [(8+8)-1:0] r;

wire [$clog2(8)-1:0] k1;
wire [$clog2(8)-1:0] k2;
wire [5-3:0] m,n;
wire [8-1:0] l1;
wire [8-1:0] l2;
wire [(5*2)-1:0] tmp;
wire [$clog2(8)-1:0] p;
wire [$clog2(8)-1:0] q;
wire [$clog2(8):0]sum;
wire [5-1:0]mm,nn;
LOD_5_8_8_u u1(.in_a(a),.out_a(l1));
LOD_5_8_8_u u2(.in_a(b),.out_a(l2));
P_Encoder_5_8_8_u u3(.in_a(l1), .out_a(k1));
P_Encoder_5_8_8_u u4(.in_a(l2), .out_a(k2));
Mux_5_8_8_u u5(.in_a(a), .select(k1), .out(m));
Mux_5_8_8_u u6(.in_a(b), .select(k2), .out(n));
assign p=(k1>(5-1))?k1-(5-1):0;
assign q=(k2>(5-1))?k2-(5-1):0;
assign mm=(k1>5-1)?({1'b1,m,1'b1}):a[5-1:0];
assign nn=(k2>5-1)?({1'b1,n,1'b1}):b[5-1:0];

assign tmp=mm*nn;
assign sum=p+q;

Barrel_Shifter_5_8_8_u u7(.in_a(tmp), .count(sum), .out_a(r));

endmodule

//------------------------------------------------------------
module LOD_5_8_8_u (in_a, out_a);

input [8-1:0]in_a;
output reg [8-1:0]out_a;

integer k,j;
reg [8-1:0]w;

always @(*)
    begin
        out_a[8-1] = in_a[8-1];
        w[8-1] = in_a[8-1]?0:1;
        for (k = 8-2; k>=0; k=k-1)
	        begin
                w[k] = in_a[k]?0:w[k+1];
                out_a[k] = w[k+1]&in_a[k];
	        end
	end

endmodule

//--------------------------------
module P_Encoder_5_8_8_u (in_a, out_a);

input [8-1:0]in_a;
output reg [$clog2(8)-1:0]out_a;

integer i;
    always @* begin
        out_a = 0;
        for (i=8-1; i>=0; i=i-1)
            if (in_a[i]) out_a = i[$clog2(8)-1:0];
    end
endmodule

//--------------------------------
module Barrel_Shifter_5_8_8_u (in_a, count, out_a);

input [$clog2(8):0]count;
input [(5*2)-1:0]in_a;
output [(8+8)-1:0]out_a;

wire [(8 + 8)-1:0] tmp;
assign tmp = {{((8 + 8)-(5*2)){1'b0}}, in_a};
assign out_a=(tmp<<count);

endmodule

//--------------------------------
module Mux_5_8_8_u (in_a, select, out);

input [$clog2(8)-1:0]select;
input [8-1:0]in_a;
output reg [5-3:0]out;

integer i;
always @(*) begin
    out = 0;
    for (i = 5; i < (8); i=i+1) begin :mux_gen_block
        if (select == i[$clog2(8)-1:0])
            out = in_a[i-1 -: 5-2];
    end
end

endmodule