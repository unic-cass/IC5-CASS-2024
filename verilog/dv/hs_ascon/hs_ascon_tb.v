`default_nettype none
`timescale 1 ns / 1 ns
`define k 128
`define r 64
`define a 12
`define b 6
`define l 40
`define y 104
`define KEY 'h6d4f8bbf60ec05a07b201d4e5b2119ac
`define NONCE 'h05885e606e1271b8d47a74c7b297a318
`define AD 'h4153434f4e
`define PT 'h6173636f6e2d756e6963617373
`define CT 'h18490112f8d5867a830748390b

module ascon_tb;
	parameter PERIOD = 20;
	parameter max = (`k>=`y && `k>=`l)? `k: ((`y>=`l)? `y: `l);
	reg clock;
	reg RSTB;
	reg CSB;
	reg power1, power2;
	reg power3, power4;

	wire gpio;
	wire [37:0] mprj_io;

	reg 	  clk = 0;
	reg 	  rst = 0;
    reg       keyxSI;
    reg       noncexSI;
    reg       associated_dataxSI;
    reg       input_dataxSI;
    reg       ascon_startxSI;
    reg       decrypt;

	integer ctr = 0;
    reg [`y-1:0] cipher_text, plain_text;
    reg [127:0] tag;

	wire   output_dataxSO;
    wire   tagxSO;
    wire   ascon_readyxSO;
    integer check_time;
	wire [7:0] checkbits;

	assign checkbits = mprj_io[31:24];
	assign mprj_io[3] = (CSB == 1'b1) ? 1'b1 : 1'bz;

	//input
	
	assign mprj_io[16] = clk;
	assign mprj_io[15] = rst;
	assign mprj_io[14] = keyxSI;
	assign mprj_io[13] = noncexSI;
	assign mprj_io[12] = associated_dataxSI;
	assign mprj_io[11] = input_dataxSI;
	assign mprj_io[10] = ascon_startxSI;
	assign mprj_io[9]  = decrypt;
	
	//output

	assign output_dataxSO = mprj_io[19];
	assign tagxSO = mprj_io[18];
	assign ascon_readyxSO = mprj_io[17];



	always #12.5 clock <= (clock === 1'b0);

	
	initial begin
		repeat (100) begin
			repeat (1000) @(posedge clk);
				$display("+1000 cycles");
		end
	
		$display("%c[1;31m",27);
		`ifdef GL
			$display ("Monitor: Timeout, Test Mega-Project IO Ports (GL) Failed");
		`else
			$display ("Monitor: Timeout, Test Mega-Project IO Ports (RTL) Failed");
		`endif
		$display("%c[0m",27);
		$finish;
		end 
	always #(PERIOD) clk = ~clk;
	initial begin
		wait(checkbits == 8'hB4);
		$display("Monitor: Test MPRJ (RTL) Started!");
	end
	task write;
    input [max-1:0] rd, i, key, nonce, ass_data, ct; 
    begin
		
        @(negedge clk);
        if (i <`k) keyxSI = key[`k-1-i];
        if (i < 128) noncexSI = nonce[127-i];
        if (i < `y) input_dataxSI = ct[`y-1-i];
        if (i < `l) associated_dataxSI = ass_data[`l-1-i];
    end
    endtask

    task read_dec;
    input integer i;
    begin
        @(posedge clk);
        if (i < `y) plain_text[i] = output_dataxSO;
        if (i < 128) tag[i] = tagxSO;
    end
    endtask


    task read_enc;
    input integer i;
    begin
        @(posedge clk);
        if (i < `y) cipher_text[i] = output_dataxSO;
        if (i < 128) tag[i] = tagxSO;
    end
    endtask
	
	initial begin
		$dumpfile("ascon.vcd");
		$dumpvars(0, ascon_tb);
		#15230
		$display("Start encryption! at %d", $time);
        decrypt = 0;
        rst = 1;
        #(2*PERIOD)
        rst = 0;
        ctr = 0;
        repeat(max) begin
            write($random, ctr, `KEY, `NONCE, `AD, `PT);
            ctr = ctr + 1;
        end
        ctr = 0;
        ascon_startxSI = 1;
        check_time = $time;
		$display("Key:\t%h", uut.chip_core.mprj.ascon_wrapper.ascon.key);
        $display("Nonce:\t%h", uut.chip_core.mprj.ascon_wrapper.ascon.nonce);
        $display("AD:\t%h", uut.chip_core.mprj.ascon_wrapper.ascon.associated_data);
        $display("PT:\t%h", uut.chip_core.mprj.ascon_wrapper.ascon.input_data);
        #(5.5*PERIOD)
        ascon_startxSI = 0;
        #(500*PERIOD)
        $display("Start decryption! %d", $time);
        decrypt = 1;
        rst = 1;
        #(2.5*PERIOD)
        rst = 0;
        ctr = 0;
        repeat(max) begin
            write($random, ctr, `KEY, `NONCE, `AD, `CT);
            ctr = ctr + 1;
        end
        ctr = 0;
        ascon_startxSI = 1;
        check_time = $time;
		#(0.5*PERIOD)
		$display("Key:\t%h", uut.chip_core.mprj.ascon_wrapper.ascon.key);
        $display("Nonce:\t%h", uut.chip_core.mprj.ascon_wrapper.ascon.nonce);
        $display("AD:\t%h", uut.chip_core.mprj.ascon_wrapper.ascon.associated_data);
        $display("CT:\t%h", uut.chip_core.mprj.ascon_wrapper.ascon.input_data);
        #(5.5*PERIOD)
        ascon_startxSI = 0;
    end
		
	always @(*) begin
        if(ascon_readyxSO) begin
			//Trỏ tới uut (caravel) -> chip core -> mprj -> .... (Theo đường dẫn của gtkwave)
            if (uut.chip_core.mprj.ascon_wrapper.ascon.flag_dec) begin
                check_time = $time - check_time;
                $display("Decryption Done! It took%d clock cycles", check_time/(2*PERIOD));
                #(4*PERIOD)
                repeat(max) begin
                    read_dec(ctr);
                    ctr = ctr + 1;
                end
                $finish;
            end else begin
                check_time = $time - check_time;
                $display("Encryption Done! It took%d clock cycles", check_time/(2*PERIOD));
                #(4*PERIOD)
                repeat(max) begin
                    read_enc(ctr);
                    ctr = ctr + 1;
                end

                $finish; // only encrypt
            end
        end

	end


	initial begin
		RSTB <= 1'b0;
		CSB  <= 1'b1;		// Force CSB high
		#2000;
		RSTB <= 1'b1;	    	// Release reset
		#3000000; 
		CSB = 1'b0;		// CSB can be released
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		power3 <= 1'b0;
		power4 <= 1'b0;
		#100;
		power1 <= 1'b1;
		#100;
		power2 <= 1'b1;
		#100;
		power3 <= 1'b1;
		#100;
		power4 <= 1'b1;
	end

	always @(mprj_io[19:17]) begin
		#1 $display("MPRJ-IO state = %b ", mprj_io[19:17]);
	end

	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD3V3;
	wire VDD1V8;
	wire VSS;
	
	assign VDD3V3 = power1;
	assign VDD1V8 = power2;
	assign VSS = 1'b0;

	caravel uut (
		.vddio	  (VDD3V3),
		.vddio_2  (VDD3V3),
		.vssio	  (VSS),
		.vssio_2  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (VDD3V3),
		.vdda1_2  (VDD3V3),
		.vdda2    (VDD3V3),
		.vssa1	  (VSS),
		.vssa1_2  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (VDD1V8),
		.vccd2	  (VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock    (clock),
		.gpio     (gpio),
		.mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("ascon.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);

endmodule
`default_nettype wire
