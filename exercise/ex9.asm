    processor 6502
    seg code
    org $F000
start:
    lda #1
loop:
    clc
    adc #1
    cmp #10
    bne loop
    org $FFFC
    .word start
    .word start