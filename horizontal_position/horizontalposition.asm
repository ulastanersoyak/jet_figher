    processor 6502
    include "../macros/macro.h"
    include "../macros/vcs.h"
    seg.u var
    org $80
p0_x byte ;player0 x coordinate
    seg code
    org $F000
res:;reset
    CLEAN_START
    ldx #$00 ;black colour
    stx COLUBK
    lda #50
    sta p0_x ;p0_x =50
dk:;draw kernel
    lda #2 ;%00000010
    sta VSYNC
    sta VBLANK
    repeat 3
        sta WSYNC
    repend
    lda #0
    sta VSYNC
    lda p0_x
    and #$7F ;%01111111 make sure a register is positive
    sec ;set crry flag before subtraction
    sta WSYNC
    sta HMCLR ;horizontal movelen clear
div:;division loop -since 6502 opcode doesnt include any division, division is achieved via series of subtractions
    sbc #15 ;subtraction takes 2 clock cycles and branching takes 3 clock cycle thus making a total of 5 clock cycle in each
            ;subtraction. each CPU clock cycle is equivelent of 3 TIA clock cycles so each division is 15 pixel. to determine 
            ;p0_x location calculate rough position by dividing by 15 and use remainder to fine tune the exact position
    bcs div ;jump to div if a<0
    eor #7 ;exclusive or with %00000111 to fine tune the x position 
    repeat 4 ;HMP0 uses 4 bits %xxxx0000
        asl
    repend
    sta HMP0 ;store the p0 position
    sta RESP0 ;reset rough position
    sta WSYNC 
    sta HMOVE ;apply fine positioning offset
    repeat 35 ;37 - 2 vblank lines used above
        sta WSYNC
    repend
    lda #0
    sta VBLANK
    repeat 60
        sta WSYNC  ; wait for 60 empty scanlines
    repend
    ldy 8          ; counter to draw 8 rows of bitmap
d_bmap:
    lda p0_bmap,Y ; load player bitmap slice of data
    sta GRP0       ; set graphics for player 0 slice
    lda p0c,Y  ; load player color from lookup table
    sta COLUP0     ; set color for player 0 slice
    sta WSYNC      ; wait for next scanline
    dey
    bne d_bmap ; repeat next scanline until finished
    lda #0
    sta GRP0       ; disable P0 bitmap graphics
    repeat 124
        sta WSYNC
    repend
ovs:
    lda #2
    sta VBLANK
    repeat 30
        sta WSYNC
    repend
    inc p0_x
    jmp dk
;lookup table for the player graphics bitmap
p0_bmap:
    byte #%00000000
    byte #%00010000
    byte #%00001000
    byte #%00011100
    byte #%00110110
    byte #%00101110
    byte #%00101110
    byte #%00111110
    byte #%00011100
;lookup table for the player colors
p0c:
    byte #$00
    byte #$02
    byte #$02
    byte #$52
    byte #$52
    byte #$52
    byte #$52
    byte #$52
    byte #$52

    org $FFFC
    .word res
    .word res
