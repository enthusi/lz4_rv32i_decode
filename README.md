# assembly RISCV RV32IC lz4 decoder
lz4 decoder for **RISCV RV32I** CPUs in *assembly* language\
pointer to packed data in `a0` on entry\
pointer to depack destination in `s0` on entry\
used: `a1,a2,a3,a4,a5,a6` for compliance with C-extension\
size *116 Bytes for RV32IC*
     *168 Bytes for RV32I*

Code assumes a 2 byte header (little endian size) and then \
the raw compressed BLOCK in lz4 format (up to 64 kB).\
Compressed for example with `lz4 -12 -B4` and header + tail cropped.\
(See Makefile).

## application in bare metal assembler
packedearth.asm is a bare metal assembly example for the Longan Nano.\
It displays an lz4 compressed image (160x80) of the earth map in 565 format (25.6 KB).\
Total size: *4624 Bytes.*\
![screenshot](http://martinwendt.de/earth2.png)

The decoder and example code assembles well with the wonderful [bronzebeard](https://github.com/theandrew168/bronzebeard).\

Licensed under the 3-Clause BSD License
Copyright 2021, Martin Wendt
