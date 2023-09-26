    processor 6502
    include "../macros/macro.h"
    include "../macros/vcs.h"
    seg code
    org $F000
    ;painting the CRT (the kernel) requires 3 vertical sync lines, 37 vertical blank lines, 
    ;192 visible lines (what user sees) and 30 overscanlines in the exact order 
start:
    CLEAN_START ;macro for safely cleaning of memory and TIA
    ;start a new frame by turning on VBLANK and VSYNX
next_frame:
    lda #2 ;same as the binary value %00000010 
    sta VBLANK ;turn on VBLANK
    sta VSYNC ;turn on VSYNC    
    ;generate 3 lines of VSYNC
    sta WSYNC ;wait for VSYNC 
    sta WSYNC
    sta WSYNC
    lda #0
    sta VSYNC; turn off VSYNC
    ;generate 37 scanlines of vertical blank
    ldx #37
vb_loop:
    sta WSYNC ;hit WSYNC and wait for the next scanline
    dex ;x--
    bne vb_loop ;if x!=0 jump to vb_loop
    lda #0
    sta VBLANK ;turn off VBLANK
    ;generate visible scanlines (192 lines)
    ldx #192;
vsl_loop:
    stx COLUBK ;set background colour to x
    sta WSYNC ;wait for the scaline
    dex ;x--
    bne vsl_loop ;if x!=0 jump to vsl_loop
    ;generate 30 scanlines of overscan to complete the frame
    lda #2 ;turn on VBLANK again
    sta VBLANK
    ldx #30
ovs_loop
    sta WSYNC ;wait for the next scaline
    dex ;x--
    bne ovs_loop ;if x!=0 jump to vsl_loop
    jmp next_frame

    ;complete ROM size to 4kb
    org $FFFC
    .word start
    .word start