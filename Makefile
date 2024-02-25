export BUILD := build
export SRC := src
export BINARY := $(BUILD)/linked.o
export ARMIPS ?= armips
export ROM_CODE := AGFE
export LD := arm-none-eabi-ld
export CC := arm-none-eabi-gcc

export INCLUDE := -I gs_headers/build/include -I $(SRC) -I .

export AS := -mthumb
export CFLAGS := -O2 -Wall -mthumb $(INCLUDE) -mcpu=arm7tdmi -march=armv4t -mthumb-interwork -fno-builtin -mlong-calls -fdiagnostics-color -fcall-used-r4
export LDFLAGS := -T linker.ld -T gs_headers/build/linker/AGFE.ld -r
export DEPDIR = .d
export DEPFLAGS = -MT $@ -MMD -MP -MF $(DEPDIR)/$*.Td

rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

# SRC Code
C_SRC=$(call rwildcard,$(SRC),*.c)
S_SRC=$(call rwildcard,$(SRC),*.s)

# Binaries
C_OBJ=$(C_SRC:%=%.o)
S_OBJ=$(S_SRC:%=%.o)

OBJECTS=$(addprefix $(BUILD)/,$(C_OBJ) $(S_OBJ))

.PHONY: all clean

all: main.s $(BINARY) $(call rwildcard,patches,*.s)
	@echo "\e[1;32mCreating ROM\e[0m"
	@$(ARMIPS) main.s

clean:
	rm -rf build

$(BINARY): $(OBJECTS)
	@echo "\e[1;32mLinking ELF binary $@\e[0m"
	@$(LD) $(LDFLAGS) -o $@ $^

$(BUILD)/%.c.o: %.c $(DEPDIR)/%.d
	@echo "\e[32mCompiling $<\e[0m"
	@mkdir -p $(@D)
	@mkdir -p $(DEPDIR)/$<
	@$(CC) $(DEPFLAGS) $(CFLAGS) -c $< -o $@
	@mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d

$(BUILD)/%.s.o: %.s
	@echo "\e[32mAssembling $<\e[0m"
	@mkdir -p $(@D)
	@$(AS) $(ASFLAGS) $< -o $@

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d
-include $(patsubst %,$(DEPDIR)/%.d,$(basename $(C_SRC)))