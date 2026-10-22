module tb_top;
  logic clk=0, rst_n=0;
  logic [31:0] in_data[0:4], out_data[0:4];
  logic in_valid[0:4], in_ready[0:4], out_valid[0:4], out_ready[0:4];
  always #5 clk=~clk;
  noc_router dut(.*);
endmodule
