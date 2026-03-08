ASM=nasm
QEMU=qemu-system-i386

SRC=boot.asm
BIN=out/boot.bin
IMG=out/boot.img

all: $(IMG)

$(BIN): $(SRC)
	$(ASM) -f bin $(SRC) -o $(BIN)

$(IMG): $(BIN)
	dd if=/dev/zero of=$(IMG) bs=512 count=720
	dd if=$(BIN) of=$(IMG) conv=notrunc

run: $(IMG)
	$(QEMU) -rtc base=localtime -fda $(IMG)

clean:
	rm -f $(BIN) $(IMG)