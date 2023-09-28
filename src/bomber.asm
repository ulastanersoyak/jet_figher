    processor 6502
    include "test/macros/macro.h"
    include "test/macros/vcs.h"
    seg.u var
    org $80
p0x byte ;player0 x pos
p0y byte ;player0 y pos
p0s word ;player0 sprite ptr
p0c word ;player0 colour ptr
p1x byte ;player1 x pos
p1y byte ;player1 y pos
p1s word ;player1 sprite ptr
p1c word ;player1 colour ptr
    seg code 
    org $F000
res:;reset
    CLEAN_START
    lda #10 
    sta p0y ;p0y=10
    lda #60
    sta p0x ;p0x=60
    lda #83
    sta p1y
    lda #54
    sta p1x
    ;p0
    lda #<p0_spr;set lookup table for p0 sprite
    sta p0s
    lda #>p0_spr
    sta p0s+1
    lda #<p0_clr;set lookup table for p0 colour
    sta p0c
    lda #>p0_clr
    sta p0c+1
    ;p1
    lda #<p1_spr;set lookup table for p0 sprite
    sta p1s
    lda #>p1_spr
    sta p1s+1
    lda #<p1_clr;set lookup table for p0 colour
    sta p1c
    lda #>p1_clr
    sta p1c+1
dk:;draw kernel
    lda #2
    sta VSYNC
    sta VBLANK
    repeat 3
        sta WSYNC ;start a new frame by renderin 3 vsync scanline
    repend
    lda #0
    sta VSYNC
    ldx #37;37 vblank lines
    sec
vbl:;vblank loop
    sta WSYNC
    dex ;x--
    bne vbl
    lda #0
    sta VBLANK ;disable blank scanlines
vl;visible lines
    ;colour palette -> https://en.wikipedia.org/wiki/List_of_video_game_console_palettes
    lda #$84 ;blue
    sta COLUBK
    lda #$C2 ;green
    sta COLUPF
    lda #%00000001 ;enable reflection of playfield
    sta CTRLPF ;control playfield register (left most bit decides on reflection or repetition)
    lda #$F0
    sta PF0
    lda #$FC
    sta PF1
    lda #0
    sta PF2
    ldx #96 ;half of visible lines because of 2-line kernel usage
.vll:;visible line loop
.check_p0;check if p0 is ready to render
    txa ;transfer x to a register
    sec ;set the carry flag for subtraction
    sbc p0y ;subtract p0 y from current line
    cmp p0h ;check if sprite is in render position
    bcc .dp0 ;if rs < p0h, draw p0
    lda #0 ;else set a register to 0 in order to prepare for next iter
.dp0;draw player0 sprite
    tay ;transfer a to y
    lda (p0s),Y
    sta WSYNC
    sta GRP0
    lda (p0c),Y
    sta COLUP0

.check_p1;check if p1 is ready to render
    txa ;transfer x to a register
    sec ;set the carry flag for subtraction
    sbc p1y ;subtract p0 y from current line
    cmp p1h ;check if sprite is in render position
    bcc .dp1 ;if rs < p0h, draw p0
    lda #0 ;else set a register to 0 in order to prepare for next iter
.dp1;draw player1 sprite
    tay ;transfer a to y
    lda #%00000101
    sta NUSIZ1
    lda (p1s),Y
    sta WSYNC
    sta GRP1
    lda (p1c),Y
    sta COLUP1

    dex
    bne .vll

;overcan!!
    lda #2
    sta VBLANK
    ldx #30 ;30 ovescan scanlines
ovs:
    sta WSYNC
    dex ;x--
    bne ovs ;jump to ovs if x!=0
    lda #0
    sta VBLANK ;disable blank scanlines
    jmp dk
p0_spr:;p0 sprite
    .byte #%00000000         ;
    .byte #%00010100         ;   # #
    .byte #%01111111         ; #######
    .byte #%00111110         ;  #####
    .byte #%00011100         ;   ###
    .byte #%00011100         ;   ###
    .byte #%00001000         ;    #
    .byte #%00001000         ;    #
    .byte #%00001000         ;    #
p0h =.-p0_spr;player 0 height = current location -location of p0spr
p0_trn:;p0 turn sprite
    .byte #%00000000         ;
    .byte #%00001000         ;    #
    .byte #%00111110         ;  #####
    .byte #%00011100         ;   ###
    .byte #%00011100         ;   ###
    .byte #%00011100         ;   ###
    .byte #%00001000         ;    #
    .byte #%00001000         ;    #
    .byte #%00001000         ;    #
p1_spr:;p1 sprite
    .byte #%00000000         ;
    .byte #%00001000         ;    #
    .byte #%00001000         ;    #
    .byte #%00101010         ;  # # #
    .byte #%00111110         ;  #####
    .byte #%01111111         ; #######
    .byte #%00101010         ;  # # #
    .byte #%00001000         ;    #
    .byte #%00011100         ;   ###
p1h=.-p1_spr
p0_clr:;p0 colour
    .byte #$00
    .byte #$FE
    .byte #$0C
    .byte #$0E
    .byte #$0E
    .byte #$04
    .byte #$BA
    .byte #$0E
    .byte #$08
p0_tclr:;p0 turn colour
    .byte #$00
    .byte #$FE
    .byte #$0C
    .byte #$0E
    .byte #$0E
    .byte #$04
    .byte #$0E
    .byte #$0E
    .byte #$08
p1_clr:;p1 colour
    .byte #$00
    .byte #$32
    .byte #$32
    .byte #$0E
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40

    org $FFFC
    .word res
    .word res