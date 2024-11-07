// // // SPDX-FileCopyrightText: 2020 Efabless Corporation
// // //
// // // Licensed under the Apache License, Version 2.0 (the "License");
// // // you may not use this file except in compliance with the License.
// // // You may obtain a copy of the License at
// // //
// // //      http://www.apache.org/licenses/LICENSE-2.0
// // //
// // // Unless required by applicable law or agreed to in writing, software
// // // distributed under the License is distributed on an "AS IS" BASIS,
// // // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// // // See the License for the specific language governing permissions and
// // // limitations under the License.
// // // SPDX-License-Identifier: Apache-2.0

`default_nettype none

module controller (
`ifdef USE_POWER_PINS
	inout vccd1,	// User area 1 1.8V supply
	inout vssd1,	// User area 1 digital ground
`endif

	// // Wishbone Slave ports (WB MI A)
	input wb_clk_i,
	input wb_rst_i,

	// Logic Analyzer Signals
	input  [31:0] la_data_in,
	output reg [31:0] la_data_out,
	
	// Interconnection bus of BEC
	output reg slv_enable,
	output reg load_data,
	output [5:0] load_status,
	output reg [31:0] data_out,
	output ki,
	
	// IO for trigger
	output io_out,
    output io_oeb,

	input next_key,

	input [3:0] becStatus,
	input slv_done,
	input [31:0] data_in
);
	wire clk;
	wire rst;
	reg enable_write, enable_proc, updateRegs;
	reg master_ena_proc;
	reg mode_exec, first_round;
	
	reg [17:0] counter, buf_cnt;

	reg [191:0] reg_w1, reg_z1, reg_w2, reg_z2, reg_d, reg_inv_w0;
	reg [191:0] buf_w1, buf_z1, buf_w2, buf_z2, buf_d, buf_inv_w0;
	reg [162:0] reg_wout, reg_zout, reg_key, buf_key;

	reg [5:0] counterControl;

	// FSM Definition
	reg [1:0]current_state, next_state;
	parameter idle=2'b00, write_mode=2'b01,  proc=2'b11, read_mode=2'b10;
	assign ki = (master_ena_proc) ? reg_key[0] : 1'b0;

	assign load_status = counterControl;

	// Assuming LA probes [65:64] are for controlling the count clk & reset  
	assign clk = wb_clk_i;
	assign rst = wb_rst_i;

	assign io_out = slv_enable;

    assign io_oeb = {rst};

	always @(posedge clk) begin
		if (rst) 
			current_state <= idle;
		else
			current_state <= next_state;
	end

	always @(*) begin
		case (current_state)
			idle: begin
				if (enable_write == 1'b1) begin
					next_state = write_mode;
				end else begin 
					next_state = idle;
				end
			end

			write_mode: begin
				if (enable_proc == 1'b1) begin
					next_state = proc;
				end else begin 
					next_state = write_mode;
				end
			end

			proc: begin
				if (slv_done) begin
					next_state = read_mode;
				end else begin 
					next_state = proc;
				end
			end

			read_mode: begin
				if (updateRegs == 1'b1) begin
					next_state = idle;
				end else begin
					next_state = read_mode;
				end
			end

			default:
			next_state <= idle;
		endcase
	end

	always @(posedge clk) begin
		if (rst) begin
			enable_proc 	<= 1'b0;
			updateRegs 	 	<= 1'b0;
			enable_write 	<= 1'b0;
			master_ena_proc <= 1'b0;

		end begin
			case (current_state)
				idle: begin
					enable_proc <= 1'b0;
					updateRegs  <= 1'b0;
					// Enable execute the encryption when Multiple Mode enable, except first round
					if (mode_exec == 1'b1) begin				
						master_ena_proc <= ~(first_round | slv_done);
					end

					/* Enable FSM change to the next State when la_data = 0xAB30
					If Multiple Mode enable, wait until the encryption completed */

					if (la_data_in[31:16] == 16'hAB30) begin
						enable_write <= 1'b1;
					end else 
						enable_write <= 1'b0;
				end 

				write_mode: begin
					// Enable execute the encryption when Multiple Mode enable, except first round
					if (mode_exec == 1'b1) begin				
						master_ena_proc <= ~(first_round | slv_done);
					end
					/* Enable FSM change to the next State when la_data = 0xEF41
					If Multiple Mode enable, wait until the encryption completed */

					if (la_data_in[31:16] == 16'hEF41) begin
						if ((mode_exec == 1'b0) | first_round == 1'b1) 
							enable_proc <= 1'b1;
						else if ((mode_exec == 1'b1) & (becStatus == 4'h8))
							enable_proc <= 1'b1;
						else
							enable_proc <= 1'b0;
					end else 
						enable_proc <= 1'b0;
				end

				proc: begin
					enable_write <= 1'b0;
					enable_proc <= 1'b0;
					if (~slv_done)
						master_ena_proc <= 1'b1;
					else
						master_ena_proc <= 1'b0;
				end

				read_mode: begin
					// Enable execute the encryption when Multiple Mode enable
					if (mode_exec == 1'b1) begin				
						master_ena_proc <= ~slv_done;
					end else begin
						master_ena_proc <= 1'b0;
					end

					/* Enable FSM changes to the next State when la_data = 0xAB50.
					If Multiple Mode is enabled, wait until the encryption completed */
					if (la_data_in == 32'hAB500000) begin
						if ((mode_exec == 1'b0)) begin
							updateRegs <= 1'b1;
						end else if (becStatus == 4'h1) begin
							updateRegs <= 1'b1;
						end
					end	else
						updateRegs <= 1'b0;
				end

				default: begin
					master_ena_proc <= 1'b0;
					enable_write 	<= 1'b0;
					enable_proc 	<= 1'b0;
					updateRegs 		<= 1'b0;
				end
			endcase


		/* Get results data from BEC by shift registers
		*/
			if (master_ena_proc) begin
				if ((counterControl[5:3] == 3'b100) & (counterControl[2:0] != 3'b111))
					data_out 	<= reg_w1[31:0];
				else if ((counterControl[5:3] == 3'b101) & (counterControl[2:0] != 3'b111))
					data_out 	<= reg_z1[31:0];
				else if ((counterControl[5:3] == 3'b010) & (counterControl[2:0] != 3'b111))
					data_out 	<= reg_w2[31:0];
				else if ((counterControl[5:3] == 3'b011) & (counterControl[2:0] != 3'b111))
					data_out 	<= reg_z2[31:0];
				else if ((counterControl[5:3] == 3'b001) & (counterControl[2:0] != 3'b111))
					data_out 	<= reg_d[31:0];
				else if ((counterControl[5:3] == 3'b000) & (counterControl[2:0] != 3'b111))
					data_out 	<= reg_inv_w0[31:0];
			end else begin
				data_out <= {(32){1'b0}};
			end
			if (master_ena_proc) begin
				if ((counterControl == 6'b000000) | ((counterControl == 6'h01) & (becStatus == 4'h8))) begin
					slv_enable  <= 1'b0;
					load_data	<= 1'b1;
				end else if (counterControl == 6'h0E) begin
					load_data	<= 1'b0;
				end else if ((counterControl == 6'h2E) & (becStatus == 4'h4)) begin
					slv_enable  <= 1'b1;
				end
			end else begin
				slv_enable <= 1'b0;
				load_data  <= 1'b0;
			end
		end
	end

	always @(posedge clk) begin
		if (rst) begin
			reg_w1			<= 0; 	
			reg_z1 			<= 0;
			reg_w2 			<= 0;
			reg_z2 			<= 0;
			reg_d 			<= 0;
			reg_inv_w0		<= 0;
			reg_key			<= 0;
			reg_wout		<= 0;
			reg_zout		<= 0;

			buf_w1			<= 0; 	
			buf_z1 			<= 0;
			buf_w2 			<= 0;
			buf_z2 			<= 0;
			buf_d 			<= 0;
			buf_inv_w0		<= 0;
			buf_key			<= 0;

			counterControl	<= 0;
			la_data_out 	<= {(32){1'b0}};
			first_round 	<= 1;
			mode_exec		<= 0;
			buf_cnt		<= 0;
			counter			<= 0;
			// slv_enable		<= 1'b0;
			// load_data		<= 1'b0;
		end else begin
			case (current_state)
				idle: begin
					la_data_out[31:0] <= 32'h00000000; 

					// When Multiple Mode enables, the reg_key cyclic right shifts when next_key = 1
					if ((master_ena_proc == 1'b1) & (next_key == 1'b1)) begin
						reg_key <= {reg_key[0], reg_key[162:1]};
					end
				end 

				write_mode: begin
					la_data_out [31:0] <= 0;
					// Load data into Buffers in write_mode
					if (la_data_in[31:26] == 6'b000000) begin
						buf_w1[162:137] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b000001) begin
						buf_w1[136:111] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b000010) begin
						buf_w1[110:85] 	<= la_data_in[25:0];	
					end else if (la_data_in[31:26] == 6'b000011) begin
						buf_w1[84:59] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b000100) begin
						buf_w1[58:33] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b000101) begin
						buf_w1[32:7] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b000110) begin
						buf_w1[6:0] 	<= la_data_in[6:0];

					end else if (la_data_in[31:26] == 6'b001000) begin
						buf_z1[162:137] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b001001) begin
						buf_z1[136:111] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b001010) begin
						buf_z1[110:85] 	<= la_data_in[25:0];	
					end else if (la_data_in[31:26] == 6'b001011) begin
						buf_z1[84:59] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b001100) begin
						buf_z1[58:33] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b001101) begin
						buf_z1[32:7] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b001110) begin
						buf_z1[6:0] 	<= la_data_in[6:0];

					end else if (la_data_in[31:26] == 6'b010000) begin
						buf_w2[162:137] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b010001) begin
						buf_w2[136:111] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b010010) begin
						buf_w2[110:85] 	<= la_data_in[25:0];	
					end else if (la_data_in[31:26] == 6'b010011) begin
						buf_w2[84:59] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b010100) begin
						buf_w2[58:33] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b010101) begin
						buf_w2[32:7] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b010110) begin
						buf_w2[6:0] 	<= la_data_in[6:0];

					end else if (la_data_in[31:26] == 6'b011000) begin
						buf_z2[162:137] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b011001) begin
						buf_z2[136:111] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b011010) begin
						buf_z2[110:85] 	<= la_data_in[25:0];	
					end else if (la_data_in[31:26] == 6'b011011) begin
						buf_z2[84:59] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b011100) begin
						buf_z2[58:33] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b011101) begin
						buf_z2[32:7] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b011110) begin
						buf_z2[6:0] 	<= la_data_in[6:0];

					end else if (la_data_in[31:26] == 6'b100000) begin
						buf_inv_w0[162:137] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b100001) begin
						buf_inv_w0[136:111] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b100010) begin
						buf_inv_w0[110:85] 	<= la_data_in[25:0];	
					end else if (la_data_in[31:26] == 6'b100011) begin
						buf_inv_w0[84:59] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b100100) begin
						buf_inv_w0[58:33] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b100101) begin
						buf_inv_w0[32:7] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b100110) begin
						buf_inv_w0[6:0] 	<= la_data_in[6:0];

					end else if (la_data_in[31:26] == 6'b101000) begin
						buf_d[162:137] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b101001) begin
						buf_d[136:111] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b101010) begin
						buf_d[110:85] 	<= la_data_in[25:0];	
					end else if (la_data_in[31:26] == 6'b101011) begin
						buf_d[84:59] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b101100) begin
						buf_d[58:33] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b101101) begin
						buf_d[32:7] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b101110) begin
						buf_d[6:0] 		<= la_data_in[6:0];

					end else if (la_data_in[31:26] == 6'b110000) begin
						buf_key[162:137] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b110001) begin
						buf_key[136:111] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b110010) begin
						buf_key[110:85] 	<= la_data_in[25:0];	
					end else if (la_data_in[31:26] == 6'b110011) begin
						buf_key[84:59] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b110100) begin
						buf_key[58:33] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b110101) begin
						buf_key[32:7] 	<= la_data_in[25:0];
					end else if (la_data_in[31:26] == 6'b110110) begin
						buf_key[6:0] 	<= la_data_in[6:0];
					end

					// When processor permits BEC to execute encryption, all buffers push data into corresponding registers
					if ((la_data_in[31:16] == 16'hEF41)) begin
						reg_w1 		<= 	buf_w1;
						reg_z1 		<= 	buf_z1;
						reg_w2 		<= 	buf_w2;
						reg_z2 		<= 	buf_z2;
						reg_d 		<= 	buf_d;
						reg_inv_w0	<= 	buf_inv_w0;
						reg_key		<= 	buf_key;
					end

					// When Multiple Mode enables, the reg_key cyclic right shifts when next_key = 1
					if ((master_ena_proc == 1'b1) & (next_key == 1'b1)) begin
						reg_key <= {reg_key[0], reg_key[162:1]};
					end
					
				end

				proc: begin
					la_data_out[31:26] <= 6'b101111;
					la_data_out[25:0] <= {(26){1'b0}};
					if (next_key) begin
						reg_key <= {reg_key[0], reg_key[162:1]};
					end
				end

				read_mode: begin
					// When enable read turns on, controller enables bec to write results into corresponding registers
					case (counterControl)
						6'b000000: 
							reg_wout[31:0] 	<= data_in;
						6'b000010:
							reg_wout[63:32] 	<= data_in;
						6'b000011: 
							reg_wout[95:64] 	<= data_in;
						6'b000100:
							reg_wout[127:96] 	<= data_in;
						6'b000101:
							reg_wout[159:128] 		<= data_in;
						6'b000110:
							reg_wout[162:160] 		<= data_in[2:0];
						6'b001000: 
							reg_zout[31:0] 	<= data_in;
						6'b001001:
							reg_zout[63:32] 	<= data_in;
						6'b001010: 
							reg_zout[95:64] 	<= data_in;
						6'b001011:
							reg_zout[127:96] 	<= data_in;
						6'b001100:
							reg_zout[159:128] 		<= data_in;
						6'b001101:
							reg_zout[162:160] 		<= data_in[2:0];
						default:
							reg_zout <= reg_zout;
					endcase

					/* Pull Result Data to the processor */
					if (~load_data) begin
						case (la_data_in) 
							32'h00000000: begin
								la_data_out 	<= {4'b0001, reg_wout[162:135]}; 
							end
							32'h00010000: begin
								la_data_out 	<= {4'b0010, reg_wout[134:107]}; 
							end
							
							32'h00020000: begin
								la_data_out 	<= {4'b0011, reg_wout[106:79]}; 
							end

							32'h00030000: begin
								la_data_out 	<= {4'b0100, reg_wout[78:51]}; 
							end

							32'h00040000: begin
								la_data_out 	<= {4'b0101, reg_wout[50:23]}; 
							end

							32'h00050000: begin
								la_data_out 	<= {4'b0110,5'b00000, reg_wout[22:0]}; 
							end

							32'h00060000: begin
								la_data_out 	<= {4'b0111, reg_zout[162:135]}; 
							end

							32'h00070000: begin
								la_data_out 	<= {4'b1000, reg_zout[134:107]}; 
							end
							
							32'h00080000: begin
								la_data_out 	<= {4'b1001, reg_zout[106:79]}; 
							end

							32'h00090000: begin
								la_data_out 	<= {4'b1010, reg_zout[78:51]}; 
							end

							32'h000A0000: begin
								la_data_out 	<= {4'b1100, reg_zout[50:23]}; 
							end

							32'h000C0000: begin
								la_data_out 	<= {4'b1101,5'b00000, reg_zout[22:0]}; 
							end
							32'hAB500000: begin
								// Processor indicates receiveing completed => Ready for next test case
								if ((mode_exec == 1'b1) & (slv_done == 1'b1)) begin
									// If Multiple Execution enabled, wait until slave completed
									la_data_out<= 32'hC8000000 ^ {14'h0000, counter};
								end else if (mode_exec == 1'b0) begin
									la_data_out<= 32'hC8000000 ^ {14'h0000, counter};;
								end else begin
									la_data_out <= 32'hAD400000 ^ {14'h0000, counter};;
								end
							end

							default: 
								la_data_out 	<= {4'b0001, reg_wout[162:135]}; 
						endcase
					end 
					

					if ((master_ena_proc == 1'b1) & (next_key == 1'b1))  begin
						reg_key <= {reg_key[0], reg_key[162:1]};
					end
				end
				
				default: begin
					la_data_out<= 32'hFFFFFFFF; 
				end
			endcase
			
			if (slv_done) begin
				first_round <= 1'b0;
				counter 	<= buf_cnt;
			end
			
			if (la_data_in[31:0] == 32'hFD300000) begin
				mode_exec <= 1'b1;
			end else if (la_data_in[31:0] == 32'hFC300000) begin
				mode_exec <= 1'b0;
			end

			if (slv_enable) begin
				buf_cnt <= buf_cnt + 1;
			end else begin
				buf_cnt <= 0;
			end

			if (master_ena_proc == 1'b1) begin
				if ((counterControl < 47)) begin
					counterControl <= counterControl + 1;
					if (counterControl == 6'h2E) begin
						reg_w1 <= {reg_w1[31:0], reg_w1[191:32]};
						reg_z1 <= {reg_z1[31:0], reg_z1[191:32]};
						reg_w2 <= {reg_w2[31:0], reg_w2[191:32]};
						reg_z2 <= {reg_z2[31:0], reg_z2[191:32]};
						reg_inv_w0 <= {reg_inv_w0[31:0], reg_inv_w0[191:32]};
						reg_d <= {reg_d[31:0], reg_d[191:32]};
					end else if ((counterControl[2:0] != 3'b111) & (counterControl[2:0] != 3'b000)) begin
						reg_w1 <= {reg_w1[31:0], reg_w1[191:32]};
						reg_z1 <= {reg_z1[31:0], reg_z1[191:32]};
						reg_w2 <= {reg_w2[31:0], reg_w2[191:32]};
						reg_z2 <= {reg_z2[31:0], reg_z2[191:32]};
						reg_inv_w0 <= {reg_inv_w0[31:0], reg_inv_w0[191:32]};
						reg_d <= {reg_d[31:0], reg_d[191:32]};
					end
				end else if (slv_done | becStatus == 4'h8) begin
					counterControl <= 6'b000000;
				end 
			end else if (slv_done) begin
				counterControl <= 6'b000000;
			end
	
		end
	end
endmodule

`default_nettype wire
/* verilator lint_off EOFNEWLINE */
