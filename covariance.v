`timescale 1ns / 1ps


module rando(inp, clk, covres, reset);
    //reg [31:0] inp[0:99][0:99];
    input clk;
    input [31:0]inp; 
    output wire [31:0] covres; reg[2:0] state; input reset;
    reg rr1, rr2, rr3, rr2b,en; reg [13:0] addra1, addra2,addra3, addra2b, size=100;
    reg [31:0] mean1[0:99]; //length has to be changed based on size
    reg [31:0] mdata,data1,data2,data3,data4,din,dout; //length has to be changed based on size
    wire[31:0] mdout,mdoutb;
    
    blk_mem_gen_0 ramin(.clka(clk), .wea(rr1), .addra(addra1), .dina(inp), .douta(dout));
    blk_mem_gen_1 rammean(.clka(clk), .wea(rr2), .addra(addra2), .dina(mdata), .douta(mdout), .clkb(clk), .web(rr2b), .addrb(addra2b), .dinb(0), .doutb(mdoutb), .enb(en));
    blk_mem_gen_0 ramout(.clka(clk), .wea(rr3), .addra(addra3), .dina(din), .douta(covres));
    reg[1:0] flag, flag2, flag1;
    reg [31:0] a1, a2;
    
    integer i,j,k,a=0;

   always@(posedge clk)
     begin
     if (reset)
     begin
        state<=3'b000; rr1<=1;rr2<=0;
        addra1<=0;
        addra2<=0;
        addra3<=0;
        data1<=0;
        data2<=0;
        data3<=0;
        flag<=0;flag2<=0;
        j<=0;k<=0;
        rr2b<=0;en<=0;addra2b<=0;
        a1<=0;a2<=0;
     end
     else
     begin
     case(state)
        3'b000:begin
         if(a==size-1)
         begin
         mean1[a]<=32'd0;state<=3'b001;
         end
         else
         begin
         state<=3'b000;
         mean1[a]<=32'd0;a<=a+1;
         end
         end
        3'b001:begin 
                if (addra1==size*size-1)
                begin
                mean1[j]=mean1[j]+inp;
                state<=3'b010; rr1<=0;j=0;addra1<=0;
                end
                else
                begin
                state<=3'b001;
                if((addra1%size)==0)
                begin
/*                if(i==size)
                begin
                i=0;
                end
*/              j=0;    
                mean1[j]=mean1[j]+inp;j=j+1;
                end
                else
                begin
                mean1[j]=mean1[j]+inp;j=j+1;
                end
                addra1<=addra1+1;
                end
               end
        3'b010:begin
                if(j==size-1)
                begin
                mean1[j]<=mean1[j]/size;
                state<=3'b011;j<=0;addra1<=0;rr2<=1;addra2<=0;
                end
                else
                begin
                state<=3'b010;
                mean1[j]<=mean1[j]/size;
                j<=j+1;
                end    
               end
        3'b011:begin
               case(flag)
                0:begin flag<=flag+1;addra1<=addra1+1; end
                1:begin flag<=flag+1;addra1<=addra1+1;addra2<=addra2-1; end  // addra2 manipulated
                default:begin
                if(j==size*size)
                begin
                state<=3'b100;addra1<=0;addra2<=0;rr2<=0;i<=0;j<=0;en<=1;addra2b<=0; data2<=0;
                end
                else
                begin
                state<=3'b011;
                mdata<=dout-mean1[j%size];
                j<=j+1;
                addra1<=addra1+1;addra2<=addra2+1;          
                end
                end
                endcase                     
               end
        3'b100:begin
               if(addra3==size*size)
               begin
               state<=3'b101;addra3<=0;
               end
               else
               begin
               state<=3'b100;
               a1<=mdout;
               a2<=mdoutb;
               data1<=a1*a2;
               
               case(k)
               0:begin rr3<=0;
               if(rr3)begin addra3<=addra3+1;rr3<=0; end
               addra2<=addra2+size;
               addra2b<=addra2b+size;
               data2<=data2+data1;
               k<=k+1; end
               size-1:
                    begin k<=0;
                    if(i<=size)
                    begin data2<=data1;din<=data2/(size-1);
                    if(flag2==0)
                    flag2<=1;
                    else
                    rr3<=1; end      
                    case(j)
                    size-1:begin j<=0;
                            i<=i+1;                             
                        addra2<=(i+1);addra2b<=0; end
                    default:begin j<=j+1;addra2<=i;addra2b<=(j+1); end 
                     endcase
                     end
              default: 
               begin
               addra2<=addra2+size;
               addra2b<=addra2b+size;
               data2<=data2+data1;
               k<=k+1;
               end
                endcase
               end 
              end
       3'b101:
       begin 
       if(addra3<size*size)
       begin
       addra3<=addra3+1;
       end
       end                         
      endcase
     end
     end 
         
endmodule
