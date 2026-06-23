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

#define BIT_MAX_12 1650
#define BIT_MAX_16 26400

// Per-conversion i2c retry cap. The Pi bus intermittently throws transient
// errors (e.g. EREMOTEIO); we retry the conversion rather than abort, but bail
// loudly if the bus is persistently unresponsive.
#define MAX_I2C_ATTEMPTS 1000

int fetch(int addr, char * dev, char * wbuf1, char * wbuf2, int res, int samples){

    uint8_t write_buf[3];
    uint8_t read_buf[2];

    if (samples < 1){
        samples = 1;
    }

    int i2c_file = open(dev, O_RDWR);

    if (i2c_file == -1){
        perror(dev);
        exit(1);
    }

    if (ioctl(i2c_file, I2C_SLAVE, addr) < 0){
        perror("failed to acquire bus access and/or talk to slave");
        exit(1);
    }

    // Average `samples` single-shot conversions, returning the mean. The i2c
    // device is opened once for the whole batch (the open/ioctl/close dominate
    // the per-conversion cost), so averaging N samples here is far cheaper than
    // taking N separate single reads. Averaging in the raw conversion domain is
    // exact: the volts/percent scaling that the callers apply is linear.

    long sum = 0;

    for (int s = 0; s < samples; s++){

        int16_t conversion = 0;
        int got = 0;
        int attempts = 0;

        // Acquire one conversion, retrying on a transient i2c error rather than
        // aborting. Averaging many conversions makes a single bus glitch likely,
        // and a conversion-ready poll must tolerate the odd failed read; we only
        // bail (loudly) if the bus stays unresponsive past MAX_I2C_ATTEMPTS.

        while (! got){

            if (++attempts > MAX_I2C_ATTEMPTS){
                fprintf(stderr, "fetch: i2c bus unresponsive after %d attempts\n",
                        attempts);
                exit(1);
            }

            write_buf[0] = 1; // set pointer to config register
            write_buf[1] = strtol(wbuf1, NULL, 0);
            write_buf[2] = strtol(wbuf2, NULL, 0);

            read_buf[0] = 0;
            read_buf[1] = 0;

            if (write(i2c_file, write_buf, 3) != 3){
                continue;
            }

            // AND with 10000000 and wait for bit 15 of the config register to
            // go false. This bit stores the "conversion complete" indicator.

            int ready = 1;

            while ((read_buf[0] & 0x80) == 0){
                if (read(i2c_file, read_buf, 2) != 2){
                    ready = 0;
                    break;
                }
            }

            if (! ready){
                continue;
            }

            // 0: conversion register
            // 1: configuration register

            write_buf[0] = 0;
            if (write(i2c_file, write_buf, 1) != 1){
                continue;
            }

            if (read(i2c_file, read_buf, 2) != 2){
                continue;
            }

            conversion = read_buf[0] << 8 | read_buf[1];

            if (res == 12){
                conversion = conversion >> 4;
            }

            got = 1;
        }

        sum += conversion;
    }

    close(i2c_file);

    return (int)(sum / samples);
}

float voltage_c (int addr, char * dev, char * wbuf1, char * wbuf2, int res, int samples){

    int conversion = fetch(addr, dev, wbuf1, wbuf2, res, samples);

    float volts;

    if (res == 12){
        volts = (float)conversion * 4.096 / 2048.0;
    }
    else {
        volts = (float)conversion * 4.096 / 32767.0;
    }

    return volts;
}

int raw_c (int addr, char * dev, char * wbuf1, char * wbuf2, int res, int samples){

    int conversion = fetch(addr, dev, wbuf1, wbuf2, res, samples);

    return conversion;
}

float percent_c (int addr, char * dev, char * wbuf1, char * wbuf2, int res, int samples){

    int conversion = fetch(addr, dev, wbuf1, wbuf2, res, samples);

    float percent;

    if (res == 12){
        percent = (float)conversion / BIT_MAX_12 * 100;
    }
    else {
        percent = (float)conversion / BIT_MAX_16 * 100;
    }

    return percent;
}

MODULE = RPi::ADC::ADS  PACKAGE = RPi::ADC::ADS

PROTOTYPES: DISABLE

int
fetch (addr, dev, wbuf1, wbuf2, res, samples)
    int addr
    char * dev
    char * wbuf1
    char * wbuf2
    int res
    int samples

float
voltage_c (addr, dev, wbuf1, wbuf2, res, samples)
    int addr
    char * dev
    char * wbuf1
    char * wbuf2
    int res
    int samples

int
raw_c (addr, dev, wbuf1, wbuf2, res, samples)
    int addr
    char * dev
    char * wbuf1
    char * wbuf2
    int res
    int samples

float
percent_c (addr, dev, wbuf1, wbuf2, res, samples)
    int addr
    char * dev
    char * wbuf1
    char * wbuf2
    int res
    int samples
