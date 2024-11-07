/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include <defs.h>
#include <stub.c>
#include <../../../verilog/dv/la_bec/io_la.c>

void main()
{
	int j;
	uint32_t reg_wout_0, reg_wout_1, reg_wout_2, reg_wout_3, reg_wout_4, reg_wout_5, reg_zout_0, reg_zout_1, reg_zout_2, reg_zout_3, reg_zout_4, reg_zout_5;

	reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_27 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_26 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_23 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_22 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_21 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_20 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_19 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_18 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_17 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_16 = GPIO_MODE_MGMT_STD_OUTPUT;

	reg_mprj_io_15 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_14 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_13 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_12 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_11 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_10 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_9  = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_8  = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_7  = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_5  = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_4  = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_3  = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_2  = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_1  = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_0  = GPIO_MODE_USER_STD_OUTPUT;

	reg_mprj_io_6  = GPIO_MODE_MGMT_STD_OUTPUT;

	reg_uart_enable = 1;

	// Now, apply the configuration
	reg_mprj_xfer = 1;
	while (reg_mprj_xfer == 1);
	
	// Flag start of the test 
	reg_mprj_datal	=	reg_la0_data = 0xAB300000;

	for (uint32_t i = 0; i< 2; i++){
		reg_la0_data = 0xAB30FFFF;
		// Configure LA probes 2, 1, and 0 [95:0] as outputs from the cpu 
		// Configure LA probes 3 [127:96] as inputs to the cpu
		reg_la0_oenb = reg_la0_iena = 0xFFFFFFFF;    // [31:0]
		reg_la1_oenb = reg_la1_iena = 0xFFFFFFFF;    // [63:32]
		reg_la2_oenb = reg_la2_iena = 0xFFFFFFFF;    // [95:64]
		reg_la3_oenb = reg_la3_iena = 0x00000000;    // [127:96]
		// Write Process from Processor to BEC core (la3[31:30] = "01")
		reg_mprj_datal = 0xAB410000 ^ (i << 8);
		write_data(i);
		// break;
		
		while (reg_la3_data_in != 0x9C000000) {
			// Hold BEC wait until jump to `Proc` state
			reg_la2_data	= 	0x00000000;
			reg_la1_data	=	0x00000000;
			reg_la0_data 	=	0xAB410000;
		}

		while (reg_la3_data_in  == 0x9C000000) {
			// Inform processer being processing
			reg_mprj_datal = 0xAB420000 ^ (i << 8);
			// Configure LA probes 0 [31:0] as inputs to the cpu 
			// Configure LA probes 3, 2, and 1 [127:32] as output from the cpu
			reg_la0_oenb = reg_la0_iena = 0xFFFFFFFF;  // [31:0]
			reg_la1_oenb = reg_la1_iena = 0x00000000;  // [63:32]
			reg_la2_oenb = reg_la2_iena = 0x00000000;  // [95:64]
			reg_la3_oenb = reg_la3_iena = 0x00000000;  // [127:96]
			reg_la0_data =0xAB40FFFF; // Processor ready for read results from BEC 

		}
		reg_mprj_datal = 0xAB510000 ^ (i << 8);
		
		// reg_wout_0, reg_wout_1, reg_wout_2, reg_wout_3, reg_wout_4, reg_wout_5, reg_zout_0, reg_zout_1, reg_zout_2, reg_zout_3, reg_zout_4, reg_zout_5 = read_data();
		
		while ((reg_la3_data_in & 0xC0000000) == 0xC0000000) {
			if ((reg_la3_data_in & 0xFF000000) == 0xC8000000) {
				reg_wout_3 = reg_la3_data_in & 0x0003FFFF;			// Take 81 bits
				reg_wout_4 = reg_la2_data_in;
				reg_wout_5 = reg_la1_data_in;

				reg_la0_data = 0xAB080000;
			} else if ((reg_la3_data_in & 0xFF000000) == 0xCC000000) {
				reg_zout_0 = reg_la3_data_in & 0x0001FFFF;
				reg_zout_1 = reg_la2_data_in;
				reg_zout_2 = reg_la1_data_in;

				reg_la0_data = 0xAB0C0000;
			} else if ((reg_la3_data_in & 0xFF000000) == 0xD0000000) {
				reg_zout_3 = reg_la3_data_in & 0x0003FFFF;			// Take 81 bits
				reg_zout_4 = reg_la2_data_in;
				reg_zout_5 = reg_la1_data_in;

				reg_la0_data = 0xAB100000;
				break;
			} else {
				reg_wout_0 = reg_la3_data_in & 0x0001FFFF;
				reg_wout_1 = reg_la2_data_in;
				reg_wout_2 = reg_la1_data_in;
				
				reg_la0_data = 0xAB040000;
			}
		}

		while (1){
			reg_la0_data = 0xAB500000;
			if ((reg_wout_0 == wA_array[i][0]) & (reg_wout_1 == wA_array[i][1]) & (reg_wout_2 == wA_array[i][2]) & (reg_wout_3 == wA_array[i][3]) & (reg_wout_4 == wA_array[i][4]) & (reg_wout_5 == wA_array[i][5])){
				reg_mprj_datal = 0xAB430000 ^ (i << 8);
				reg_la0_data = reg_wout_0;
			} else {
				reg_mprj_datal = 0xAB440000 ^ (i << 8);
				reg_la0_data = reg_wout_0;
			}
			break;
		}
		while (reg_la3_data_in ^ 0xFF000000 == 0xC400000) {
			reg_la0_data = 0xAB500000;
			// if (reg_la3_data_in == 0x40000000)
			break;
		}
		// reg_mprj_datal = 0xAB510000;
	}
	reg_mprj_datal = 0xABFF0000;
}