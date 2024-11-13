/// sta-blackbox
// behavior model of the vco
module vco_adc2
  (
`ifdef USE_POWER_PINS
    input vdda1,	// User area 1 1.8V supply
    input vssa1,	// User area 1 analog ground
`endif

   input 		    clk,
   input 		    enable_in,
   inout 		    analog_in,
   inout vbias_12,
   inout vbias_34,
   output  quantizer_out
   );
`ifdef FUNCTIONAL
   reg [18:0] 		     counter_reg;
   reg    [287976:0]   vco_val;
//   reg 			     clk;
   reg 			     rst;
 `define NULL 0
   integer 		     data_file    ;
   integer 		     scan_file    ;
   integer 		     i;
   integer 		     a;
   reg [15:0] 		     line;
   
   
   
   initial begin
      $display("Load vco-phase");
      // $readmemb("testdata/0.0001V_1kHz.txt", vco_val);
      data_file = $fopen("testdata/0.1V_1kHz.txt", "r");
        if (data_file == `NULL) begin
	   $display("data_file handle was NULL");
	   $finish;
	end
      i = 0;
      while (! $feof(data_file)) begin
	 scan_file = $fgets(line, data_file);
	 vco_val[i] = line[8];
	 i = i+1;
      end
      $fclose(data_file);
   end
   // set the frequency to 50MHz to match the system freq
   // always #20.8 clk <= (clk === 1'b0);
   
   // initial begin
   //    clk = 0;
   // end

   initial begin
      rst <= 1'b1;
      #2000;
      rst <= 1'b0;
   end

   always @(posedge clk) begin
      if (rst == 1'b1) begin
	 counter_reg <= 19'h0;
      end else begin
	 if (enable_in == 1'b0) begin
	    if (counter_reg == 287976)
	      counter_reg <= 19'h0;
	    else
	      counter_reg <= counter_reg + 1;
	 end
      end
   end

   assign quantizer_out = (enable_in == 1'b0) ? vco_val[counter_reg] : 0;
`endif
endmodule // vco

