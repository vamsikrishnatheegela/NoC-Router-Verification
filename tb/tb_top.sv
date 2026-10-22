module tb_top;
 reg clk=0,rst_n=0; reg [159:0] in_data; reg [4:0] in_valid,out_ready; wire [159:0] out_data; wire [4:0] in_ready,out_valid;
 always #5 clk=~clk;
 noc_router dut(.*);
endmodule
