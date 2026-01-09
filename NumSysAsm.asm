; Программа на NASM x64 для перевода целых положительных чисел из различных систем счисления (до 16-чной)
; в десятичную с. с.


bits 64 ; essential for x64
%include "io64.inc" ; enabling useful macros
DEFAULT REL ; enabling relative adressing (default for linux)

section .data
errorMessage db "At least one of the characters at origNumber was not from the alphabet. The program was shut down", 0
alphabet db "0123456789abcdef", 0
searched db "c"
origNumber db "f8^^", 0
lenOrigNumber equ $ - origNumber - 1 ; this is number of characters in string without null terminator

section .bss
newNumber resb 20

section .text
extern ExitProcess     ; Terminates the process
global main


main:
    
    xor r8, r8
    xor rsi, rsi ; counter
    xor rcx, rcx
    xor r11, r11
    mov r12, lenOrigNumber
    mov r13, origNumber + lenOrigNumber - 1 ; start address of the original number
    mov r14, 16 ; temporary store for base of orig number, should be redone in future
    ;dec r13 ; needed to create a working loop
    mov r9, alphabet ; indexOf function argument
    ConvertLoop:
        xor rax, rax
        cmp rsi, lenOrigNumber ; making sure we don't run out of length of original symbols, idk how2explainit
        je ConvertEnd
        
        
        mov r10, r13 ; 
        call indexOf ; the result will be stored in r8
        cmp r8, -1
        je errorHandler
        
        ;Finding the "powed multiplicator" value
        mov rax, r14 ; value to be powed
        mov rcx, rsi ; number of times to pow the value
        call Pow ; the result will be in rax
        
        ;Multiplying the digit and number based powed by index
        mul r8 ; the result is in rax
        
        ;Adding the result to zero in rdx register
        add r11, rax
        inc rsi ; incrementing counter
        dec r13 ; decrementing the adress of char
        jmp ConvertLoop

        
        
        
        
        
    
ConvertEnd:
    PRINT_DEC 8, r11    
    ret ; exiting our program
    
    


;==============================INDEX OF FUNCTION==========================================================
; indexOf "function" returns the index of the first appearance of the character
; in the spicified "string" (char sequence). If it is not found - returns -1
; In order to call indexOf these registers are used:
; r9 - adress of the first element of string, r10 - address of ASCII char to be found
; rcx - counter for looping, r8 - the found index, e. g. return value
    
indexOf:
    push r9
    push rcx
    xor rcx, rcx
    push r11
    push r12
.indexOfLoop:
    cmp byte [r9], 0
    je indexOfNotFound
    movzx r11, byte [r10] ; moving the dereferenced value of searched char to a register
    movzx r12, byte [r9] ; achieving the same size of operands to compare them
    cmp r12, r11 ; comparing the element of char sequence with the needed char
    je indexOfFound ; jumping if symbols are equal
    inc rcx ; incrementing counter
    inc r9 ; incrementing the address to work with next character
    jmp .indexOfLoop
    
indexOfFound:
    mov r8, rcx
    jmp indexOfExit
    
indexOfNotFound:
    mov r8, -1
    jmp indexOfExit
    
indexOfExit:
    pop r12
    pop r11
    pop rcx
    pop r9
    ret



;==============================POW FUNCTION================================================================
; rax - value to be powered; rcx - power itself; the result will be stored in rax register.
; Keep in mind that the function works only with positive powers including zero
; in other cases it may enter an infinite loop
Pow:
    push rbx
    push rcx
    mov rbx, rax
    cmp rcx, 0 ; checking for zero in power (all power have to be decremented by one)
    je powerIsZero
powLoopLable:
    cmp rcx, 1
    je powExit ; exiting without changes to rax if power is 1
    mul rbx
    dec rcx
    jmp powLoopLable
powerIsZero: 
    mov rax, 1 ; returning 1 if power in rcx is zero
    jmp powExit
powExit:
    pop rcx
    pop rbx
    ret
    
;==============================ERROR HANDLER================================================================
; It is called when any symbol from the input was not found in origNumber 'variable', even doe it is 
; just a pointer
errorHandler:
    PRINT_STRING errorMessage
    mov rsp, rbp
    pop rbp
    mov rcx, 1          ; Parameter 1: uExitCode = 0 (success)
    call ExitProcess

    
    
    
 