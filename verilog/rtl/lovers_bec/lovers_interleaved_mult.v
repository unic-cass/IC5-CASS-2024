/*--------------------------------------------------------------------------
-- Interleaved Multiplier (interleaved_mult.v)
--
-- LSB first
-- 
-- Computes the polynomial multiplication mod f in GF(2**m)
-- Implements a sequential cincuit

-- Defines 2 entities (interleaved_data_path and interleaved_mult)
-- 
----------------------------------------------------------------------------

-----------------------------------
-- Interleaved MSB-first multipication data_path
-----------------------------------*/


module shift_reg (clk, load, shift_r, rst, A, Z);
   input  [162:0] A;
   input  wire clk, load, shift_r, rst;
   output wire [162:0] Z;

   reg [162:0] aa;
   
   assign Z = aa;

   always @(posedge clk) begin
	   if (rst)
		   aa <= 0;
	   else if (load)
		   aa <= A;
	   else if (shift_r) begin
		  if (aa[162]) begin
			aa <= (aa << 1) ^ {3'b000, 160'h00000000000000000000000000000000000000C9};
			// aa[7:0] <= aa[7:0] ^ 8'hC9;
		  end else begin
			aa <= aa << 1;
		  end
		end
		// Z <= aa;
	end
endmodule

//---------------------------------
// interleaved_mult
//---------------------------------

module interleaved_mult (clk, rst, start, A, B, Z, done);
	input  [162:0] A, B;
	input  clk, rst, start;
	output wire [162:0] Z;
	output wire done;

	reg load_done, shift_r;
	reg [7:0] count;
	reg [162:0]  regB, regC;
	wire [162:0] regA;
	reg count_done;

	assign Z = regC;
	
	reg [1:0] current_state, next_state;
	parameter IDLE = 2'b00, LOAD = 2'b01, SHIFT = 2'b10, ST_DONE =2'b11;
	assign done = (current_state == ST_DONE) ? 1'b1 : 1'b0;
	shift_reg u_shift_reg (
		.A(A),
		.clk(clk),
		.load(load_done),
		.shift_r(shift_r),
		.rst(rst),
		.Z(regA)
	);

	always @(posedge clk) begin
		if (rst) begin
			count <= 0;
			count_done <= 1'b0;
			regC <= 0;
			regB <= 0;
		end else if (current_state == SHIFT) begin
			if (count == 163) begin
				count <= 0;
				count_done <= 1'b1;
			end else begin
				regB <= regB >> 1;
				count <= count + 1;
				count_done <= 1'b0;
				if (regB[0] == 1'b1)
					regC <= regC ^ regA;
				else
					regC <= regC;
			end
		end else if (current_state == LOAD) begin
			regB <= B;
			regC <= 0;
			count <= 0;
			count_done <= 1'b0;
		end 
	end

	//FSM process
	always @(posedge clk) begin
		if (rst) begin
			shift_r <= 1'b0;
			load_done <= 1'b0;
		end else begin
			case (next_state)
				IDLE: begin
					shift_r <= 1'b0;
					load_done <= 1'b0;
				end
				LOAD: begin
					load_done <= 1'b1;
					shift_r <= 1'b0;
				end
				SHIFT: begin
					load_done <= 1'b0;
					shift_r <= 1'b1;
				end
				ST_DONE: begin
					shift_r <= 1'b0;
				end
				default: begin
					load_done <= 1'b0;
					shift_r <= 1'b0;
				end
			endcase
		end
	end
	

	always @(posedge clk) begin
		if (rst)
			current_state <= IDLE;
		else
			current_state <= next_state;
		end  

	always @(*) begin
		case (current_state)
			IDLE: begin
				if (start && !count_done)
					next_state = LOAD;
				else
					next_state = IDLE;
			end
			LOAD: begin
				
				next_state = SHIFT;
				
			end
			SHIFT: begin
				if (count_done && start)
					next_state = ST_DONE;
				else if (~start)
					next_state = IDLE;
				else
					next_state = SHIFT;
			end
			ST_DONE: begin
				next_state = IDLE;
			end
			default: next_state = IDLE;
		endcase
	end

endmodule





