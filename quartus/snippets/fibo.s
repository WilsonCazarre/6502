; Registradores do adaptador de interface
DDRA  = $0803
DDRB  = $0802
PORTA = $0801
PORTB = $0800

; Endereços para variáveis na RAM
N1 = $00
N2 = $01
R  = $02

  ; Usamos a diretriz .org para indicar para o assembler onde 
  ; nosso programa começa no espaço de memória
  .org $8000
  
  ; Define todos os bits de porta B como Entrada
  lda #$00 ; 0 - Entrada / 1 - Saída
  sta DDRB

  ; Define todos os bits de porta A como saída
  lda #$ff
  sta DDRA

  
restart:
  ; Inicializa N1 = 0, N2 = 1, R = 1
  lda #$00
  sta N1
  lda #$01
  sta N2
  sta R
loop:
  ; Esse loop continua executando enquanto (R - PORTB) > 0
  ; Do contrário ele pula de volta para restart, para recalcular a sequência
  lda R
  cmp PORTB
  bpl restart
  ; Exibe o valor R na PORTA, efetivamente mostrando a saída para o usuário
  sta PORTA 

  ; R = N1 + N2
  lda N1
  clc
  adc N2
  sta R

  ; N1 = N2
  lda N2
  sta N1

  ; N2 = R
  lda R
  sta N2

  jmp loop



