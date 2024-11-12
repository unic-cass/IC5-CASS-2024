`default_nettype none

module ascon_wrapper (
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
// clock is mapped to io_in[10]
// reset is mapped to io_in[9]
    input      clk,
    input      rst,
    input      [5:0] io_in,
    output [2:0] io_out,
    output [10:0] io_oeb
);
   reg 		  rst_sync1, rst_sync2;
   // FIXME: This should matched with the order in the io config
   assign io_oeb = 11'b000_1111_1111;
   always @(posedge clk) begin
      rst_sync1 <= rst;
      rst_sync2 <= rst_sync1;
   end

    Ascon ascon(
        .clk(clk),
        .rst(rst_sync2),
        .keyxSI(io_in[5]),
        .noncexSI(io_in[4]),
        .associated_dataxSI(io_in[3]),
        .input_dataxSI(io_in[2]),
        .ascon_startxSI(io_in[1]),
        .decrypt(io_in[0]),
        .output_dataxSO(io_out[2]),
        .tagxSO(io_out[1]),
        .ascon_readyxSO(io_out[0])
    );
    
endmodule

`default_nettype wire
