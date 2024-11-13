// this code is taken from: https://vlsiverify.com/verilog/verilog-codes/asynchronous-fifo/
module async_fifo #(parameter DEPTH=8, DATA_WIDTH=32) ( 
  input 		  wclk, 
  input 		  wrst_n,
  input 		  rclk,
  input 		  rrst_n,
  input 		  w_en,
  input 		  r_en,
  input [DATA_WIDTH-1:0]  data_in,
  output [DATA_WIDTH-1:0] data_out,
  output 		  full,
  output 		  empty);
  
  parameter PTR_WIDTH = $clog2(DEPTH);
 
  wire [PTR_WIDTH:0] g_wptr_sync, g_rptr_sync;
  wire [PTR_WIDTH:0] b_wptr, b_rptr;
  wire [PTR_WIDTH:0] g_wptr, g_rptr;

  wire [PTR_WIDTH-1:0] waddr, raddr;

  synchronizer #(PTR_WIDTH) sync_wptr (rclk, rrst_n, g_wptr, g_wptr_sync); //write pointer to read clock domain
  synchronizer #(PTR_WIDTH) sync_rptr (wclk, wrst_n, g_rptr, g_rptr_sync); //read pointer to write clock domain 
  
  wptr_handler #(PTR_WIDTH) wptr_h(wclk, wrst_n, w_en,g_rptr_sync,b_wptr,g_wptr,full);
  rptr_handler #(PTR_WIDTH) rptr_h(rclk, rrst_n, r_en,g_wptr_sync,b_rptr,g_rptr,empty);
  fifo_mem #(.DATA_WIDTH(DATA_WIDTH)) fifom(wclk, w_en, rclk, r_en,b_wptr, b_rptr, data_in,full,empty, data_out);

endmodule // asynchronous_fifo

module wptr_handler #(parameter PTR_WIDTH=3) (
  input wclk,
  input wrst_n,
  input w_en,
  input [PTR_WIDTH:0] g_rptr_sync,
  output [PTR_WIDTH:0] b_wptr,
  output [PTR_WIDTH:0] g_wptr,
  output full);

  reg [PTR_WIDTH:0] b_wptr_reg, g_wptr_reg;
  reg full_reg;

  wire [PTR_WIDTH:0] b_wptr_next;
  wire [PTR_WIDTH:0] g_wptr_next;
   
  reg wrap_around;
  wire wfull;
  
  assign b_wptr_next = b_wptr_reg+(w_en & !full);
  assign g_wptr_next = (b_wptr_next >>1)^b_wptr_next;
  
  always@(posedge wclk or negedge wrst_n) begin
    if(!wrst_n) begin
      b_wptr_reg <= 0; // set default value
      g_wptr_reg <= 0;
    end
    else begin
      b_wptr_reg <= b_wptr_next; // incr binary write pointer
      g_wptr_reg <= g_wptr_next; // incr gray write pointer
    end
  end
  
  always@(posedge wclk or negedge wrst_n) begin
    if(!wrst_n) full_reg <= 0;
    else        full_reg <= wfull;
  end

  assign wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});
  assign full = full_reg;
  assign b_wptr = b_wptr_reg;
  assign g_wptr = g_wptr_reg;

endmodule // wptr_handler

module rptr_handler #(parameter PTR_WIDTH=3) (
  input 	       rclk,
  input 	       rrst_n,
  input 	       r_en,
  input [PTR_WIDTH:0]  g_wptr_sync,
  output [PTR_WIDTH:0] b_rptr,
  output [PTR_WIDTH:0] g_rptr,
  output 	       empty);

  reg [PTR_WIDTH:0] b_rptr_reg, g_rptr_reg;
  reg empty_reg;

  wire [PTR_WIDTH:0] b_rptr_next;
  wire [PTR_WIDTH:0] g_rptr_next;
  wire rempty;

  assign b_rptr_next = b_rptr_reg+(r_en & !empty);
  assign g_rptr_next = (b_rptr_next >>1)^b_rptr_next;
  assign rempty = (g_wptr_sync == g_rptr_next);
  
  always@(posedge rclk or negedge rrst_n) begin
    if(!rrst_n) begin
      b_rptr_reg <= 0;
      g_rptr_reg <= 0;
    end
    else begin
      b_rptr_reg <= b_rptr_next;
      g_rptr_reg <= g_rptr_next;
    end
  end
  
  always@(posedge rclk or negedge rrst_n) begin
    if(!rrst_n) empty_reg <= 1;
    else        empty_reg <= rempty;
  end
  assign empty = empty_reg;
  assign b_rptr = b_rptr_reg;
  assign g_rptr = g_rptr_reg;
endmodule

module fifo_mem #(parameter DEPTH=8, DATA_WIDTH=8, PTR_WIDTH=3) (
  input 		  wclk,
  input 		  w_en,
  input 		  rclk,
  input 		  r_en,
  input [PTR_WIDTH:0] 	  b_wptr,
  input [PTR_WIDTH:0] 	  b_rptr,
  input [DATA_WIDTH-1:0]  data_in,
  input 		  full,
  input 		  empty,
  output [DATA_WIDTH-1:0] data_out);

  reg [DATA_WIDTH-1:0] fifo[0:DEPTH-1];
  
  always@(posedge wclk) begin
    if(w_en & !full) begin
      fifo[b_wptr[PTR_WIDTH-1:0]] <= data_in;
    end
  end
  /*
  always@(posedge rclk) begin
    if(r_en & !empty) begin
      data_out <= fifo[b_rptr[PTR_WIDTH-1:0]];
    end
  end
  */
  assign data_out = fifo[b_rptr[PTR_WIDTH-1:0]];
endmodule // fifo_mem

module synchronizer #(parameter WIDTH=3) (
   input 	    clk,
   input 	    rst_n,
   input [WIDTH:0]  d_in,
   output [WIDTH:0] d_out);

   reg [WIDTH:0]    d_out_reg;
   reg [WIDTH:0]    q1;
   always@(posedge clk) begin
      if(!rst_n) begin
	 q1 <= 0;
	 d_out_reg <= 0;
      end
      else begin
	 q1 <= d_in;
	 d_out_reg <= q1;
      end
   end
   assign d_out = d_out_reg;
endmodule // synchronizer


