DDRA=$0803
DDRB=$0802
PORTA=$0801
PORTB=$0800
  
  .org $8000
reset:
  lda #$00 
  sta DDRB ; Set PORTB as input

  lda #$ff
  sta DDRA ; Set PORTB as output

loop:
  lda PORTB
  sta PORTA
  jmp loop