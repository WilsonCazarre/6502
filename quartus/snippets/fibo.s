DDRA=$0803
DDRB=$0802
PORTA=$0801
PORTB=$0800

; EN=%10000000
; RW=%01000000
; RS=%00100000

N1=$00
N2=$01
R=$02


  ; lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  ; sta PORTB

  ; lda #0         ; Clear E/RW/RS
  ; sta PORTA
  ; lda #EN
  ; sta PORTA
  ; lda #0         ; Clear E/RW/RS
  ; sta PORTA

  ; lda #%00000001 ; Clear display
  ; sta PORTB

  ; lda #0         ; Clear E/RW/RS
  ; sta PORTA
  ; lda #EN
  ; sta PORTA
  ; lda #0         ; Clear E/RW/RS
  ; sta PORTA

  .org $8000
  
  lda #$00 ; 0 - Input / 1 - Output
  sta DDRB

  lda #$ff
  sta DDRA

restart:
  lda #$01
  sta N1
  sta N2
  sta R
loop:
  lda R
  cmp PORTB
  bcc restart
  sta PORTA
  lda N1
  clc
  adc N2
  sta R
  lda N2
  sta N1
  lda R
  sta N2
  jmp loop



