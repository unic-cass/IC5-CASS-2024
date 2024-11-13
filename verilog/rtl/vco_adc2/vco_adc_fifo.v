// This code is taken from clint-lemire from https://gist.github.com/C47D/e299230c65b82a87d7fc83579d78b168

module vco_adc_fifo #(
  parameter DATA_WIDTH = 32,
  parameter PTR_MSB      = 9,
  parameter ADDR_MSB     = 8
  )
  (
   input		   clk,
   input		   rst,
   input		   read_i,
   input		   write_i,
   input [DATA_WIDTH-1:0]  data_i,
   output [DATA_WIDTH-1:0] data_o,
   output		   full_o,
   output		   empty_o
  );
  
   reg [DATA_WIDTH-1:0]	   memory [0:2**PTR_MSB-1];
   reg [PTR_MSB:0]	 readPtr, writePtr;
   reg [DATA_WIDTH-1:0]	 data_reg;

   wire			 full, empty;
   wire [ADDR_MSB:0]	 writeAddr = writePtr[ADDR_MSB:0];
   wire [ADDR_MSB:0]	 readAddr = readPtr[ADDR_MSB:0]; 
  
  always@(posedge clk)begin
    if(rst)begin
      readPtr     <= 0;
      writePtr    <= 0;
    end
    else begin
      if(write_i && ~full)begin
        memory[writeAddr] <= data_i;
        writePtr         <= writePtr + 1;
      end
      if(read_i && ~empty)begin
        data_reg <= memory[readAddr];
        readPtr <= readPtr + 1;
      end
    end
  end

   assign data_o = data_reg;
   
   assign empty = (writePtr == readPtr) ? 1'b1: 1'b0;
   assign empty_o = empty;

   assign full = ((writePtr[ADDR_MSB:0] == readPtr[ADDR_MSB:0])&(writePtr[PTR_MSB] != readPtr[PTR_MSB])) ? 1'b1 : 1'b0;
   assign full_o  = full;

endmodule
