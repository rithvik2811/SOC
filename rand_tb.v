`timescale 1ns / 1ps



module tbrando;
reg [31:0] inp;
reg clk, reset; 
wire [31:0] covres;
integer i;

rando uut (inp, clk, covres, reset);
initial 
clk = 1'b0;
always #5 clk=~clk;

initial 
begin
reset=1; #10
reset=0;
#1000
for(i=1;i<=10000;i=i+1)
         begin
           inp=i;#10; 
         end
end
endmodule
