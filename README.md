# assembly RISCV RV32IC lz4 decoder
lz4 decoder for **RISCV RV32I** CPUs in *assembly* language\
pointer to packed data in `a0` on entry\
pointer to depack destination in `s0` on entry\
used: `a1,a2,a3,a4,a5,a6` for compliance with C-extension\
size *116 Bytes for RV32IC*\
     *168 Bytes for RV32I*

Code assumes a 2 byte header (little endian size) and then \
the raw compressed BLOCK in lz4 format (up to 64 kB).\
Compressed for example with `lz4 -12 -B4` and header + tail cropped.\
(See Makefile).

Now it is even listed on the official [LZ4 page](http://lz4.github.io/lz4/). ;-)\
Another bare metal example is here: [mandelbrot in under 1kb](https://github.com/enthusi/mandelbrot_riscv_assembler).
## application in bare metal assembler
`packedearth.asm` is a bare metal assembly example for the Longan Nano.\
It displays an lz4 compressed image (160x80) of the earth map in 565 format (25.6 KB).\
Total size: *4624 Bytes.*\
![screenshot](http://martinwendt.de/earth2.png)
 
The decoder and example code assembles well with the wonderful [bronzebeard](https://github.com/theandrew168/bronzebeard).
### usage
```
make
make flash
```
### including in own code
You can of course either assemble the source as you need or even simply include the 
binary 'blob' `lz4depack.bin` at any arbitrary position (aligned to 16bit with C extention).

The routine uses only relative short jumps and is therefore fully relocatable even in binary form.\
It simply requires `a0` and `a1` to be set before call. `a1,a2,a3,a4,a5,a6,t0` are used and NOT saved.

### Assemble with GCC instead of Bronzebeard
As kindly suggested by [brucehoult](https://github.com/brucehoult)
you can make the register defines gcc/gas compatible:
```
perl -pe 's/^\s*([a-z_]+)\s*=\s*([a-zA-Z0-9]+)(\s*#.*)?$/#define $1 $2/' lz4depack.asm >lz4depack.S
```
Then assemble, using the C preprocessor:
```
riscv64-unknown-elf-gcc -march=rv32ic -mabi=ilp32 lz4depack.S -c
``
And check the code using riscv64-unknown-elf-size or riscv64-unknown-elf-objdump

Licensed under the 3-Clause BSD License
Copyright 2021, Martin Wendt

