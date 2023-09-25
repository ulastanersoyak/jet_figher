    processor 6502
    seg code
    org $F000
start:
    ldy #10
loop:
    tya
    sta $80,Y
    dey
    bpl loop



    org $FFFC
    .word start
    .word start


