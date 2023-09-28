    processor 6502
    include "../include/macro.h"
    include "../include/vcs.h"
    seg.u var
    org $80
p0x byte ;player0 x pos
p0y byte ;player0 y pos
p1x byte ;enemy x pos
p1y byte ;enemy y pos
    seg code 
    org $F000
res:;reset
    CLEAN_START
    lda #10 
    sta p0y ;p0y=10
    lda #60
    sta p0x ;p0x=60
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
    sta VBLANK
    dex ;x--
    bne vbl
    lda #0
    sta VBLANK
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
    ldx #192 ;count of remaining scanlines
.vll:;visible line loop
    sta WSYNC
    dex ;x--
    bne .vll ;jmp to .vll if x!=0
    lda #2
    sta VBLANK
    ldx #30 ;30 ovescan scanlines
ovs:
    sta WSYNC
    dex ;x--
    bne ovs ;jump to ovs if x!=0
    lda #0
    sta VBLANK
    jmp dk

    org $FFFC
    .word res
    .word res