section .data
    msg db 'Hello, World!', 10, 0  ; 10 is the newline character, 0 is the null terminator

section .text
    global _main
    extern _printf
    extern _exit

_main:
    ; Push the message address to the stack as an argument for printf
    push msg
    call _printf
    add esp, 4     ; Clean up the stack

    ; Push the exit code (0) and call exit
    push 0
    call _exit