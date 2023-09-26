    processor 6502
    include "../macros/macro.h"
    include "../macros/vcs.h"
    seg code
    org $F000
reset:
    CLEAN_START
    ldx #$80 ;blue background
    stx COLUBK
    lda #%1111 ;white playfield
    sta COLUPF
    ;set registers for player0 and player1
    lda #$48 ;player0 colour bright red
    sta COLUP0
    lda #$C6 ;player1 colour light green
    sta COLUP1
    ldy #%00000010 ;CTRLPF(control playfield) D1(second bit from the end) is set 
                    ;to 1 (meaning the playfield will be treated as scoreboard)
    sty CTRLPF 
start_frame:
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
start_kernel:
    ;draw 10 empty scanlines at the top of the frame
    repeat 10
        sta WSYNC
    repend
    ldy #0
sb_loop:
    ;display 10 scanlines for scorboard numbers
    ;get data from an array of bytes
    lda n_bmap,Y ;get the data from the bitmap at the end of the cartdidge's memory. using Y as a method of indexing the array
    sta PF1 ;store the data row in playfield1 register
    sta WSYNC ;draw a scanline
    iny ;i++
    cpy #10 ;compare y with literal 10 to determine wheter the array has been traversed or not
    bne sb_loop ;jump to scoreboard loop if array is not fully traversed
    lda #0
    sta PF1 ;disable playfield
    ;add some space between scoreboard and player sprites
    repeat 50
        sta WSYNC
    repend
    ldy #0
p0_loop: ;load player0
    lda p_bmap,Y ;load the sprite from the array at the memory location of player bitmap. using Y register as index
    sta GRP0 ;store the sprite at graphic register player 0 (GRP0)
    sta WSYNC 
    iny ;i++
    cpy #10 ;check if the array is traversed or not
    bne p0_loop ;keep looping until array is traversed
    lda #0 
    sta GRP0 ;disable GRP0 
    ldy #0
p1_loop:;do the exact same thing for player1
    lda p_bmap,Y
    sta GRP1
    sta WSYNC
    iny
    cpy #10
    bne p1_loop
    lda #0
    sta GRP1
    ;so far 10(empty space at the top)+10(scoreboard)+50(padding between scoreboard and players)+10(p0)+10(p1)=90 scanlines used
    ;fill remaining 192-90=102 lines
    repeat 102
        sta WSYNC
    repend
    ;fill 30 VBLANK overscan lines
    repeat 30
        sta WSYNC
    repend
    jmp reset
    ;define an array of bytes to draw the scoreboard number. defined near the end of the cartridge's memory.
    org $FFE8
p_bmap:
    .byte #%01111110   ;  ######
    .byte #%11111111   ; ########
    .byte #%10011001   ; #  ##  #
    .byte #%11111111   ; ########
    .byte #%11111111   ; ########
    .byte #%11111111   ; ########
    .byte #%10111101   ; # #### #
    .byte #%11000011   ; ##    ##
    .byte #%11111111   ; ########
    .byte #%01111110   ;  ######
    ;define an array of bytes to draw the scoreboard number.
    org $FFF2
n_bmap:
    .byte #%00001110   ; ########
    .byte #%00001110   ; ########
    .byte #%00000010   ;      ###
    .byte #%00000010   ;      ###
    .byte #%00001110   ; ########
    .byte #%00001110   ; ########
    .byte #%00001000   ; ###
    .byte #%00001000   ; ###
    .byte #%00001110   ; ########
    .byte #%00001110   ; ########

    org $FFFC
    .word reset
    .word reset