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

static void print_hex(uint32_t data){
  char a;
  for (int i = 0; i < 8; ++i){
    a = (data >> ((7-i) << 2)) & 0xf;
    a = (a > 9) ? (a + 0x37) : (a+0x30);
    putchar(a);
  }
  putchar('\n');
}

#define reg_mprj_slave (*(volatile uint32_t*)0x30000000)

// --------------------------------------------------------
#define reg_mprj_vco_adc (*(volatile uint32_t*)0x30000004)
#define reg_mprj_status  (*(volatile uint32_t*)0x30000008)
#define reg_mprj_no_data (*(volatile uint32_t*)0x3000000C)

#define SHIFT_FACTOR(a) ((a & 0xf) << 25)
#define FILTER_EN	(1 << 24)
#define VCO_EN	(1 << 23)
#define CAPTURE_CONT	(1 << 22) // a= 0: stop after number of sample; a = 1: non-stop
#define NUM_SAMPLES(a)  ((a & 0xFFF) << 10)
#define OVERSAMPLE(a)   (((a-1) & 0x3FF))
#define VCO_ADC0_EN	(FILTER_EN | VCO_EN)
#define VCO_IDLE    0x0
#define VCO_WORKING 0x1
#define VCO_EMPTY   0x2
#define VCO_FULL    0x3

static uint32_t mprj_set_config(uint32_t enable, uint32_t ovs) {
  // enable sinc3
  uint32_t cfg = (enable << 31);
  cfg |= 1 << 26;
  cfg |= ovs & 0x3FF;
  // enable vco0

  return cfg;
}

static uint32_t read_data(uint32_t* data, int len) {
  for (int i = 0; i < len; ++i)
    data[i] = reg_mprj_vco_adc;
}
static uint32_t vco_data[128];

void main()
{
    // The upper GPIO pins are configured to be output
    // and accessble to the management SoC.
    // Used to flag the start/end of a test
    // The lower GPIO pins are configured to be output
    // and accessible to the user project.  They show
    // the project count value, although this test is
    // designed to read the project count through the
    // logic analyzer probes.
    // I/O 6 is configured for the UART Tx line
    reg_spi_enable = 1;
    reg_wb_enable = 1;
    
/*     reg_spimaster_config = 0xb002;      // Apply stream mode */

/* #ifdef USE_PLL */

/* #endif */

    reg_mprj_datal = 0x00000000;
    reg_mprj_datah = 0x00000000;

    reg_mprj_io_37 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_36 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_35 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_34 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_33 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_32 = GPIO_MODE_MGMT_STD_OUTPUT;

    reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_27 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_26 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;

    // analog_io 9-10
    reg_mprj_io_16 = GPIO_MODE_USER_STD_ANALOG;
    reg_mprj_io_17 = GPIO_MODE_USER_STD_ANALOG;
    // analog_io 12-13
    reg_mprj_io_20 = GPIO_MODE_USER_STD_ANALOG;
    reg_mprj_io_19 = GPIO_MODE_USER_STD_ANALOG;
    // analog_io 15-16
    reg_mprj_io_23 = GPIO_MODE_USER_STD_ANALOG;
    reg_mprj_io_22 = GPIO_MODE_USER_STD_ANALOG;

    /* Apply configuration */
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);
    /*
     *-------------------------------------------------------------
     * Register 2610_000c       reg_hkspi_pll_ena
     * SPI address 0x08 = PLL enables
     * bit 0 = PLL enable, bit 1 = DCO enable
     *
     * Register 2610_0010       reg_hkspi_pll_bypass
     * SPI address 0x09 = PLL bypass
     * bit 0 = PLL bypass
     *
     * Register 2610_0020       reg_hkspi_pll_source
     * SPI address 0x11 = PLL source
     * bits 0-2 = phase 0 divider, bits 3-5 = phase 90 divider
     *
     * Register 2610_0024       reg_hkspi_pll_divider
     * SPI address 0x12 = PLL divider
     * bits 0-4 = feedback divider
     *
     * Register 2620_0004       reg_clk_out_dest
     * SPI address 0x1b = Output redirect
     * bit 0 = trap to mprj_io[13]
     * bit 1 = clk  to mprj_io[14]
     * bit 2 = clk2 to mprj_io[15]
     *-------------------------------------------------------------
     */
    reg_hkspi_pll_ena = 0x1;
    reg_hkspi_pll_source = 0x33;
    reg_hkspi_pll_bypass = 0;
    reg_hkspi_pll_divider = 0x0c;

    reg_la0_oenb = reg_la0_iena = 0xFFFFFFFF;    // [31:0]

    // Flag start of the test
    reg_mprj_datal = 0xB4000000;

    reg_mprj_slave = SHIFT_FACTOR(10) | VCO_ADC0_EN | NUM_SAMPLES(2048) | OVERSAMPLE(500);
    while((reg_mprj_status & 0x1) != 0);
    // read until empty
    for (int i = 0; i < 1024; ++i){
      vco_data[0] = reg_mprj_vco_adc;
    }
    // reread the data memory
    //reg_mprj_slave = CLEAR_RPTR | NUM_SAMPLES(64) | OVERSAMPLE(16);
    //reg_mprj_slave = NUM_SAMPLES(64) | OVERSAMPLE(16);
    //for (int i = 0; i < 64; ++i)
    //  vco_data[0] = reg_mprj_vco_adc;

    /*
    // reset wptr & rptr
    reg_mprj_slave = (1<< 30) | (1 << 29) | (1 << 26) | 255;
    // sample again
    reg_mprj_slave = mprj_set_config(1, 255);
    while(((reg_mprj_status >> 1) & 0x1) == 0);
    // read until empty
    for (int i = 0; i < 16; ++i)
      vco_data[0] = reg_mprj_vco_adc;
    */
    // Flag end of the test
    reg_mprj_datal = 0xB9000000;
}
