    processor 6502
    include "../macros/vcs.h"
    include "../macros/macro.h"
    seg.u var
    org $80
p0x byte ;player 0 x coordinate
    seg code
    org $F000
res: ;reset
    CLEAN_START
    ldx #$80 ;blue
    stx COLUBK
    ldx #$D0 ;green
    stx COLUPF ;make playfield green
    lda #10
    sta p0x
dk:;draw kernel
    lda #2
    sta VSYNC
    sta VBLANK
    repeat 3
        sta WSYNC
    repend
    lda #0
    sta VSYNC
    lda p0x
    and #$7F ;logical and with 0000111 to fix range
    sta WSYNC
    sta HMCLR
    sec ;set carry for subtraction
div:;division loop
    sbc #15 ;a-15
    bcs div ;loop until carry bit is set
    eor #7 ;adjust the a between -8 to 7 range with xor
    repeat 4
        asl ;4 left shifts since HMP0 onyl uses the top 4 bits
    repend
    sta HMP0 ;set fine pos
    sta RESP0 ;reset 15-step brute pos
    sta WSYNC
    sta HMOVE ;apply horizontal motion
    repeat 35 ;37-2 used blank scanlines
        sta WSYNC
    repend
    lda #0
    sta VBLANK
    repeat 160
        sta WSYNC 
    repend
    ldy #17 ;17 rows of player bitmap
d_bmap:;draw bitmap
    lda p0_bmap,Y
    sta GRP0 ;graphic register player0
    lda p0c,Y
    sta COLUP0 ;colour player0
    sta WSYNC
    dey ;y--
    bne d_bmap ;draw the sprite until whole bitmap is traversed
    lda #0
    sta GRP0 ;disable player0 graphics after whole sprite is done
    lda #$FF ;enable grass playfield
    sta PF0
    sta PF1
    sta PF2
    repeat 15
        sta WSYNC
    repend
    lda #0
    sta PF0
    sta PF1
    sta PF2
ovs:
    lda #2
    sta VBLANK
    repeat 30
        sta WSYNC
    repend
p0up:
    lda #%00010000
    bit SWCHA
    bne p0down 
    inc p0x 
p0down:
    lda #%00100000
    bit SWCHA
    bne p0left 
    dec p0x
p0left:
    lda #%01000000
    bit SWCHA
    bne p0right 
    dec p0x 
p0right:
    lda #%10000000
    bit SWCHA
    bne noip 
    inc p0x 
noip:
    ; fallback when no input was performed
    jmp dk
p0_bmap:
    byte #%00000000
    byte #%00010100
    byte #%00010100
    byte #%00010100
    byte #%00010100
    byte #%00010100
    byte #%00011100
    byte #%01011101
    byte #%01011101
    byte #%01011101
    byte #%01011101
    byte #%01111111
    byte #%00111110
    byte #%00010000
    byte #%00011100
    byte #%00011100
    byte #%00011100
p0c:
    byte #$00
    byte #$F6
    byte #$F2
    byte #$F2
    byte #$F2
    byte #$F2
    byte #$F2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$3E
    byte #$3E
    byte #$3E
    byte #$24

    org $FFFC
    .word res
    .word res