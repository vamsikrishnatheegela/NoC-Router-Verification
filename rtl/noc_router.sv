module noc_router #(parameter integer DATA_W=32, FIFO_DEPTH=4)(
 input wire clk,rst_n,
 input wire [5*DATA_W-1:0] in_data, input wire [4:0] in_valid, output wire [4:0] in_ready,
 output wire [5*DATA_W-1:0] out_data, output wire [4:0] out_valid, input wire [4:0] out_ready);
 localparam integer PW=(FIFO_DEPTH<=2)?1:$clog2(FIFO_DEPTH), CW=$clog2(FIFO_DEPTH+1);
 reg [DATA_W-1:0] mem[0:4][0:FIFO_DEPTH-1]; reg [CW-1:0] count[0:4]; reg [PW-1:0] rp[0:4],wp[0:4];
 wire [2:0] route[0:4]; reg [5*DATA_W-1:0] od; reg [4:0] ov; integer i,j;
 genvar g; generate for(g=0;g<5;g=g+1) begin
   assign in_ready[g]=(count[g]<FIFO_DEPTH);
   assign route[g]=(count[g]!=0 && mem[g][rp[g]][DATA_W-1 -: 3]<=3'd4)?mem[g][rp[g]][DATA_W-1 -: 3]:3'd4;
 end endgenerate
 always @* begin od=0; ov=0; for(j=0;j<5;j=j+1) if(count[j]!=0) begin od[route[j]*DATA_W +: DATA_W]=mem[j][rp[j]]; ov[route[j]]=1'b1; end end
 assign out_data=od; assign out_valid=ov;
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n) for(i=0;i<5;i=i+1) begin count[i]<=0;rp[i]<=0;wp[i]<=0; end
  else for(i=0;i<5;i=i+1) begin
   if(in_valid[i]&&in_ready[i]) begin mem[i][wp[i]]<=in_data[i*DATA_W +: DATA_W]; wp[i]<=(wp[i]==FIFO_DEPTH-1)?0:wp[i]+1'b1; end
   if(count[i]!=0&&out_ready[route[i]]) rp[i]<=(rp[i]==FIFO_DEPTH-1)?0:rp[i]+1'b1;
   case({in_valid[i]&&in_ready[i],count[i]!=0&&out_ready[route[i]]}) 2'b10:count[i]<=count[i]+1'b1;2'b01:count[i]<=count[i]-1'b1;default:count[i]<=count[i];endcase
  end
 end
endmodule
