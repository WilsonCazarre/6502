DDRA=$0803
DDRB=$0802
PORTA=$0801
PORTB=$0800

reset:
  ldx #$00
loop:
  stx $00
  lda $00
  inx
  bne loop

  jmp reset