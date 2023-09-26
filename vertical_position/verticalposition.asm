    processor 6502
    include "../macros/macro.h"
    include "../macros/vcs.h"
    seg.u variables
    org $80 ;from $80 to $FF can be used to initialize "variables". since stack starts from $FF and grows towards
            ;the $80 address, variable memory can be smaller.
p0_h byte ;player sprite height
p0_y byte ;player sprite y position
    seg code
    org $F000
reset:
    CLEAN_START
    ldx #$00 ;black colour
    stx COLUBK
    lda #180
    sta p0_y ;player y pos=180
    lda #9
    sta p0_h ;player height=9
init_frame:
    lda #2
    sta VBLANK
    sta VSYNC
    repeat 3
        sta WSYNC
    repend
    lda #0
    sta VSYNC
    repeat 37
        sta WSYNC
    repend
    lda #0
    sta VBLANK
    ;draw 192 kernel scanliens
    ldx #192
dk:;draw kernel
    txa ;transfer x to a
    sec ;enable carry bit to make a subtraction 
    sbc p0_y ;a-= p0_y
    cmp p0_h ;checks if x reached to the player sprites bounds
    bcc ld_bmap ;if rs<p0_h ,load the bitmap
    lda #0 ;else a=0
ld_bmap: ;load bitmap
    tay
    lda p0_bmap,Y ;load bitmap slice of data
    sta WSYNC ;get next scanline
    sta GRP0 ;set graphics for player0 slice
    lda p0c,Y ;load player colour from lookup table
    sta COLUP0
    dex ;x--
    bne dk
ovs:;30 overscan scanlines
    lda #2
    sta VBLANK
    repeat 30
        sta WSYNC
    repend
    dec p0_y
    jmp init_frame
;lookup table for the player graphics bitmap
p0_bmap:
    byte #%00000000
    byte #%00101000
    byte #%01110100
    byte #%11111010
    byte #%11111010
    byte #%11111010
    byte #%11111110
    byte #%01101100
    byte #%00110000
;lookup table for the player colors
p0c:
    byte #$00
    byte #$40
    byte #$40
    byte #$40
    byte #$40
    byte #$42
    byte #$42
    byte #$44
    byte #$D2
;Complete ROM size adding reset addresses at $FFFC
    org $FFFC
    .word reset
    .word reset