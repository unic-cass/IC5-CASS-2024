`default_nettype none

module ascon_wrapper (
`ifdef USE_POWER_PINS
    inout vccd1,    // User area 1 1.8V supply
    inout vssd1,    // User area 1 digital ground
`endif
    input      clk,
    input      rst,
    input      [5:0] io_in,
    output     [2:0] io_out,
    output     [10:0] io_oeb
);

    assign io_oeb = 11'b000_1111_1111;

    // Module Ascon
    wire output_dataxSO;
    wire tagxSO;
    wire ascon_readyxSO;

    Ascon ascon (
        .clk(clk),
        .rst(rst), 
        .keyxSI(io_in[5]),
        .noncexSI(io_in[4]),
        .associated_dataxSI(io_in[3]),
        .input_dataxSI(io_in[2]),
        .ascon_startxSI(io_in[1]),
        .decrypt(io_in[0]),
        .output_dataxSO(output_dataxSO),
        .tagxSO(tagxSO),
        .ascon_readyxSO(ascon_readyxSO)
    );

    assign io_out[2] = output_dataxSO;
    assign io_out[1] = tagxSO;
    assign io_out[0] = ascon_readyxSO;

endmodule

`default_nettype wire
