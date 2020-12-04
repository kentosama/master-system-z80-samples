####################################
# Makefile for SMS Hello World!
# Date: November 22, 2020
# Author: Jacques Belosoukinski <kentosama>
# Github: https://github.com/kentosama
###################################

# Recursive wildcard
rwildcard = $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

ASM=wla-z80
LD=wlalink
OUT_DIR=out
CPUS?=$(shell nproc)
MAKEFLAGS:=--jobs=$(CPUS)

SRC_DIR:=src
SRC:=$(wildcard $(SRC_DIR)/*.asm)
SRC_EXTRA_C:= $(wildcard $(SRC_DIR)/**/*.asm)
SRC+= $(SRC_EXTRA_C)

OBJ:=$(SRC:.asm=.rel)
OBJS:=$(addprefix $(OUT_DIR)/, $(OBJ))

BIN=helloworld.sms
EMULATOR=blastem

release: prebuild $(OUT_DIR)/$(BIN) postbuild

all: release

.PHONY: clean

run: release
	$(EMULATOR) $(OUT_DIR)/$(BIN)

prebuild:
	@mkdir -p $(OUT_DIR)
	@echo -e '[objects]' > $(OUT_DIR)/tmp
	@echo -e $(OBJS) >> $(OUT_DIR)/tmp

postbuild:
	

clean:
	@rm -f $(OUT_DIR)/tmp
	@rm -rf $(OUT_DIR)/$(SRC_DIR)
	
$(OUT_DIR)/$(BIN): $(OBJS)
	$(LD) -v -r $(OUT_DIR)/tmp $(OUT_DIR)/$(BIN)

	
$(OUT_DIR)/%.rel: %.asm
	@mkdir -p $(@D)
	$(ASM) -o $@ $^
	
