PORTA=$ffff
PORTB=$fffe

  lda #0
  sta PORTA
  ldx #0
loop:
  stx PORTB
  inx
  adc #0
  sta PORTA
  jmp loop