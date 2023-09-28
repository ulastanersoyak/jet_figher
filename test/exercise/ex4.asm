    processor 6502
    seg code
    org $F000
start:
    lda #100
    clc
    adc #5
    sec
    sbc #10

    org $FFFC
    .word start
    .word start
    