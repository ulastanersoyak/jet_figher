    processor 6502
    include "../macros/macro.h"
    include "../macros/vcs.h"
    seg code
    org $F000 ;start at cartridge reading range
start:
    CLEAN_START ;clean memory
    ldx #$80 ;blue background
    stx COLUBK ;store x as a background colour
    lda #$1C ;yellow playfield
    sta COLUPF ;store a as a playfield colour
set_frame:
    lda #2 ;same as %00000010
    sta VSYNC ;set VSYNC on
    sta VBLANK ;set VBLANK on
    ;generate 3 scanlines of sync
    repeat 3 ;a special dasm macro for repetition
        sta WSYNC 
    repend ;ends the repetition
    lda #0
    sta VSYNC ;turn off VSYNC
    ;generate 37 scanlines of vertical blank
    repeat 37
        sta WSYNC ;wait for scanline
    repend
    lda #0
    sta VBLANK ;turn off VBLANK
    ldx #%00000001 ;CTRLPF(control playfield) register's D0 flag represents repetition 
                    ;or reflection (it will be a reflection in this case)
    stx CTRLPF ;set the x to the CTRLPF register
    ;generate 192 visible scanlines
    ;skip 7 scanlines with no playfield
    ldx #0
    ;disable playfield with these 3 lines
    stx PF0
    stx PF1
    stx PF2
    repeat 7
        sta WSYNC
    repend
    ;set PF0 to 1110 (least significant bit first) and PF1-PF2 to 1111 1111
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2
    repeat 7
        sta WSYNC
    repend
    ;set next 164 scanlines only with PF0 third bit enabled (0010)
    ;disable PF1 and PF2
    ldx #0
    stx PF1
    stx PF2
    ldx #%00100000
    stx PF0 ;set PF0
    repeat 164
        sta WSYNC
    repend
    ;do the same thing as top 14 scanlines
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2
    repeat 7
        sta WSYNC
    repend
    ldx #0
    stx PF0
    stx PF1
    stx PF2
    repeat 7
        sta WSYNC
    repend
    ;generate 30 scanlines for overscreen
    lda #2
    sta VBLANK ;turn VBLANK on
    repeat 30
        sta WSYNC
    repend
    lda #0
    sta VBLANK ;turn VBLANK off
    jmp start
    org $FFFC
    .word start
    .word start