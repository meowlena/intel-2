;====================================================================
;                           Milena Silva Braga
;                                00319002
;       Livro The Art of Assembly Language usado como referência
;====================================================================

.model small

.STACK 100h


.DATA
    comando    DB 512 DUP(?)    ; nome do arquivo de entrada

.CONST
    CR          equ 0Dh         ; Código ASCII de CR
    LF          equ 0Ah         ; Código ASCII de LF
    msgStartup  DB  "# Verificador de correspondencia de arquivo # ", CR, LF, 0
    msgInput    DB  "Digite o comando desejado: ", CR, LF, 0

.CODE ; Begin code segment
.STARTUP ; Generate start-up code
;--------------------------------------------------------------------------------cut

;---interação com usuário (comando)------------------------------ 
    lea si, msgStartup
    call printMsg
    call printEnter

    lea si, msgInput
    call printMsg
    call printEnter

    lea si, comando
    call readString
    call printEnter

    lea si, comando
    call printMsg
    call printEnter

;--------------------------------------------------------------------

;---processsamento comando-------------------------------------------

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

;
;--------------------------------------------------------------------
	end
;--------------------------------------------------------------------