; ========================================================================================
; CALCULADORA DIDÁTICA EM ASSEMBLY x86 (32-BITS)
; Portável entre Windows e Linux usando a Biblioteca Padrão do C (libc)
; ========================================================================================

; ----------------------------------------------------------------------------------------
; DECLARAÇÕES EXTERNAS
; Aqui avisamos ao montador (assembler) que essas funções não estão neste arquivo.
; Elas serão injetadas depois pelo "Linker" (geralmente o GCC) usando a biblioteca do C.
; ----------------------------------------------------------------------------------------
extern printf           ; Importa a função printf do C para imprimir textos na tela
extern scanf            ; Importa a função scanf do C para ler o teclado do usuário

; ----------------------------------------------------------------------------------------
; SEÇÃO DE DADOS INICIALIZADOS (.data)
; Onde declaramos nossas constantes e textos que já têm um valor definido desde o início.
; O 'db' significa "Define Byte" (define uma cadeia de caracteres, 1 byte por letra).
; O '0' no final de cada string é o "Null Terminator", obrigatório na linguagem C.
; ----------------------------------------------------------------------------------------
section .data           ; Indica o início da seção de dados estáticos
    msg_titulo  db "=== CALCULADORA ASSEMBLY ===", 10, 0 ; Texto de título com quebra de linha (10)
    msg_n1      db "Digite o 1o numero inteiro: ", 0     ; Texto pedindo o primeiro número
    msg_n2      db "Digite o 2o numero inteiro: ", 0     ; Texto pedindo o segundo número
    msg_menu    db "Escolha: 1(+) 2(-) 3(*) 4(/): ", 0   ; Texto do menu de operações
    msg_res     db "Resultado: %d", 10, 10, 0            ; Molde para imprimir o resultado inteiro (%d)
    msg_erro    db "Erro: Divisao por zero!", 10, 0      ; Mensagem de erro matemático
    fmt_int     db "%d", 0                               ; Molde para o scanf ler um inteiro (%d)

; ----------------------------------------------------------------------------------------
; SEÇÃO DE DADOS NÃO-INICIALIZADOS (.bss)
; Onde reservamos espaço na memória RAM para as variáveis que mudarão durante a execução.
; O 'resd 1' significa "Reserve Double-word" (reserva 4 bytes na memória para 1 variável).
; ----------------------------------------------------------------------------------------
section .bss            ; Indica o início da seção de variáveis vazias
    num1    resd 1      ; Reserva 4 bytes para armazenar o primeiro número digitado
    num2    resd 1      ; Reserva 4 bytes para armazenar o segundo número digitado
    opcao   resd 1      ; Reserva 4 bytes para armazenar a escolha do menu do usuário
    result  resd 1      ; Reserva 4 bytes para armazenar o resultado da conta

; ----------------------------------------------------------------------------------------
; SEÇÃO DE CÓDIGO (.text)
; Onde a verdadeira mágica acontece. Aqui escrevemos as instruções para a CPU.
; ----------------------------------------------------------------------------------------
section .text           ; Indica o início da seção do código-fonte (texto executável)
    global main         ; Torna o rótulo 'main' visível para o Linker (ponto de entrada)

main:                   ; Rótulo indicando onde o programa começa
    
    ; --- PREPARAÇÃO DA FUNÇÃO MAIN (PROLÓGO) ---
    push ebp            ; Salva o valor atual do registrador base da pilha (EBP)
    mov ebp, esp        ; Atualiza o ponteiro base (EBP) para apontar para o topo da pilha (ESP)

    ; --- IMPRIME O TÍTULO ---
    push msg_titulo     ; Coloca o endereço da string do título no topo da pilha como argumento
    call printf         ; Chama a função printf do C, que vai ler o topo da pilha
    add esp, 4          ; Limpa a pilha (remove os 4 bytes do argumento que colocamos no push)

    ; --- LÊ O PRIMEIRO NÚMERO ---
    push msg_n1         ; Coloca o endereço da mensagem "Digite o 1o numero..." na pilha
    call printf         ; Chama o printf para exibi-la
    add esp, 4          ; Limpa a pilha (4 bytes da mensagem)
    push num1           ; Coloca o endereço da variável 'num1' na pilha (onde salvar o dado)
    push fmt_int        ; Coloca o formato "%d" na pilha (como ler o dado)
    call scanf          ; Chama o scanf (lê teclado) baseado nos dois argumentos acima
    add esp, 8          ; Limpa a pilha (4 bytes de 'num1' + 4 bytes de 'fmt_int' = 8)

    ; --- LÊ O SEGUNDO NÚMERO ---
    push msg_n2         ; Coloca o endereço da mensagem do 2º número na pilha
    call printf         ; Chama o printf para exibi-la
    add esp, 4          ; Limpa a pilha (4 bytes)
    push num2           ; Coloca o endereço da variável 'num2' na pilha
    push fmt_int        ; Coloca o formato "%d" na pilha
    call scanf          ; Chama o scanf para ler o segundo número
    add esp, 8          ; Limpa a pilha (8 bytes removidos)

    ; --- LÊ A OPÇÃO DO MENU ---
    push msg_menu       ; Coloca o endereço da mensagem do menu na pilha
    call printf         ; Chama o printf para mostrar o menu
    add esp, 4          ; Limpa a pilha (4 bytes)
    push opcao          ; Coloca o endereço da variável 'opcao' na pilha
    push fmt_int        ; Coloca o formato "%d" na pilha
    call scanf          ; Chama o scanf para ler a escolha (1, 2, 3 ou 4)
    add esp, 8          ; Limpa a pilha (8 bytes)

    ; --- LÓGICA DE DECISÃO (SWITCH-CASE EM ASSEMBLY) ---
    mov eax, [opcao]    ; Move o valor (conteúdo) digitado em 'opcao' para o registrador EAX
    cmp eax, 1          ; Compara o valor de EAX com o número 1
    je op_soma          ; Se for igual (Jump if Equal), pula para o rótulo 'op_soma'
    cmp eax, 2          ; Compara o valor de EAX com o número 2
    je op_subtracao     ; Se for igual, pula para o rótulo 'op_subtracao'
    cmp eax, 3          ; Compara o valor de EAX com o número 3
    je op_multiplicacao ; Se for igual, pula para o rótulo 'op_multiplicacao'
    cmp eax, 4          ; Compara o valor de EAX com o número 4
    je op_divisao       ; Se for igual, pula para o rótulo 'op_divisao'
    jmp fim             ; Se não for nenhuma opção (Jump incondicional), pula para o fim

    ; ------------------------------------------------------------------------------------
    ; ROTINAS DE CÁLCULO
    ; ------------------------------------------------------------------------------------

op_soma:                ; Rótulo da operação de Adição
    mov eax, [num1]     ; Move o conteúdo do primeiro número para o registrador EAX
    add eax, [num2]     ; Soma EAX com o conteúdo do segundo número (resultado fica no EAX)
    mov [result], eax   ; Copia o valor de EAX (resultado final) para a variável 'result'
    jmp imprime_res     ; Pula direto para a rotina que imprime na tela, ignorando os outros blocos

op_subtracao:           ; Rótulo da operação de Subtração
    mov eax, [num1]     ; Move o conteúdo de 'num1' para EAX
    sub eax, [num2]     ; Subtrai 'num2' de EAX (resultado fica no EAX)
    mov [result], eax   ; Guarda o resultado da subtração na variável 'result'
    jmp imprime_res     ; Pula para imprimir o resultado

op_multiplicacao:       ; Rótulo da operação de Multiplicação
    mov eax, [num1]     ; Move o conteúdo de 'num1' para o registrador EAX
    imul eax, [num2]    ; Multiplica EAX por 'num2' com sinal (Integer Multiply), salvando no EAX
    mov [result], eax   ; Guarda o valor final em 'result'
    jmp imprime_res     ; Pula para imprimir o resultado

op_divisao:             ; Rótulo da operação de Divisão (exige mais cuidado da CPU)
    mov ebx, [num2]     ; Move o divisor (num2) para o registrador EBX
    cmp ebx, 0          ; Compara o divisor (EBX) com zero
    je erro_div_zero    ; Se for igual a zero, pula para o erro (não pode dividir por 0)
    
    mov eax, [num1]     ; Move o dividendo (num1) para EAX (obrigatório na divisão x86)
    cdq                 ; Converte Double (EAX) pra Quadword (EDX:EAX). Prepara o EDX para divisão com sinal.
    idiv ebx            ; Divide os registradores unidos (EDX:EAX) por EBX. Quociente vai pra EAX, resto pra EDX.
    mov [result], eax   ; Pega o quociente (EAX) e salva em 'result'
    jmp imprime_res     ; Pula para imprimir o resultado

erro_div_zero:          ; Rótulo de tratamento de erro
    push msg_erro       ; Coloca a mensagem de erro na pilha
    call printf         ; Chama printf para avisar o usuário do erro
    add esp, 4          ; Limpa a pilha
    jmp fim             ; Pula direto para o encerramento do programa

imprime_res:            ; Rótulo para imprimir sucesso
    push dword [result] ; Coloca o valor do 'result' (os 4 bytes numéricos) na pilha
    push msg_res        ; Coloca o texto "Resultado: %d" na pilha
    call printf         ; Chama printf. Ele substitui o %d pelo valor de result
    add esp, 8          ; Limpa os 8 bytes da pilha após a chamada

fim:                    ; Rótulo de saída do programa
    ; --- ENCERRAMENTO DA FUNÇÃO MAIN (EPÍLOGO) ---
    mov eax, 0          ; Define o código de retorno do programa (0 = Sucesso) no EAX
    mov esp, ebp        ; Restaura o topo da pilha pro estado original antes de iniciarmos
    pop ebp             ; Restaura o registrador base antigo (EBP)
    ret                 ; Retorna o controle para o sistema operacional (sai do programa)
