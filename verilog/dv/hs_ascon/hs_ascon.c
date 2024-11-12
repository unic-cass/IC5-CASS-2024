
#include <defs.h>
#include <stub.c>

void main()
{

	//reg_spimaster_control = 0xa002;	// Enable, prescaler = 2,
                                        // connect to housekeeping SPI

	reg_mprj_io_16 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_15 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_14 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_13 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_12 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_11 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_10 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_9  =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	
	reg_mprj_io_17 =  GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_18 =  GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_19 =  GPIO_MODE_USER_STD_OUTPUT;




	/* Apply configuration */
	reg_mprj_xfer = 1;
	while (reg_mprj_xfer == 1);

	reg_mprj_datal = 0xB4000000;
}

