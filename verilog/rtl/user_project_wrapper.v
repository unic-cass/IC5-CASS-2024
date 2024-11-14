// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper #(
	parameter BITS = 32
) (
`ifdef USE_POWER_PINS
	inout vdda1,	// User area 1 3.3V supply
	inout vdda2,	// User area 2 3.3V supply
	inout vssa1,	// User area 1 analog ground
	inout vssa2,	// User area 2 analog ground
	inout vccd1,	// User area 1 1.8V supply
	inout vccd2,	// User area 2 1.8v supply
	inout vssd1,	// User area 1 digital ground
	inout vssd2,	// User area 2 digital ground
`endif
// Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
	output [2:0] user_irq

);
/*---------------------------------------------------*/
/* User project wire description instantiated here   */
/*---------------------------------------------------*/
   wire [31:0] 	     configBus, dataBus;
   wire 	     ki;
   wire 	     slave_ena, w_slvDone, w_load_data;
   wire [5:0] 	     w_loadStatus;
   wire [3:0] 	     w_becStatus;
   wire 	     next_key;
   wire          phase0;
   wire          vco_enb;

/*--------------------------------------*/
/* User project is instantiated  here   */
/*--------------------------------------*/
    vmsu_8bit_top vmsu_8bit_top (
    `ifdef USE_POWER_PINS
        .vccd1(vccd1),	// User area 1 1.8V power
        .vssd1(vssd1),	// User area 1 digital ground
    `endif

        .clk(wb_clk_i),    // Connect clock from wishbone clock input
        .rst(wb_rst_i),    // Connect reset from wishbone reset input
        .a(la_data_in[71:64]),    // Map input A from IO pads (8 bits)
        .b(la_data_in[79:72]),   // Map input B from IO pads (8 bits)
        .control(la_data_in[80]), // Map control signal from Logic Analyzer
        .p(la_data_out[111:96])   // Output the result P to IO pads (16 bits)
    );


    lovers_controller lovers_controller (
	`ifdef USE_POWER_PINS
		.vccd1(vccd1),	// User area 1 1.8V power
		.vssd1(vssd1),	// User area 1 digital ground
	`endif

		.wb_clk_i(wb_clk_i),
		.wb_rst_i(wb_rst_i),
		
		// Logic Analyzer

		.la_data_in(la_data_in[31:0]),
		.la_data_out(la_data_out[63:32]),
		
		// Control bus sm_bec_v3
		.slv_enable(slave_ena),
		.load_status(w_loadStatus),
		.next_key(next_key),
		.slv_done(w_slvDone),
		.becStatus(w_becStatus),
		.load_data(w_load_data),

		// IOs [17:0] for efficiency evaluation
		// IOs 18 for trigger
		.io_out(io_out[8]),
		.io_oeb(io_oeb[8]),

		// Data bus sm_bec_v3
		.data_out(configBus),
		.data_in(dataBus),
		.ki(ki)
	);

	bec lovers_bec (
		`ifdef USE_POWER_PINS
			.vccd2(vccd2),  // User area 2 1.8V power
			.vssd2(vssd2),  // User area 2 digital ground
		`endif

		.clk(wb_clk_i),
		.rst(wb_rst_i),
		.enable(slave_ena),
		.load_data(w_load_data),

		.load_status(w_loadStatus),
		.data_in(configBus),
		.ki(ki),
		.next_key(next_key),
		.becStatus(w_becStatus),
		.data_out(dataBus),
		.done(w_slvDone)
	);

   ascon_wrapper ascon_wrapper (
`ifdef USE_POWER_PINS
    .vccd1(vccd1),      // User area 1 1.8V supply
    .vssd1(vssd1),      // User area 1 digital ground
`endif
// clock is mapped to io_in[10]
// reset is mapped to io_in[9]
    .clk(io_in[16]),
    .rst(io_in[15]),
    .io_in(io_in[14:9]),
    .io_out(io_out[19:17]),
    .io_oeb({io_oeb[19:9]}));

      vco_adc_wrapper vco_adc_wrapper
	(
`ifdef USE_POWER_PINS
         .vccd1(vccd1),       // User area 1 1.8V power
         .vssd1(vssd1),       // User area 1 digital ground
`endif
         .wb_clk_i(wb_clk_i),
         .wb_rst_i(wb_rst_i),
	 .user_clock2(user_clock2),
           // MGMT SoC Wishbone Slave
         .wbs_cyc_i(wbs_cyc_i),
         .wbs_stb_i(wbs_stb_i),
         .wbs_we_i(wbs_we_i),
         .wbs_sel_i(wbs_sel_i),
         .wbs_adr_i(wbs_adr_i),
         .wbs_dat_i(wbs_dat_i),
         .wbs_ack_o(wbs_ack_o),
         .wbs_dat_o(wbs_dat_o),
	 .io_oeb(io_oeb[25:23]),
         .phase_in(phase0),
         .vco_enb_o(vco_enb));

   vco_adc2 vco_adc2
     (
`ifdef USE_POWER_PINS
      .vdda1(vdda1),
      .vssa1(vssa1),
`endif
      .clk(user_clock2),
      .enable_in(vco_enb),
      .analog_in(analog_io[16]),
      .vbias_34(analog_io[18]),
      .vbias_12(analog_io[17]),
      .quantizer_out(phase0));

endmodule	// user_project_wrapper

`default_nettype wire
