module noc_router #(
    parameter int DATA_W = 32,
    parameter int FIFO_DEPTH = 4
) (
    input  logic clk, input logic rst_n,
    input  logic [DATA_W-1:0] in_data [0:4],
    input  logic in_valid [0:4], output logic in_ready [0:4],
    output logic [DATA_W-1:0] out_data [0:4],
    output logic out_valid [0:4], input logic out_ready [0:4]
);
  localparam int PW = $clog2(FIFO_DEPTH+1);
  logic [DATA_W-1:0] mem [0:4][0:FIFO_DEPTH-1];
  logic [PW-1:0] count [0:4];
  logic [$clog2(FIFO_DEPTH)-1:0] rd_ptr [0:4], wr_ptr [0:4];
  logic [2:0] route [0:4];
  integer i;

  function automatic [2:0] route_for(input logic [DATA_W-1:0] p);
    // Packet destination is bits [31:28]: 0=N,1=S,2=E,3=W,4=LOCAL.
    route_for = (p[DATA_W-1 -: 3] <= 3'd4) ? p[DATA_W-1 -: 3] : 3'd4;
  endfunction

  always_comb begin
    for (int k=0;k<5;k++) begin
      in_ready[k] = (count[k] < FIFO_DEPTH);
      out_data[k] = '0; out_valid[k] = 1'b0;
      route[k] = (count[k] != 0) ? route_for(mem[k][rd_ptr[k]]) : 3'd4;
    end
    for (int k=0;k<5;k++) begin
      if (count[k] != 0) begin
        out_data[route[k]] = mem[k][rd_ptr[k]];
        out_valid[route[k]] = 1'b1;
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i=0;i<5;i++) begin count[i] <= '0; rd_ptr[i] <= '0; wr_ptr[i] <= '0; end
    end else begin
      for (i=0;i<5;i++) begin
        if (in_valid[i] && in_ready[i]) begin
          mem[i][wr_ptr[i]] <= in_data[i];
          wr_ptr[i] <= wr_ptr[i] + 1'b1;
        end
        if (count[i] != 0 && out_ready[route[i]])
          rd_ptr[i] <= rd_ptr[i] + 1'b1;
        case ({(in_valid[i] && in_ready[i]),(count[i] != 0 && out_ready[route[i]])})
          2'b10: count[i] <= count[i] + 1'b1;
          2'b01: count[i] <= count[i] - 1'b1;
          default: count[i] <= count[i];
        endcase
      end
    end
  end
endmodule
