    processor 6502
    seg Code
    org $F000
start:
    lda #10
    sta $80
    inc $80
    dec $80

    org $FFFC
    .word start
    .word start