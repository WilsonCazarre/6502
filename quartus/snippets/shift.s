DDRA=$0803
DDRB=$0802
PORTA=$0801  ; input
PORTB=$0800  ; output

  .org $8000
reset:
  lda #$0f
  asl
  asl
  asl
  asl
  asl

  lsr
  lsr
  lsr
  lsr
  lsr
loop:
  jmp loop

nmi:
  rti

  .org $fffa
  .word nmi
  .word reset