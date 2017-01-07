#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <inttypes.h>
#include <linux/i2c-dev.h>
#include <unistd.h>
#include <sys/ioctl.h>

float fetch(int ADS_ADDRESS, const char * dev_name){

//    const char * dev_name = "/dev/i2c-1";
    int i2c_file;

    uint8_t write_buf[3];
    uint8_t read_buf[2];

    i2c_file = open(dev_name, O_RDWR);

    if (i2c_file == -1){
        perror(dev_name);
        exit(1);
    }
    
    if (ioctl(i2c_file, I2C_SLAVE, ADS_ADDRESS) < 0){
        perror("failed to acquire bus access and/or talk to slave");
        exit(1);
    }

    write_buf[0] = 1;
    write_buf[1] = 0xC3;
    write_buf[2] = 0x03;

    read_buf[0]= 0;        
    read_buf[1]= 0;
    
    if (write(i2c_file, write_buf, 3) != 3){
        perror("failed to write to the i2c bus");
        exit(1);
    }

    while ((read_buf[0] & 0x80) == 0){
        read(i2c_file, read_buf, 2);
    }

    write_buf[0] = 0;
    write(i2c_file, write_buf, 1);

    read(i2c_file, read_buf, 2);

    int16_t result = read_buf[0] << 8 | read_buf[1];
  
    close(i2c_file);

    return (float)result * 4.096/32767.0;
}

MODULE = RPi::ADS1x15  PACKAGE = RPi::ADS1x15

PROTOTYPES: DISABLE


float
fetch (ADS_ADDRESS, dev_name)
	int	ADS_ADDRESS
    const char * dev_name
