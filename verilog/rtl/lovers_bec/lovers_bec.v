// // SPDX-FileCopyrightText: 2020 Efabless Corporation
// //
// // Licensed under the Apache License, Version 2.0 (the "License");
// // you may not use this file except in compliance with the License.
// // You may obtain a copy of the License at
// //
// //      http://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing, software
// // distributed under the License is distributed on an "AS IS" BASIS,
// // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// // See the License for the specific language governing permissions and
// // limitations under the License.
// // SPDX-License-Identifier: Apache-2.0

module lovers_bec (
`ifdef USE_POWER_PINS
	inout vccd2,	// User area 2 1.8v supply
	inout vssd2,	// User area 2 digital ground
`endif

	input clk,
	input rst, 
	input enable,
	input load_data,
	input [2:0] load_status,
	input [162:0] data_in, 
	input trigLoad,
	input ki,

	output wire next_key,
	output wire [3:0]  becStatus,
	output done,
	output [162:0] data_out
);
	// FSM Definition
	reg [3:0] current_state, next_state;
	parameter idle= 4'h0, dload=4'h1, st0=4'h2, st1=4'h3, st2=4'h4, st3=4'h5, st4=4'h6, st5=4'h7, st6=4'h8, st7=4'h9, uload=4'ha;

	reg [162:0] regA, regB, regC, regD, reg_d, reg_inv_w0;

	reg [7:0] reg_key_iter;
	reg configuration, local_enable;
	reg [162:0] inACB_1, inACB_2;
	wire [162:0] outACB;
	
	wire done_loop, next_round;
	reg downloadSig, uploadSig, procSig, idleSig;
	
	assign becStatus = {idleSig, downloadSig, procSig, uploadSig};
	assign data_out = ((uploadSig == 1'b1) & (load_status == 3'b000)) ? regA : ((uploadSig == 1'b1) & (load_status == 3'b001)) ? regB: 0;
	assign next_key = done_loop;

	assign done_loop = (current_state == st7)? 1'b1 : 1'b0;
	assign done = (current_state == uload) ? 1'b1 : 1'b0;

	// assign configuration = ((current_state == st3) ^ (current_state == st6)) ? 1'b1 : 1'b0;

	acb u1(
		.clk(clk),
		.rst(rst),
		.enable(local_enable),
		.A(inACB_1),
		.B(inACB_2),
		.C(outACB),
		.configuration(configuration),
		.done(next_round)
	);

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			current_state <= idle;
			idleSig <= 1'b0;
			downloadSig <= 1'b0;
			procSig <= 1'b0;
			uploadSig <= 1'b0;
		end	else begin
			current_state <= next_state;
			case (next_state)
				idle:begin
					idleSig <= 1'b1;
					uploadSig <= 1'b0;
				end
				dload: begin
					idleSig <= 1'b0;
					downloadSig <= 1'b1;
				end
				st0: begin
					procSig <= 1'b1;
					downloadSig <= 1'b0;
				end
				uload: begin
					procSig <= 1'b0;
					uploadSig <= 1'b1;
				end
				default: begin
					procSig <= 1'b1;
					downloadSig <= 1'b0;
				end
			endcase
		end
			
	end

	always @(*) begin
		case (current_state)
			idle:	begin
				if (load_data)
					next_state = dload;
				else
					next_state = idle;
			end

			dload: 	begin
				if (enable)
					next_state = st0;
				else
					next_state = dload;
			end
			
			st0: begin
				if (next_round) 
					next_state = st1;
				else
					next_state = st0;
			end
			   	

			st1:    if (next_round)
						next_state = st2;
					else
						next_state = st1;

			st2:    if (next_round)
						next_state = st3;
					else
						next_state = st2;
			
			st3:    if (next_round)
					next_state = st4;
				else
					next_state = st3;

			st4:    if (next_round)
						next_state = st5;
					else
						next_state = st4;

			st5:    if (next_round)
						next_state = st6;
					else
						next_state = st5;

			st6:    if (next_round) begin
						next_state = st7;
					end	else
						next_state = st6;
			st7: 	if (reg_key_iter == 162)
						next_state = uload;
					else
						next_state = st0;
			uload: begin
				if (load_status == 3'b001)
					next_state = idle;
				else
					next_state = uload;
			end 
			default: next_state = idle;
		endcase
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			regA <= 0;
			regB <= 0;
			regC <= 0;
			regD <= 0;

			reg_inv_w0 <= 0;
			reg_d <= 0;

			inACB_1 <= 0;
			inACB_2 <= 0;
			configuration <= 0;
			reg_key_iter <= 0;
            local_enable <= 1'b0;
		end else begin
			if (downloadSig & trigLoad) begin
				if (ki) begin
					case (load_status)
						3'b000:  	inACB_1 <= data_in;
						3'b001: 	regB 	<= data_in;
						3'b010:		regC	<= data_in;
						3'b011:		begin
										regD 	<= data_in;
										inACB_2 <= data_in;
									end
						3'b101:		reg_d	<= data_in;
						3'b100:		reg_inv_w0 <= data_in;
						default: 	reg_inv_w0 <= data_in;
					endcase
				end else begin
					case (load_status)
						3'b000:  	regA	<= data_in;
						3'b001: 	begin
										regB 	<= data_in;
										inACB_2 <= data_in;
									end
						3'b010:		inACB_1	<= data_in;
						3'b011:		regD 	<= data_in;
						3'b101:		reg_d	<= data_in;
						3'b100:		reg_inv_w0 <= data_in;
						default: 	reg_inv_w0 <= data_in;
					endcase
				end
			end else if (procSig) begin
				if (next_round) begin
					case (current_state)
						st0: begin
							if (ki) begin
								regA <= outACB;
							end else begin
								regC <= outACB;
							end
						end 

						st1: begin
							if (ki) begin
								regA <= regA ^ outACB;
							end else begin
								regC <= regC ^ outACB;
							end
						end

						st2: begin
							if (ki) begin
								regB <= outACB;
							end else begin
								regD <= outACB;
							end
						end

						st3: begin
							if (ki) begin
								regA <= regA ^ outACB;
								regB <= regB ^ outACB;
							end else begin
								regC <= regC ^ outACB;
								regD <= regD ^ outACB;
							end
						end

						st4: begin
							if (ki) begin
								regC <= outACB;
							end else begin
								regA <= outACB;
							end
						end

						st5: begin
							if (ki) begin
								regD <= outACB;
							end else begin
								regB <= outACB;
							end
						end

						st6: begin
							if (ki) begin
								regD <= regC ^ outACB;
							end else begin
								regB <= regA ^ outACB;
							end
						end

						default: begin
							if (ki) begin
								regA <= outACB;
							end else begin
								regC <= outACB;
							end
						end
					endcase
				end
			end else if (uploadSig) begin
				reg_d <= 0;
				reg_inv_w0 <= 0;
				regC <= 0;
				regD <= 0;
			end
			

			if (local_enable) begin
				case (current_state)
					st0: begin
						configuration <= 1'b0;
						if ((reg_key_iter !== 0)) begin
							if (ki) begin
								inACB_2 <= regD;
								inACB_1 <= regA;
							end else begin
								inACB_2 <= regB;
								inACB_1 <= regC;
							end	
						end
					end 

					st1: begin
						if (ki) begin
                            inACB_1 <= regB;
                            inACB_2 <= regC;
						end else begin
                            inACB_1 <= regA;
                            inACB_2 <= regD;
                        end
					end

					st2: begin
						inACB_1 <= regB; 
                        inACB_2 <= regD;
					end

					st3: begin
						configuration <= 1'b1;
						inACB_1 <= reg_inv_w0;
						if (ki) begin
                            inACB_2 <= regA;
						end else begin
                            inACB_2 <= regC;
                        end
					end

					st4: begin
						configuration <= 1'b0;
						if (ki) begin
                            inACB_1 <= regC;
                            inACB_2 <= regC ^ regD;    
						end else begin
                            inACB_1 <= regA;
                            inACB_2 <= regA ^ regB;
                        end
					end

					st5: begin
						if (ki) begin
                            inACB_1 <= regD;
                            inACB_2 <= regD;
						end else begin
                            inACB_1 <= regB;
                            inACB_2 <= regB;
                        end
					end

					st6: begin
						configuration <= 1'b1;
						inACB_1 <= reg_d;
                        if (ki) begin
                            inACB_2 <= regD;
						end else begin
                            inACB_2 <= regB;
                        end
					end

					default: begin
					
						configuration <= 1'b0;
					end 
				endcase
			end

			if (procSig) begin
				local_enable <= ~(next_round);
				if (done_loop) begin
                    if (reg_key_iter < 163) begin
                        reg_key_iter <= reg_key_iter + 1;
					end else begin
                        reg_key_iter <= 0;
                    end
				end else begin
                    reg_key_iter <= reg_key_iter;
                end
			end else begin
				local_enable <= 0;
                reg_key_iter <= 0;
			end
		end
	end
endmodule

/* verilator lint_off EOFNEWLINE */
