    processor 6502
    include "test/macros/macro.h"
    include "test/macros/vcs.h"
    seg.u var
    org $80
    ;6502 processor documentation -> http://www.6502.org/tutorials/6502opcodes.html
mx byte ;missile x pos
my byte ;missile y pos
p0x byte ;player0 x pos
p0y byte ;player0 y pos
p0s word ;player0 sprite ptr
p0c word ;player0 colour ptr
p0ao byte ;p0 animation offset
p0h = 9;player 0 height = current location -location of p0spr
p1x byte ;player1 x pos
p1y byte ;player1 y pos
p1s word ;player1 sprite ptr
p1c word ;player1 colour ptr
p1h = 9
rng byte ;generate psedo random numbers for p1y
score byte;2-digit score stored as BCD
highest byte;2-digit timer stored as BCD
temp byte;auxiliary variable to store temp values
oneoffset word;lookup table offset for the score ones digit
tenoffset word
scrsp byte;store the sprite bit pattern for the score
hsp byte;highest sprite
dgh = 5;digit height
tclr byte;terrain colour
rclr byte;river colour
    seg code 
    org $F000
res:;reset
    CLEAN_START
    lda #10
    sta p0y ;p0y=10
    lda #68
    sta p0x ;p0x=68
    lda #83
    sta p1y
    lda #54
    sta p1x
    lda #%11010100
    sta rng
    lda #0
    sta score;score=0
    sta highest;timer=0
    mac DRM;missile drawing m_acro 
        lda #%00000000
        cpx my;compare scanline with missile y pos
        bne .skmd
        lda #%00000010;second bit enables m0 display
        inc my
.skmd:;skip missile draw
    sta ENAM0;store value on TIA missile register
    endm
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
    repeat 32;CHANGED
        sta WSYNC
    repend
    lda p0x
    ldy #0
    jsr setx ;set player0 horizontal position
    lda p1x
    ldy #1
    jsr setx ;set player1 horizontal position
    lda mx;missle x pos
    ldy #2 
    jsr setx
    jsr calcdigoff ; calculate scoreboard digits lookup table offset
    jsr genjetsn ;configure and enable constant jet sound on background
    sta WSYNC
    sta HMOVE ;apply horizontal movements set by subroutine
    lda #0
    sta VBLANK
    ;scoreboard setup
    ;clear TIA register before each frame
    lda #0 
    sta PF0
    sta PF1
    sta PF2
    sta GRP0
    sta GRP1
    sta CTRLPF
    sta COLUBK
    lda #$1E
    sta COLUPF
    ldx #dgh;start X counter with 5 (height of digits)
scrdgtl:;scire digit loop
    ldy tenoffset;get the tens digit offset for the score
    lda digit,Y;load the bit pattern from lookup table
    and #$F0;mask/remove the graphics for the ones digit
    sta scrsp;save the score tens digit pattern in a variable
    ldy oneoffset;get the ones digit offset for the score
    lda digit,Y;load the digit bit pattern from lookup table
    and #$0F;mask/remove the graphics for the tens digit
    ora scrsp;merge it with the saved tens digit sprite
    sta scrsp;and save it
    sta WSYNC;wait for the end of scanline
    sta PF1;update the playfield to display the score sprite
    ldy tenoffset+1;get the left digit offset for the highest
    lda digit,Y;load the digit pattern from lookup table
    and #$F0;mask/remove the graphics for the ones digit
    sta hsp;save the highest tens digit pattern in a variable
    ldy oneoffset+1;get the ones digit offset for the highest
    lda digit,Y;load digit pattern from the lookup table
    and #$0F;mask/remove the graphics for the tens digit
    ora hsp;merge with the saved tens digit graphics
    sta hsp;and save it
    jsr slp12;wastes some cycles
    sta PF1;update the playfield for highest display
    ldy scrsp;preload for the next scanline
    sta WSYNC;wait for next scanline
    sty PF1;update playfield for the score display
    inc tenoffset
    inc tenoffset+1
    inc oneoffset
    inc oneoffset+1;increment all digits for the next line of data
    jsr slp12;waste some cycles
    dex;X--
    sta PF1;update the playfield for the highest display
    bne scrdgtl;if dex != 0, then branch to ScoreDigitLoop
    sta WSYNC
    lda #0
    sta PF0
    sta PF1
    sta PF2
    repeat 3
        sta WSYNC
    repend
vl;visible lines
    ;colour palette -> https://en.wikipedia.org/wiki/List_of_video_game_console_palettes
    lda tclr
    sta COLUPF               ; set the terrain background color
    lda rclr
    sta COLUBK   
    lda #%00000001 ;enable reflection of playfield
    sta CTRLPF ;control playfield register (left most bit decides on reflection or repetition)
    lda #$F0
    sta PF0
    lda #$FC
    sta PF1
    lda #0
    sta PF2
    ldx #84  ;half of visible lines because of 2-line kernel usag
.vll:;visible line loop
    DRM;draw missile macro
.check_p0;check if p0 is ready to render
    txa ;transfer x to a register
    sec ;set the carry flag for subtraction
    sbc p0y ;subtract p0 y from current line
    cmp p0h ;check if sprite is in render position
    bcc .dp0 ;if rs < p0h, draw p0
    lda #0 ;else set a register to 0 in order to prepare for next iter
.dp0;draw player0 sprite
    clc;clear carry flag before addition
    adc p0ao
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
    lda #0
    sta p0ao
;overcan
    lda #2
    sta VBLANK
    ldx #30 ;30 ovescan scanlines
ovs:
    sta WSYNC
    dex ;x--
    bne ovs ;jump to ovs if x!=0
    lda #0
    sta VBLANK ;disable blank scanlines
    ;process input for p0 (up-down-left-right)
p0up:;check if p0 is pressed up arrow
    lda #%00010000;p0 up
    bit SWCHA
    bne p0dw
    lda p0y
    cmp #70
    bpl p0dw
    inc p0y;p0 y pos++
    lda #0
    sta p0ao
p0dw:;p0 down
    lda #%00100000
    bit SWCHA
    bne p0le
    lda p0y
    cmp #5
    bmi p0le
    dec p0y;p0 y pos--
    lda #0
    sta p0ao
p0le:;p0 left
    lda #%01000000
    bit SWCHA
    bne p0ri
    lda p0x
    cmp #32
    bmi p0ri
    dec p0x;p0 x pos--
    lda #9
    sta p0ao
p0ri:;p0 right
    lda #%10000000
    bit SWCHA
    bne mish 
    lda p0x
    cmp #102
    bpl mish 
    inc p0x;p0 x pos++
    lda #9
    sta p0ao
mish:;missile shoot
    lda #%10000000
    bit INPT4;check button pressed
    bne df
    lda p0x
    clc
    adc #5
    sta mx;store mxpos as p0xpos
    lda p0y
    clc
    adc #4
    sta my;store mypos as p0ypos
df:;if none action taken by p0
up1pos:;update p1 y position
    lda p1y ;transfer p1 y pos to a register
    clc ;clear carry register for comparison
    cmp #0 ;check if p1 reached to 0 
    bmi .resp1pos ;reset p1 y position to top if it reached 0
    dec p1y ;else p1y--
    jmp endpos ;jump over reset
.resp1pos:;reset p1 position
    jsr GO
    jsr rngp1 
endpos:
.cp0p1:;p0 p1 collision chck
    lda #%10000000;CXPPMM bit 7 detects p0 and p1 collision
    bit CXPPMM ;check CXPPMM bit 7 
    bne .CP0P1 ;jump if collided
    jsr strclr
    jmp .cm0p1
.CP0P1:;when p0 collides with p1
    jsr GO ;game over
.cm0p1:;missile 0 p1 collision check
    lda #%10000000
    bit CXM0P;m0 p1 collision check register
    bne .CM0P1
    jmp .endclch
.CM0P1;when m0 collides with p1
    sed ;decimal mode for incrementing the score
    lda score
    clc
    adc #1
    sta score
    cld ;disable decimal mode
    lda #0
    sta my;make missile disappear after collision
    jsr rngp1
    ldx highest
    cpx score
    bcc .sethigh
    jmp .endclch

.sethigh:
    sed ;decimal mode for incrementing the score
    lda highest
    clc
    adc #1
    sta highest
    cld ;disable decimal mode
.endclch;end collision check
    sta CXCLR;clear collisions
    jmp dk
genjetsn subroutine
    lda #3
    sta AUDV0
    lda p0y
    repeat 3
        lsr
    repend
    sta temp
    lda #31
    sec
    sbc temp
    sta AUDF0 ;pitch
    lda #1
    sta AUDC0
    rts
strclr subroutine;set terrain river colour
    lda #$C2
    sta tclr;set terrain color to green
    lda #$84
    sta rclr;set river color to blue
    rts
setx subroutine ;set object's x positon subroutine
    sta WSYNC
    sec ;set carry flag
.div:;division loop -since 6502 opcode doesnt include any division, division is achieved via series of subtractions
    sbc #15 ;subtraction takes 2 clock cycles and branching takes 3 clock cycle thus making a total of 5 clock cycle in each
            ;subtraction. each CPU clock cycle is equivelent of 3 TIA clock cycles so each division is 15 pixel. to determine 
            ;p0_x location calculate rough position by dividing by 15 and use remainder to fine tune the exact position
    bcs .div ;jump to div if a<0
    eor #7 ;exclusive or with %00000111 to fine tune the x position 
    repeat 4 ;HMP0 uses 4 bits %xxxx0000
        asl
    repend
    sta HMP0,Y
    sta RESP0,Y
    rts
GO subroutine;game over subroutine
    lda #$30
    sta tclr;set terrain color to red
    sta rclr;set river color to red
    lda #0
    sta score;Score = 0
    rts
rngp1 subroutine;random number generator for p1 starting position
    lda rng
    asl
    eor rng
    asl
    eor rng
    asl
    asl
    eor rng
    asl
    rol rng ;performs a series of shifts and bit operations
    lsr
    lsr;divide the value by 4 with 2 right shifts
    sta p1x;save random number on player1 x position
    lda #30
    adc p1x;30+p1x to compensate for left playfield 
    sta p1x;set new value to the p1x
    lda #96
    sta p1y;set the y-position to the top of the screen
    rts
calcdigoff subroutine
    ldx #1;X register is the loop counter
prepscrl;this will loop twice, first X=1, and then X=0
    lda score,X;load A with highest (X=1) or Score (X=0)
    and #$0F;remove the tens digit by masking 4 bits 00001111
    sta temp;save the value of A into Temp
    asl;shift left (it is now N*2)
    asl;shift left (it is now N*4)
    adc temp;add the value saved in Temp (+N)
    sta oneoffset,X;save A in OnesDigitOffset+1 or OnesDigitOffset
    lda score,X;load A with highest (X=1) or Score (X=0)
    and #$F0;remove the ones digit by masking 4 bits 11110000
    lsr;shift right (it is now N/2)
    lsr;shift right (it is now N/4)
    sta temp;save the value of A into Temp
    lsr;shift right (it is now N/8)
    lsr;shift right (it is now N/16)
    adc temp;add the value saved in Temp (N/16+N/4)
    sta tenoffset,X;store A in TensDigitOffset+1 or TensDigitOffset
    dex;X--
    bpl prepscrl; while X >= 0, loop to pass a second time
    rts
slp12 subroutine
    rts
digit:
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00110011          ;  ##  ##
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %00010001          ;   #   #
    .byte %01110111          ; ### ###
    .byte %00100010          ;  #   #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %01010101          ; # # # #
    .byte %01100110          ; ##  ##
    .byte %01010101          ; # # # #
    .byte %01110111          ; ### ###
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %01100110          ; ##  ##
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01010101          ; # # # #
    .byte %01100110          ; ##  ##
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01110111          ; ### ###
    .byte %01110111          ; ### ###
    .byte %01000100          ; #   #
    .byte %01100110          ; ##  ##
    .byte %01000100          ; #   #
    .byte %01000100          ; #   #
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