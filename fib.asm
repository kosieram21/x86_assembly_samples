section .bss
    input_buffer: resb 11 ; 10 digits + null byte

section .data
	functionMsg:     db 'Fibonacci Caculator',10
	functionMsgLen:  equ $-functionMsg
	
	inputMsg:        db 'n: '
	inputMsgLen:     equ $-inputMsg
	
	outputMsg:       db 'The nth Fibonacci number is ',10
	outputMsgLen:    equ $-outputMsg
	
	newline:         db 10

section .text
	global _start

_start:
  ; Write program function message
	mov eax,4               ; The system call for write (sys_write)
	mov ebx,1               ; File descriptor 1 - standard output
	mov ecx,functionMsg     ; Pointer to the function message
	mov edx,functionMsgLen  ; Function message length
	int 80h                 ; Call the kernel
	
	; Write input message
	mov eax,4               ; The system call for write (sys_write)
	mov ebx,1               ; File descriptor 1 - standard output
	mov ecx,inputMsg        ; Pointer to the input message
	mov edx,inputMsgLen     ; Input message length
	int 80h                 ; Call the kernel
	
	; Read user input
	mov eax,3               ; The system call for read (sys_read)
	mov ebx,0               ; File descriptor 0 - standard input
	mov ecx,input_buffer    ; Pointer to the input buffer
	mov edx,10              ; Maximum bytes to read (10)
	int 80h                 ; Call the kernel
	
	; Write user input
	mov eax,4               ; The system call for write (sys_write)
	mov ebx,1               ; File descriptor 1 - standard output
	mov ecx,input_buffer    ; Pointer to the input buffer
	mov edx,10              ; Bytes to write (10)
	int 80h                 ; Call the kernel
	
	; Write newline character
	mov eax,4               ; The system call for write (sys_write)
	mov ebx,1               ; File descriptor 1 - standard output
	mov ecx,newline         ; Pointer to the newline character
	mov edx,1               ; Bytes to write (1)
	int 80h                 ; Call the kernel
	
	; Convert the input buffer into an integer
	mov ebx, input_buffer   ; Store input buffer pointer in EBX
  xor eax, eax            ; Clear EAX to accumulate the result
    
	.ascii2int:
	  movzx edx, byte [ebx] ; Move the a bytes from EBX into EDX (zero extended)
	  cmp edx,0             ; Check for newline character - means we are done parsing input
	  je .compute_fib       ; Conditional jump to after the ascii2int loop
	  sub edx,'0'           ; Convert the ascii character to an integer
	  imul eax,eax,10       ; Shift all digits in the accumulator (EAX) 1 digit to the right
	  add eax,edx           ; Add the next digit into the accumulator (EAX)
	  inc ebx               ; Increment the buffer pointer (EBX)
	  jmp .ascii2int        ; Unconditional jump to start of ascii2int loop
	  
	.compute_fib:
	  mov ebx,0             ; Store F0 in EBX
	  mov ecx,1             ; Store F1 in ECX
	  cmp eax,0             ; Check if n (stored in accumulator EAX) is 0
	  je .F0_base_case      ; Conditional jump to F0_base_case
	  cmp eax,1             ; Check if n (store in accumulator EAX) is 1
	  je .F1_base_case      ; Conditional jump to F1_base_case
	  sub eax,1             ; Subtract 1 from accumulator - remaining Fibonacci numbers to compute
	.next_fib:
	  mov edx,ebx           ; Move EBX into EDX - setup to compute next Fibonacci number FN
	  add edx, ecx          ; Compute the next Fibonacci number FN
	  mov ebx, ecx          ; FN-2 = FN-1
	  mov ecx, edx          ; FN-1 = FN
	  sub eax,1             ; Subtract 1 from accumulator - remaining Fibonacci numbers to compute
	  cmp eax,0             ; Check if there are any remaining Fibonacci numbers to compute
	  je .int2ascii         ; Conditional jump to start of int2ascii loop
	  jmp .next_fib         ; Unconditional jump to start of next_fib loop
	  
	.F0_base_case:
	  mov edx,ebx           ; Move F0 from EBX to EDX
	  jmp .int2ascii        ; Unconditional jump to start of int2ascii loop
	  
	.F1_base_case:
	  mov edx,ecx           ; Move F1 from ECX to EDX
	  jmp .int2ascii        ; Unconditional jump to start of int2ascii loop
	  
	.int2ascii:
	  ;;Finish me
	  jmp .done             ; Unconditional jump to done
	  
	.done:
	  ; Write the output message
	  mov eax,4             ; The system call for write (sys_write)
	  mov ebx,1             ; File descriptor 1 - standard output
	  mov ecx,outputMsg     ; Pointer to the output message
	  mov edx,outputMsgLen  ; Output message length
	  int 80h               ; Call the kernel
	  
	  ; Write newline character
	  mov eax,4               ; The system call for write (sys_write)
	  mov ebx,1               ; File descriptor 1 - standard output
	  mov ecx,newline         ; Pointer to the newline character
	  mov edx,1               ; Bytes to write (1)
	  int 80h                 ; Call the kernel
	
	  ; Exit program
	  mov eax,1             ; The system call for exit (sys_exit)
	  mov ebx,0             ; Exit with return "code" of 0 (no error)
	  int 80h;              ; Call the kernel