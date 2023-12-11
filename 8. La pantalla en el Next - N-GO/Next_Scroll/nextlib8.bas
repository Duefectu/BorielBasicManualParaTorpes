' vim:ts=4:et:
' ---------------------------------------------------------
' NextLib v8 - David Saphier / em00k 2022
' Help and thanks Boriel, Flash, Baggers, Britlion, Shiru, Mike Daily 
' Matt Davies for help on the fastPLotL2 
' ---------------------------------------------------------

#ifndef __NEXTLIB__
#define __NEXTLIB__

#pragma push(case_insensitive)
#pragma case_insensitive = TRUE
#pragma zxnext = TRUE

' the following consts are courtesy of ped7g  https://github.com/ped7g/SpecBong/blob/master/constants.i.asm
asm 
BIT_UP			equ 4	; 16
BIT_DOWN		equ 5	; 32
BIT_LEFT		equ 6	; 64
BIT_RIGHT		equ 7	; 128

DIR_NONE		equ %00000000
DIR_UP			equ %00010000
DIR_DOWN		equ %00100000
DIR_LEFT		equ %01000000
DIR_RIGHT		equ %10000000

DIR_UP_I		equ %11101111
DIR_DOWN_I		equ %11011111
DIR_LEFT_I		equ %10111111
DIR_RIGHT_I		equ %01111111

;-----------------------------------------------------------------------------
;-- I/O ports - ZX Spectrum classic (48, 128, Timex, Pentagon, ...) ports

ULA_P_FE                        equ $FE     ; BORDER + MIC + BEEP + read Keyboard
TIMEX_P_FF                      equ $FF     ; Timex video control port

ZX128_MEMORY_P_7FFD             equ $7FFD   ; ZX Spectrum 128 ports
ZX128_MEMORY_P_DFFD             equ $DFFD
ZX128P3_MEMORY_P_1FFD           equ $1FFD

AY_REG_P_FFFD                   equ $FFFD
AY_DATA_P_BFFD                  equ $BFFD

Z80_DMA_PORT_DATAGEAR           equ $6B     ; on ZXN the zxnDMA handles this in zxnDMA mode
Z80_DMA_PORT_MB02               equ $0B     ; on ZXN the zxnDMA handles this in Zilog mode

DIVMMC_CONTROL_P_E3             equ $E3
SPI_CS_P_E7                     equ $E7
SPI_DATA_P_EB                   equ $EB

KEMPSTON_MOUSE_X_P_FBDF         equ $FBDF
KEMPSTON_MOUSE_Y_P_FFDF         equ $FFDF
KEMPSTON_MOUSE_B_P_FADF         equ $FADF   ; kempston mouse wheel+buttons

KEMPSTON_JOY1_P_1F              equ $1F
KEMPSTON_JOY2_P_37              equ $37

;-----------------------------------------------------------------------------
;-- I/O ports - ZX Spectrum NEXT specific ports

TBBLUE_REGISTER_SELECT_P_243B   equ $243B
    ; -- port $243B = 9275  Read+Write (detection bitmask: %0010_0100_0011_1011)
    ;   -- selects NextREG mapped at port TBBLUE_REGISTER_ACCESS_P_253B

TBBLUE_REGISTER_ACCESS_P_253B   equ $253B
    ; -- port $253B = 9531  Read?+Write? (detection bitmask: %0010_0101_0011_1011)
    ;   -- data for selected NextREG (read/write depends on the register selected)

; indexes into DAC_CHANNEL_* def-arrays, depending on the type of DAC you want to use
DAC_GS_COVOX_INDEX              equ     1
DAC_PENTAGON_ATM_INDEX          equ     2
DAC_SPECDRUM_INDEX              equ     3
DAC_SOUNDRIVE1_INDEX            equ     4
DAC_SOUNDRIVE2_INDEX            equ     5
DAC_COVOX_INDEX                 equ     6
DAC_PROFI_COVOX_INDEX           equ     7
    ; -- enable 8bit DACs with PERIPHERAL_3_NR_08, use DAC_*_INDEX to access particular set of ports
    ;DEFARRAY    DAC_CHANNEL_A  @@,  @@, $FB, $DF, $1F, $F1,  @@, $3F
    ;DEFARRAY    DAC_CHANNEL_B  @@, $B3,  @@,  @@, $0F, $F3, $0F,  @@
    ;DEFARRAY    DAC_CHANNEL_C  @@, $B3,  @@,  @@, $4F, $F9, $4F,  @@
    ;DEFARRAY    DAC_CHANNEL_D  @@,  @@, $FB, $DF, $5F, $FB,  @@, $5F
    ; -- like for example: ld bc,DAC_CHANNEL_B[DAC_PROFI_COVOX_INDEX]

I2C_SCL_P_103B                  equ $103B   ; i2c bus port (clock) (write only?)
I2C_SDA_P_113B                  equ $113B   ; i2c bus port (data) (read+write)
UART_TX_P_133B                  equ $133B   ; UART tx port (read+write)
UART_RX_P_143B                  equ $143B   ; UART rx port (read+write)
UART_CTRL_P_153B                equ $153B   ; UART control port (read+write)

ZILOG_DMA_P_0B                  equ $0B
ZXN_DMA_P_6B                    equ $6B
    ; -- port $6B = 107 Read+Write (detection bitmask: %xxxx_xxxx_0110_1011)
    ;   - The zxnDMA is mostly compatible with Zilog DMA chip (Z8410) (at least
    ;     as far as old ZX apps are concerned), but has many modifications.
    ;   - core3.1.1 update - Zilog/zxnDMA mode is now selected by port number, not PERIPHERAL_2_NR_06!
    ;   - core3.0 update - (REMOVED) specific behaviour details can be selected (PERIPHERAL_2_NR_06)

LAYER2_ACCESS_P_123B            equ $123B
    ; -- port $123B = 4667 Read+Write (detection bitmask: %0001_0010_0011_1011)
    ;   - see ports.txt or wiki for details (has become a bit more complex over time)

LAYER2_ACCESS_WRITE_OVER_ROM    equ $01     ; map Layer2 bank into ROM area (0000..3FFF) for WRITE-only (reads as ROM)
LAYER2_ACCESS_L2_ENABLED        equ $02     ; enable Layer2 (make banks form nextreg $12 visible)
LAYER2_ACCESS_READ_OVER_ROM     equ $04     ; map Layer2 bank into ROM area (0000..3FFF) for READ-only
LAYER2_ACCESS_SHADOW_OVER_ROM   equ $08     ; bank selected by bits 6-7 is from "shadow Layer 2" banks range (nextreg $13)
LAYER2_ACCESS_BANK_OFFSET       equ $10     ; bit 2-0 is bank offset for current active mapping +0..+7 (other bits are reserved, use 0)
LAYER2_ACCESS_OVER_ROM_BANK_M   equ $C0     ; (mask of) value 0..3 selecting bank mapped for R/W (Nextreg $12 or $13)
LAYER2_ACCESS_OVER_ROM_BANK_0   equ $00     ; screen lines 0..63    (256x192) or columns 0..63    (320x256) or columns 0..127   (640x256)
LAYER2_ACCESS_OVER_ROM_BANK_1   equ $40     ; screen lines 64..127  (256x192) or columns 64..127  (320x256) or columns 128..255 (640x256)
LAYER2_ACCESS_OVER_ROM_BANK_2   equ $80     ; screen lines 128..191 (256x192) or columns 128..191 (320x256) or columns 256..383 (640x256)
LAYER2_ACCESS_OVER_ROM_48K      equ $C0     ; maps all 0..191 lines into $0000..$BFFF region (256x192) or 2/3 of columns in 320x256/640x256

SPRITE_STATUS_SLOT_SELECT_P_303B    equ $303B
    ; -- port $303B = 12347  Read+Write (detection bitmask: %0011_0000_0011_1011)
    ;   -- write:
    ;     - sets both "sprite slot" (0..63) and "pattern slot" (0..63 +128)
    ;     - once the sprite/pattern slots are set, they act independently and
    ;     each port ($xx57 and $xx5B) will auto-increment its own slot index
    ;     (to resync one can write to this port again).
    ;     - the +128 flag will make the pattern upload start at byte 128 of pattern
    ;     slot (second half of slot)
    ;     - The sprite-slot (sprite-attributes) may be optionally interlinked with
    ;     NextReg $34 (feature controlled by NextReg $34)
    ;     - auto-increments of slot position from value 63 are officially
    ;     "undefined behaviour", wrap to 0 is not guaranteed. (only setting slots
    ;     explicitly back to valid 0..63 will make your code future-proof)
    ;   -- read (will also reset both collision and max-sprites flags):
    ;     - bit 1 = maximum sprites per line hit (set when sprite renderer ran
    ;               out of time when preparing next scanline)
    ;     - bit 0 = collision flag (set when any sprites draw non-transparent
    ;               pixel at the same location)
    ;     Both flags contain values for current scanline already at the beginning
    ;     of scanline (sprite engine renders one line ahead into buffer and updates
    ;     flags progressively as it renders the sprites)
SPRITE_STATUS_MAXIMUM_SPRITES   equ $02
SPRITE_STATUS_COLLISION         equ $01
SPRITE_SLOT_SELECT_PATTERN_HALF equ 128     ; add it to 0..63 index to make pattern upload start at second half of pattern

SPRITE_ATTRIBUTE_P_57           equ $57
    ; -- port $xx57 = 87 write-only (detection bitmask: %xxxx_xxxx_0101_0111)
    ;  - writing 4 or 5 bytes long structures to control particular sprite
    ;  - after 4/5 bytes block the sprite slot index is auto-incremented
    ;  - for detailed documentation check official docs or wiki (too long)

SPRITE_PATTERN_P_5B             equ $5B
    ; -- port $xx5B = 91 write-only (detection bitmask: %xxxx_xxxx_0101_1011)
    ;  - each pattern slot is 256 bytes long = one 16x16 pattern of 8-bit pixels
    ;    or two 16x16 patterns of 4-bit pixels.
    ;  - Patterns are uploaded in "English" order (left to right, top to bottom),
    ;    one byte encodes single pixel in 8 bit mode and two pixels in 4 bit
    ;    mode (bits 7-4 are "left" pixel, 3-0 are "right" pixel)
    ;  - pixels are offset (index) into active sprite palette

TURBO_SOUND_CONTROL_P_FFFD      equ $FFFD   ; write with bit 7 = 1 (port shared with AY)

;-----------------------------------------------------------------------------
;-- NEXT HW Registers (NextReg)
MACHINE_ID_NR_00                equ $00
NEXT_VERSION_NR_01              equ $01
NEXT_RESET_NR_02                equ $02
MACHINE_TYPE_NR_03              equ $03
ROM_MAPPING_NR_04               equ $04     ;In config mode, allows RAM to be mapped to ROM area.
PERIPHERAL_1_NR_05              equ $05     ;Sets joystick mode, video frequency and Scandoubler.
PERIPHERAL_2_NR_06              equ $06     ;Enables turbo/50Hz/60Hz keys, DivMMC, Multiface and audio (beep/AY)
TURBO_CONTROL_NR_07             equ $07
PERIPHERAL_3_NR_08              equ $08     ;ABC/ACB Stereo, Internal Speaker, SpecDrum, Timex Video Modes, Turbo Sound Next, RAM contention and [un]lock 128k paging.
PERIPHERAL_4_NR_09              equ $09     ;Sets scanlines, AY mono output, Sprite-id lockstep, disables Kempston and divMMC ports.
PERIPHERAL_5_NR_0A              equ $0A     ;Mouse buttons and DPI settings (core 3.1.5)
NEXT_VERSION_MINOR_NR_0E        equ $0E
ANTI_BRICK_NR_10                equ $10
VIDEO_TIMING_NR_11              equ $11
LAYER2_RAM_BANK_NR_12           equ $12     ;bank number where visible Layer 2 video memory begins.
LAYER2_RAM_SHADOW_BANK_NR_13    equ $13     ;bank number for "shadow" write-over-rom mapping
GLOBAL_TRANSPARENCY_NR_14       equ $14     ;Sets the color treated as transparent for ULA/Layer2/LoRes
SPRITE_CONTROL_NR_15            equ $15     ;LoRes mode, Sprites configuration, layers priority
    ; bit 7: enable LoRes mode
    ; bit 6: sprite rendering (1=sprite 0 on top of other, 0=sprite 0 at bottom)
    ; bit 5: If 1, the clipping works even in "over border" mode
    ; 4-2: layers priority: 000=SLU, 001=LSU, 010=SUL, 011=LUS, 100=USL, 101=ULS, 110=S,mix(U+L), 111=S,mix(U+L-5)
    ; bit 1: enable sprites over border, bit 0: show sprites
LAYER2_XOFFSET_NR_16            equ $16
LAYER2_YOFFSET_NR_17            equ $17
CLIP_LAYER2_NR_18               equ $18
CLIP_SPRITE_NR_19               equ $19
CLIP_ULA_LORES_NR_1A            equ $1A
CLIP_TILEMAP_NR_1B              equ $1B
CLIP_WINDOW_CONTROL_NR_1C       equ $1C     ;set to 15 to reset all clip-window indices to 0
VIDEO_LINE_MSB_NR_1E            equ $1E
VIDEO_LINE_LSB_NR_1F            equ $1F
VIDEO_INTERUPT_CONTROL_NR_22    equ $22     ;Controls the timing of raster interrupts and the ULA frame interrupt.
VIDEO_INTERUPT_VALUE_NR_23      equ $23
ULA_XOFFSET_NR_26               equ $26     ;since core 3.0
ULA_YOFFSET_NR_27               equ $27     ;since core 3.0
HIGH_ADRESS_KEYMAP_NR_28        equ $28     ;reads first 8b part of value written to $44 (even unfinished 16b write)
LOW_ADRESS_KEYMAP_NR_29         equ $29
HIGH_DATA_TO_KEYMAP_NR_2A       equ $2A
LOW_DATA_TO_KEYMAP_NR_2B        equ $2B
DAC_B_MIRROR_NR_2C              equ $2C     ;reads as MSB of Pi I2S left side sample, LSB waits at $2D
DAC_AD_MIRROR_NR_2D             equ $2D     ;another alias for $2D, reads LSB of value initiated by $2C or $2E read
SOUNDDRIVE_DF_MIRROR_NR_2D      equ $2D     ;Nextreg port-mirror of port 0xDF
DAC_C_MIRROR_NR_2E              equ $2E     ;reads as MSB of Pi I2S right side sample, LSB waits at $2D
TILEMAP_XOFFSET_MSB_NR_2F       equ $2F
TILEMAP_XOFFSET_LSB_NR_30       equ $30
TILEMAP_YOFFSET_NR_31           equ $31
LORES_XOFFSET_NR_32             equ $32
LORES_YOFFSET_NR_33             equ $33
SPRITE_ATTR_SLOT_SEL_NR_34      equ $34     ;Sprite-attribute slot index for $35-$39/$75-$79 port $57 mirrors
SPRITE_ATTR0_NR_35              equ $35     ;port $57 mirror in nextreg space (accessible to copper)
SPRITE_ATTR1_NR_36              equ $36
SPRITE_ATTR2_NR_37              equ $37
SPRITE_ATTR3_NR_38              equ $38
SPRITE_ATTR4_NR_39              equ $39
PALETTE_INDEX_NR_40             equ $40     ;Chooses a ULANext palette number to configure.
PALETTE_VALUE_NR_41             equ $41     ;Used to upload 8-bit colors to the ULANext palette.
PALETTE_FORMAT_NR_42            equ $42     ;ink-mask for ULANext modes
PALETTE_CONTROL_NR_43           equ $43     ;Enables or disables ULANext interpretation of attribute values and toggles active palette.
PALETTE_VALUE_9BIT_NR_44        equ $44     ;Holds the additional blue color bit for RGB333 color selection.
TRANSPARENCY_FALLBACK_COL_NR_4A equ $4A     ;8-bit colour to be drawn when all layers are transparent
SPRITE_TRANSPARENCY_I_NR_4B     equ $4B     ;index of transparent colour in sprite palette (only bottom 4 bits for 4-bit patterns)
TILEMAP_TRANSPARENCY_I_NR_4C    equ $4C     ;index of transparent colour in tilemap graphics (only bottom 4 bits)
MMU0_0000_NR_50                 equ $50     ;Set a Spectrum RAM page at position 0x0000 to 0x1FFF
MMU1_2000_NR_51                 equ $51     ;Set a Spectrum RAM page at position 0x2000 to 0x3FFF
MMU2_4000_NR_52                 equ $52     ;Set a Spectrum RAM page at position 0x4000 to 0x5FFF
MMU3_6000_NR_53                 equ $53     ;Set a Spectrum RAM page at position 0x6000 to 0x7FFF
MMU4_8000_NR_54                 equ $54     ;Set a Spectrum RAM page at position 0x8000 to 0x9FFF
MMU5_A000_NR_55                 equ $55     ;Set a Spectrum RAM page at position 0xA000 to 0xBFFF
MMU6_C000_NR_56                 equ $56     ;Set a Spectrum RAM page at position 0xC000 to 0xDFFF
MMU7_E000_NR_57                 equ $57     ;Set a Spectrum RAM page at position 0xE000 to 0xFFFF
COPPER_DATA_NR_60               equ $60
COPPER_CONTROL_LO_NR_61         equ $61
COPPER_CONTROL_HI_NR_62         equ $62
COPPER_DATA_16B_NR_63           equ $63     ; same as $60, but waits for full 16b before write
VIDEO_LINE_OFFSET_NR_64         equ $64     ; (core 3.1.5)
ULA_CONTROL_NR_68               equ $68
DISPLAY_CONTROL_NR_69           equ $69
LORES_CONTROL_NR_6A             equ $6A
TILEMAP_CONTROL_NR_6B           equ $6B
TILEMAP_DEFAULT_ATTR_NR_6C      equ $6C
TILEMAP_BASE_ADR_NR_6E          equ $6E     ;Tilemap base address of map
TILEMAP_GFX_ADR_NR_6F           equ $6F     ;Tilemap definitions (graphics of tiles)
LAYER2_CONTROL_NR_70            equ $70
LAYER2_XOFFSET_MSB_NR_71        equ $71     ; for 320x256 and 640x256 L2 modes (core 3.0.6+)
SPRITE_ATTR0_INC_NR_75          equ $75     ;port $57 mirror in nextreg space (accessible to copper) (slot index++)
SPRITE_ATTR1_INC_NR_76          equ $76
SPRITE_ATTR2_INC_NR_77          equ $77
SPRITE_ATTR3_INC_NR_78          equ $78
SPRITE_ATTR4_INC_NR_79          equ $79
USER_STORAGE_0_NR_7F            equ $7F
EXPANSION_BUS_ENABLE_NR_80      equ $80
EXPANSION_BUS_CONTROL_NR_81     equ $81
INTERNAL_PORT_DECODING_0_NR_82  equ $82     ;bits 0-7
INTERNAL_PORT_DECODING_1_NR_83  equ $83     ;bits 8-15
INTERNAL_PORT_DECODING_2_NR_84  equ $84     ;bits 16-23
INTERNAL_PORT_DECODING_3_NR_85  equ $85     ;bits 24-31
EXPANSION_BUS_DECODING_0_NR_86  equ $86     ;bits 0-7 mask
EXPANSION_BUS_DECODING_1_NR_87  equ $87     ;bits 8-15 mask
EXPANSION_BUS_DECODING_2_NR_88  equ $88     ;bits 16-23 mask
EXPANSION_BUS_DECODING_3_NR_89  equ $89     ;bits 24-31 mask
EXPANSION_BUS_PROPAGATE_NR_8A   equ $8A     ;Monitoring internal I/O or adding external keyboard
ALTERNATE_ROM_NR_8C             equ $8C     ;Enable alternate ROM or lock 48k ROM
ZX_MEM_MAPPING_NR_8E            equ $8E     ;shortcut to set classic zx128+3 memory model at one place
PI_GPIO_OUT_ENABLE_0_NR_90      equ $90     ;pins 0-7
PI_GPIO_OUT_ENABLE_1_NR_91      equ $91     ;pins 8-15
PI_GPIO_OUT_ENABLE_2_NR_92      equ $92     ;pins 16-23
PI_GPIO_OUT_ENABLE_3_NR_93      equ $93     ;pins 24-27
PI_GPIO_0_NR_98                 equ $98     ;pins 0-7
PI_GPIO_1_NR_99                 equ $99     ;pins 8-15
PI_GPIO_2_NR_9A                 equ $9A     ;pins 16-23
PI_GPIO_3_NR_9B                 equ $9B     ;pins 24-27
PI_PERIPHERALS_ENABLE_NR_A0     equ $A0
PI_I2S_AUDIO_CONTROL_NR_A2      equ $A2
;PI_I2S_CLOCK_DIVIDE_NR_A3       equ $A3    ; REMOVED in core 3.1.5 (no more master-mode)
ESP_WIFI_GPIO_OUTPUT_NR_A8      equ $A8
ESP_WIFI_GPIO_NR_A9             equ $A9
EXTENDED_KEYS_0_NR_B0           equ $B0     ;read Next compound keys as standalone keys (outside of zx48 matrix)
EXTENDED_KEYS_1_NR_B1           equ $B1     ;read Next compound keys as standalone keys (outside of zx48 matrix)
;DIVMMC_TRAP_ENABLE_1_NR_B2      equ $B2    ; NOT IMPLEMENTED in core yet (as of 3.1.4), may happen in future
;DIVMMC_TRAP_ENABLE_2_NR_B4      equ $B4    ; NOT IMPLEMENTED in core yet (as of 3.1.4), may happen in future
DEBUG_LED_CONTROL_NR_FF         equ $FF     ;Turns debug LEDs on and off on TBBlue implementations that have them.

;-----------------------------------------------------------------------------
;-- common memory addresses
MEM_ROM_CHARS_3C00              equ $3C00   ; actual chars start at $3D00 with space
MEM_ZX_SCREEN_4000              equ $4000
MEM_ZX_ATTRIB_5800              equ $5800
MEM_LORES0_4000                 equ $4000
MEM_LORES1_6000                 equ $6000
MEM_TIMEX_SCR0_4000             equ $4000
MEM_TIMEX_SCR1_6000             equ $6000

;-----------------------------------------------------------------------------
;-- Copper commands
COPPER_NOOP                     equ %00000000
COPPER_WAIT_H                   equ %10000000
COPPER_HALT_B                   equ $FF   ; 2x $FF = wait for (511,63) = infinite wait

;-----------------------------------------------------------------------------
; DMA (Register 6)
DMA_RESET					equ $C3
DMA_RESET_PORT_A_TIMING		equ $C7
DMA_RESET_PORT_B_TIMING		equ $CB
DMA_LOAD					equ $CF
DMA_CONTINUE				equ $D3
DMA_DISABLE_INTERUPTS		equ $AF
DMA_ENABLE_INTERUPTS		equ $AB
DMA_RESET_DISABLE_INTERUPTS	equ $A3
DMA_ENABLE_AFTER_RETI		equ $B7
DMA_READ_STATUS_BYTE		equ $BF
DMA_REINIT_STATUS_BYTE		equ $8B
DMA_START_READ_SEQUENCE		equ $A7
DMA_FORCE_READY				equ $B3
DMA_DISABLE					equ $83
DMA_ENABLE					equ $87
DMA_READ_MASK_FOLLOWS		equ $BB
end asm 

#define NextReg(REG,VAL) \
	ASM\
	DW $91ED\
	DB REG\
	DB VAL\
	END ASM 
	
#define OUTINB \
	Dw $90ED

#define BREAK \
	DB $c5,$DD,$01,$0,$0,$c1 \
	
#define BBREAK \
	ASM\
	BREAK\
	END ASM 
	
#define MUL_DE \
	DB $ED,$30\

#define SWAPNIB \
	DB $ED,$23

#define ADD_HL_A \
		DB $ED,$31\

#define PIXELADD \
		DB $ED,$94\

#define SETAE \
		DB $ED,$95\

#define PIXELDN \
		DB $ED,$93\


#define TEST val \
		DB $ED,$27\
		DB val

#define ADDBC value \
		DB $ED,$36\
		DW value

#define ADDHLA \
		DB $ED,$31\

#define ADDDEA \
		DB $ED,$32\

#define ADDBCA \
		DB $ED,$33\

#define PUSHD value \
		DB $ED,$8A\
		DW value 
		
#define DIHALT \
		ASM\
		di\
		halt\
		end asm 

#define nnextreg reg,value\
		ASM\
		dw $92ed\
		db reg\
		db value\
		end asm\

#define nextregna reg \
		dw $92ed \
		db reg 

#define ESXDOS \
		rst 8 	

#define getreg(REG) \
	db $3e,REG,$01,$3b,$24,$ed,$79,$04,$ed,$78	

#define ReenableInts \
	ld a,(.itbuff) : or a : jr z,$+3 : ei 		


#define EnableSFX \
	asm : ld a,1 : ld (sfxenablednl),a : end asm 


#define DisableSFX \
	asm : xor a : ld (sfxenablednl),a : end asm 

#define EnableMusic \
	asm : ld a,1 : ld (sfxenablednl+1),a : end asm 

#define DisableMusic \
	asm : ld a,2 : ld (sfxenablednl+1),a : end asm 




asm 
	M_GETSETDRV			equ $89
	F_OPEN     			equ $9a
	F_CLOSE    			equ $9b
	F_READ     			equ $9d
	F_WRITE    			equ $9e
	F_SEEK     			equ $9f
	F_STAT				equ $a1 
	F_SIZE				equ $ac
	FA_READ     		equ $01
	FA_APPEND   		equ $06
	FA_OVERWRITE		equ $0C
	LAYER2_ACCESS_PORT 	EQU $123B
end asm 

'border 0 : paper 0: ink 7 : cls 
 
Sub MMU8(byval nn as ubyte, byval na as ubyte)
	asm 	
		PROC 
			LOCAL NREG
			LD 		a,(IX+5)		; slot
			add 	a,$50			; NextREG $50 - $57 for slot 
			ld 		(NREG),a		; store at NREG 
			LD 		a,(IX+7)		; get memory bank selected
			DW 		$92ED			; lets select correctly slot 
			NREG: 	DB 0			; 
		ENDP 
	end asm 
end sub 

Sub fastcall MMU8new(byval slot as ubyte, byval memorybank as ubyte)
	' changes 8kb  slots valid slots 0-7 mapped as below 
	' banks 16 - 223
	' Area       16k 8k def 
	' $0000-$1fff	1	 0	ROM		ROM (255)				Normally ROM. Writes mappable by layer 2. IRQ and NMI routines here.
	' $2000-$3fff		 1				ROM (255)			Normally ROM. Writes mapped by Layer 2.
	' $4000-$5fff	2	 2	5			10					Normally used for normal/shadow ULA screen.
	' $6000-$7fff		 3				11					Timex ULA extended attribute/graphics area.
	' $8000-$9fff	3	 4	2			4					Free RAM.
	' $a000-$bfff		 5				5					Free RAM.
	' $c000-$dfff	4	 6	0			0					Free RAM. Only this area is remappable by 128 memory management.
	' $e000-$ffff		 7	1								Free RAM. Only this area is remappable by 128 memory management.
	'
	' 16kb  	8kb 
	' 8-15		16-31		$060000-$07ffff	128K	Extra RAM
	' 16-47		32-95		$080000-$0fffff	512K	1st extra IC RAM (available on unexpanded Next)
	' 48-79		96-159	$100000-$17ffff	512K	2nd extra IC RAM (only available on expanded Next)
	' 80-111	160-223	$180000-$1fffff	512K	3rd extra IC RAM (only available on expanded Next)'
	' Fastcall a is first param, next on stack 
	asm 	
		;; break 
		PROC 
			LOCAL 	NREG
			add 	a,$50			; A= 1st param so add $50 for MMU $50-$57
			ld 		(NREG),a		; store at NREG 
			pop 	de				; dont need this but need off the stack 
			pop 	af 				; get second param in af, this will be the bank
			DW 		$92ED			; lets select correctly slot 
		NREG: 		DB 0			; 
			push 	de 				; fix stack before leaving
		ENDP 
	end asm 
end sub 

Sub fastcall MMU16(byval memorybank as ubyte)
	' changes 16kb 128k style bank @ $c000, supports full ram
	' now works slots 6 and 7 will be changed 
		' asm 
		' ; bank 16-31 32-95 96-159 169-223 
		' ;; break 	

		' ld d,a				; 4
		' AND %00000111 ; 4
		' ld bc,$7ffd		; 10 
		' out (c),a			; 12 
		' ;and 248
		' ;ld (23388),a 
		' ld a,d				; 4 
		' AND %11110000 ; 4
		' SWAPNIB				; 16
		' ld b,$df		 	; 7
		' out (c),a			; 12 = 73 t states								
		
		' end asm 
' old routine before optimization 
' 		; bank 16-31 32-95 96-159 169-223 
	asm 
		ld 		a,(IX+5)			; 19 ts
		AND 	%00000111 			; 4
		ld 		bc,$7ffd			; 10 
		out 	(c),a				; 12 
		ld 		a,(IX+5)			; 19 
		AND 	%11110000 			; 4
		srl 	a 					; 8 
		srl 	a					; 8
		srl 	a					; 8 
		srl 	a					; 8 
		ld 		bc,$dffd 			; 10 
		out 	(c),a				; 12 = 122
	end asm 

end sub  

Function fastcall GetMMU(byval slot as ubyte) as ubyte 
	asm 
		ld 		bc,$243B			; Register Select 
		add 	a,$50				; a = slot already so add $50 for slot regs 
		out		(c),a				; 
		ld 		bc,$253B			; reg access 
		in 		a,(c)
	end asm 
END function 	


function fastcall checkints() as ubyte 
asm 
	PROC 
	LOCAL start, intsdisable
    start:    
        ; Detect if interrupts were enabled 
        ; The value of IFF2 is copied to the P/V flag by LD A,I and LD A,R.
		ex 		af,af'
        ld 		a,i 
        ld 		a,r 
        jp 		po,intsdisable 
        ld 		a,1              ; ints on 
        ld 		(itbuff),a
		ex 		af,af'
        ret 
    intsdisable:
        xor 	a               ; ints off 
        ld 		(itbuff),a    
		ex 		af,af'
        ret 
	ENDP 
    itbuff:
        db 0 
end asm 
end function

Function GetReg(byval slot as ubyte) as ubyte 
	asm 	
		push 	bc 
		ld 		bc,$243B			; Register Select 
		out		(c),a				; 
		
		inc 	b  
		in 		a,(c)
		pop 	bc 
	end asm 
END function  

sub Debug(BYVAL x as UBYTE,byval y as ubyte, s as string)
	' fast print, doesnt need the print library '
	asm 
	PROC 
		;; break 
		ld 		l,(IX+8)  						; address string start containing string size  
		ld 		h,(IX+9)
		push 	hl  							; save this 
		ld 		b,0 							; flatten b 
		ld 		c,(hl)							; first byte is length of string
		push 	bc 								; save it 
		CHAN_OPEN		EQU 5633
		ld 		a,2								; upper screen
		call 	CHAN_OPEN						; get the channel sorted
		ld 		a,22							; AT 
		rst 	16								; print 
		ld 		a,(IX+5)						; x
		rst 	16
		ld 		a,(IX+7)						; y 
		rst 	16
		pop 	bc								; pop back length 
		pop 	de 								; pop back start 
		inc 	de 
		inc 	de 
		call 	8252							; use rom print 

	ENDP 
	end asm 
end sub  
	
sub fastcall ShowLayer2(byval switch as ubyte)
	' 0 to disable layer 2 
	' 1 to enable layer 2 
	asm 
		PROC 
		LOCAL disable 
		or 		a
		jr 		z,disable
		nextreg $69,%10000000
		ret
	disable:
		nextreg $69,0
		ENDP 
	end asm 
end sub 

Sub fastcall ScrollLayer(byval x as ubyte,byval y as ubyte)
	asm 
		PROC 
		pop 	hl 					; store ret address 
		nextreg $16,a				; a has x 
		pop 	af 
		nextreg $17,a 				; now a as y 
		push 	hl 
		ENDP
	end asm
end sub 

SUB fastcall PlotL2(byVal X as ubyte, byval Y as ubyte, byval T as ubyte)

ASM 
		; PlotL2 (c) 2020 David Saphier / em00k 
	PROC 
		LOCAL skip_wrap1, .no_wrap
		; call 	_checkints
		; di
		; BREAK 	 
		pop  	hl      ; save return address off stack 
		; pop 	de 
		ld   	e,a     ; put a into e
		ld   	bc,LAYER2_ACCESS_PORT
		pop  	af      ; pop stack into a = Y 
		ld   	d,a     ; put into d
		and  	$c0     ; yy00 0000
	;	cp 		$c0
	;	jr 		z,.skip_wrap1
	;	jr 		.no_wrap
	;	xor 	a
	skip_wrap1:
	;	pop 	af
	;	jr 		skip_wrap2
	.no_wrap:
		ENDP 
	end asm 
LayerShadow:
	asm 
		or   	3       ; yy00 0011
		out  	(c),a   ; select 8k-bank    
		ld   	a,d     ; yyyy yyyy
		and  	63      ; 00yy yyyy	
		ld   	d,a
		pop 	af      ; get colour/map value off stack 
		ld  	(de),a   ; set pixel value
	skip_wrap2:	
		ld   	a,2     ; 0000 0010
		out  	(c),a   ; Layer2 writes off 
		push 	hl      ; restore return address
		; ReenableInts
		; ei
  END ASM 
end sub    


SUB fastcall PlotL2Shadow(byVal X as ubyte, byval Y as ubyte, byval T as ubyte)
	asm 
    	ld   	bc,LAYER2_ACCESS_PORT
    	pop  	hl      ; save return address 
    	ld   	e,a     ; put a into e
    	pop  	af      ; pop stack into a 
    	ld   	d,a     ; put into d
    	and  	192     ; yy00 0000
    	or   	1       ; yy00 0011
    	out  	(c),a   ; select 8k-bank    
    	ld   	a,d     ; yyyy yyyy
    	and  	63      ; 00yy yyyy
    	ld   	d,a
    	pop  	af      ; get colour/map value 
    	ld   	(de),a   ; set pixel value
    	ld   	a,0     ; 0000 0010
    	out  	(c),a   ; select ROM?
    	push 	hl      ; restore return address
	end asm 
end sub   

SUB fastcall CIRCLEL2(byval x as ubyte, byval y as ubyte, byval radius as ubyte, byval col as ubyte)

ASM
		;; break 
		PROC
		LOCAL __CIRCLEL2_LOOP
		LOCAL __CIRCLEL2_NEXT
		LOCAL __circle_col
		LOCAL circdone
		pop ix 		; return address off stack 
		ld e,a 		; x 
		pop af 
		ld d,a 
		pop af
		ld h,a
		pop af 
		ld (__circle_col+1),a
		
CIRCLEL2:
; __FASTCALL__ Entry: D, E = Y, X point of the center
; A = Radious
__CIRCLEL2:
		push de	
		;ld h,a
		ld a, h
		exx
		pop de		; D'E' = x0, y0
		ld h, a		; H' = r

		ld c, e
		ld a, h
		add a, d
		ld b, a
		call __CIRCLEL2_PLOT	; PLOT (x0, y0 + r)

		ld b, d
		ld a, h
		add a, e
		ld c, a
		call __CIRCLEL2_PLOT	; PLOT (x0 + r, y0)

		ld c, e
		ld a, d
		sub h
		ld b, a
		call __CIRCLEL2_PLOT ; PLOT (x0, y0 - r)

		ld b, d
		ld a, e
		sub h
		ld c, a
		call __CIRCLEL2_PLOT ; PLOT (x0 - r, y0)

		exx
		ld b, 0		; B = x = 0
		ld c, h		; C = y = Radius
		ld hl, 1
		or a
		sbc hl, bc	; HL = f = 1 - radius

		ex de, hl
		ld hl, 0
		or a
		sbc hl, bc  ; HL = -radius
		add hl, hl	; HL = -2 * radius
		ex de, hl	; DE = -2 * radius = ddF_y, HL = f

		xor a		; A = ddF_x = 0
		ex af, af'	; Saves it

__CIRCLEL2_LOOP:
		ld a, b
		cp c
		jp nc,circdone		; Returns when x >= y

		bit 7, h	; HL >= 0? : if (f >= 0)...
		jp nz, __CIRCLEL2_NEXT

		dec c		; y--
		inc de
		inc de		; ddF_y += 2

		add hl, de	; f += ddF_y

__CIRCLEL2_NEXT:
		inc b		; x++
		ex af, af'
		add a, 2	; 1 Cycle faster than inc a, inc a

		inc hl		; f++
		push af
		add a, l
		ld l, a
		ld a, h
		adc a, 0	; f = f + ddF_x
		ld h, a
		pop af
		ex af, af'

		push bc	
		exx
		pop hl		; H'L' = Y, X
		
		ld a, d
		add a, h
		ld b, a		; B = y0 + y
		ld a, e
		add a, l
		ld c, a		; C = x0 + x
		call __CIRCLEL2_PLOT ; plot(x0 + x, y0 + y)

		ld a, d
		add a, h
		ld b, a		; B = y0 + y
		ld a, e
		sub l
		ld c, a		; C = x0 - x
		call __CIRCLEL2_PLOT ; plot(x0 - x, y0 + y)

		ld a, d
		sub h
		ld b, a		; B = y0 - y
		ld a, e
		add a, l
		ld c, a		; C = x0 + x
		call __CIRCLEL2_PLOT ; plot(x0 + x, y0 - y)

		ld a, d
		sub h
		ld b, a		; B = y0 - y
		ld a, e
		sub l
		ld c, a		; C = x0 - x
		call __CIRCLEL2_PLOT ; plot(x0 - x, y0 - y)
		
		ld a, d
		add a, l
		ld b, a		; B = y0 + x
		ld a, e	
		add a, h
		ld c, a		; C = x0 + y
		call __CIRCLEL2_PLOT ; plot(x0 + y, y0 + x)
		
		ld a, d
		add a, l
		ld b, a		; B = y0 + x
		ld a, e	
		sub h
		ld c, a		; C = x0 - y
		call __CIRCLEL2_PLOT ; plot(x0 - y, y0 + x)

		ld a, d
		sub l
		ld b, a		; B = y0 - x
		ld a, e	
		add a, h
		ld c, a		; C = x0 + y
		call __CIRCLEL2_PLOT ; plot(x0 + y, y0 - x)

		ld a, d
		sub l
		ld b, a		; B = y0 - x
		ld a, e	
		sub h
		ld c, a		; C = x0 + y
		call __CIRCLEL2_PLOT ; plot(x0 - y, y0 - x)

		exx
		jp __CIRCLEL2_LOOP

__CIRCLEL2_PLOT:
		
		push de
		push af
		ld  e,c     ; put b into e x
		ld  d,b     ; put c into d y
		ld a,d
		ld  bc,$123B
		and 192     ; yy00 0000
		or  3       ; yy00 0011
		out (c),a   ; select 8k-bank    
		ld  a,d     ; yyyy yyyy
		and 63      ; 00yy yyyy
		ld  d,a
__circle_col:
		ld 	a,255
		ld  (de),a   ; set pixel value
		ld  a,2     ; 0000 0010
		out (c),a   ; select ROM?
		
		pop af 
		pop de
		ret 
circdone:
		push ix 
	;	; break 		
		ENDP
END ASM 
end sub 

Sub fastcall NextRegA(reg as ubyte,value as ubyte)
	asm 
		PROC
		LOCAL 	reg
		ld 		(reg),a			; 17 
		pop 	hl 				; 10 
		pop 	af				; 10 
		DW $92ED 				; 20
	reg:	
		db 		0
		push 	hl 				; 11 		68 T (old 75t)
		ENDP 
	end asm
end sub 

sub fastcall swapbank(byVal bank as ubyte)
	asm
		; classic 128k paging 
		di					; disable ints
		ld 		e,a
		lD 		a,(23388)
		AND 	248
		OR 		e 			; select bank e
		LD 		BC,32765 
		LD 		(23388),A
		OUT 	(C),A
		EI
	END ASM 
end sub 

SUB zx7Unpack(source as uinteger, dest AS uinteger)
	' dzx7 by einar saukas et al '
	' source address, destination address 
	ASM 
	;	push hl
	;	push ix
	;	LD L, (IX+4)
	;	LD H, (IX+5)
		LD E, (IX+6)
		LD D, (IX+7)	
		call dzx7_turbo

		jp zx7end
				
		dzx7_turbo:
		ld      a, $80
		dzx7s_copy_byte_loop:
		ldi                             ; copy literal byte
		dzx7s_main_loop:
		call    dzx7s_next_bit
		jr      nc, dzx7s_copy_byte_loop ; next bit indicates either literal or sequence

		; determine number of bits used for length (Elias gamma coding)
		push    de
		ld      bc, 0
		ld      d, b
		dzx7s_len_size_loop:
		inc     d
		call    dzx7s_next_bit
		jr      nc, dzx7s_len_size_loop

		; determine length
		dzx7s_len_value_loop:
		call    nc, dzx7s_next_bit
		rl      c
		rl      b
		jr      c, dzx7s_exit           ; check end marker
		dec     d
		jr      nz, dzx7s_len_value_loop
		inc     bc                      ; adjust length

		; determine offset
		ld      e, (hl)                 ; load offset flag (1 bit) + offset value (7 bits)
		inc     hl
		defb    $cb, $33                ; opcode for undocumented instruction "SLL E" aka "SLS E"
		jr      nc, dzx7s_offset_end    ; if offset flag is set, load 4 extra bits
		ld      d, $10                  ; bit marker to load 4 bits
		dzx7s_rld_next_bit:
		call    dzx7s_next_bit
		rl      d                       ; insert next bit into D
		jr      nc, dzx7s_rld_next_bit  ; repeat 4 times, until bit marker is out
		inc     d                       ; add 128 to DE
		srl	d			; retrieve fourth bit from D
		dzx7s_offset_end:
		rr      e                       ; insert fourth bit into E

		; copy previous sequence
		ex      (sp), hl                ; store source, restore destination
		push    hl                      ; store destination
		sbc     hl, de                  ; HL = destination - offset - 1
		pop     de                      ; DE = destination
		ldir
		dzx7s_exit:
		pop     hl                      ; restore source address (compressed data)
		jr      nc, dzx7s_main_loop
		dzx7s_next_bit:
		add     a, a                    ; check next bit
		ret     nz                      ; no more bits left?
		ld      a, (hl)                 ; load another group of 8 bits
		inc     hl
		rla
		ret
		zx7end:
	;	pop ix
	;	pop hl
	END ASM 
	
end sub

Sub InitSprites(byVal Total as ubyte, spraddress as uinteger, bank as uinteger=0)
	' uploads sprites from memory location to sprite memory 
	' Total = number of sprites, spraddess memory address 
	' works for both 8 and 4 bit sprites 
	asm  

		ld 		d,(IX+5)													; d = Total sprites to upload
		
		xor 	a 															; clear a to 0 and point to 
		ld 		bc, SPRITE_STATUS_SLOT_SELECT_P_303B						; first sprite 
		out 	(c), a

		; let check if a bank was set ? 
		

		ld 		b,d															; how many sprites to send 

		ld 		l, (IX+6)													; hl = spraddress 
		ld 		h, (IX+7)

	sploop:

		push 	bc
		ld 		bc,$005b					
		otir
		pop 	bc 
		djnz 	sploop

	end asm 

end sub 

Sub fastcall InitSprites2(byVal Total as ubyte, spraddress as uinteger,bank as ubyte=$0)
    ' uploads sprites from memory location to sprite memory 
    ' Total = number of sprites, spraddess memory address, optinal bank parameter to page into slot 0/1 
    ' works for both 8 and 4 bit sprites 

    asm  
        PROC
        LOCAL spr_nobank, spr_address, sploop, sp_out
        
        ; ; break 
        ld      (spr_address+1), hl                                         ; save spr_address  16 T    3bytes 
        exx     
        pop     hl
        exx                                                                 ; save ret address  18 T  3bytes , 36 T with exx : push hl : exx   

        ld      d, a                                                        ; save Total sprites from a to d 

        xor 	a 															; clear a to 0 and point to 
        ld 		bc, SPRITE_STATUS_SLOT_SELECT_P_303B						; first sprite 
        out 	(c), a

        ; let check if a bank was set ? 
        inc     sp 
        inc     sp 
        pop     af                                                          ; bank in a  
        or      a   
        jr      z,spr_nobank                                                ; is it bank zero then skip over 
        nextreg $50,a                                                       ; setting slot 0 to a bank  
        inc     a 
        nextreg $51,a                                                       ; setting slot 1 to a bank + 1 

    spr_nobank:

        ld 		b,d															; how many sprites to send 

    spr_address: 
        ld      hl,0                                                        ; smc from above 

    sploop:                                                                 ; sprite upload loop 

        push 	bc
        ld 		bc,$005b					
        otir
        pop 	bc 
        djnz 	sploop

        nextreg $50, $FF                                                    ; restore rom 
        nextreg $51, $FF                                                    ; restore rom 

    sp_out:
        exx    
        push    hl 
        exx 
        
        ENDP 

    end asm 

end sub

sub RemoveSprite(spriteid AS UBYTE, visible as ubyte)
	
	asm 

		push 	bc 
		ld 		a,(IX+5)				; get ID spriteid
		ld 		bc, $303b				; selct sprite  
		out 	(c), a
		ld 		bc, $57					; sprite port  

		; REM now send 4 bytes 

		xor 	a 						; get x and send byte 1
		out 	(c), a          		;   X POS 
		out 	(c), a          		;   X POS
		out 	(c), a 
		ld 		a,(IX+7)				; Sprite visible and show pattern #0 byte 4
		out 	(c), a
		pop 	bc 

	end asm 

end sub 	      

sub UpdateSprite(ByVal x AS uinteger,ByVal y AS UBYTE,ByVal spriteid AS UBYTE,ByVal pattern AS UBYTE,ByVal mflip as ubyte,ByVal anchor as ubyte)
	'                  5                    7              9                     11                   13				   15						17			
	'  http://devnext.referata.com/wiki/Sprite_Attribute_Upload
	'  Uploads attributes of the sprite slot selected by Sprite Status/Slot Select ($303B). 
	' Attributes are in 4 byte blocks sent in the following order; after sending 4 bytes the address auto-increments to the next sprite. 
	' This auto-increment is independent of other sprite ports. The 4 bytes are as follows:

	' Byte 1 is the low bits of the X position. Legal X positions are 0-319 if sprites are allowed over the border or 32-287 if not. The MSB is in byte 3.
	' Byte 2 is the Y position. Legal Y positions are 0-255 if sprites are allowed over the border or 32-223 if not.
	' Byte 3 is bitmapped:

	' Bit	Description
	' 4-7	Palette offset, added to each palette index from pattern before drawing
	' 3	Enable X mirror
	' 2	Enable Y mirror
	' 1	Enable rotation
	' 0	MSB of X coordinate
	' Byte 4 is also bitmapped:
	' 
	' Bit	Description
	' 7	Enable visibility
	' 6	Reserved
	' 5-0	Pattern index ("Name")

	ASM 
		;				
		;				X   Y ID  Pa 
		;			   45   7  9  11 13 15
		;				0   1  0  3  2  4
		; UpdateSprite(32 ,32 ,1 ,1 ,0 ,6<<1)
		ld a,(IX+9)			;19						; get ID spriteid
		ld bc, $303b		;10						; selct sprite slot 
		; sprite 
		out (c), a			;12
		
		ld bc, $57			;10						; sprite control port 
		ld a,(IX+4) 		;19						; attr 0 = x  (msb in byte 3)
		out (c), a          ;12			
		
		ld a,(IX+7)			;19						; attr 1 = y  (msb in optional byte 5)
		out (c), a 			;12
		
		ld d,(IX+13)		;19						; attr 2 = now palette offset and no rotate and mirrors flags send  byte 3 and the MSB of X 
		;or (IX+5)			;19	
		
		ld a,(IX+5)			;19						; msb of x 
		and 1				;7
		or d 				;4
		out (c), a 			;12					; attr 3 
		
		
		ld a,(IX+11)		;19						; attr 4 = Sprite visible and show pattern
		or 192 				;7						; bit 7 for visibility bit 6 for 4 bit 	

		out (c), a			;12
		ld a,(IX+15)		;19						; attr 5 the sub-pattern displayed is selected by "N6" bit in 5th sprite-attribute byte.
		out (c), a			;12 					; att 
		; 243 T 	
	END ASM 
end sub

sub LoadBMPOld(byval fname as STRING)

		dim pos as ulong
		
		pos = 1024+54+16384*2

		asm 
				ld a,1
				ld (loadbank),a
				DW $91ed,$2456
				DW $91ed,$2557
		keeploading:

		end asm 
		'
		
		LoadSD(fname, $c000, $4000, pos)                 'dump its contents to the screen
		pos=pos-16384
	
		asm 
				
				ld bc, $123b
				ld a,(loadbank)
				or %00000001
				out (c),a
				ld	bc,$4000		;we need to copy it backwards
				ld	hl,$FFFF		;start at $ffff
				ld c,64 			; 64 lines per third 
				ld de,255			; start top right 
		ownlddr:
				ld b,0				; b=256 loops 
		innderlddr:
				
				ld a,(hl)			
				ld (de),a 			; put a in (de)
				;and %00000101		; for border effect 
				;out ($fe),a
				
				dec hl 				; dec hl and de 
				dec de 					
				djnz innderlddr		; has b=0 again?
				inc d 				; else inc d 256*2
				inc d 			
				dec bc				; dec bc b=0 if we're here 
				ld a,b				; a into b 
				or c				; or outer loop c with a
				jp nz,ownlddr		; both a and c are not zero 

				ld a, 0				; enable write  
				ld bc, $123b 		; set port for writing	
				out (c), a
				
				ld a,(loadbank)
				add a,$40
				ld (loadbank),a
				cp $c1
				jp nz,keeploading
				
				jp endingn
		loadbank:
				db 0
		endingn:
				ld a,0
				ld (loadbank),a 
				Dw $91ed,$0056
				Dw $91ed,$0157
		end asm
		
end sub 

sub LoadBMP(byval fname as STRING)

	'dim pos as ulong
	
	'pos = 1024+54+16384*2

	asm 
		PROC 
		LOCAL outstack, eosadd, outbank, tstack, loadbmploop, flip_layer2lines, copyloop, decd
		LOCAL startoffset, L2offsetpos, thandle, offset, loadbmpend
			call _checkints
			di 
			;ld (outstack+1),sp
			;ld sp,tstack
			push ix  
			getreg($52)						; a = current $4000 bank 
			ld (outbank+3),a 					; 
			ld a,(IX+7)
			ld (flip),a 
			;
			; hl address 
			ld a,(hl)
			add hl,2 
			push hl		
			add hl,a 
			ld (eosadd+1),hl
			ld a,(hl)
			ld (eosadd+4),a  
			ld (hl),0 
			pop ix 

			;xor a		
			;rst $08
			;db $89					; M_GETSETDRV equ $89
			ld a, '*' 						; use current drive

			ld b, FA_READ 					; set mode
			ESXDOS : db F_OPEN 	
			; a = handle 	
			ld (thandle),a 	
			getreg($12) 						; get L2 start 
			add a,a 	
			ld (startbank),a 					; start bank of L2 
			ld b,7							; loops 8 times 
			ld c,a 
		
loadbmploop:
			ld a,c							; get the bank in c and put in a 
			nextreg $52,a					; set mmu slot 2 to bank L2bank ($4000-5fff)
			inc c	
			push bc 
			
			; now seek 
			ld a,(thandle)
			ld ixl,0 
			ld l,0 
			ld bc,0
			ld de,(L2offsetpos)
			ESXDOS : db F_SEEK
			
			; now read 
			ld a,(thandle)
			ld ix,$4000
			ld bc,$2000
			ESXDOS : db F_READ 
			
			;ld a,(flip)
			;or a 
			call flip_layer2lines
			
			ld hl,(L2offsetpos)
			ld de,$2000	
			sbc hl,de
			ld (L2offsetpos),hl
			
			pop bc 
			djnz loadbmploop 
			
			ld a,(thandle)
			ESXDOS : db F_CLOSE
			
			ld hl,startoffset
			ld (L2offsetpos),hl 
			
outbank:
			nextreg $52,0
eosadd:
			ld hl,000
			ld (hl),0 
			pop ix 
outstack: 
			;ld sp,0
			ReenableInts
			jp loadbmpend

flip_layer2lines:
	
			; $4000 - $5fff Layer2 BMP data loaded 
			; the data is upside down so we need to flip line 0 - 32
			; hl = top line first left pixel, de = bottom line, first left pixel 
			ld hl,$4000 : ld de,$5f00 : ld bc,$1000
	
copyloop:	
			ld a,(hl)						; hl is the top lines, get the value into a
			ex af,af'						; swap to shadow a reg 
			ld a,(de)						; de is bottom lines, get value in a 
			ld (hl),a						; put this value into hl 
			ex af,af'						; swap back shadow reg 
			ld (de),a 						; put the value into de 
			inc hl							; inc hl to next byte 
			inc e							; only inc e as we have to go left to right then up with d 
			call z,decd					; it did do we need to dec d 
			dec bc							; dec bc for our loop 
			ld a,b							; has bc = 0 ?
			or c
			jr nz,copyloop					; no carry on until it does 
			
			ret 
decd:
			dec d 							; this decreases d to move a line up 
			ret					

startoffset equ 1078+16384+16384+8192		
		
L2offsetpos:
			dw startoffset
	
startbank:
			db 32
			ds 8
tstack: 
			db 0 
flip: 		db 0 
			
thandle:
			db 0 
offset:	
			dw 0 
loadbmpend:
		ENDP 
	end asm 
			
end sub 

Function ReserveBank() as ubyte 
	' This routine requests a free memory bank from NextZXOS APU
	' If NextZXOS is not running it will send back 223
	asm 
		reservebank:
			ld 		hl,$0001  	; H=banktype (ZX=0, 1=MMC); L=reason (1=allocate)
			exx
			ld 		c,7 			; RAM 7 required for most IDEDOS calls
			ld 		de,$01bd 	; IDE_BANK
			rst 	$8:defb $94 ; M_P3DOS
			jp 		nc,failed
			ld 		a,e 
			jr 		notfailed
		bank:
			db 		223
		failed:				; added this for when working in CSpect in
			ld 		a,255

		notfailed:					
	end asm 				
end function				
				

sub FreeBank(bank as ubyte)
	' marks a memory bank as freed that was reserved with ReserveBank()
	asm 		
freebank:	
			ld 		hl,$0003  	; H=banktype (ZX=0, 1=MMC); L=reason (3=release)
			ld 		e,a
			exx
			ld 		c,7 		; RAM 7 required for most IDEDOS calls
			ld 		de,$01bd 	; IDE_BANK
			rst $8	
			defb 	$94 		; M_P3DOS
			; jr notfailed
	end asm 
end sub  

#ifndef NEX
Sub LoadSDBank(byval filen as String,ByVal address as uinteger,ByVal length as uinteger,ByVal offset as ulong, bank as ubyte)
	'filen = "myfile.bin"
	'address = address to load to must be $0  
	'length to load, set to 0 to autodetect 
	'offset into file 
	'bank
	'; current slots 2 is stored 
	'; bank is paged into slot 2
	'; will continue to loop and increase bank every 8kb 
	'; uses string in ram passed so doesnt need to copy the fname 

		
		asm 		;en00k 2020 / David Saphier	
		PROC
		LOCAL initdrive, filehandle, error, mloop, fileseek
		LOCAL loadsdout, filesize, printrst, failed, slot6
		LOCAL fixstring, offset

		call _checkints
		di
		
		ld d,(IX+5) : ld e,(IX+4) : ex de,hl		; this gets the string sent
		ld a,(hl) : ld b,a : add hl,2 
		ld (nameaddress),hl 
		
		push hl 									; start of dtring in memory 
		add hl,a : ld a,(hl) : ld (hl),0 			; ensures end is zero 
		ld (fixstring+1),hl : ld (fixstring+4),a 
		pop hl 
		push ix 
		push hl 
		;; break
		;ld (endofloadsdbank+1),sp 				; move stack to temp
		;ld sp,endfilename-2						; because we're paging $4000-$5fff
		
		; get current regs from $52
		ld a,$52 								; mmu slot 6 
		ld bc,$243B								; Register Select 
		out(c),a									; read reg 
		inc b 		
		in a,(c)		
		ld (slot6+1),a 							; store bank
		 
		; store the address, len, offset values in ram with smc 
		
ldadd:	ld c,(ix+6) : ld b,(ix+7) 				; address 
		ld a,b : and 127 : or $40 : ld b,a : ld (address+2),bc
		
		ld c,(ix+8) : ld b,(ix+9) 				; size 
		ld (loadsize+1),bc 						; if size is 0 then we will detect
		ld a,b : add a,c : ld (changesize+1),a 
		
		ld l,(ix+10) : ld h,(ix+11) 		
		ld (offset+1),hl							; offset DE 	

		ld l,(ix+12) : ld h,(ix+13)						
		ld (offset+4),hl 							; offset BE 

		ld l,(ix-4) : ld h,(ix-3)					; filespec 
		
		ld a,(ix+15)								; get our custom bank 
		ld (curbank),a 
		nextreg $52,a
		
		push hl : pop ix 
		;ld ix,.LABEL._filename
		ld (nameaddressfname+2),hl 
		
initdrive:
		ld a, '*' 	
		ld b, FA_READ
		; ix = filespec 
		ESXDOS : db F_OPEN
		ld (filehandle),a			; store file handle 
		; this is where we should handle an error 
		jp c,error 					; c flag had an error.  

fstat:	ld ix, fileinfobuffer
		ESXDOS : db F_STAT
		jp c,error 					; c flag had an error.  
		
changesize:
		ld a,0 : or a : call z,filesize0
		
		ld a,(filehandle) 
fileseek:
		ld ixl,0						; start  
		ld l,0						; cspect bug?
offset: 	ld de,0000					; filled in at start ldadd
		ld bc,0000
		ESXDOS : db F_SEEK			; seek 
		jp c,error 					; c flag had an error.  
address: 
		ld ix,0000		
loadsize:		
		ld bc,0000 				; length to load from BC in stack 
loadagain:
		
		ld a,(filehandle) 			; read to address 
		ESXDOS : db $9d

		jp c,error 					; c flag had an error. 
		ld (filesize),bc 			; bc read bytes 
		
		ld a,$20 : cp b : jr nz,loadsdout
		ld a,(curbank) : inc a : ld (curbank),a  : nextreg $52,a 
		jr loadagain
		
filesize0:
		ld bc,(fileinfobuffer+7)
		ld a,b
		ld (filesize),a
		ld a,c
		ld (filesize+1),a
		ld bc,$2000 
		ld (loadsize+1),bc 
		ret 
		
fileinfobuffer:
		ds 11,0			; this will contain the file info
filehandle:
		db 0 
curbank:
		db 0 
end asm 
filesize2:
asm 
filesize:
		dw 00,00,$FF
nameaddress: 
		dw 0000 
	error:
		nextreg $69,0					; turn off layer 2 
		ld a,(slot6+1) : nextreg $52,a 	; bring back slot 2 
		ld b,60
		ld ix,failed : call printrst
nameaddressfname:		
		ld ix,.LABEL._filename : call printrst
	mloop:
		ld a,0 : out (254),a : ld a,2 : out (254),a  : djnz mloop : jp mloop
printrst:
		ld a,(ix+0) : or a : ret z : rst 16 : inc ix : jp printrst
failed: 
		db 16,2,17,6
		db "Failed to open : ",13,0	 	
		
loadsdout:
		ld a,(filehandle)
		ESXDOS : db F_CLOSE		; done, close file 
	
slot6:	ld a,0 : nextreg $52,a
fixstring:
		ld hl,0000				; smc from above 
		ld (hl),0	
endofloadsdbank:
		;ld sp,0000
		pop hl					; restore hl 
		pop ix 					; restore ix 
		ReenableInts
		ENDP
	end asm 
end sub 
#else
	#define LoadSDBank(arga,argb,argc,argd,arge) \
		
#endif

Sub LoadSD(byval filen as String,ByVal address as uinteger,ByVal length as uinteger,ByVal offset as ulong)

		asm 			
		PROC
		LOCAL initdrive, filehandle,error, fileopen, divfix, fileseek, fileread, loadsdout
		LOCAL fnloop
		; call _checkints
		; di
		nextreg $50, $ff
		nextreg $51, $ff
		 ld h,(IX+5) : ld l,(IX+4)
		 ld de,.LABEL._filename
		 ld a,(hl) : ld b,a : add hl,2 
 fnloop:		
		 ldi :  djnz fnloop : ldi : 
		 xor a: ld (de),a
carryon:		 
		
		push ix	
		push hl

		ld e,(ix+6)				; address 
		ld d,(ix+7)
		ld c,(ix+8)				; size 
		ld b,(ix+9)
		ld l,(ix+10)
		ld h,(ix+11)			; offset 
		push bc 				; store size 
		push de 				; srote address 
		push hl 				; offset 32bit 1111xxxx
		ld l,(ix+12)
		ld h,(ix+13)			; offset xxxx1111
		push hl 				; offset 		
		
	initdrive:
		xor a		
		ESXDOS
		db M_GETSETDRV			; M_GETSETDRV equ $89
		ld (filehandle),a

		ld ix,.LABEL._filename 
		call fileopen
		ld a,(filehandle) 
		; or a
		; bug in divmmc requries us to read a byte first 
		; at thie point stack = offset 
		; stack +2 = address 
		; stack +4 = length to load 
		
		ld a,(filehandle) 
divfix:	
		ld bc,1					; FMODE_READ = #01
		ld ix,0					
		ESXDOS					; read a byte 
		db F_READ				; read bytes 
	
		ld a,(filehandle) 

fileseek:
		ld ixl,0
		ld l,0					; start  
		pop bc 
		pop de					; offset into de 
		ESXDOS			
		db F_SEEK				; seek 
		pop ix 					; address to load from DE in stack 
		pop bc 					; length to load from BC in stack 
	
	fileread:							
		jp c,error 
		ld a,(filehandle) 
		ESXDOS
		db F_READ				; read bytes 
		; bc read bytes 
		ld (filesize),bc 
		jp loadsdout

	filehandle:
		db 0 		
end asm 
filesize:
asm 
filesize:
		dw 0000
	error:
	#ifdef DEBUG
		LOCAL mloop, printrst, failed 
		nextreg $69,0
		ld b,60
		ld ix,failed
		call printrst
		ld ix,.LABEL._filename
		call printrst
	mloop:
		ld a,0
		out (254),a
		ld a,2
		out (254),a 
		;halt 
		djnz mloop
		jp mloop
	printrst:
		ld a,(ix+0) : or a : ret z : rst 16 : inc ix : jp printrst
	failed: 
		db 16,2,17,6
		db "Failed to open : ",13,0	 	
	#else 
		jp loadsdout
	#endif 	
fileopen:		
		ld b,$01				; mode 1 read 
		push ix
		pop hl
		ESXDOS
		db F_OPEN
		ld (filehandle),a
		ret
	
	loadsdout:
		ld a,(filehandle)
		or a
		ESXDOS
		db F_CLOSE			; done, close file 
	loadsdout2:	
		pop hl
		pop ix 				; restore stack n stuff
		ENDP
		; ReenableInts
	end asm 

end sub 

Sub SaveSD(byval filen as String,ByVal address as uinteger,ByVal length as uinteger)
	
	' 
	' saves to SD filen=filename address=start address to save lenght=number of bytes to save  
	'
	dim tlen as uinteger
	filen = filen + chr(0)
	tlen=len(filen)+1
	'dim cco as ubyte=0
	for nbx=0 to tlen
		'if code(filen(cco))>32
		poke @filename+nbx,code (filen(nbx))
		'cco=cco+1
		'endif 
	next 
	poke @filename+nbx+1,0

	asm 
		PROC
		; ; break 
		LOCAL initdrive
		LOCAL filehandle
		LOCAL error
		LOCAL fileopen
		LOCAL mloop
		push ix						; both needed for returning nicely 
		push hl
		ld e,(ix+6)					; address in to de 
		ld d,(ix+7)
		ld c,(ix+8)					; size in to bc 
		ld b,(ix+9)
		;ld l,(ix+10)				; for offset but not used here
		;ld h,(ix+11)				; offset 
		push bc 					; store size 
		push de 					; srote address 
	;	push hl 					; offset 
		
	initdrive:
		xor a		
		rst $08
		db $89						; M_GETSETDRV = $89
		ld (filehandle),a			; store filehandle from a to filehandle buffer 

		ld ix,.LABEL._filename 	; load ix with filename buffer address 
		call fileopen				; open 
		ld a,(filehandle) 			; make sure a had filehandle again 
		;or a
		
		; not needed here but may add back in to save on an offset ....
		; bug in divmmc requries us to read a byte first 
		; at thie point stack = offset 
		; stack +2 = address 
		; stack +4 = length to SAVE 
		
		;divfix:	
		;	ld bc,1
		;	ld ix,0					
		;	rst $08					; read a byte 
		;	db $9d					; read bytes 

		;ld a,(filehandle) 
		
	;fileseek:
	
		;ld l,0						; start  
		;ld bc,0					; highword
		
		;pop de						; offset into de 

		;rst $08				
		;db $9f						; seek 
		pop ix 						; address to Save from DE in stack 
		pop bc 						; length to SAVE from BC in stack 
		call filewrite
		jp savesdout
		
	filewrite:

		db 62						; read 
		
	filehandle:
		db 0 						
		or a 						
		jp z,error
		rst $08
		db $9e						; write bytes 
		ret 
		
		jp savesdout

	error:
		ld b,5
	mloop:
		ld a,2
		out (254),a
		ld a,7
		out (254),a
		djnz mloop
		jp savesdout

	fileopen:		
		
		ld b,$e					; mode write
		;db 33						; open 
		;ld	b,$0c
		push ix
		pop hl
	;	ld a,42
		rst $08
		db $9a						; F_OPEN 
		ld (filehandle),a
		ret
	
	savesdout:
		
		ld a,(filehandle)
		or a
		rst $08
		db $9b					; done, close file 
		
		pop hl
		pop ix 					; restore stack n stuff
	ENDP 
	
	end asm 

end sub 


SUB DoTile(byVal X as ubyte, byval Y as ubyte, byval T as ubyte)

    ASM 
        PUSH IX 
        ; Grab xyt
        ld b,(IX+7)
        ld c,(IX+5)
        ld a,(IX+9)

    ; tile data @ $c000
        ;----------------
        ; Original code by Michael Ware adjustd to work with ZXB
        ; Plot tile to layer 2
        ; in - bc = y/x tile coordinate (0-11, 0-15)
        ; in - a = number of tile to display
        ;----------------

    PlotTile16:
        ex af,af'
        ld a,b
        SWAPNIB
        ld d,a
        ld a,c
        SWAPNIB
        ld e,a
        ld a,d
        and 192 
        or 3
        ld bc,LAYER2_ACCESS_PORT
        out (c),a                 ; select bank
        ex af, af'
        or 192                     ; tiles start from $C000
        ld h,a 
        ld l,0                    ; put tile number * 256 into hl.
        ld a,d 
        and 63 
        ld d,a
        ld a,16
        ld b,0
    plotTilesLoop:
        ld c, 16                ; t 7
        push de
        ldir
        ;DB $ED,$B4
        pop de                    ; blat from hl to de, bc times
        inc d
        dec a
        jr nz,plotTilesLoop
        ;ret
        POP IX 
    END ASM 
end sub


SUB DoTileBank16(byVal X as ubyte, byval Y as ubyte, byval T as ubyte, byval B as ubyte)
	' X 0 -15 Y 0 -11 T tile 0 - 255 B = bank tiles are loaded in  
	ASM 
		;PUSH IX 
		; Grab xyt	
		PROC 
		LOCAL tbanks	
		#ifndef IM2 
			call _checkints
			di 
		#endif 
		ld a,$52 : ld bc,$243B : out(c),a : inc b : in a,(c)	
		ld (tbanks+3),a 

		ld h,(IX+11) 			; bank 
		ld a,(IX+9)				; tile 
		; 0010 0000
		swapnib 
		; 0000 0010
		rrca : and %111 
		add a,h 

		nextreg $52,a 
		ld a,(IX+9)		; tile 
		;and 63
		ld b,(IX+7)		; y 
		ld c,(IX+5)		; x 
    ; tile data @ $4000
		;----------------
		; Original code by Michael Ware adjusted to work with ZXB
		; Plot tile to layer 2
		; in - bc = y/x tile coordinate (0-11, 0-15)
		; in - a = number of tile to display
		;---------------- 
	PlotTile16:
		 
		ex af,af'
		ld a,b   		; put y into a 
		SWAPNIB			; * 16 
		ld d,a			; put new y into d 
		ld a,c			; get x into a 
		SWAPNIB			; * 16
		ld e,a			; now put new x into e 
		ld a,d			; bring bank d 
		and 192			; we start at $4000
		or 3			; enable  l2 
		ld hl,shadowlayerbit
		or (hl)
		ld bc,LAYER2_ACCESS_PORT
		out (c),a 				; select bank
		ex af, af'
		and 31 					
		or $40 					; tiles start from $4000
		
		ld h,a 
		ld l,0					; put tile number * 256 into hl.
		ld a,d 
		and 63 
		ld d,a
		ld a,16
		ld b,0
	plotTilesLoop:
		ld c, 16					; t 7
		push de
		ldir
		;DB $ED,$B4
		pop de					
		inc d
		dec a
		jr nz,plotTilesLoop
tbanks:		
		nextreg $52,0
;outstack:
		;ld sp,00 
		ld a,%00000010
		
		ld bc,LAYER2_ACCESS_PORT
		out (c),a 				; select bank
	#ifndef IM2 
		ReenableInts
	#endif
		;ret
		;POP IX 
		ENDP
	END ASM 
end sub

SUB DoTile8(byVal X as ubyte, byval Y as ubyte, byval T as ubyte)

	ASM 
		;; break 
		PUSH de 
		push hl
		; Grab xyt
		ld l,(IX+5)
		
		ld h,(IX+7)

		ld a,(IX+9)

		;----------------
		; Original code by Michael Ware adjustd to work with ZXB
		; Plot tile to layer 2 (needs to accept > 256 tiles)
		; in - hl = y/x tile coordinate (0-17, 0-31)
		; in - a = number of tile to display
		;----------------
PlotTile8:
		ld d,64
		ld e,a					; 11
		MUL_DE					; ?

		ld a,%11000000
		or d		 				; 8
		ex de,hl					; 4			; cannot avoid an ex (de now = yx)
		ld h,a					; 4
		ld a,e
		rlca
		rlca
		rlca
		ld e,a					; 4+4+4+4+4 = 20	; mul x,8
		ld a,d
		rlca
		rlca
		rlca
		ld d,a					; 4+4+4+4+4 = 20	; mul y,8
		and 192
		or 3						; or 3 to keep layer on				; 8
		ld bc,LAYER2_ACCESS_PORT
		out (c),a      			; 21			; select bank

		ld a,d
		and 63
		ld d,a					; clear top bits of y (dest) (4+4+4 = 12)
		; T96 here
		ld a,8					; 7
plotTilesLoop2:
		push de					; 11
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi		; 8 * 16 = 128
		
		pop de					; 11
		inc d					; 4 add 256 for next line down
		dec a					; 4
		jr nz,plotTilesLoop2			; 12/7
		;ret  
		ld a,2
		ld bc,LAYER2_ACCESS_PORT
		out (c),a      ; 21			; select bank
	END ASM 
end sub

SUB DoTileBank8(byVal X as ubyte, byval Y as ubyte, byval T as ubyte, byval b as ubyte)

	ASM 
		; Draws a tile from bank b. Total tile size can be 16kb
		; required bank is auto paged into $4000-$5FFF
		; 256x192 L2 8x8 256 colour tile

		PUSH de 
		push hl
		PROC
		LOCAL tbanks,noinc,PlotTile8,plotTilesLoop2
		#ifndef IM2 
			call _checkints
			di 
		#endif 
		ld a,$52 : ld bc,$243B : out(c),a : inc b : in a,(c)	
		ld (tbanks+3),a 
		
		ld a,(IX+11)		; bank 
		ld h,(IX+9)			; tile

	;	swapnib				; 8						; tile / 32 
	; 	rrca				; 4		12					; rotate right 
	;	rrca				; 4 	16						; rotate right 
	;	rrca				; 4		20					; rotate right 
	;	and %1				; 7		27				; and with %1
	;	add a,h 			; 4 	31t
		
		bit 7,h			; 8 t 		
		jr z,noinc	 	; 12 / 7t 	20
		inc a 			; 4 		24
		noinc: 

		nextreg $52,a 		; set correct bank 

		; Grab xyt
		ld l,(IX+5)			; x
		ld h,(IX+7)			; y
		ld a,(IX+9)			; tile
		and 127

		;----------------
		; Original code by Michael Ware adjustd to work with ZXB
		; Plot tile to layer 2 (needs to accept > 256 tiles)
		; in - hl = y/x tile coordinate (0-17, 0-31)
		; in - a = number of tile to display
		;----------------
PlotTile8:
		ld d,64
		ld e,a					; 11
		mul d,e 

		ld a,%01000000			; tiles at $4000
		or d		 				; 8
		ex de,hl					; 4			; cannot avoid an ex (de now = yx)
		ld h,a					; 4
		ld a,e
		rlca
		rlca
		rlca
		ld e,a					; 4+4+4+4+4 = 20	; mul x,8
		ld a,d
		rlca
		rlca
		rlca
		ld d,a					; 4+4+4+4+4 = 20	; mul y,8
		and 192
		or 3						; or 3 to keep layer on				; 8
		ld bc,LAYER2_ACCESS_PORT
		out (c),a      			; 21			; select bank

		ld a,d
		and 63
		ld d,a					; clear top bits of y (dest) (4+4+4 = 12)
		; T96 here
		ld a,8					; 7
plotTilesLoop2:
		push de					; 11
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi		; 8 * 16 = 128
		
		pop de					; 11
		inc d					; 4 add 256 for next line down
		dec a					; 4
		jr nz,plotTilesLoop2			; 12/7

tbanks:		
		nextreg $52,0			
		ld a,2
		ld bc,LAYER2_ACCESS_PORT
		out (c),a      ; 21			; select bank
		#ifndef IM2 
			ReenableInts
		#endif
		ENDP
	END ASM 
end sub

SUB DoTileBank8Test(byVal X as ubyte, byval Y as ubyte, byval T as ubyte, byval b as ubyte, byval c as ubyte)

	ASM 
		; Draws a tile from bank b. Total tile size can be 16kb
		; required bank is auto paged into $4000-$5FFF
		; 256x192 L2 8x8 256 colour tile

		PUSH de 
		push hl
		PROC
		LOCAL tbanks,noinc,PlotTile8,plotTilesLoop2
		#ifndef IM2 
			call _checkints
			di 
		#endif 
		ld a,$52 : ld bc,$243B : out(c),a : inc b : in a,(c)	
		ld (tbanks+3),a 
		
		ld a,(IX+11)		; bank 
		ld h,(IX+9)			; tile
		
		bit 7,h			; 8 t 		
		jr z,noinc	 	; 12 / 7t 	20
		inc a 			; 4 		24
		noinc: 

		nextreg $52,a 		; set correct bank 

		; Grab xyt
		ld l,(IX+5)			; x
		ld h,(IX+7)			; y
		ld a,(IX+9)			; tile
		and 127

		;----------------
		; Original code by Michael Ware adjustd to work with ZXB
		; Plot tile to layer 2 (needs to accept > 256 tiles)
		; in - hl = y/x tile coordinate (0-17, 0-31)
		; in - a = number of tile to display
		;----------------
PlotTile8:
		ld d,64
		ld e,a					; 11
		mul d,e 

		ld a,%01000000			; tiles at $4000
		or d		 				; 8
		ex de,hl					; 4			; cannot avoid an ex (de now = yx)
		ld h,a					; 4
		ld a,e
		rlca
		rlca
		rlca
		ld e,a					; 4+4+4+4+4 = 20	; mul x,8
		ld a,d
		rlca
		rlca
		rlca
		ld d,a					; 4+4+4+4+4 = 20	; mul y,8
		and 192
		or 3						; or 3 to keep layer on				; 8
		ld bc,LAYER2_ACCESS_PORT
		out (c),a      			; 21			; select bank

		ld a,d
		and 63
		ld d,a					; clear top bits of y (dest) (4+4+4 = 12)
		; T96 here
		; ld a,8					; 7
		ld a,(IX+13)
		ld bc,$800 
plotTilesLoop2:
		
		push bc
		ld bc,8
		push de		
		ldirx
		pop de 
		inc d 
		pop bc 
		djnz plotTilesLoop2

tbanks:		
		nextreg $52,0			
		ld a,2
		ld bc,LAYER2_ACCESS_PORT
		out (c),a      ; 21			; select bank
		#ifndef IM2 
			ReenableInts
		#endif
		ENDP
	END ASM 
end sub

sub fastcall FDoTile16(tile as ubyte, x as ubyte ,y as ubyte, bank as ubyte)
	' y 0  to 15
	' x 0  to 19
	' 
	' draws tile on layer 2 320x240, fast call so optimized 
	asm 
	; draw 16x16 tile on Layer2 @ 320x256
	; bank is start bank, bank will automatically increase depending on tile number 
	; stack is moved due to $4000 - $5FFF being used. All input values are pushed to the 
	; stack on entry, so we must pop them off, YY00 0X00 Ti00 bk00	
	; en00k 2020 / David Saphier
	PROC 
	LOCAL notbank67,bigtiles, tbanks, smctilnum, outstack, l2320on, l2on
		#ifndef IM2 
			call _checkints
			di 
		#endif 
		exx 						;4 				; swap regs 
		pop hl 						;10				; save ret address
		exx							;4				; back to data  

		pop de 						;10 			; get d<-y off stack yy00
		pop hl						;10				; get h<-x off stack xx00 
		ld l,d						;4 				; now make hl x/y 
		
		; we can use de here 
		pop de 										; start bank in de 
;		ld (outstack+1),sp 							; save stack 
;		ld sp,nbtempstackstart-2					; set stack to nb temp stack 
		ld (smctilnum+1),a							; store tile for below 
		swapnib										; tile / 32 
		rrca										; rotate right 
		and %0111									; and with %111
		add a,d 									; add to start bank 
		ld d,a   									; save a into d
		
		ld a,$52 : ld bc,$243B : out(c),a : inc b : in a,(c)	

		ld (tbanks+3),a 								; store current slot 2 bank
		ld a,d										; get bank to page in from d 
		nextreg $52,a 
		ld bc,LAYER2_ACCESS_PORT
		
smctilnum:		
		ld a,0 					;7					; set from above 
		and 31					; 
		ld d,a					; get offset into tiles from 0000 
		ld e,0

		ld a,%01000000			;7 					; this is $4000
		or d 					;4					; 

		; de tile offset / hl = y/x 
		ex de,hl 				;4					; swap de / hl  
													; and get x/y
		ld h,a 					;4					; now put $cx00 with a into h 
													; hl is source 
		push hl 				;11
		; de y/x 			
		; y first 
		ld a,d 					;4					;  y * 16

		;rlca 					;4
		;rlca 					;4
		;rlca 					;4
		;rlca 					;4 
		swapnib 				;8 
		ld d,a 					;4					; save back in d 
	
		; x 
		ld l,e					;4					; treat x as word 
		ld h,0 					;7					; to catch bit 0 
		add hl, hl				;11					; of h 
		add hl, hl				;11
		add hl, hl				;11					; 
		add hl, hl				;11					; if h bit 0 then banks 6-7
		push hl 					;11				; store hl for the mo 
		bit 0,h : jr z,notbank67  ;7 + 12/22
		ld h,4 					;7					; bit 3 for bank mask 
notbank67:
		ld a,l 					;4					; now get msb of xx 
		swapnib 				;8					; swap the nibbles 
		rrca					;4					; right 2 times 
		rrca					;4
		and 3					;7					; now bits 7/8 in position 1/0
		or h 					;4					; was hl>65535, then or bit 2
		; bank bitmask 
		ld h,a 					;4					; save in h, h has the banks 	
l2on:
		ld a,%00000011			;7					; l2 enable, writes enable 
		out (c),a 				;12					; out to port 
		ld a,h					;4					; get back bit 4 mode banks from h 
		add a,%00010000			;7					; set bit 4 
l2320on:	
		out (c),a 				;12					; out to port 
		pop hl 					;10					; get hl of stack 
		
		ld a,l 					;4					; store l in a 
		ld l,d					;4					; d/y into l 
		and 63					;7					; and 63 to a 
		ld h,a 					;4					; put in h/x 
	
		ex de,hl 				;4
		pop hl 						;11				; source address 

		ld a,16 					;7
		; uses ldws which is 
		; ld a,(hl)
		; ld (de),a 
		; inc hl : inc d 
		;
		; 314 T so far 
bigtiles:
		push de 					;11
		ldws 						;14
		ldws						;14 
		ldws						;14
		ldws						;14
		ldws						;14
		ldws						;14
		ldws 						;14
		ldws 						;14 
		ldws 						;14
		ldws						;14 
		ldws						;14
		ldws						;14
		ldws						;14
		ldws						;14
		ldws 						;14
		ldws 						;14 
		
		pop de						;10
		inc de						;6
		dec a						;4
		jr nz,bigtiles				;12/22
		; 142 T *2
tbanks:		
		nextreg $52,0	
outstack:
;		ld sp,0 
		exx 						;4
		push hl 					;11
		exx 						;4 
		#ifndef IM2
			ReenableInts 
		#endif 	
	ENDP 
	end asm 

end sub 

	
sub fastcall FDoTile8(tile as ubyte, x as ubyte ,y as ubyte, bank as ubyte)
	' y 0  to 31
	' x 0  to 39
	' bank as start bank 
	' draws tile on layer 2 320x240. tile data at $c000 
	asm 
	; a = y 
	; on entry stack YY00 0Xxx cc00	
	; en00k 2020 / David Saphier
	PROC 
	LOCAL notbank67,drawtiles, smctilnum, outstack,tbanks, l2on, l2320on 
		#ifndef IM2 
			call _checkints
			di 
		#endif 
		exx 						;4 					; swap regs 
		pop hl 					;10					; save ret address
		exx						;4					; back to data  
		

		pop de 					;10 					; get d<-y off stack yy00
		pop hl					;10					; get h<-x off stack xx00 
		ld l,d					;4 					; now make hl x/y 
		
		; we can use de here 
		; move stack and set up banks 
		pop de 										; start bank in de  
		ld (smctilnum+1),a							; store tile for below 
		swapnib										; tile / 32 
	 	rrca											; rotate right 
		rrca											; rotate right 
		rrca											; rotate right 
		and %1										; and with %1
		add a,d 										; add to start bank 
		ld d,a   									; save a into d
		
		ld a,$52 : ld bc,$243B : out(c),a : inc b : in a,(c)	
		
		ld (tbanks+3),a 								; store current slot 2 bank
		ld a,d										; get bank to page in from d 
		nextreg $52,a 

smctilnum: 
		ld a,0 
		and $7f										; this is so we wrap around out 8kb bank 
		ld d,64					;7					; each 8x8 tile is 64 bytes 
		ld e,a 					;4					; tile x bytes 
		mul d,e 					;8					; get offset into tiles from 0000 
							
		ld a,%01000000			;7					; add $4000 to the offset 
		or d 					;4					; 
													; a = lsb in an offset from $c0xx

		; de tile offset / hl = y/x 
		ex de,hl 				;4					; swap de / hl  
													; and get x/y
		ld h,a 					;4					; now put $cx00 with a into h 
													; hl is source 
		push hl 					;11
		; de y/x 			
		; y first 
		ld a,d 					;4					;  y * 8
		rlca 					;4
		rlca 					;4
		rlca 					;4 
		ld d,a 					;4					; save back in d 
	
		; x 
		ld l,e					;4					; treat x as word 
		ld h,0 					;7					; to catch bit 0 
		add hl, hl				;11					; of h 
		add hl, hl				;11
		add hl, hl				;11					; if h bit 0 then banks 6-7
		push hl 					;11					; store hl for the mo 
		bit 0,h : jr z,notbank67  ;7 + 12/22
		ld h,4 					;7					; bit 3 for bank mask 
		
notbank67:
		ld a,l 					;4					; now get msb of xx 
		swapnib 					;8					; swap the nibbles 
		rrca						;4					; right 2 times 
		rrca						;4
		and 3					;7					; now bits 7/8 in position 1/0
		or h 					;4					; was de>65535, then or bit 2
		; bank bitmask 
		ld h,a 					;4					; save in h, h has the banks 
		ld bc,LAYER2_ACCESS_PORT	;7 					;
l2on:
		ld a,%00000011			;7					; l2 enable, writes enable 
		out (c),a 				;12					; out to port 
		ld a,h					;4					; get back bit 4 mode banks from h 
		add a,%00010000			;7					; set bit 4 
l2320on:	
		out (c),a 				;12					; out to port 
		pop hl 					;10					; get hl of stack 
		
		ld a,l 					;4					; store l in a 
		ld l,d					;4					; d/y into l 
		and 63					;7					; and 63 to a 
		ld h,a 					;4					; put in h/x 
	
		ex de,hl 				;4
		pop hl 					;11					; source address 

		ld a,8 					;7
		; uses ldws which is 
		; ld a,(hl)
		; ld (de),a 
		; inc hl : inc d 
		;
		; 314 T so far 
drawtiles:
		push de 					;11
		ldws 					;14
		ldws						;14 
		ldws						;14
		ldws						;14
		ldws						;14
		ldws						;14
		ldws 					;14
		ldws 					;14 
		pop de					;10
		inc de					;6
		dec a					;4
		jr nz,drawtiles			;12/22
		; 142 T
tbanks:		
		nextreg $52,0	
outstack:
		exx 						;4
		push hl 					;11
		exx 						;4 
		
		#ifndef IM2
			ReenableInts 
		#endif 		
	ENDP 
	end asm 

end sub 



Sub L2Text(byval x as ubyte,byval y as ubyte ,m$ as string, fntbnk as ubyte, colormask as ubyte)
	
	asm 
		PROC
		; ; break 
		LOCAL plotTilesLoop2, printloop, inloop, addspace, addspace2 
		; x and y is char blocks, fntbnk is a bank which contains 8x8L2 font 
		; need to get m$ address, x , y and maybe fnt bank?
		; pages into $4000 and back to $0a when done
		#ifndef IM2 
		;	call _checkints
		;	di 
		#endif 
		; break 
		getreg($52) 
		;ld a,$52
		;ld bc,$243B			; Register Select 
		;out(c),a				; 
		;inc b 
		;in a,(c)
		ld (textfontdone+1),a 

		ld e,(IX+5) : ld d,(IX+7)	
		ld l,(IX+8) : ld h,(IX+9)
		ld a,(hl) : ld b,a 
		inc hl : inc hl 
		ld a,(IX+11) : nextreg $52,a 
	 
printloop:
		push bc 
		ld a,(hl)
		cp 32 : jp z,addspace
		cp 33 : jp z,addspace2
		sub 32 	
inloop:	
		push hl : push de 
		ex de,hl 
		call PlotTextTile
		pop de : pop hl 
		inc hl  
		inc e   
		pop bc
		djnz printloop
		jp textfontdone
addspace:
		ld a,0
		jp inloop 
addspace2:
		ld a,0
		jp inloop 

PlotTextTile:
		; break 
		ld d,64 : ld e,a			
		MUL_DE					
		ld a,$40  : or d		; $4000  // % 11 = C000
		ex de,hl	 : ld h,a : ld a,e
		rlca : rlca : rlca
		ld e,a : ld a,d
		rlca : rlca : rlca
		ld d,a : and 192 : or 3
		ld bc,LAYER2_ACCESS_PORT
		out (c),a : ld a,d : and 63
		ld d,a : ld bc,$800 
		push de 
		ld a,(IX+13)
		;ld a,8
plotTilesLoop2:
		
		push bc
		ld bc,8
		push de		
		ldirx
		pop de 
		inc d 
		pop bc 
		djnz plotTilesLoop2

		;ldi : ldi : ldi : ldi : ldi : ldi : ldi : ldi
		;pop de 
		;inc d 
		;dec a 
		;jr nz,plotTilesLoop2
		pop de 
		ret 
textfontdone:
		ld a,$0a : nextreg $52,a
endofl2text:
		ld a,2 : ld bc,LAYER2_ACCESS_PORT
		out (c),a
		#ifndef IM2 
		;	ReenableInts
		;ei
		#endif 
	ENDP 

	end asm 
	
end sub 


Sub FL2Text(byval x as ubyte,byval y as ubyte ,byval m$ as string, fntbnk as ubyte)
	
	asm 
	 
	PROC
	LOCAL plotTilesLoop2, printloop, inloop, addspace, addspace2,outstack,slot2out,PlotTextTile,textfontdone 
	; x and y is char blocks, fntbnk is a bank which contains 8x8L2 font 
	; need to get m$ address, x , y and maybe fnt bank?
	; pages into $4000 and back to $0a when done 
		#ifndef IM2 
			call _checkints
			di 
		#endif 
;		ld 		(outstack+1),sp 							; save stack 
;		ld 		sp,nbtempstackstart-2						; set stack to nb temp stack 
		getreg($52)
		ld 		(slot2out+3),a 
		ld 		d,(IX+7) 
		ld 		e,(IX+5)	
		ld 		a,(hl) 
		ld 		b,a 
		inc 	hl 
		inc 	hl  
		ld 		a,(IX+11) 
		nextreg $52,a 
	 
printloop:
		push 	bc 
		ld 		a,(hl)
		cp 		32 : jp z,addspace
		cp 		33 : jp z,addspace2
		sub 	34 	
inloop:	
		; hl string de yx 
		ex 		de,hl
		; de string hl yx 
		push 	hl : push de 
		; hl = y/x de string adderess 
		call 	PlotTextTile
		pop 	hl : pop de
		inc 	hl	; string address 
		inc 	e   ; inc x 
		pop 	bc
		djnz 	printloop
		jp 		textfontdone
	
addspace:
		ld a,57
		jp inloop 
addspace2:
		ld a,0
		jp inloop 

PlotTextTile:
		ld d,64 : ld e,a				 ; d = 64 : a = tile 
		MUL_DE						; 64 * A = TILE DATA OFFSET 
		ld a,%01000000 : or d			; make sure its in $4000 range
		
		
		ex de,hl	 : ld h,a 											; hl is source 
		push hl 					;11
		; de y/x 			
		; y first 
		ld a,d 					;4					;  y * 8
		rlca 					;4
		rlca 					;4
		rlca 					;4 
		ld d,a 					;4					; save back in d 
	
		; x 
		ld l,e					;4					; treat x as word 
		ld h,0 					;7					; to catch bit 0 
		add hl, hl				;11					; of h 
		add hl, hl				;11
		add hl, hl				;11					; if h bit 0 then banks 6-7
		push hl 					;11					; store hl for the mo 
		bit 0,h : jr z,notbank67  ;7 + 12/22
		ld h,4 					;7					; bit 3 for bank mask 
		
notbank67:
		ld a,l 					;4					; now get msb of xx 
		swapnib 					;8					; swap the nibbles 
		;rrca						;4					; right 2 times 
		;rrca						;4
		srl a 
		srl a 
		and 3					;7					; now bits 7/8 in position 1/0
		or h 					;4					; was de>65535, then or bit 2
		; bank bitmask 
		ld h,a 					;4					; save in h, h has the banks 
		ld bc,LAYER2_ACCESS_PORT	;7 					;
l2on:
		ld a,%00000011			;7					; l2 enable, writes enable 
		out (c),a 				;12					; out to port 
		ld a,h					;4					; get back bit 4 mode banks from h 
		add a,%00010000			;7					; set bit 4 
l2320on:	
		out (c),a 				;12					; out to port 
		pop hl 					;10					; get hl of stack 
		
		ld a,l 					;4					; store l in a 
		ld l,d					;4					; d/y into l 
		and 63					;7					; and 63 to a 
		ld h,a 					;4					; put in h/x 
	
		ex de,hl 				;4
		pop hl 					;11					; source address 

		ld a,8 					;7
plotTilesLoop2:
		push de 
		push af 
		ldws 
		ldws
		ldws 
		ldws 
		ldws 
		ldws 
		ldws 
		ldws
		pop af 
		pop de				
		inc de
		dec a
		jr nz,plotTilesLoop2
		ret 
textfontdone:
		;ld a,$0a : nextreg $52,a 
		ld bc,LAYER2_ACCESS_PORT		
		ld a, 2
		out (c),a :	
slot2out:
		nextreg $52,0
outstack:
		#ifndef IM2 
			ReenableInts
		#endif 
	ENDP 
 
	end asm 
	
end sub 


sub fastcall FPlotL2(y as ubyte ,x as uinteger ,c as ubyte)
	
	asm 
	; a = y 
	; on entry stack YY00 0Xxx cc00	
	;en00k 2020 / David Saphier	
		#ifndef IM2 
			call _checkints
			di 
		#endif 
		exx 						;4 					; swap regs 
		pop hl 					;10					; save ret address
		exx						;4					; back to data  
		ld bc,LAYER2_ACCESS_PORT	;7 					; check if bit 0 of h is set if so >255
		
		push af 					;11					; save y to stack 
		ex de,hl 				;4 					; de = xx hl = 00 
		
		bit 0, d 				; 7 				; is bit 0 of de set ?
		jr z,nobanks6and7		; 12/7				; no de value <256 so banks 0 - 5
		ld d,%100				 	; 7 				; de >255 high bank %100 so banks 6-7
							
	nobanks6and7: 					
		ld a,e 					;4					; now get msb of xx from e into a 
		swapnib 					;8					; swap the nibbles 0000xxxx
		srl a					;8					; right 2 times 
		srl a					;8
		and 3					;7					; first two bits 
		or d 					;4					; or with highbank d 
		ld e,a 					;4					; save in e 
						
		ld a,%00000011			;7					; intial write to l2 port 
		out (c),a 				;12					; enable writes and showlayer 
							
		ld a,e					;4					; retrieve e containing banks 
							
		add a,%00010000			;7					; bit 4 extended L2 writes enable 
		out (c),a 				;12					; out to port 
							
		pop af 					;10					; get back y 
		pop hl 					;10 					; get back hl for l 
		ld h,l 					;4					; put l into h 
		ld l,a					;4					; now put y into l 
		ld a,h 					;4					; x into a 
		and 63					;7					; columns wrap at 64 bytes
		ld h,a  					;4 					; put back into h, hl now complete 

		pop af					;10					; get the colour specified 
		ld (hl),a 				;7					; make the write 
		
		exx 						;4
		push hl 					;11
		exx 						;4 
		#ifndef IM2 
			ReenableInts
		#endif 
	end asm 

end sub


SUB PalUpload(ByVal address as uinteger, byval colours as ubyte,byval offset as ubyte)
	' sends palette to registers address @label, num of cols 0 = 256, offset default 0
	asm 
		;; break 
		ld l,(IX+4)
		ld h,(IX+5)
		ld b,(IX+7)
		ld e,(IX+9)
		ld a,e
		
	loadpal:
		
		;ld b,0							; this will make 256 loops 0, then b is dec'd and starts again from 255
		;ld a,2
		ld d,0 
		DW $92ED						; NextReg $40,0
		DB $40
		;xor a							; clear A
		;ld hl,palette					; start of palette data
		ld c,0
	palloop:
		ld a,(hl)						; load first value, send to NextReg
		
		DW $92ED						; NextRegA $44 with A
		DB $44
		inc hl							; next byte 
		ld a,(hl)						; read into a 
		;ld a,1
		DW $92ED						; NextRegA so send A to reg $44
		DB $44
		inc hl 							; incy dinky doo hl
		 
		djnz palloop					; did b do 256 loops? no? then loop to palloop
		ld a,128
		DW $92ED
		DB $40
		xor a 
		DW $92ED						; NextRegA so send A to reg $44
		DB $44
		DW $92ED						; NextRegA so send A to reg $44
		DB $44
		;pop de
		;pop hl 
	end asm 		
end sub 
 
Sub CLS256(byval colour as ubyte)

	' Original code Mike Dailly
	' and adjusted to work with ZXB
	
	ASM 
		

	Cls256:
		#ifndef IM2 
			call _checkints
			di 
		#endif 
		push	bc
		push	de
		push	hl

		ld bc,$123b				; L2 port 
		in a,(c)				; read value 
		push af 				; store it 
		xor a 
		out	(c),a 

		
		ld a,(IX+5)				; get colour 
		
		ld	d,a					; byte to clear to
		ld	e,3					; number of blocks
		ld	a,1					; first bank... (bank 0 with write enable bit set)

		ld      bc, $123b                
	LoadAll:	
		out	(c),a				; bank in first bank
		push	af       
                ; Fill lower 16K with the desired byte
		ld	hl,0
	ClearLoop:		
		ld	(hl),d
		inc	l
		jr	nz,ClearLoop
		inc	h
		ld	a,h
		cp	$40
		jr	nz,ClearLoop

		pop	af					; get block back
		add	a,$40
		dec	e					; loops 3 times
		jr	nz,LoadAll

		ld  bc, $123b			; switch off background (should probably do an IN to get the original value)

		pop af 
		ld	a,2
		out	(c),a     
		;nextreg $50,$ff 
		;lnextreg $51,$ff 
		
		pop	hl
		pop	de
		pop	bc	
		#ifndef IM2 
			ReenableInts
		#endif 
	end asm 
end sub 

Sub ClipLayer2( byval x1 as ubyte, byval x2 as ubyte, byval y1 as ubyte, byval y2 as ubyte ) 

	'; clips the layer2 defaults are : x1=0,x2=255,y1=0,y1=191
	'; $92ED = NextReg A, Clipping Register is 24
	
	asm 
		ld a,(IX+5)    
		DW $92ED : DB 24 			
		ld a,(IX+7)	  
		DW $92ED : DB 24
		ld a,(IX+9)		 
		DW $92ED : DB 24 
		ld a,(IX+11)	
		DW $92ED : DB 24		  
	end asm 
end sub 

Sub ClipULA( byval x1 as ubyte, byval x2 as ubyte, byval y1 as ubyte, byval y2 as ubyte ) 

	'; clips the ULA defaults are : x1=0,x2=255,y1=0,y1=191
	'; $92ED = NextReg A, ULA Clipping Register is 26
	asm 
		ld a,(IX+5)    
		DW $92ED : DB 26 			
		ld a,(IX+7)	  
		DW $92ED : DB 26
		ld a,(IX+9)		 
		DW $92ED : DB 26 
		ld a,(IX+11)	
		DW $92ED : DB 26		  
	end asm 
end sub

Sub ClipTile( byval x1 as ubyte, byval x2 as ubyte, byval y1 as ubyte, byval y2 as ubyte ) 

	'; clips the ULA defaults are : x1=0,x2=255,y1=0,y1=191
	'; $92ED = NextReg A, ULA Clipping Register is 26
	asm 
		ld a,(IX+5)    
		DW $92ED : DB 27 			
		ld a,(IX+7)	  
		DW $92ED : DB 27
		ld a,(IX+9)		 
		DW $92ED : DB 27 
		ld a,(IX+11)	
		DW $92ED : DB 27		  
	end asm 
end sub

Sub ClipSprite( byval x1 as ubyte, byval x2 as ubyte, byval y1 as ubyte, byval y2 as ubyte ) 

	'; clips the ULA defaults are : x1=0,x2=255,y1=0,y1=191
	'; $92ED = NextReg A, ULA Clipping Register is 26
	asm 
		ld a,(IX+5)    
		DW $92ED : DB $19			
		ld a,(IX+7)	  
		DW $92ED : DB $19
		ld a,(IX+9)		 
		DW $92ED : DB $19
		ld a,(IX+11)	
		DW $92ED : DB $19		  
	end asm 
end sub

sub TileMap(byval address as uinteger, byval blkoff as ubyte, byval numberoftiles as uinteger,byval x as ubyte,byval y as ubyte, byval width as ubyte, byval mapwidth as uinteger)
		' this point to a memory location containing a map width is viewable screen 
		' mapwidth is the length of the whole map eg fro scrolling 
		' this is a L2 command and not L3 TileMap HW 
		
		asm 
		
		ld bc,$123b				; L2 port 
		in a,(c)				; read value 
		push af 				; store it
		;xor a 
		;out (c),a
		
		ld a,(IX+7)
		ld (offset),a
		;ld a,(IX+15)				; width 
		;ld (width_tm),a

		; do tile map @ address 
		;; break
		;;ld l,(IX+4)					; put address into hl 
		;;ld h,(IX+5)

		
		; inner x loop 

		ld c,(IX+8)					; 	loop number of loops from numberoftiles
		ld b,(IX+9)					; 
		
		ld d,(IX+11)					; 	x
		ld e,(IX+13)					;   y
		
		;ld de,0						; x 
		;ld e,0						; y 
		ld a,(IX+15)				; if x>0 we need to add it to our width value 
		add a,d 					; 
		ld (IX+15),a 				; store back in IX+15
		
	forx:	
	;; break 
		push bc 					; save loop counter 
		push de 					; save de (xy)
		push hl 					; save the address (hl)
		
		ld b,(hl)					; get tile number from map address 
		ld a,(offset)
		add a,b
		;ld a,b
		;ld a,(hl)
		ld l,d						; put x into c
		ld h,e						; put y into b 

		call PlotTile82				; draw the tile 

		pop hl 						; bring back til map address 
		
		;ld de,32
		ld e,(IX+16)					; 	x
		ld d,(IX+17)					;   y
		
		add hl,de 
		
		pop de 						; bring back de (xy)
		inc d						; increase x so , d+1
								; increase x so , d+1
		ld a,d 						; a=d 
		;cp 32						; compare to 31?
		
		cp (IX+15)
		call z,resetx				; if d=32 then resetx 
		
		pop bc 
		dec bc 
		ld a,b
		or c 
		jp nz,forx 
		
		jp tileend					; we're done jump to end 
	
	resetx:
		inc e						; lets to y first, so y+1
		ld a,e						; a=e  a=y
		cp 24						; if a=24  y=24?
		jp z,timetoexit				; jp tileened			; yes we reached the bottom line so exit 
		;ld d,0						; else let x=0
		ld d,(IX+11)				; else let x = startx 
		ret 						; jump back to forx loop 

	timetoexit:
		pop bc						; dump bc off stack 						
		jp tileend					; we're done jump to end  

	PlotTile82:
		ld d,64
		
		ld e,a						; 11
		mul d,e						; ?
		;; break 
		ld a,%11000000
		;ld a,%00000000
		or d		 				; 8
		ex de,hl					; 4			; cannot avoid an ex (de now = yx)
		ld h,a						; 4
		ld a,e
		rlca
		rlca
		rlca
		ld e,a						; 4+4+4+4+4 = 20	; mul x,8
		ld a,d
		rlca
		rlca
		rlca
		ld d,a						; 4+4+4+4+4 = 20	; mul y,8
		and 192
		or 1						; 8
		
		ld bc,LAYER2_ACCESS_PORT
		out (c),a      				; 21			; select bank

		ld a,d
		and 63
		ld d,a						; clear top 2 bits of y (dest) (4+4+4 = 12)
		; T96 here
		ld a,8						; 7
	plotTilesLoopA:
		push de						; 11
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi							; 8 * 16 = 128
		
		pop de						; 11
		inc d						; 4 add 256 for next line down
		dec a						; 4
		jr nz,plotTilesLoopA		; 12/7
		ret  
	offset:
		db 0
	width_tm:
		db 31
	tileend:
		ld  bc, LAYER2_ACCESS_PORT 	; switch off background (should probably do an IN to get the original value)
		pop af 					; restore layer2 on or off 
		ld a,2
		out	(c),a     
		
	end asm 
	'	NextReg($50,$ff)
END SUB 



sub fastcall FlipBuffer()
	asm  
		exx 
		getreg($12) : ld d,a
		getreg($13)
		nextreg $12,a 
		ld a,d 
		nextreg $13,a 		
		exx 
	end asm 
end sub 

sub fastcall EnableShadow()
	asm 
		ld a,8 : ld (shadowlayerbit),a 
	end asm 
end sub 
sub fastcall DisableShadow()
	asm 
		xor a : ld (shadowlayerbit),a 
	end asm 
end sub 

sub WaitRetrace(byval repeats as uinteger)
	asm 
	PROC 
	LOCAL readline
		readline:	
			ld 		a,VIDEO_LINE_LSB_NR_1F
			ld 		bc,TBBLUE_REGISTER_SELECT_P_243B
			out 	(c),a
			inc 	b
			in 		a,(c)
			cp 		250				; line to wait for 
			jr 		nz,readline
			dec 	hl 
			ld 		a,h
			or 		l 
			jr 		nz,readline 
	ENDP 		
	end asm 
end sub  

sub fastcall WaitRetrace2(byval repeats as ubyte)
	asm 
	PROC 
		
		LOCAL readline
		pop hl : exx 
		ld d,0
		ld e,a 
		readline:
			ld bc,$243b
			ld a,$1e
			out (c),a
			inc b
			in a,(c)
			ld h,a
			dec b
			ld a,$1f
			out (c),a
			inc b
			in a,(c)
			ld  l,a
			and a
			sbc hl,de
			add hl,de
			jr nz,readline
		exx : push hl 
	ENDP 
	end asm 

end sub 
sub WaitKey()
	asm
	; waits for any keypress or kemp 1/2 or md pad abc/start
	PROC
		;	; break 
	LOCAL WaitAnyKey,.NoKey,.NoKempston,.AnyKeyOrKempston,.check_key
	LOCAL raster_line_wait, rloop
			; push 	bc
	WaitAnyKey:
		.NoKey:
			xor 	a									; flush a & flags to 0 
			in 		a, ($FE)							; key keyboard port
			cpl											; invert the result
			and 	31									; mask off 31
			jr 		nz, .NoKey							; if the result is not 0 jim ot NoKey
		.NoKempston:
			ld 		e,2									; 2 frames for raster_line_wait
			call 	raster_line_wait					; call raster_line_wait
			in 		a, (31)								; read the kempston port into a
			inc 	a									; add + 1 
			jr 		z, .AnyKeyOrKempston				; is a now 0 then jump to AnyKeyOrKempston
			dec 	a									; subtract 1 from a 
			jr 		nz, .NoKempston						; if a is not 0 then jump to .NoKempston
		.AnyKeyOrKempston:      	
			ld 		e,2									; 2 frames 
			call 	raster_line_wait					; call raster_line_wait 
			in 		a, (31)								; read kempston port
			inc 	a									; add + 1 to a 
			jr 		z,.check_key						; if its 0 jump to check_key
			dec 	a									; subtract 1 from a 
			ret 	nz									; if the resul is non z return 
		.check_key:             
			in 		a, ($FE)
			cpl
			and 	31
			jr 		z, .AnyKeyOrKempston
			jr		exit_wait_key 

	raster_line_wait:
			ld      bc,TBBLUE_REGISTER_SELECT_P_243B
			ld      a,VIDEO_LINE_MSB_NR_1E
			out     (c),a									; select NR $1E
			inc     b
	rloop:
			in      a,(c)									; A = raster line MSB
			; cp 		165
			xor     e
			rra
			jr      nc,rloop								; loop until MSB.1 != E.1
			dec     e										; decrement counter
			jr      nz,rloop								; loop until counter == 0
			ret				

	exit_wait_key: 
			; pop 	bc 
			ret		
		ENDP
		end asm 
end sub 

	
	asm  
		ld iy,$5c3a	
		jp endfilename
	end asm 
	 
	checkints()

filename:
	asm 		
	filename:
		DEFS 256,0
	endfilename:	
	end asm 

	#ifndef NOSP 
		asm 
		nbtempstackstart:
			ld sp,endfilename-2
		end asm 
	#endif 

	asm 
	;	sfxenablednl:
	;	db 0,0 
		shadowlayerbit:
		db 0
	end asm 
	
const BIT_UP 		as ubyte =4
const BIT_DOWN 		as ubyte =5
const BIT_LEFT 		as ubyte =6
const BIT_RIGHT 	as ubyte =7
const DIR_NONE 		as ubyte =%00000000
const DIR_UP 		as ubyte =%00010000
const DIR_DOWN 		as ubyte =%00100000
const DIR_LEFT 		as ubyte =%01000000
const DIR_RIGHT 	as ubyte =%10000000
const DIR_UP_I 		as ubyte =%11101111
const DIR_DOWN_I 	as ubyte =%11011111
const DIR_LEFT_I 	as ubyte =%10111111
const DIR_RIGHT_I 	as ubyte =%01111111
const ULA_P_FE 		as ubyte =$FE
const TIMEX_P_FF 	as ubyte =$FF
const ZX128_MEMORY_P_7FFD as uinteger =$7FFD
const ZX128_MEMORY_P_DFFD as uinteger =$DFFD
const ZX128P3_MEMORY_P_1FFD as uinteger =$1FFD
const AY_REG_P_FFFD as uinteger =$FFFD
const AY_DATA_P_BFFD as uinteger =$BFFD
const Z80_DMA_PORT_DATAGEAR as ubyte =$6B
const Z80_DMA_PORT_MB02 as ubyte =$0B
const DIVMMC_CONTROL_P_E3 as ubyte =$E3
const SPI_CS_P_E7 as ubyte =$E7
const SPI_DATA_P_EB as ubyte =$EB
const KEMPSTON_MOUSE_X_P_FBDF as uinteger =$FBDF
const KEMPSTON_MOUSE_Y_P_FFDF as uinteger =$FFDF
const KEMPSTON_MOUSE_B_P_FADF as uinteger =$FADF
const KEMPSTON_JOY1_P_1F as ubyte =$1F
const KEMPSTON_JOY2_P_37 as ubyte =$37
const TBBLUE_REGISTER_SELECT_P_243B as uinteger =$243B
const TBBLUE_REGISTER_ACCESS_P_253B as uinteger =$253B
const DAC_GS_COVOX_INDEX as ubyte =1
const DAC_PENTAGON_ATM_INDEX as ubyte =2
const DAC_SPECDRUM_INDEX as ubyte =3
const DAC_SOUNDRIVE1_INDEX as ubyte =4
const DAC_SOUNDRIVE2_INDEX as ubyte =5
const DAC_COVOX_INDEX as ubyte =6
const DAC_PROFI_COVOX_INDEX as ubyte =7
const I2C_SCL_P_103B as uinteger =$103B
const I2C_SDA_P_113B as uinteger =$113B
const UART_TX_P_133B as uinteger =$133B
const UART_RX_P_143B as uinteger =$143B
const UART_CTRL_P_153B as uinteger =$153B
const ZILOG_DMA_P_0B as ubyte =$0B
const ZXN_DMA_P_6B as ubyte =$6B
const LAYER2_ACCESS_P_123B as uinteger =$123B
const LAYER2_ACCESS_WRITE_OVER_ROM as ubyte =$01
const LAYER2_ACCESS_L2_ENABLED as ubyte =$02
const LAYER2_ACCESS_READ_OVER_ROM as ubyte =$04
const LAYER2_ACCESS_SHADOW_OVER_ROM as ubyte =$08
const LAYER2_ACCESS_BANK_OFFSET as ubyte =$10
const LAYER2_ACCESS_OVER_ROM_BANK_M as ubyte =$C0
const LAYER2_ACCESS_OVER_ROM_BANK_0 as ubyte =$00
const LAYER2_ACCESS_OVER_ROM_BANK_1 as ubyte =$40
const LAYER2_ACCESS_OVER_ROM_BANK_2 as ubyte =$80
const LAYER2_ACCESS_OVER_ROM_48K as ubyte =$C0
const SPRITE_STATUS_SLOT_SELECT_P_303B as uinteger =$303B
const SPRITE_STATUS_MAXIMUM_SPRITES as ubyte =$02
const SPRITE_STATUS_COLLISION as ubyte =$01
const SPRITE_SLOT_SELECT_PATTERN_HALF as ubyte =128
const SPRITE_ATTRIBUTE_P_57 as ubyte =$57
const SPRITE_PATTERN_P_5B as ubyte =$5B
const TURBO_SOUND_CONTROL_P_FFFD as uinteger =$FFFD
const MACHINE_ID_NR_00 as ubyte =$00
const NEXT_VERSION_NR_01 as ubyte =$01
const NEXT_RESET_NR_02 as ubyte =$02
const MACHINE_TYPE_NR_03 as ubyte =$03
const ROM_MAPPING_NR_04 as ubyte =$04
const PERIPHERAL_1_NR_05 as ubyte =$05
const PERIPHERAL_2_NR_06 as ubyte =$06
const TURBO_CONTROL_NR_07 as ubyte =$07
const PERIPHERAL_3_NR_08 as ubyte =$08
const PERIPHERAL_4_NR_09 as ubyte =$09
const PERIPHERAL_5_NR_0A as ubyte =$0A
const NEXT_VERSION_MINOR_NR_0E as ubyte =$0E
const ANTI_BRICK_NR_10 as ubyte =$10
const VIDEO_TIMING_NR_11 as ubyte =$11
const LAYER2_RAM_BANK_NR_12 as ubyte =$12
const LAYER2_RAM_SHADOW_BANK_NR_13 as ubyte =$13
const GLOBAL_TRANSPARENCY_NR_14 as ubyte =$14
const SPRITE_CONTROL_NR_15 as ubyte =$15
const LAYER2_XOFFSET_NR_16 as ubyte =$16
const LAYER2_YOFFSET_NR_17 as ubyte =$17
const CLIP_LAYER2_NR_18 as ubyte =$18
const CLIP_SPRITE_NR_19 as ubyte =$19
const CLIP_ULA_LORES_NR_1A as ubyte =$1A
const CLIP_TILEMAP_NR_1B as ubyte =$1B
const CLIP_WINDOW_CONTROL_NR_1C as ubyte =$1C
const VIDEO_LINE_MSB_NR_1E as ubyte =$1E
const VIDEO_LINE_LSB_NR_1F as ubyte =$1F
const VIDEO_INTERUPT_CONTROL_NR_22 as ubyte =$22
const VIDEO_INTERUPT_VALUE_NR_23 as ubyte =$23
const ULA_XOFFSET_NR_26 as ubyte =$26
const ULA_YOFFSET_NR_27 as ubyte =$27
const HIGH_ADRESS_KEYMAP_NR_28 as ubyte =$28
const LOW_ADRESS_KEYMAP_NR_29 as ubyte =$29
const HIGH_DATA_TO_KEYMAP_NR_2A as ubyte =$2A
const LOW_DATA_TO_KEYMAP_NR_2B as ubyte =$2B
const DAC_B_MIRROR_NR_2C as ubyte =$2C
const DAC_AD_MIRROR_NR_2D as ubyte =$2D
const SOUNDDRIVE_DF_MIRROR_NR_2D as ubyte =$2D
const DAC_C_MIRROR_NR_2E as ubyte =$2E
const TILEMAP_XOFFSET_MSB_NR_2F as ubyte =$2F
const TILEMAP_XOFFSET_LSB_NR_30 as ubyte =$30
const TILEMAP_YOFFSET_NR_31 as ubyte =$31
const LORES_XOFFSET_NR_32 as ubyte =$32
const LORES_YOFFSET_NR_33 as ubyte =$33
const SPRITE_ATTR_SLOT_SEL_NR_34 as ubyte =$34
const SPRITE_ATTR0_NR_35 as ubyte =$35
const SPRITE_ATTR1_NR_36 as ubyte =$36
const SPRITE_ATTR2_NR_37 as ubyte =$37
const SPRITE_ATTR3_NR_38 as ubyte =$38
const SPRITE_ATTR4_NR_39 as ubyte =$39
const PALETTE_INDEX_NR_40 as ubyte =$40
const PALETTE_VALUE_NR_41 as ubyte =$41
const PALETTE_FORMAT_NR_42 as ubyte =$42
const PALETTE_CONTROL_NR_43 as ubyte =$43
const PALETTE_VALUE_9BIT_NR_44 as ubyte =$44
const TRANSPARENCY_FALLBACK_COL_NR_4A as ubyte =$4A
const SPRITE_TRANSPARENCY_I_NR_4B as ubyte =$4B
const TILEMAP_TRANSPARENCY_I_NR_4C as ubyte =$4C
const MMU0_0000_NR_50 as ubyte =$50
const MMU1_2000_NR_51 as ubyte =$51
const MMU2_4000_NR_52 as ubyte =$52
const MMU3_6000_NR_53 as ubyte =$53
const MMU4_8000_NR_54 as ubyte =$54
const MMU5_A000_NR_55 as ubyte =$55
const MMU6_C000_NR_56 as ubyte =$56
const MMU7_E000_NR_57 as ubyte =$57
const COPPER_DATA_NR_60 as ubyte =$60
const COPPER_CONTROL_LO_NR_61 as ubyte =$61
const COPPER_CONTROL_HI_NR_62 as ubyte =$62
const COPPER_DATA_16B_NR_63 as ubyte =$63
const VIDEO_LINE_OFFSET_NR_64 as ubyte =$64
const ULA_CONTROL_NR_68 as ubyte =$68
const DISPLAY_CONTROL_NR_69 as ubyte =$69
const LORES_CONTROL_NR_6A as ubyte =$6A
const TILEMAP_CONTROL_NR_6B as ubyte =$6B
const TILEMAP_DEFAULT_ATTR_NR_6C as ubyte =$6C
const TILEMAP_BASE_ADR_NR_6E as ubyte =$6E
const TILEMAP_GFX_ADR_NR_6F as ubyte =$6F
const LAYER2_CONTROL_NR_70 as ubyte =$70
const LAYER2_XOFFSET_MSB_NR_71 as ubyte =$71
const SPRITE_ATTR0_INC_NR_75 as ubyte =$75
const SPRITE_ATTR1_INC_NR_76 as ubyte =$76
const SPRITE_ATTR2_INC_NR_77 as ubyte =$77
const SPRITE_ATTR3_INC_NR_78 as ubyte =$78
const SPRITE_ATTR4_INC_NR_79 as ubyte =$79
const USER_STORAGE_0_NR_7F as ubyte =$7F
const EXPANSION_BUS_ENABLE_NR_80 as ubyte =$80
const EXPANSION_BUS_CONTROL_NR_81 as ubyte =$81
const INTERNAL_PORT_DECODING_0_NR_82 as ubyte =$82
const INTERNAL_PORT_DECODING_1_NR_83 as ubyte =$83
const INTERNAL_PORT_DECODING_2_NR_84 as ubyte =$84
const INTERNAL_PORT_DECODING_3_NR_85 as ubyte =$85
const EXPANSION_BUS_DECODING_0_NR_86 as ubyte =$86
const EXPANSION_BUS_DECODING_1_NR_87 as ubyte =$87
const EXPANSION_BUS_DECODING_2_NR_88 as ubyte =$88
const EXPANSION_BUS_DECODING_3_NR_89 as ubyte =$89
const EXPANSION_BUS_PROPAGATE_NR_8A as ubyte =$8A
const ALTERNATE_ROM_NR_8C as ubyte =$8C
const ZX_MEM_MAPPING_NR_8E as ubyte =$8E
const PI_GPIO_OUT_ENABLE_0_NR_90 as ubyte =$90
const PI_GPIO_OUT_ENABLE_1_NR_91 as ubyte =$91
const PI_GPIO_OUT_ENABLE_2_NR_92 as ubyte =$92
const PI_GPIO_OUT_ENABLE_3_NR_93 as ubyte =$93
const PI_GPIO_0_NR_98 as ubyte =$98
const PI_GPIO_1_NR_99 as ubyte =$99
const PI_GPIO_2_NR_9A as ubyte =$9A
const PI_GPIO_3_NR_9B as ubyte =$9B
const PI_PERIPHERALS_ENABLE_NR_A0 as ubyte =$A0
const PI_I2S_AUDIO_CONTROL_NR_A2 as ubyte =$A2
const ESP_WIFI_GPIO_OUTPUT_NR_A8 as ubyte =$A8
const ESP_WIFI_GPIO_NR_A9 as ubyte =$A9
const EXTENDED_KEYS_0_NR_B0 as ubyte =$B0
const EXTENDED_KEYS_1_NR_B1 as ubyte =$B1
const DEBUG_LED_CONTROL_NR_FF as ubyte =$FF
const MEM_ROM_CHARS_3C00 as uinteger =$3C00
const MEM_ZX_SCREEN_4000 as uinteger =$4000
const MEM_ZX_ATTRIB_5800 as uinteger =$5800
const MEM_LORES0_4000 as uinteger =$4000
const MEM_LORES1_6000 as uinteger =$6000
const MEM_TIMEX_SCR0_4000 as uinteger =$4000
const MEM_TIMEX_SCR1_6000 as uinteger =$6000
const COPPER_NOOP as ubyte =%00000000
const COPPER_WAIT_H as ubyte =%10000000
const COPPER_HALT_B as ubyte =$FF
const DMA_RESET as ubyte =$C3
const DMA_RESET_PORT_A_TIMING as ubyte =$C7
const DMA_RESET_PORT_B_TIMING as ubyte =$CB
const DMA_LOAD as ubyte =$CF
const DMA_CONTINUE as ubyte =$D3
const DMA_DISABLE_INTERUPTS as ubyte =$AF
const DMA_ENABLE_INTERUPTS as ubyte =$AB
const DMA_RESET_DISABLE_INTERUPTS as ubyte =$A3
const DMA_ENABLE_AFTER_RETI as ubyte =$B7
const DMA_READ_STATUS_BYTE as ubyte =$BF
const DMA_REINIT_STATUS_BYTE as ubyte =$8B
const DMA_START_READ_SEQUENCE as ubyte =$A7
const DMA_FORCE_READY as ubyte =$B3
const DMA_DISABLE as ubyte =$83
const DMA_ENABLE as ubyte =$87
const DMA_READ_MASK_FOLLOWS as ubyte =$BB

#pragma pop(case_insensitive)

#endif