DDRA=$0803
DDRB=$0802
PORTA=$0801  ; saida
PORTB=$0800  ; entrada

EN=%10000000
RW=%01000000
RS=%00100000

  .org $8000
  lda #$ff

  sta DDRA
  sta DDRB

  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr send_lcd_cmd

  lda #%00000001 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr send_lcd_cmd

  lda #%00001111 ; Display on; Cursor on; Cursor blink
  jsr send_lcd_cmd

  lda #%00000110 ; Entry mode set
  jsr send_lcd_cmd


  ldx #$00
next_char:
  lda message1, x
  jsr print_char
  inx
  cpx #16
  bne next_char

  lda #%11000000 ; Go to next line
  jsr send_lcd_cmd

  ldx #$00
next_char1:
  lda message2, x
  jsr print_char
  inx
  cpx #16
  bne next_char1
exit:
  jmp exit

print_char:
  sta PORTB

  lda #RS        
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        
  sta PORTA
  rts

send_lcd_cmd:
  sta PORTB

  lda #0         ; Clear E/RW/RS
  sta PORTA
  lda #EN
  sta PORTA
  lda #0         ; Clear E/RW/RS
  sta PORTA
  rts

message1:
  .byte "Hello, world!   "
message2:
  .byte "UNIFESP ICT     "