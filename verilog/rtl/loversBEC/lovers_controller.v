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

module lovers_controller (
`ifdef USE_POWER_PINS
	inout vccd1,	// User area 1 1.8V supply
	inout vssd1,	// User area 1 digital ground
`endif

	// // Wishbone Slave ports (WB MI A)
	input wb_clk_i,
	input wb_rst_i,

	// Logic Analyzer Signals
	input  [127:0] la_data_in,
	output reg [127:0] la_data_out,
	
	// Interconnection bus of BEC
	output reg master_ena_proc,
	output load_data,
	output reg [2:0] load_status,
	output [162:0] data_out,
	output reg trigLoad,
	output ki,
	input next_key,

	input slv_done,
    input [3:0] becStatus,
	input [162:0] data_in
);
	wire clk;
	wire rst;
	reg enable_proc, enable_write, updateRegs;

	reg [162:0] reg_temp;

	// FSM Definition
	reg [1:0]current_state, next_state;
	parameter idle=2'b00, write_mode=2'b01,  proc=2'b11, read_mode=2'b10;
	assign ki = (current_state == proc) ? reg_temp[0] : 1'b0;
	// assign trigLoad = (enable_write == 1'b1) ? ~la_data_out[122] : 1'b0;
	assign data_out = ((current_state == write_mode) & la_data_out[122] == 1'b0) ? reg_temp : 0;
	assign load_data = enable_write;
	// Assuming LA probes [65:64] are for controlling the count clk & reset  
	assign clk = wb_clk_i;
	assign rst = wb_rst_i;
	
	// assign slv_done = (current_state == 2'b11) ? 1'b1 : 1'b0;

	/*
	Nơi khai báo tên instantaneous và nối các chân của khối BEC.
	*/

	always @(posedge clk or posedge rst) begin
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
			next_state = idle;
		endcase
	end

	always @(posedge clk or posedge rst) begin
        if (rst) begin
			enable_write <= 1'b0;
			enable_proc <= 1'b0;
			master_ena_proc <= 1'b0;
			updateRegs <= 1'b0;
		end else begin
			case (current_state)
				idle: begin
					enable_proc <= 1'b0;
					updateRegs <= 1'b0;
					if (la_data_in[31:16] == 16'hab30) begin
						enable_write <= 1'b1;
					end else 
						enable_write <= 1'b0;
				end 

				write_mode: begin
					updateRegs <= 1'b0;
					if (la_data_in[31:16] == 16'hAB41) begin
						enable_proc <= 1'b1;
					end else 
						enable_proc <= 1'b0;
				end

				proc: begin
					enable_write <= 1'b0;
					if (~slv_done)
						master_ena_proc <= 1'b1;
					else
						master_ena_proc <= 1'b0;
				end

				read_mode: begin
					master_ena_proc <= 1'b0;
					if (la_data_in[31:16] == 16'hAB50)
						updateRegs <= 1'b1;
					else
						updateRegs <= 1'b0;
				end
				default: begin
					master_ena_proc <= 1'b0;
					enable_write <= 1'b0;
					enable_proc <= 1'b0;
					updateRegs <= 1'b0;
				end
			endcase
		end		
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			reg_temp      <= 0;
			load_status   <= 0;
			trigLoad	  <= 0;
			la_data_out <= {(128){1'b0}};
	
		end else begin
			case (current_state)
				idle: begin
					la_data_out[127:122] <= 6'b000000; 
				end 

				write_mode: begin
					if (la_data_in[95:82] == 14'b00000000000001) begin
						reg_temp[162:82] 	<= la_data_in[80:0];
						la_data_out[125:122] <= 4'b0001; 	//0x04
					end else if (la_data_in[95:82] == 14'b00000000000011) begin
						reg_temp[81:0] 		<= la_data_in[81:0];
						la_data_out[125:122] <= 4'b0010;	//0x08
						trigLoad			<= 1'b1;
						load_status <= 3'b000;				// Pushing w1 to the BEC

					end else if (la_data_in[95:82] == 14'b00000000000111) begin
						reg_temp[162:82] 	<= la_data_in[80:0];
						la_data_out[125:122] <= 4'b0011;	//0x0C
						trigLoad			<= 1'b0;
					end else if (la_data_in[95:82] == 14'b00000000001111) begin
						reg_temp[81:0] 		<= la_data_in[81:0];
						la_data_out[125:122] <= 4'b0100; 	//0x10
						trigLoad			<= 1'b1;
						load_status <= 3'b001;				// Pushing z1 to the BEC
					end else if (la_data_in[95:82] == 14'b00000000011111) begin
						reg_temp[162:82] 	<= la_data_in[80:0];
						la_data_out[125:122] <= 4'b0101;	//0x14
						trigLoad			<= 1'b0;
					end else if (la_data_in[95:82] == 14'b00000000111111) begin
						reg_temp[81:0] 		<= la_data_in[81:0];
						la_data_out[125:122] <= 4'b0110;	//0x18
						trigLoad			<= 1'b1;
						load_status <= 3'b010;				// Pushing w2 to the BEC
					end else if (la_data_in[95:82] == 14'b00000001111111) begin
						reg_temp[162:82] 	<= la_data_in[80:0];
						la_data_out[125:122] <= 4'b0111;	//0x1C
						trigLoad			<= 1'b0;
					end else if (la_data_in[95:82] == 14'b00000011111111) begin
						reg_temp[81:0] 		<= la_data_in[81:0];
						la_data_out[125:122] <= 4'b1000;	//0x20
						trigLoad			<= 1'b1;
						load_status <= 3'b011;				// Pushing z2 to the BEC
					end else if (la_data_in[95:82] == 14'b00000111111111) begin
						reg_temp[162:82] 	<= la_data_in[80:0];
						la_data_out[125:122] <= 4'b1001;	//0x24
						trigLoad			<= 1'b0;
					end else if (la_data_in[95:82] == 14'b00001111111111) begin
						reg_temp[81:0] 		<= la_data_in[81:0];
						la_data_out[125:122] <= 4'b1010;	//0x28
						trigLoad			<= 1'b1;
						load_status <= 3'b100;				// Pushing inv_w0 to the BEC
					end else if (la_data_in[95:82] == 14'b00011111111111) begin
						reg_temp[162:82] 	<= la_data_in[80:0];
						la_data_out[125:122] <= 4'b1011;	// 0x2C in
						trigLoad			<= 1'b0;
					end else if (la_data_in[95:82] == 14'b00111111111111) begin
						reg_temp[81:0] 		<= la_data_in[81:0];
						la_data_out[125:122] <= 4'b1100; 	//0x30
						trigLoad			<= 1'b1;
						load_status <= 3'b101;				// Pushing d to the BEC
					end else if (la_data_in[95:82] == 14'b01111111111111) begin
						reg_temp[162:82] 	<= la_data_in[80:0];
						trigLoad			<= 1'b0;
						la_data_out[125:122] <= 4'b1101;	//0x34
					end else if (la_data_in[95:82] == 14'b11111111111111) begin
						reg_temp[81:0] 		<= la_data_in[81:0];
						la_data_out[127:122] <= 6'b011110;	//0x78
					end
				end

				proc: begin
					la_data_out[127:122] <= 6'b100111;
					la_data_out[121:0] <= {(122){1'b0}};
					if (next_key) begin
						reg_temp <= reg_temp >> 1;
					end
				end

				read_mode: begin
					// enable_write <= 1'h0;
					reg_temp <= data_in;
					if (la_data_in[31:24] == 8'hAB) begin
						case (la_data_in[23:16]) 
							8'h04: begin
								load_status <= 3'b000;
								la_data_out[113:32] 	<= reg_temp[81:0]; 
								la_data_out[127:114]	<= 14'b11001000000000;		// 0xC8
							end

							8'h08: begin
								load_status <= 3'b001;
								la_data_out[112:32] 	<= reg_temp[162:82]; 
								la_data_out[127:114]	<= 14'b11001100000000;		// 0xCC
							end

							8'h0C: begin
								load_status <= 3'b001;
								la_data_out[113:32] 	<= reg_temp[81:0]; 
								la_data_out[127:114]	<= 14'b11010000000000;		// 0xD0
							end

							default: begin
								load_status <= 3'b000;
								la_data_out[112:32] 	<= reg_temp[162:82]; 		// 0xC4
								la_data_out[127:114]	<= 14'b11000100000000;
							end
						endcase
					end
				end
				
				default: begin
					reg_temp	<= 0;
					load_status <= 0;
					
					
					la_data_out[127:122] <= 6'b001100; 
				end
			endcase
		end
	end
endmodule

`default_nettype wire
