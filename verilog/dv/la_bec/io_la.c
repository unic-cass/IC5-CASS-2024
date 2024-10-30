// #include <../../../verilog/dv/la_bec/sm_bec_v3_randomKey_spec.h>
// #include <../../../verilog/dv/la_bec/sm_bec_v3_randomKey_txt.h>
#include <../../../verilog/dv/la_bec/sm_bec_v3_randomKey_spec.h>
// #include <../../../verilog/dv/la_bec/sm_bec_v3_randomKey_txt.h>
static uint32_t write_la(int i, uint32_t wStatus, uint32_t data_reg0, uint32_t data_reg1, uint32_t data_reg2) {
	//  Configure BEC Status Notifications [127:122]
	// Next 4-bits of addresses inside BEC core
	// First 2-bits of FSM status inside BEC core    
	uint32_t BecStatus 	= reg_la3_data_in & 0x3C000000; //Take 4 bits of becStatus (la3_data_in[29:26])
	uint32_t becAddres;
	if ((BecStatus == 0x04000000)) {
		// la3_data_in[29:26] = "0001" --- w1(low)
		becAddres = 0x000C0000;
	} else if (BecStatus == 0x08000000) {
		// la3_data_in[29:26] = "0010" --- z1(high)
		becAddres = 0x001C0000;
	} else if (BecStatus == 0x0C000000) {
		// la3_data_in[29:26] = "0011" --- z1(low)
		becAddres = 0x003C0000;
	} else if (BecStatus == 0x10000000) {
		// la3_data_in[29:26] = "0100" --- w2(high)
		becAddres = 0x007C0000;
	} else if (BecStatus == 0x14000000) {
		// la3_data_in[29:26] = "0101" --- w2(low)
		becAddres = 0x00FC0000;
	} else if (BecStatus == 0x18000000) {
		// la3_data_in[29:26] = "0110" --- z2(high)
		becAddres = 0x01FC0000;
	} else if (BecStatus == 0x1C000000) {
		// la3_data_in[29:26] = "0111" --- z2(low)
		becAddres = 0x03FC0000;
	} else if (BecStatus == 0x20000000) {
		// la3_data_in[29:26] = "1000" --- inv_w0(high)
		becAddres = 0x07FC0000;
	} else if (BecStatus == 0x24000000) {
		// la3_data_in[29:26] = "1001" --- inv_w0(low)
		becAddres = 0x0FFC0000;
	} else if (BecStatus == 0x28000000) {
		// la3_data_in[29:26] = "1010" --- d(high)
		becAddres = 0x1FFC0000;
	} else if (BecStatus == 0x2C000000) {
		// la3_data_in[29:26] = "1011" --- d(low)
		becAddres = 0x3FFC0000;
	} else if (BecStatus == 0x30000000 ) {
		// la3_data_in[29:26] = "1100" --- key(high)
		becAddres = 0x7FFC0000;
	} else if (BecStatus == 0x34000000) {
		// la3_data_in[29:26] = "1101" --- key(low)
		becAddres = 0xFFFC0000;
	} else {
		// la3_data_in[29:26] = "0001" --- w0(high)
		becAddres = 0x00040000;	
	}
	reg_la2_data = 0;
	reg_la1_data = data_reg1;
	reg_la0_data = data_reg2;
	reg_la2_data = becAddres ^ data_reg0;

	// reg_la1_data = data_reg1;
	// reg_la2_data = becAddres ^ data_reg0;
}

static uint32_t write_data (int i) {
  while ((reg_la3_data_in & 0xFF000000 )!= 0x78000000) {
	// if (i == 0) {
		// Writing w1 register
		write_la(0, reg_la3_data_in, w1[0], w1[1], w1[2]);
		write_la(0, reg_la3_data_in, w1[3], w1[4], w1[5]);

		// Writing z1 register
		write_la(0, reg_la3_data_in, z1[0], z1[1], z1[2]);
		write_la(0, reg_la3_data_in, z1[3], z1[4], z1[5]);

		// Writing w2 register
		write_la(0, reg_la3_data_in, w2[0], w2[1], w2[2]);
		write_la(0, reg_la3_data_in, w2[3], w2[4], w2[5]);

		// Writing z2 register
		write_la(0, reg_la3_data_in, z2[0], z2[1], z2[2]);
		write_la(0, reg_la3_data_in, z2[3], z2[4], z2[5]);

		// Writing inv_w0 register
		write_la(0, reg_la3_data_in, inv_w0[0], inv_w0[1], inv_w0[2]);
		write_la(0, reg_la3_data_in, inv_w0[3], inv_w0[4], inv_w0[5]);

		// Writing d register
		write_la(0, reg_la3_data_in, d[0], d[1], d[2]);
		write_la(0, reg_la3_data_in, d[3], d[4], d[5]);
		// Writing key register
		write_la(i, reg_la3_data_in, k_array[i][0], k_array[i][1], k_array[i][2]);
		write_la(i, reg_la3_data_in, k_array[i][3], k_array[i][4], k_array[i][5]);
		break;
	// } else {
	// 	write_la(i, reg_la3_data_in, k_array[i][0], k_array[i][1], k_array[i][2]);
	// 	write_la(i, reg_la3_data_in, k_array[i][3], k_array[i][4], k_array[i][5]);
	// 	// break;
	// 	}
	}
}

static uint32_t read_data () {
	
	uint32_t reg_wout_0, reg_wout_1, reg_wout_2, reg_wout_3, reg_wout_4, reg_wout_5, reg_zout_0, reg_zout_1, reg_zout_2, reg_zout_3, reg_zout_4, reg_zout_5;
	while ((reg_la3_data_in & 0xC0000000) == 0xC0000000) {
		if ((reg_la3_data_in & 0xFF000000) == 0xC8000000) {
			reg_wout_3 = reg_la3_data_in & 0x0001FFFF;			// Take 81 bits
			reg_wout_4 = reg_la2_data_in;
			reg_wout_5 = reg_la1_data_in;

			reg_la0_data = 0xAB080000;
		} else if ((reg_la3_data_in & 0xFF000000) == 0xCC000000) {
			reg_zout_0 = reg_la3_data_in & 0x0003FFFF;
			reg_zout_1 = reg_la2_data_in;
			reg_zout_2 = reg_la1_data_in;

			reg_la0_data = 0xAB0C0000;
		} else if ((reg_la3_data_in & 0xFF000000) == 0xD0000000) {
			reg_zout_3 = reg_la3_data_in & 0x0001FFFF;			// Take 81 bits
			reg_zout_4 = reg_la2_data_in;
			reg_zout_5 = reg_la1_data_in;

			reg_la0_data = 0xAB100000;
			break;
		} else {
			reg_wout_0 = reg_la3_data_in & 0x0003FFFF;
			reg_wout_1 = reg_la2_data_in;
			reg_wout_2 = reg_la1_data_in;
			
			reg_la0_data = 0xAB040000;
		}
	}
	return reg_wout_0, reg_wout_1, reg_wout_2, reg_wout_3, reg_wout_4, reg_wout_5, reg_zout_0, reg_zout_1, reg_zout_2, reg_zout_3, reg_zout_4, reg_zout_5;
}