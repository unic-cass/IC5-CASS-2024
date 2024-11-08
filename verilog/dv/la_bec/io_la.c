// #include <../../../verilog/dv/la_bec/sm_bec_v3_randomKey_spec.h>
// #include <../../../verilog/dv/la_bec/sm_bec_v3_randomKey_txt.h>
#include <../../../verilog/dv/la_bec/sm_bec_v3_randomKey_spec.h>
// #include <../../../verilog/dv/la_bec/sm_bec_v3_randomKey_txt.h>
static uint32_t write_la(int i, uint32_t becAddres, uint32_t data_reg0) {
	reg_la0_data = becAddres ^ data_reg0;
}

static uint32_t write_data (int i) {
  while ((reg_la1_data_in & 0xFF000000 )!= 0x78000000) {

		write_la(0, 0x00000000, w1[0]);
		write_la(0, 0x04000000, w1[1]);
		write_la(0, 0x08000000, w1[2]);
		write_la(0, 0x0C000000, w1[3]);
		write_la(0, 0x10000000, w1[4]);
		write_la(0, 0x14000000, w1[5]);
		write_la(0, 0x18000000, w1[6]);

		write_la(0, 0x20000000, z1[0]);
		write_la(0, 0x24000000, z1[1]);
		write_la(0, 0x28000000, z1[2]);
		write_la(0, 0x2C000000, z1[3]);
		write_la(0, 0x30000000, z1[4]);
		write_la(0, 0x34000000, z1[5]);
		write_la(0, 0x38000000, z1[6]);

		write_la(0, 0x40000000, w2[0]);
		write_la(0, 0x44000000, w2[1]);
		write_la(0, 0x48000000, w2[2]);
		write_la(0, 0x4C000000, w2[3]);
		write_la(0, 0x50000000, w2[4]);
		write_la(0, 0x54000000, w2[5]);
		write_la(0, 0x58000000, w2[6]);

		write_la(0, 0x60000000, z2[0]);
		write_la(0, 0x64000000, z2[1]);
		write_la(0, 0x68000000, z2[2]);
		write_la(0, 0x6C000000, z2[3]);
		write_la(0, 0x70000000, z2[4]);
		write_la(0, 0x74000000, z2[5]);
		write_la(0, 0x78000000, z2[6]);

		write_la(0, 0x80000000, inv_w0[0]);
		write_la(0, 0x84000000, inv_w0[1]);
		write_la(0, 0x88000000, inv_w0[2]);
		write_la(0, 0x8C000000, inv_w0[3]);
		write_la(0, 0x90000000, inv_w0[4]);
		write_la(0, 0x94000000, inv_w0[5]);
		write_la(0, 0x98000000, inv_w0[6]);

		write_la(0, 0xA0000000, d[0]);
		write_la(0, 0xA4000000, d[1]);
		write_la(0, 0xA8000000, d[2]);
		write_la(0, 0xAC000000, d[3]);
		write_la(0, 0xB0000000, d[4]);
		write_la(0, 0xB4000000, d[5]);
		write_la(0, 0xB8000000, d[6]);
		
		// Writing key register
		write_la(i, 0xC0000000, k_array[i][0]);
		write_la(i, 0xC4000000, k_array[i][1]);
		write_la(i, 0xC8000000, k_array[i][2]);
		write_la(i, 0xCC000000, k_array[i][3]);
		write_la(i, 0xD0000000, k_array[i][4]);
		write_la(i, 0xD4000000, k_array[i][5]);
		write_la(i, 0xD8000000, k_array[i][6]);
		break;
	}
}

static uint32_t read_data () {
	
	uint32_t reg_wout_0, reg_wout_1, reg_wout_2, reg_wout_3, reg_wout_4, reg_wout_5, reg_zout_0, reg_zout_1, reg_zout_2, reg_zout_3, reg_zout_4, reg_zout_5;
	while ((reg_la1_data_in & 0xF0000000) != 0xF0000000) {
		if ((reg_la1_data_in & 0xF0000000) == 0x00000000) {
			reg_wout_0 = reg_la1_data_in & 0x0FFFFFFF;			// Take 29 bits
		} else if ((reg_la1_data_in & 0xF0000000) == 0x10000000){
			reg_wout_1 = reg_la1_data_in & 0x0FFFFFFF;
		} else if ((reg_la1_data_in & 0xF0000000) == 0x20000000) {
			reg_wout_2 = reg_la1_data_in & 0x0FFFFFFF;			// Take 81 bits
		} else if ((reg_la1_data_in & 0xF0000000) == 0x30000000) {
			reg_wout_3 = reg_la1_data_in & 0x0FFFFFFF;			// Take 81 bits_la0_data = 0xAB040000;
		} else if ((reg_la1_data_in & 0xF0000000) == 0x40000000) {
			reg_wout_4 = reg_la1_data_in & 0x0FFFFFFF;			// Take 81 bits
		} else if ((reg_la1_data_in & 0xF0000000) == 0x50000000) {
			reg_wout_5 = reg_la1_data_in & 0x0FFFFFFF;			// Take 81 bits

		} else if ((reg_la1_data_in & 0xF0000000) == 0x60000000) {
			reg_zout_0 = reg_la1_data_in & 0x0FFFFFFF;			// Take 29 bits
		} else if ((reg_la1_data_in & 0xF0000000) == 0x70000000){
			reg_zout_1 = reg_la1_data_in & 0x0FFFFFFF;
		} else if ((reg_la1_data_in & 0xF0000000) == 0x80000000) {
			reg_zout_2 = reg_la1_data_in & 0x0FFFFFFF;			// Take 81 bits
		} else if ((reg_la1_data_in & 0xF0000000) == 0x90000000) {
			reg_zout_3 = reg_la1_data_in & 0x0FFFFFFF;			// Take 81 bits_la0_data = 0xAB040000;
		} else if ((reg_la1_data_in & 0xF0000000) == 0xA0000000) {
			reg_zout_4 = reg_la1_data_in & 0x0FFFFFFF;			// Take 81 bits
		} else if ((reg_la1_data_in & 0xF0000000) == 0xB0000000) {
			reg_zout_5 = reg_la1_data_in & 0x0FFFFFFF;			// Take 81 bits
		}
	}
	return reg_wout_0, reg_wout_1, reg_wout_2, reg_wout_3, reg_wout_4, reg_wout_5, reg_zout_0, reg_zout_1, reg_zout_2, reg_zout_3, reg_zout_4, reg_zout_5;
}