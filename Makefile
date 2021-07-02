SOURCE=packedearth
ASM=bronzebeard --compress
DFU=python3 -m bronzebeard.dfu 28e9:0189
PACKER=lz4depack

$(SOURCE).bin: $(SOURCE).asm earth2prep.dat
	$(ASM)  $(SOURCE).asm -o $(SOURCE).bin
	
lz4:	$(PACKER).asm
	$(ASM) $(PACKER).asm -o $(PACKER).bin
	
flash: $(SOURCE).bin
	$(DFU) $(SOURCE).bin

earth2prep.dat: earth2.png PNG888to565.py rawlz4.py
	python  PNG888to565.py earth2.png earth2.bin
	lz4 -f -12 -B4 earth2.bin earth2.lz4
	python rawlz4.py earth2.lz4
