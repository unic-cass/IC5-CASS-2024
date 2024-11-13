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
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

`define REG_MPRJ_SLAVE       24'h300000 // VCO Based address
`define REG_MPRJ_VCO_CONFIG  8'h00
`define REG_MPRJ_FIFO_DATA   8'h04 // VCO read data from the fifo
`define REG_MPRJ_STATUS      8'h08 // VCO status
`define REG_MPRJ_NUM_DATA    8'h0C // VCO number of data writen into the fifo

module vco_adc_wrapper #(
    parameter BITS = 32,
    parameter MEM_ADDR_W = 9
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
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
    input user_clock2,
    // Logic Analyzer Signals
    // input  [127:0] la_data_in,
    // output [127:0] la_data_out,
    // input  [127:0] la_oenb,

    // IOs
    // input  [`MPRJ_IO_PADS-1:0] io_in,
    // output [`MPRJ_IO_PADS-1:0] io_out,
    // output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    // output [2:0] irq,
  // output [9:0] oversample_o,
  // output  sinc_en_o,
  // // output [1:0] adc_sel_o,
  input phase_in,
  // input  adc_dvalid_i,
  // input [31:0] adc_dat_i,
  output vco_enb_o
);

   // localparam MAX_SIZE=2048;
   // localparam MEMSIZE = 1024;

   reg [9:0] oversample_reg;
   reg ena_reg;
   reg adc_sel_reg;
   reg 	     wbs_ack_reg;

   reg [1:0] 	 status_reg;
   reg [31:0] 	 num_data_reg;
   reg [31:0] 	 data_o;
   reg 		 full_reg;
   reg 		 empty_reg;
   reg 		 ren_1d_reg, ren_2d_reg, ren_3d_reg;
   reg  	 vco_en_reg;
   reg [11:0] 	 num_samples_reg;
   reg [3:0] 	 shift_factor_reg;
   reg [31:0]	 data_reg;
   reg		 div_2_reg;
   reg		 div_2_1d_reg;
   reg 		 capture_mode_reg;
 		 

   wire		 full, empty, fifo_ren, fifo_wen;
   
   wire 		  valid_w;
   wire 		  wen_w;
   wire [BITS-1:0] 	  fifo_out_w;
   wire                   ren_w;
   reg 			  ren_reg;
   wire 		  rst;
   wire 		  slave_sel;
   wire			  adc_dvalid_i; 		  
   wire [31:0]		  adc_dat_i;

   wire 		  async_fifo_full;
   wire 		  vco_en_sync;
   wire 		  async_fifo_empty;
   wire [31:0] 		  async_fifo_data;
   reg [15:0] 		  async_fifo_data_shifted;
   reg 			  wrst_n_reg, rrst_n_reg;

   // synthesis translate_off
   integer 		  rdat_file;
   integer 		  wdat_file;
   // synthesis translate_on
   // assign oversample_o = oversample_reg;
   // assign adc_sel_o = adc_sel_reg;
   // assign sinc_en_o = ena_reg;
   
   assign rst = wb_rst_i;
   assign slave_sel = (wbs_adr_i[31:8] == `REG_MPRJ_SLAVE);
   
   assign valid_w = wbs_cyc_i & wbs_stb_i;
   assign wen_w   = wbs_we_i & (valid_w & wbs_sel_i[0]);
   assign ren_w   = (wbs_we_i == 1'b0) & (valid_w & ~wbs_ack_reg);
   assign fifo_ren = ren_w & slave_sel & (wbs_adr_i[7:0] == `REG_MPRJ_FIFO_DATA);
   assign fifo_wen = (div_2_reg == 1'b0) & (div_2_1d_reg == 1'b1);

   // always @* begin
   //    case (adc_sel_reg)
   // 	2'b00: begin
   // 	   adc_dvalid_tmp <= adc_dvalid_i[0];
   // 	   adc_out <= adc0_dat_i;
   // 	end
   // 	2'b01: begin
   // 	   adc_dvalid_tmp <= adc_dvalid_i[1];
   // 	   adc_out <= adc1_dat_i;
   // 	end
   // 	2'b10: begin
   // 	   adc_dvalid_tmp <= adc_dvalid_i[2];
   // 	   adc_out <= adc2_dat_i;
   // 	end
   // 	default: begin 
   // 	   adc_dvalid_tmp <= adc_dvalid_i[0];
   // 	   adc_out <= adc0_dat_i;
   // 	end
   //    endcase // case (adc_sel)
   // end

   always @(posedge wb_clk_i) begin
      if (rst == 1'b1) begin
	 status_reg <= 2'b0;
      end else begin
	 status_reg <= {full_reg, empty_reg};
     end
   end

   always @(posedge user_clock2) begin
      wrst_n_reg <= ~rst;
   end

   always @(posedge wb_clk_i) begin
      rrst_n_reg <= ~rst;
   end

   always @(posedge wb_clk_i) begin
      if (rst == 1'b1) begin
	 num_data_reg <= {32{1'b0}};
      end else begin
	 if (ren_reg)
	   num_data_reg <= num_data_reg + 1;
      end
   end

   always @(posedge wb_clk_i) begin
      if (rst == 1'b1) begin
	 div_2_reg <= 1'b0;
	 div_2_1d_reg <= 1'b0;
	 ren_reg <= 1'b0;
      end else begin

	 if(ren_reg) div_2_reg <= ~div_2_reg;

	 div_2_1d_reg <= div_2_reg;

	 // if(async_fifo_empty == 1'b0 && ren_1d_reg == 1'b0) ren_reg <= 1'b1; else ren_reg <= 1'b0;
	 // ren_1d_reg <= ren_reg;
	 if (ren_reg) ren_reg <= 1'b0;
	 else if (async_fifo_empty == 1'b0) ren_reg <= 1'b1;
	 
      end

      if (ren_reg)
	data_reg <= {data_reg[15:0], async_fifo_data_shifted};
   end

   // assign async_fifo_data_shifted = async_fifo_data[25:10];
   always @(*)
     case (shift_factor_reg)
       4'h0: async_fifo_data_shifted = {async_fifo_data[31], async_fifo_data[15:1]};
       4'h1: async_fifo_data_shifted = {async_fifo_data[31], async_fifo_data[16:2]};
       4'h2: async_fifo_data_shifted = {async_fifo_data[31], async_fifo_data[17:3]};
       4'h3: async_fifo_data_shifted = {async_fifo_data[31], async_fifo_data[18:4]};
       4'h4: async_fifo_data_shifted = {async_fifo_data[31], async_fifo_data[19:5]};
       4'h5: async_fifo_data_shifted = {async_fifo_data[31], async_fifo_data[20:6]};
       4'h6: async_fifo_data_shifted = {async_fifo_data[31], async_fifo_data[21:7]};
       4'h7: async_fifo_data_shifted = {async_fifo_data[31], async_fifo_data[22:8]};
       4'h8: async_fifo_data_shifted = {async_fifo_data[31], async_fifo_data[23:9]};
       4'h9: async_fifo_data_shifted = {async_fifo_data[31], async_fifo_data[24:10]};
       4'ha: async_fifo_data_shifted = {async_fifo_data[31], async_fifo_data[25:11]};
       4'hb: async_fifo_data_shifted = {async_fifo_data[31], async_fifo_data[26:12]};
       4'hc: async_fifo_data_shifted = {async_fifo_data[31], async_fifo_data[27:13]};
       4'hd: async_fifo_data_shifted = {async_fifo_data[31], async_fifo_data[28:14]};
       4'he: async_fifo_data_shifted = {async_fifo_data[31], async_fifo_data[29:15]};
       4'hf: async_fifo_data_shifted = async_fifo_data[31:16];
       default: async_fifo_data_shifted = {async_fifo_data[31], async_fifo_data[15:1]};
     endcase
   
   always @(posedge wb_clk_i) begin
      if (rst == 1'b1) begin
	 wbs_ack_reg <= 1'b0;
      end else begin
	 wbs_ack_reg <= ((valid_w & (wbs_ack_o == 1'b0))
			 & (wbs_ack_reg == 1'b0));
      end
   end

   assign wbs_ack_o = (valid_w & (wbs_ack_reg == 1'b0)) ? wbs_we_i : wbs_ack_reg;
   
   always @(posedge wb_clk_i) begin
      if (rst == 1'b1) begin
	 oversample_reg		<= 10'b0;
	 ena_reg		<= 3'b0;
	 vco_en_reg		<= 3'h0;
	 num_samples_reg	<= 0;
	 capture_mode_reg		<= 1'b0;
	 shift_factor_reg <= 4'b0;
      end else begin
	 if (slave_sel && wen_w && wbs_adr_i[7:0] == 8'h00) begin
	    shift_factor_reg <= wbs_dat_i[28:25];
	    ena_reg		<= wbs_dat_i[24];
	    vco_en_reg		<= wbs_dat_i[23];
	    capture_mode_reg <= wbs_dat_i[22];
	    num_samples_reg     <= wbs_dat_i[21:10];
	    oversample_reg	<= wbs_dat_i[9:0];
	 end else if (num_data_reg == num_samples_reg && capture_mode_reg == 1'b0) begin
	    ena_reg <= 1'b0;
	    vco_en_reg <= 1'b0;
	 end
      end
   end

   always @* begin
      case (wbs_adr_i[7:0]) 
	`REG_MPRJ_VCO_CONFIG: data_o <= {ena_reg, vco_en_reg,
					 capture_mode_reg, num_samples_reg,
					 oversample_reg};
	`REG_MPRJ_FIFO_DATA:  data_o <= fifo_out_w;
	`REG_MPRJ_STATUS:     data_o <= {30'h0, status_reg};
	`REG_MPRJ_NUM_DATA:   data_o <= num_data_reg;
	default:              data_o <= 32'h0;
      endcase // case (wbs_adr_i[7:0])
      
   end // always @ *

   always @(posedge wb_clk_i) begin
      if (rst == 1'b1) begin
	 full_reg <= 1'b0;
	 empty_reg <= 1'b1;
      end
      else begin
	 full_reg <= full;
	 empty_reg <= empty;
      end
   end // always @ (posedge wb_clk_i)

   vco_adc_fifo vco_adc_fifo_0
     (.clk(wb_clk_i),
      .rst(rst),
      .read_i(fifo_ren),
      .write_i(fifo_wen),
      .data_i(data_reg),
      .data_o(fifo_out_w),
      .full_o(full),
      .empty_o(empty));

  async_fifo as_fifo
    (.wclk(user_clock2),
     .wrst_n(wrst_n_reg),
     .rclk(wb_clk_i),
     .rrst_n(rrst_n_reg),
     .w_en(adc_dvalid_i),
     .r_en(ren_reg),
     .data_in(adc_dat_i),
     .data_out(async_fifo_data),
     .full(async_fifo_full),
     .empty(async_fifo_empty));

   vco_adc vco_adc_0
     (.clk(user_clock2),
      .rst(rst),
      .oversample_in(oversample_reg),
      .enable_in(ena_reg),
      .phase_in(phase_in),
      .data_out(adc_dat_i),
      .data_valid_out(adc_dvalid_i)
      );

   aucohl_sync vco_enb_sync
     (.clk(user_clock2),
      .in(vco_en_reg),
      .out(vco_en_sync));
   
   // IO
   // assign io_out    = fifo_out_w;
   // assign io_oeb = {(`MPRJ_IO_PADS-1){~io_en_reg}};
   //assign irq  = 3'b000;
   assign wbs_dat_o = data_o;
   assign vco_enb_o = ~vco_en_sync;

`ifdef FUNCTIONAL
   // this is for debug only
   initial begin
      rdat_file = $fopen("wb_read_data.txt");
      wdat_file = $fopen("wb_write_data.txt");
   end

   always @(posedge wb_clk_i) begin
      if (full_reg == 1'b1 && fifo_wen == 1'b1)
	$display("Error: Fifo is full but a write is requested: %d", num_data_reg);
   end

   always @(posedge wb_clk_i) begin
      if (empty_reg == 1'b1 && fifo_ren == 1'b1)
	$display("Error: Fifo is empty but a read is requested");
   end

   always @(posedge wb_clk_i) begin
      if (fifo_wen && !full_reg) begin
	 $display("Fifo write: %08X", data_reg);
	 $fwrite(wdat_file, "%08X\n", data_reg);
      end
      if (wbs_ack_o && wbs_adr_i == 32'h30000004) begin
	 $display("Interface read: %08X", fifo_out_w);
	 $fwrite(rdat_file, "%08X\n", fifo_out_w);
      end
      
   end
`endif
endmodule // vco_adc_wrapper

module aucohl_sync #(parameter NUM_STAGES = 2) (
    input wire clk,
    input wire in,
    output wire out
);

    reg [NUM_STAGES-1:0] sync;

    always @(posedge clk)
        sync <= {sync[NUM_STAGES-2:0], in};

    assign out = sync[NUM_STAGES-1];

endmodule

`default_nettype wire

