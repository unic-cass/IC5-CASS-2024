// Vedic_multiplier_signed_unsigned_8bit_top

module vmsu_8bit_top (

`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

	input [7:0] a,
	input [7:0] b,
	input control,
	input clk,
	input rst,
	output [15:0] p
);

wire [7:0] q_a;
wire [7:0] q_b;
wire q_control;
wire [15:0] d_p;

//input flop
vmsu8_dff FA0 (.d(a[0]), .clk(clk), .rst(rst), .q(q_a[0]));
vmsu8_dff FA1 (.d(a[1]), .clk(clk), .rst(rst), .q(q_a[1]));
vmsu8_dff FA2 (.d(a[2]), .clk(clk), .rst(rst), .q(q_a[2]));
vmsu8_dff FA3 (.d(a[3]), .clk(clk), .rst(rst), .q(q_a[3]));
vmsu8_dff FA4 (.d(a[4]), .clk(clk), .rst(rst), .q(q_a[4]));
vmsu8_dff FA5 (.d(a[5]), .clk(clk), .rst(rst), .q(q_a[5]));
vmsu8_dff FA6 (.d(a[6]), .clk(clk), .rst(rst), .q(q_a[6]));
vmsu8_dff FA7 (.d(a[7]), .clk(clk), .rst(rst), .q(q_a[7]));

vmsu8_dff FB0 (.d(b[0]), .clk(clk), .rst(rst), .q(q_b[0]));
vmsu8_dff FB1 (.d(b[1]), .clk(clk), .rst(rst), .q(q_b[1]));
vmsu8_dff FB2 (.d(b[2]), .clk(clk), .rst(rst), .q(q_b[2]));
vmsu8_dff FB3 (.d(b[3]), .clk(clk), .rst(rst), .q(q_b[3]));
vmsu8_dff FB4 (.d(b[4]), .clk(clk), .rst(rst), .q(q_b[4]));
vmsu8_dff FB5 (.d(b[5]), .clk(clk), .rst(rst), .q(q_b[5]));
vmsu8_dff FB6 (.d(b[6]), .clk(clk), .rst(rst), .q(q_b[6]));
vmsu8_dff FB7 (.d(b[7]), .clk(clk), .rst(rst), .q(q_b[7]));

vmsu8_dff FC (.d(control), .clk(clk), .rst(rst), .q(q_control));

//combi logic
vmsu8_vmsu_8bit M0 (.a(q_a), .b(q_b), .control(q_control), .clk(clk), .rst(rst), .p(d_p));

//output flop
vmsu8_dff FP0 (.d(d_p[0]), .clk(clk), .rst(rst), .q(p[0]));
vmsu8_dff FP1 (.d(d_p[1]), .clk(clk), .rst(rst), .q(p[1]));
vmsu8_dff FP2 (.d(d_p[2]), .clk(clk), .rst(rst), .q(p[2]));
vmsu8_dff FP3 (.d(d_p[3]), .clk(clk), .rst(rst), .q(p[3]));
vmsu8_dff FP4 (.d(d_p[4]), .clk(clk), .rst(rst), .q(p[4]));
vmsu8_dff FP5 (.d(d_p[5]), .clk(clk), .rst(rst), .q(p[5]));
vmsu8_dff FP6 (.d(d_p[6]), .clk(clk), .rst(rst), .q(p[6]));
vmsu8_dff FP7 (.d(d_p[7]), .clk(clk), .rst(rst), .q(p[7]));
vmsu8_dff FP8 (.d(d_p[8]), .clk(clk), .rst(rst), .q(p[8]));
vmsu8_dff FP9 (.d(d_p[9]), .clk(clk), .rst(rst), .q(p[9]));
vmsu8_dff FP10 (.d(d_p[10]), .clk(clk), .rst(rst), .q(p[10]));
vmsu8_dff FP11 (.d(d_p[11]), .clk(clk), .rst(rst), .q(p[11]));
vmsu8_dff FP12 (.d(d_p[12]), .clk(clk), .rst(rst), .q(p[12]));
vmsu8_dff FP13 (.d(d_p[13]), .clk(clk), .rst(rst), .q(p[13]));
vmsu8_dff FP14 (.d(d_p[14]), .clk(clk), .rst(rst), .q(p[14]));
vmsu8_dff FP15 (.d(d_p[15]), .clk(clk), .rst(rst), .q(p[15]));

endmodule



module vmsu8_vmsu_8bit (
	input [7:0] a,
	input [7:0] b,
	input control,
	input clk,
	input rst,
	output [15:0] p
);

wire [7:0] a_com;
wire [7:0] b_com;
wire [7:0] mux_a;
wire [7:0] mux_b;
wire [7:0] q_mux_a;
wire [7:0] q_mux_b;
wire [15:0] d_out_multi;
wire [15:0] out_multi;
wire [15:0] out_multi_com;
wire c1,c2,c3;
wire d1_c1,d1_c2;
wire q1_c1,q1_c2;
wire d2_c1,d2_c2;

vmsu8_complementary_8bit COMA (.a(a), .c(a_com));
vmsu8_complementary_8bit COMB (.a(b), .c(b_com));

and (d1_c1, control, a[7]);
and (d1_c2, control, b[7]);

vmsu8_mux2to1 MUXA0 (.a(a[0]), .b(a_com[0]), .sel(d1_c1), .out(mux_a[0]));
vmsu8_mux2to1 MUXA1 (.a(a[1]), .b(a_com[1]), .sel(d1_c1), .out(mux_a[1]));
vmsu8_mux2to1 MUXA2 (.a(a[2]), .b(a_com[2]), .sel(d1_c1), .out(mux_a[2]));
vmsu8_mux2to1 MUXA3 (.a(a[3]), .b(a_com[3]), .sel(d1_c1), .out(mux_a[3]));
vmsu8_mux2to1 MUXA4 (.a(a[4]), .b(a_com[4]), .sel(d1_c1), .out(mux_a[4]));
vmsu8_mux2to1 MUXA5 (.a(a[5]), .b(a_com[5]), .sel(d1_c1), .out(mux_a[5]));
vmsu8_mux2to1 MUXA6 (.a(a[6]), .b(a_com[6]), .sel(d1_c1), .out(mux_a[6]));
vmsu8_mux2to1 MUXA7 (.a(a[7]), .b(a_com[7]), .sel(d1_c1), .out(mux_a[7]));

vmsu8_mux2to1 MUXB0 (.a(b[0]), .b(b_com[0]), .sel(d1_c2), .out(mux_b[0]));
vmsu8_mux2to1 MUXB1 (.a(b[1]), .b(b_com[1]), .sel(d1_c2), .out(mux_b[1]));
vmsu8_mux2to1 MUXB2 (.a(b[2]), .b(b_com[2]), .sel(d1_c2), .out(mux_b[2]));
vmsu8_mux2to1 MUXB3 (.a(b[3]), .b(b_com[3]), .sel(d1_c2), .out(mux_b[3]));
vmsu8_mux2to1 MUXB4 (.a(b[4]), .b(b_com[4]), .sel(d1_c2), .out(mux_b[4]));
vmsu8_mux2to1 MUXB5 (.a(b[5]), .b(b_com[5]), .sel(d1_c2), .out(mux_b[5]));
vmsu8_mux2to1 MUXB6 (.a(b[6]), .b(b_com[6]), .sel(d1_c2), .out(mux_b[6]));
vmsu8_mux2to1 MUXB7 (.a(b[7]), .b(b_com[7]), .sel(d1_c2), .out(mux_b[7]));

//Pipelining
vmsu8_dff FAM0 (.d(mux_a[0]), .clk(clk), .rst(rst), .q(q_mux_a[0]));
vmsu8_dff FAM1 (.d(mux_a[1]), .clk(clk), .rst(rst), .q(q_mux_a[1]));
vmsu8_dff FAM2 (.d(mux_a[2]), .clk(clk), .rst(rst), .q(q_mux_a[2]));
vmsu8_dff FAM3 (.d(mux_a[3]), .clk(clk), .rst(rst), .q(q_mux_a[3]));
vmsu8_dff FAM4 (.d(mux_a[4]), .clk(clk), .rst(rst), .q(q_mux_a[4]));
vmsu8_dff FAM5 (.d(mux_a[5]), .clk(clk), .rst(rst), .q(q_mux_a[5]));
vmsu8_dff FAM6 (.d(mux_a[6]), .clk(clk), .rst(rst), .q(q_mux_a[6]));
vmsu8_dff FAM7 (.d(mux_a[7]), .clk(clk), .rst(rst), .q(q_mux_a[7]));

vmsu8_dff FBM0 (.d(mux_b[0]), .clk(clk), .rst(rst), .q(q_mux_b[0]));
vmsu8_dff FBM1 (.d(mux_b[1]), .clk(clk), .rst(rst), .q(q_mux_b[1]));
vmsu8_dff FBM2 (.d(mux_b[2]), .clk(clk), .rst(rst), .q(q_mux_b[2]));
vmsu8_dff FBM3 (.d(mux_b[3]), .clk(clk), .rst(rst), .q(q_mux_b[3]));
vmsu8_dff FBM4 (.d(mux_b[4]), .clk(clk), .rst(rst), .q(q_mux_b[4]));
vmsu8_dff FBM5 (.d(mux_b[5]), .clk(clk), .rst(rst), .q(q_mux_b[5]));
vmsu8_dff FBM6 (.d(mux_b[6]), .clk(clk), .rst(rst), .q(q_mux_b[6]));
vmsu8_dff FBM7 (.d(mux_b[7]), .clk(clk), .rst(rst), .q(q_mux_b[7]));

vmsu8_dff FCM1 (.d(d1_c1), .clk(clk), .rst(rst), .q(q1_c1));
vmsu8_dff FCM2 (.d(d1_c2), .clk(clk), .rst(rst), .q(q1_c2));


vmsu8_multiplier_8bit MULTIPLY (.a(q_mux_a), .b(q_mux_b), .p(d_out_multi));
buf (d2_c1,q1_c1);
buf (d2_c2,q1_c2);

//Pipelining
vmsu8_dff FPM0 (.d(d_out_multi[0]), .clk(clk), .rst(rst), .q(out_multi[0]));
vmsu8_dff FPM1 (.d(d_out_multi[1]), .clk(clk), .rst(rst), .q(out_multi[1]));
vmsu8_dff FPM2 (.d(d_out_multi[2]), .clk(clk), .rst(rst), .q(out_multi[2]));
vmsu8_dff FPM3 (.d(d_out_multi[3]), .clk(clk), .rst(rst), .q(out_multi[3]));
vmsu8_dff FPM4 (.d(d_out_multi[4]), .clk(clk), .rst(rst), .q(out_multi[4]));
vmsu8_dff FPM5 (.d(d_out_multi[5]), .clk(clk), .rst(rst), .q(out_multi[5]));
vmsu8_dff FPM6 (.d(d_out_multi[6]), .clk(clk), .rst(rst), .q(out_multi[6]));
vmsu8_dff FPM7 (.d(d_out_multi[7]), .clk(clk), .rst(rst), .q(out_multi[7]));
vmsu8_dff FPM8 (.d(d_out_multi[8]), .clk(clk), .rst(rst), .q(out_multi[8]));
vmsu8_dff FPM9 (.d(d_out_multi[9]), .clk(clk), .rst(rst), .q(out_multi[9]));
vmsu8_dff FPM10 (.d(d_out_multi[10]), .clk(clk), .rst(rst), .q(out_multi[10]));
vmsu8_dff FPM11 (.d(d_out_multi[11]), .clk(clk), .rst(rst), .q(out_multi[11]));
vmsu8_dff FPM12 (.d(d_out_multi[12]), .clk(clk), .rst(rst), .q(out_multi[12]));
vmsu8_dff FPM13 (.d(d_out_multi[13]), .clk(clk), .rst(rst), .q(out_multi[13]));
vmsu8_dff FPM14 (.d(d_out_multi[14]), .clk(clk), .rst(rst), .q(out_multi[14]));
vmsu8_dff FPM15 (.d(d_out_multi[15]), .clk(clk), .rst(rst), .q(out_multi[15]));

vmsu8_dff FCM3 (.d(d2_c1), .clk(clk), .rst(rst), .q(c1));
vmsu8_dff FCM4 (.d(d2_c2), .clk(clk), .rst(rst), .q(c2));

vmsu8_complementary_16bit COMMULTI (.a(out_multi), .c(out_multi_com));

xor (c3,c2,c1);

vmsu8_mux2to1 MUXM0 (.a(out_multi[0]), .b(out_multi_com[0]), .sel(c3), .out(p[0]));
vmsu8_mux2to1 MUXM1 (.a(out_multi[1]), .b(out_multi_com[1]), .sel(c3), .out(p[1]));
vmsu8_mux2to1 MUXM2 (.a(out_multi[2]), .b(out_multi_com[2]), .sel(c3), .out(p[2]));
vmsu8_mux2to1 MUXM3 (.a(out_multi[3]), .b(out_multi_com[3]), .sel(c3), .out(p[3]));
vmsu8_mux2to1 MUXM4 (.a(out_multi[4]), .b(out_multi_com[4]), .sel(c3), .out(p[4]));
vmsu8_mux2to1 MUXM5 (.a(out_multi[5]), .b(out_multi_com[5]), .sel(c3), .out(p[5]));
vmsu8_mux2to1 MUXM6 (.a(out_multi[6]), .b(out_multi_com[6]), .sel(c3), .out(p[6]));
vmsu8_mux2to1 MUXM7 (.a(out_multi[7]), .b(out_multi_com[7]), .sel(c3), .out(p[7]));
vmsu8_mux2to1 MUXM8 (.a(out_multi[8]), .b(out_multi_com[8]), .sel(c3), .out(p[8]));
vmsu8_mux2to1 MUXM9 (.a(out_multi[9]), .b(out_multi_com[9]), .sel(c3), .out(p[9]));
vmsu8_mux2to1 MUXM10 (.a(out_multi[10]), .b(out_multi_com[10]), .sel(c3), .out(p[10]));
vmsu8_mux2to1 MUXM11 (.a(out_multi[11]), .b(out_multi_com[11]), .sel(c3), .out(p[11]));
vmsu8_mux2to1 MUXM12 (.a(out_multi[12]), .b(out_multi_com[12]), .sel(c3), .out(p[12]));
vmsu8_mux2to1 MUXM13 (.a(out_multi[13]), .b(out_multi_com[13]), .sel(c3), .out(p[13]));
vmsu8_mux2to1 MUXM14 (.a(out_multi[14]), .b(out_multi_com[14]), .sel(c3), .out(p[14]));
vmsu8_mux2to1 MUXM15 (.a(out_multi[15]), .b(out_multi_com[15]), .sel(c3), .out(p[15]));

endmodule



module vmsu8_multiplier_8bit (
        input [7:0] a,
        input [7:0] b,
        output [15:0] p
);

wire [7:4] o0;
wire [7:0] o1;
wire [7:0] o2;
wire [7:0] o3;
wire c0,c1,c2;
wire [7:0] sum0;
wire [7:4] sum1;
wire or_out;

vmsu8_multiplier_4bit U0 (.a(a[3:0]), .b(b[3:0]), .p({o0[7:4], p[3:0]}));
vmsu8_multiplier_4bit U1 (.a(a[3:0]), .b(b[7:4]), .p(o1[7:0]));
vmsu8_multiplier_4bit U2 (.a(a[7:4]), .b(b[3:0]), .p(o2[7:0]));
vmsu8_multiplier_4bit U3 (.a(a[7:4]), .b(b[7:4]), .p(o3[7:0]));

vmsu8_cla_8bit CLA0 (.a(o1[7:0]), .b(o2[7:0]), .cin(1'b0), .sum(sum0[7:0]), .cout(c0));
vmsu8_cla_8bit CLA1 (.a(sum0[7:0]), .b({4'b0000,o0[7:4]}), .cin(1'b0), .sum({sum1[7:4],p[7:4]}), .cout(c1));

or (or_out, c0, c1);

vmsu8_cla_8bit CLA2 (.a(o3[7:0]), .b({3'b000,or_out,sum1[7:4]}), .cin(1'b0), .sum(p[15:8]), .cout(c2));

endmodule



module vmsu8_complementary_16bit (
	input [15:0] a,
	output [15:0] c
);

wire [15:2] net;

assign c[0] = a[0];
xor (c[1],a[1],a[0]);
or (net[2],a[1],a[0]);
xor (c[2],net[2],a[2]);
or (net[3],net[2],a[2]);
xor (c[3],net[3],a[3]);
or (net[4],net[3],a[3]);
xor (c[4],net[4],a[4]);
or (net[5],net[4],a[4]);
xor (c[5],net[5],a[5]);
or (net[6],net[5],a[5]);
xor (c[6],net[6],a[6]);
or (net[7],net[6],a[6]);
xor (c[7],net[7],a[7]);
or (net[8],net[7],a[7]);
xor (c[8],net[8],a[8]);
or (net[9],net[8],a[8]);
xor (c[9],net[9],a[9]);
or (net[10],net[9],a[9]);
xor (c[10],net[10],a[10]);
or (net[11],net[10],a[10]);
xor (c[11],net[11],a[11]);
or (net[12],net[11],a[11]);
xor (c[12],net[12],a[12]);
or (net[13],net[12],a[12]);
xor (c[13],net[13],a[13]);
or (net[14],net[13],a[13]);
xor (c[14],net[14],a[14]);
or (net[15],net[14],a[14]);
xor (c[15],net[15],a[15]);

endmodule



module vmsu8_mux2to1 (
	input a,
	input b,
	input sel,
	output out
);

wire net[1:0];
wire sel_b;

//sel0:a , sel1:b

not (sel_b,sel);
nand (net[0],a,sel_b);
nand (net[1],b,sel);
nand (out,net[0],net[1]);

endmodule



module vmsu8_complementary_8bit (
	input [7:0] a,
	output [7:0] c
);

wire [7:2] net;

assign c[0] = a[0];
xor (c[1],a[1],a[0]);
or (net[2],a[1],a[0]);
xor (c[2],net[2],a[2]);
or (net[3],net[2],a[2]);
xor (c[3],net[3],a[3]);
or (net[4],net[3],a[3]);
xor (c[4],net[4],a[4]);
or (net[5],net[4],a[4]);
xor (c[5],net[5],a[5]);
or (net[6],net[5],a[5]);
xor (c[6],net[6],a[6]);
or (net[7],net[6],a[6]);
xor (c[7],net[7],a[7]);

endmodule



module vmsu8_cla_8bit (
    input [7:0] a,
    input [7:0] b,
    input cin,
    output [7:0] sum,
    output cout
);

    wire [7:0] p, g, c;
    wire [35:0] temp_c; // Intermediate carry wires

    // Generate Propagate and Generate signals
    xor (p[0], a[0], b[0]); // Propagate
    xor (p[1], a[1], b[1]);
    xor (p[2], a[2], b[2]);
    xor (p[3], a[3], b[3]);
    xor (p[4], a[4], b[4]);
    xor (p[5], a[5], b[5]);
    xor (p[6], a[6], b[6]);
    xor (p[7], a[7], b[7]);

    and (g[0], a[0], b[0]); // Generate
    and (g[1], a[1], b[1]);
    and (g[2], a[2], b[2]);
    and (g[3], a[3], b[3]);
    and (g[4], a[4], b[4]);
    and (g[5], a[5], b[5]);
    and (g[6], a[6], b[6]);
    and (g[7], a[7], b[7]);

    // CLA logic for carry generation
    assign c[0] = cin;

    // C[1] = G[0] | (P[0] & C[0]);
    and (temp_c[0], p[0], c[0]);
    or  (c[1], g[0], temp_c[0]);

    // C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    and (temp_c[1], p[1], g[0]);
    and (temp_c[2], p[1], p[0], c[0]);
    or  (c[2], g[1], temp_c[1], temp_c[2]);

    // C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
    and (temp_c[3], p[2], g[1]);
    and (temp_c[4], p[2], p[1], g[0]);
    and (temp_c[5], p[2], p[1], p[0], c[0]);
    or  (c[3], g[2], temp_c[3], temp_c[4], temp_c[5]);

    // C[4] = G[3] | (P[3] & C[3]);
    and (temp_c[6], p[3], g[2]);
    and (temp_c[7], p[3], p[2], g[1]);
    and (temp_c[8], p[3], p[2], p[1], g[0]);
    and (temp_c[9], p[3], p[2], p[1], p[0], c[0]);
    or  (c[4], g[3], temp_c[6], temp_c[7], temp_c[8], temp_c[9]);

    // C[5]
    and (temp_c[10], p[4], g[3]);
    and (temp_c[11], p[4], p[3], g[2]);
    and (temp_c[12], p[4], p[3], p[2], g[1]);
    and (temp_c[13], p[4], p[3], p[2], p[1], g[0]);
    and (temp_c[14], p[4], p[3], p[2], p[1], p[0], c[0]);
    or  (c[5], g[4], temp_c[10], temp_c[11], temp_c[12], temp_c[13], temp_c[14]);

    // C[6]
    and (temp_c[15], p[5], g[4]);
    and (temp_c[16], p[5], p[4], g[3]);
    and (temp_c[17], p[5], p[4], p[3], g[2]);
    and (temp_c[18], p[5], p[4], p[3], p[2], g[1]);
    and (temp_c[19], p[5], p[4], p[3], p[2], p[1], g[0]);
    and (temp_c[20], p[5], p[4], p[3], p[2], p[1], p[0], c[0]);
    or  (c[6], g[5], temp_c[15], temp_c[16], temp_c[17], temp_c[18], temp_c[19], temp_c[20]);

    // C[7]
    and (temp_c[21], p[6], g[5]);
    and (temp_c[22], p[6], p[5], g[4]);
    and (temp_c[23], p[6], p[5], p[4], g[3]);
    and (temp_c[24], p[6], p[5], p[4], p[3], g[2]);
    and (temp_c[25], p[6], p[5], p[4], p[3], p[2], g[1]);
    and (temp_c[26], p[6], p[5], p[4], p[3], p[2], p[1], g[0]);
    and (temp_c[27], p[6], p[5], p[4], p[3], p[2], p[1], p[0], c[0]);
    or  (c[7], g[6], temp_c[21], temp_c[22], temp_c[23], temp_c[24], temp_c[25], temp_c[26], temp_c[27]);

    // C[8]
    and (temp_c[28], p[7], g[6]);
    and (temp_c[29], p[7], p[6], g[5]);
    and (temp_c[30], p[7], p[6], p[5], g[4]);
    and (temp_c[31], p[7], p[6], p[5], p[4], g[3]);
    and (temp_c[32], p[7], p[6], p[5], p[4], p[3], g[2]);
    and (temp_c[33], p[7], p[6], p[5], p[4], p[3], p[2], g[1]);
    and (temp_c[34], p[7], p[6], p[5], p[4], p[3], p[2], p[1], g[0]);
    and (temp_c[35], p[7], p[6], p[5], p[4], p[3], p[2], p[1], p[0], c[0]);
    or  (cout, g[7], temp_c[28], temp_c[29], temp_c[30], temp_c[31], temp_c[32], temp_c[33], temp_c[34], temp_c[35]);

    // Sum
    xor (sum[0], p[0], c[0]);
    xor (sum[1], p[1], c[1]);
    xor (sum[2], p[2], c[2]);
    xor (sum[3], p[3], c[3]);
    xor (sum[4], p[4], c[4]);
    xor (sum[5], p[5], c[5]);
    xor (sum[6], p[6], c[6]);
    xor (sum[7], p[7], c[7]);

endmodule



module vmsu8_multiplier_4bit (
        input [3:0] a,
        input [3:0] b,
        output [7:0] p
);

wire [3:2] o0;
wire [3:0] o1;
wire [3:0] o2;
wire [3:0] o3;
wire c0,c1,c2;
wire [3:0] sum0;
wire [3:2] sum1;
wire or_out;

vmsu8_multiplier_2bit U0 (.a(a[1:0]), .b(b[1:0]), .p({o0[3:2], p[1:0]}));
vmsu8_multiplier_2bit U1 (.a(a[1:0]), .b(b[3:2]), .p(o1[3:0]));
vmsu8_multiplier_2bit U2 (.a(a[3:2]), .b(b[1:0]), .p(o2[3:0]));
vmsu8_multiplier_2bit U3 (.a(a[3:2]), .b(b[3:2]), .p(o3[3:0]));

vmsu8_cla_4bit CLA0 (.a(o1[3:0]), .b(o2[3:0]), .cin(1'b0), .sum(sum0[3:0]), .cout(c0));
vmsu8_cla_4bit CLA1 (.a(sum0[3:0]), .b({2'b00,o0[3:2]}), .cin(1'b0), .sum({sum1[3:2],p[3:2]}), .cout(c1));

or (or_out, c0, c1);

vmsu8_cla_4bit CLA2 (.a(o3[3:0]), .b({1'b0,or_out,sum1[3:2]}), .cin(1'b0), .sum(p[7:4]), .cout(c2));

endmodule



module vmsu8_cla_4bit (
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] sum,
    output cout
);

    wire [3:0] p, g, c;
    wire [9:0] temp_c; // Intermediate carry wires

    // Generate Propagate and Generate signals
    xor (p[0], a[0], b[0]); // Propagate
    xor (p[1], a[1], b[1]);
    xor (p[2], a[2], b[2]);
    xor (p[3], a[3], b[3]);

    and (g[0], a[0], b[0]); // Generate
    and (g[1], a[1], b[1]);
    and (g[2], a[2], b[2]);
    and (g[3], a[3], b[3]);

    // CLA logic for carry generation
    assign c[0] = cin;

    // C[1] = G[0] | (P[0] & C[0]);
    and (temp_c[0], p[0], c[0]);
    or  (c[1], g[0], temp_c[0]);

    // C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    and (temp_c[1], p[1], g[0]);
    and (temp_c[2], p[1], p[0], c[0]);
    or  (c[2], g[1], temp_c[1], temp_c[2]);

    // C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
    and (temp_c[3], p[2], g[1]);
    and (temp_c[4], p[2], p[1], g[0]);
    and (temp_c[5], p[2], p[1], p[0], c[0]);
    or  (c[3], g[2], temp_c[3], temp_c[4], temp_c[5]);

    // Cout = G[3] | (P[3] & C[3]);
    and (temp_c[6], p[3], g[2]);
    and (temp_c[7], p[3], p[2], g[1]);
    and (temp_c[8], p[3], p[2], p[1], g[0]);
    and (temp_c[9], p[3], p[2], p[1], p[0], c[0]);
    or  (cout, g[3], temp_c[6], temp_c[7], temp_c[8], temp_c[9]);

    // Sum
    xor (sum[0], p[0], c[0]);
    xor (sum[1], p[1], c[1]);
    xor (sum[2], p[2], c[2]);
    xor (sum[3], p[3], c[3]);

endmodule



module vmsu8_multiplier_2bit (
	input [1:0] a,
	input [1:0] b,
	output [3:0] p
);

wire [3:0] net;

and (p[0],a[0],b[0]);
and (net[0],a[0],b[1]);
and (net[1],a[1],b[0]);
and (net[2],a[1],b[1]);

vmsu8_half_adder U0 (.a(net[0]), .b(net[1]), .sum(p[1]), .cout(net[3]));
vmsu8_half_adder U1 (.a(net[2]), .b(net[3]), .sum(p[2]), .cout(p[3]));

endmodule



module vmsu8_half_adder (
	input a,
	input b,
	output sum,
	output cout
);

xor (sum,a,b);
and (cout,a,b);

endmodule



module vmsu8_dff (
	input d,
	input clk,
	input rst,
	output reg q
);

	always @(posedge clk)
		if (rst) begin
			q <= 0;
		end  else begin
			q <= d;
		end
			
endmodule
