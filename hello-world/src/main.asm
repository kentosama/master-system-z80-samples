; ----------------------------------------------------------------------
; MEMORY MAP 
; ----------------------------------------------------------------------
.memorymap
    defaultslot 0
    slotsize $8000
    slot 0 $0000
.endme

.rombankmap
    bankstotal 1
    banksize $8000
    banks 1
.endro
; ----------------------------------------------------------------------

.bank 0 slot 0                          ; Set the bank 0 at slot 0

; ----------------------------------------------------------------------
; SDSC TAG HEADER
; ----------------------------------------------------------------------
.sdsctag 0.01, "Hello World!", "Simple Hello World! for SEGA Master System ", "Kentosama"
; ----------------------------------------------------------------------


; ----------------------------------------------------------------------
; BOOT
; ----------------------------------------------------------------------
.org $0000                              ; Program begin
    di                                  ; Disable interrupt
    im 1                                ; Set interrupt mode to 1
    ld sp, $dff0                        ; Stack pile start at $dff0
    jp Main                             ; Jump to the main subroutine
; -----------------------------------------------------------------------

; -----------------------------------------------------------------------
; SMS PAUSE
; -----------------------------------------------------------------------
.org $0066                              ; Pause
    retn                                ; Return

; ----------------------------------------------------------------------
; SEGA MASTER SYSTEM DEFINES
; ----------------------------------------------------------------------
.define VDP_CONTROL     $bf
.define VDP_DATA        $be
.define VRAM_ADDR       $4000
.define CRAM_ADDR       $c000
.define SYS_RAM         $c000
; ----------------------------------------------------------------------

; -----------------------------------------------------------------------
; MAIN PROGRAM
; -----------------------------------------------------------------------
Main:

    call SYS_ClearRAM                   ; Clear system RAM
    call VDP_Initialize                 ; Initialize VDP
    call VDP_loadFont                   ; Load font in VRAM
    call VDP_WriteMessage               ; Write message on screen
    call VDP_SetDisplayOn               ; Set display to on
-: jr -

; -----------------------------------------------------------------------

; -----------------------------------------------------------------------
; SYS CLEAR RAM
; -----------------------------------------------------------------------
SYS_ClearRAM:
    ld hl, SYS_RAM                      ; Load $c000 in hl
    ld de, $c000                        ; We start at $c000 
    ld bc, $1feb                        ; We want copy 8171 bytes
    ld (hl), l                          ; Set value to 0 (l => $00)
    ldir                                ; Copy 1 byte hl to de and decremet bc
    ret                                 ; Back to subroutine

; ----------------------------------------------------------------------
; VDP SET ADDRESS
; ----------------------------------------------------------------------
.macro VDP_SetAddress args address
    ld hl, address                      ; Load address in hl
    ld c, VDP_CONTROL                   ; Load $bf in c
    di                                  ; Disable interrupt
    out (c), l                          ; Send l to $bf 
    out (c), h                          ; Send h to $bf
    ei                                  ; Enable interrupt 
.endm
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; VDP INITIALIZE
; ----------------------------------------------------------------------
VDP_Initialize:
    
    ld hl, VDP_REGISTER_DATA            ; Load VDP_REGISTER_DATA address
    ld b, $16                           ; Write on 11 VDP registers (data with address)
    ld c, VDP_CONTROL                   ; Load VDP_CONTROL address
    otir                                ; Write on all VDP registers
    
    ; Clear VRAM
    VDP_SetAddress VRAM_ADDR            ; Use macro for set VRAM_ADDR to VDP_CONTROL
    ld b, $00                           ; Load zero value in a
    ld de, $4000                        ; Size of RAM (16384 bytes)
    ld c, VDP_DATA                      ; Load $bf in c
-: 
    ld a, b
    out (c), a                          ; Write data to VRAM
    dec de                              ; Decrement b
    ld a, d                             ; Load d in a
    or e                                ; Check if e equal 0
    jr nz, -                            ; Loop if b not equal 0

    ret
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; VDP LOAD PALETTE
; ----------------------------------------------------------------------
VDP_LoadPalette:
    VDP_SetAddress CRAM_ADDR            ; Use macro for set CRAM_ADDR to VDP_CONTROL
    ld hl, PALETTE_DATA                 ; Load palette data
    ld b, $f                            ; Set counter to $f (16 colors)
    ld c, VDP_DATA                      ; Load VDP_DATA address
    otir                                ; Send data to VDP_DATA
    ret                                 ; Return to subroutine

VDP_loadFont:                           ; Use macro for set VRAM_ADDR to VDP_CONTROL
    call VDP_LoadPalette                ; Load font palette
    VDP_SetAddress VRAM_ADDR            ; Set address in VRAM 
    ld hl, FONT_DATA                    ; Load tileset font data
    ld de, FONT_DATA_SIZE               ; Set size of tileset font data
    ld c, VDP_DATA
-:  
    ld a, (hl)                          ; Load byte in a
    out (c), a                          ; Send byte to VDP
    inc hl                              ; Incremet address
    dec de                              ; Decrement $be
    ld a, d                             ; Load $be in a
    or e                                ; Check if e equal 0
    jr nz, -                            ; Loop if not equal 0
    ret                                 ; Return to subroutine
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; VDP WRITE MESSAGE
; ----------------------------------------------------------------------
VDP_WriteMessage:
    
    VDP_SetAddress $3ace|VRAM_ADDR      ; Use macro to set $3ace (11101011001110) to VDP_CONTROL
    ld hl,MESSAGE_DATA                  ; Load MESSAGE_DATA in hl
    ld c, VDP_DATA                      ; Load VDP_DATA in c
    ld b, $ff
-:  
    ld a, (hl)                          ; Load contain of hl in a
    out (c), a                          ; Send a to VDP_DATA                    
    xor a                               ; Check if a equal 0 and store result in a
    out (c), a                          ; Send a to VDP_DATA
    inc hl                              ; Incremet hl
    dec b                               ; Decremet b
    cp b                                ; Compare b with a
    jr nz, -                            ; Loop if a not equal 0
    ret                                 ; Return to subroutine

VDP_SetDisplayOn:
    ld c, VDP_CONTROL                   ; Load $bf in c
    ld a, $40                           ; Load $40 in a 
    out (c), a                          ; Send a to VDP_CONTROL
    ld a, $81                           ; Load $81 (VDP Register 1) in a
    out (c), a                          ; Send $81 to VDP_CONTROL
    ret                                 ; Return to subroutine
; -----------------------------------------------------------------------

; -----------------------------------------------------------------------
; DATA
; -----------------------------------------------------------------------
VDP_REGISTER_DATA:
.db $04, $80, $80, $81, $ff, $82, $ff, $83, $ff, $84, $ff, $85, $fb, $86, $00, $87, $00, $88, $00, $89, $47, $8a  
VDP_REGISTER_END:

PALETTE_DATA:
.db $00, $11, $12, $13, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
PALETTE_DATA_END:

FONT_DATA:
.INCBIN	"res/font_tileset.bin" FSIZE FONT_DATA_SIZE

.asciitable
map " " to "~" = 0
.enda

MESSAGE_DATA:
.asc "HELLO SMS WORLD!!!"
.db $ff