;====================================================================
;                           Milena Silva Braga
;                                00319002
;       Livro The Art of Assembly Language usado como referência
;====================================================================

.model small

.STACK 100h


.DATA
    comando         DB 512 DUP(?)    ; nome do arquivo de entrada
    codeLength      DB 0
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
    ConstDez    equ 10
    ConstHex    equ 16

    diffAsciiNumbers    equ     48
    diffAsciiLetters    equ     55
    diffLowerToUpper    equ     32
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
    
    call getCodeLength
    mov al, codeLength
    call printNumeroDecimal

    ;mov al, BufferConversao
    
    ;call printNumeroHex
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

        cmp al, CR      ;; compara se caractere é enter
        je readRet      ;; se for, condição de parada 
        
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
printNumeroHex proc near
    mov Quociente, al
    NumPraASCIIDivisaoLoopHex:
            mov al, Quociente
            mov ah, 0

            div ConstHex
            mov Quociente, al
            mov Resto, ah

            ; testa se o Resto >= 10 para fazer
            ; a conversão com a constante adequada
            cmp Resto, 10
            jge printHexLetter


            ; conversão se Resto < 10
            add Resto, diffAsciiNumbers
            jmp printHexNotLetter

            ; conversão se Resto >= 10
            printHexLetter:
            add Resto, diffAsciiLetters

            printHexNotLetter:
            mov al, Resto
            mov ah, 0
            push ax

            inc numAlgarismos

            cmp Quociente, 0
            je loopEscreveNumeroHex
            jmp NumPraASCIIDivisaoLoopHex

    loopEscreveNumeroHex:
        cmp numAlgarismos, 0
        je fimEscreveNumero

        pop ax
        call printChar

        dec numAlgarismos

        jmp loopEscreveNumeroHex

    fimEscreveNumeroHex:
    ret
printNumeroHex endp

;--------------------------------------------------------------------
;Funcao: printa um numero na tela na base decimal
;Entra:  (A) -> ax -> numero a ser printado
;--------------------------------------------------------------------
printNumeroDecimal proc near
    mov Quociente, al
    NumPraASCIIDivisaoLoop:
            mov al, Quociente
            mov ah, 0

            div ConstDez
            mov Quociente, al
            mov Resto, ah

            add Resto, diffAsciiNumbers
            mov al, Resto
            mov ah, 0
            push ax

            inc numAlgarismos

            cmp Quociente, 0
            je loopEscreveNumero
            jmp NumPraASCIIDivisaoLoop

    loopEscreveNumero:
        cmp numAlgarismos, 0
        je fimEscreveNumero

        pop ax
        call printChar

        dec numAlgarismos

        jmp loopEscreveNumero

    fimEscreveNumero:
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
    cmp byte ptr [bp + di], '0'
    jl charInvalid
    cmp byte ptr [bp + di], '9'
    jg isUpperCaseHex

    mov bl, byte ptr [bp + di]
    mov BufferConversao, bl

    ; convertendo ascii pra numero
    sub BufferConversao, diffAsciiNumbers
    ret

    retCheckHex:
        ; convertendo o valor das letras 
        sub BufferConversao, diffAsciiLetters
    ret

isUpperCaseHex:
    ; seta flag marcando que está entre A e F por padrão
    ; verifica se está entre A e F
    ; se não, verifica se está entre a e f

    cmp byte ptr [bp + di], 'A'
    jl charInvalid

    cmp byte ptr [bp + di], 'F'
    jg isLowerCaseHex
    
    mov bl, byte ptr [bp + di]
    mov BufferConversao, bl

    jmp retCheckHex

isLowerCaseHex:
    ; verifica se está entre a e f
    ; se sim, converte pra upper case
    ; se não, é char inválido (não hexadecimal)
    cmp byte ptr [bp + di], 'a'
    jl charInvalid

    cmp byte ptr [bp + di], 'f'
    jg charInvalid
    
    ; converte pra upper case
    mov bl, byte ptr [bp + di]
    mov BufferConversao, bl
    sub BufferConversao, diffLowerToUpper

    jmp retCheckHex

charInvalid:
    ret
ConverteAsciiHexToDecimal endp


;--------------------------------------------------------------------
;Funcao: retorna tamanho do código
;Entra:  (A) -> bp -> ponteiro para código de verificação  
;        (S) -> codeLength: variável com o tamanho do código
;--------------------------------------------------------------------
getCodeLength proc near
    mov di, 0
        
        loopGetLength:
            inc di
            inc codeLength
            cmp byte ptr [bp + di], ' '
            jne loopGetLength
    ret
getCodeLength endp
;
;--------------------------------------------------------------------
	end
;--------------------------------------------------------------------