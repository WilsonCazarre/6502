DDRA=$0803
DDRB=$0802
PORTA=$0801
PORTB=$0800

  .org $8000
reset:
  sei
  lda #$40
  cli
exit:
  jmp exit

nmi:
  lda #$50
  rti

  .org $fffa
  .word nmi
  .word reset
