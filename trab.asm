;====================================================================
;                           Milena Silva Braga
;                                00319002
;       Livro The Art of Assembly Language usado como referência
;====================================================================

.model small

.STACK 100h


.DATA
    comando         DB 512 DUP(?)    ; nome do arquivo de entrada
    sizeCode        DB 0
    Quociente       DB 132
    Resto           DB 0
    NumAlgarismos   DB 0
    BufferConversao DB 0

.CONST
    CR          equ 0Dh         ; Código ASCII de CR
    LF          equ 0Ah         ; Código ASCII de LF
    space       equ 20h         ; Código ASCII de espaço
    msgStartup  DB  "# Verificador de correspondencia de arquivo # ", CR, LF, 0
    msgInput    DB  "Digite o comando desejado: ", CR, LF, 0
    ConstDez    DB 10
    ConstHex    DB 16
.CODE ; Begin code segment
.STARTUP ; Generate start-up code
;-------------------------------------------------------------------

;---interação com usuário (comando)---------------------------------
    
    lea si, msgStartup
    call printMsg
    call printEnter

    lea si, msgInput
    call printMsg
    call printEnter

    lea si, comando
    call readString
    call printEnter


;--------------------------------------------------------------------

;---processsamento comando-------------------------------------------

    lea bp, comando
    
    call ConverteAsciiHexToDecimal


    mov al, BufferConversao
    
    call printNumeroHex
    call printEnter


;--------------------------------------------------------------------

;--------------------------------------------------------------------
.EXIT
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;Funcao: imprime um char na tela
;Entra:  (A) -> AL -> char a ser impresso
;--------------------------------------------------------------------
printChar proc near 
    mov ah, 0Eh ; imprime cada caractere incrementando o cursor 
    mov bh, 0 ; page number (???)
    mov cx, 1 ; times to print the character
    int 10h ;calls interruption
    ret
printChar endp

;--------------------------------------------------------------------
;Funcao: Printa uma mensagem
;Entra:  (A) -> Si -> ponteiro pra mensagem
;--------------------------------------------------------------------
printMsg proc near
    loopPM:
        mov al, [si]
        call printChar
        inc si
        cmp [si], LF
        jz retPM
        cmp [si], 0
        jz retPM
        jmp loopPM
    retPM:
        ret
printMsg endp
;--------------------------------------------------------------------
;Funcao: Printa uma quebra de linha
;--------------------------------------------------------------------
printEnter proc near
    mov al, CR
    call printChar
    mov al, LF
    call printChar
    ret
printEnter endp

;
;--------------------------------------------------------------------
;Funcao: Lê caractere do teclado
;Entra:  (A) -> Si -> ponteiro pra onde vai ser salvo o conteúdo lido
;--------------------------------------------------------------------
readString proc near
    read:
        mov ah, 0h      ;; seta modo
        int 16h         ;; pra ler caractere do teclado

        cmp al, 0Dh     ;; compara se caractere é enter
        jz readRet      ;; se for, condição de parada 
        
        mov [si], al
        inc si
        call printChar  ;; imprime caractere lido
        
        jmp read   ;; se não, continua chamadas recursivas
    readRet:
        ret

readString endp


;--------------------------------------------------------------------
;Funcao: printa um numero na tela na base hexa
;Entra:  (A) -> ax -> numero a ser printado
;--------------------------------------------------------------------
; TODO adaptar pra hex
printNumeroHex proc near
    mov Quociente, al
    NumPraASCIIDivisaoLoopHex2:
            mov al, Quociente
            mov ah, 0

            div ConstHex
            mov Quociente, al
            mov Resto, ah

            cmp Resto, 10
            jge printHexLetter

            add Resto, 48
            jmp printHexNotLetter

            printHexLetter:
            add Resto, 55

            printHexNotLetter:
            mov al, Resto
            mov ah, 0
            push ax

            inc numAlgarismos

            cmp Quociente, 0
            je loopEscreveNumeroHex2
            jmp NumPraASCIIDivisaoLoopHex2

    loopEscreveNumeroHex2:
        cmp numAlgarismos, 0
        je fimEscreveNumero2

        pop ax
        call printChar

        dec numAlgarismos

        jmp loopEscreveNumeroHex2

    fimEscreveNumeroHex2:
    ret
printNumeroHex endp

;--------------------------------------------------------------------
;Funcao: printa um numero na tela na base decimal
;Entra:  (A) -> ax -> numero a ser printado
;--------------------------------------------------------------------
; TODO adaptar pra hex
printNumeroDecimal proc near
    mov Quociente, al
    NumPraASCIIDivisaoLoop2:
            mov al, Quociente
            mov ah, 0

            div ConstDez
            mov Quociente, al
            mov Resto, ah

            add Resto, 48
            mov al, Resto
            mov ah, 0
            push ax

            inc numAlgarismos

            cmp Quociente, 0
            je loopEscreveNumero2
            jmp NumPraASCIIDivisaoLoop2

    loopEscreveNumero2:
        cmp numAlgarismos, 0
        je fimEscreveNumero2

        pop ax
        call printChar

        dec numAlgarismos

        jmp loopEscreveNumero2

    fimEscreveNumero2:
    ret
printNumeroDecimal endp

;--------------------------------------------------------------------
;Funcao: converte ascii hex pra decimal
;Entra:  (A) -> bp -> ponteiro para código de verificação  
;        (S) -> BufferConversao: com o valor 
;--------------------------------------------------------------------
ConverteAsciiHexToDecimal proc near
    ; verifica se está entre 0 e 9
    ; se não, verifica se está entre A e F 
    ; (a e f converte pra upper case)
    cmp byte ptr [bp], '0'
    jl charInvalid
    cmp byte ptr [bp], '9'
    jg isUpperCaseHex

    mov bl, byte ptr [bp]
    mov BufferConversao, bl

    ; convertendo ascii pra numero
    sub BufferConversao, 48
    ret

    retCheckHex:
        ; convertendo o valor das letras 
        sub BufferConversao, 55
    ret

isUpperCaseHex:
    ; seta flag marcando que está entre A e F por padrão
    ; verifica se está entre A e F
    ; se não, verifica se está entre a e f

    cmp byte ptr [bp], 'A'
    jl charInvalid

    cmp byte ptr [bp], 'F'
    jg isLowerCaseHex
    
    mov bl, byte ptr [bp]
    mov BufferConversao, bl

    jmp retCheckHex

isLowerCaseHex:
    ; verifica se está entre a e f
    ; se sim, converte pra upper case
    ; se não, é char inválido (não hexadecimal)
    cmp byte ptr [bp], 'a'
    jl charInvalid

    cmp byte ptr [bp], 'f'
    jg charInvalid
    
    ; converte pra upper case
    mov bl, byte ptr [bp]
    mov BufferConversao, bl
    sub BufferConversao, 32

    jmp retCheckHex

charInvalid:
    ret
ConverteAsciiHexToDecimal endp
;
;--------------------------------------------------------------------
	end
;--------------------------------------------------------------------