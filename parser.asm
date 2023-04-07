.model small

.STACK 100h

.DATA
    code            DB 512 DUP(?)    ; nome do arquivo de entrada
    codeLength      DB 0
    Quociente       DB 132
    Resto           DB 0
    NumAlgarismos   DB 0
    BufferConversao DB 0

    command         DB 512 DUP(?)

.CONST
    CR          equ 0Dh         ; Código ASCII de CR
    LF          equ 0Ah         ; Código ASCII de LF
    space       equ 20h         ; Código ASCII de espaço
    msgStartup  DB  "# Verificador de correspondencia de arquivo # ", CR, LF, 0
    msgInput    DB  "Digite o comando desejado: ", CR, LF, 0
    ConstDez    db 10
    ConstHex    db 16

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

    lea si, command
    call readString

    call printEnter

    lea si, command
    call printMsg

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
;
;--------------------------------------------------------------------
	end
;--------------------------------------------------------------------