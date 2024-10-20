section .bss
  input_buffer: resb 11  ; 10 digits + null byte
  output_buffer: resb 11 ; 10 digits + null byte

section .data
	functionMsg:     db 'Fibonacci Caculator',10
	functionMsgLen:  equ $-functionMsg
	
	inputMsg:        db 'n: '
	inputMsgLen:     equ $-inputMsg
	
	outputMsg:       db 'The nth Fibonacci number is '
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
	  cmp edx,0             ; Check for null byte - means we are done parsing input
	  je .compute_fib       ; Conditional jump to after the ascii2int loop
	  sub edx,'0'           ; Convert the ascii character to an integer
	  imul eax,eax,10       ; Shift all digits in the accumulator (EAX) 1 digit to the right
	  add eax,edx           ; Add the next digit into the accumulator (EAX)
	  inc ebx               ; Increment the buffer pointer (EBX)
	  jmp .ascii2int        ; Unconditional jump to start of ascii2int loop
	  
	; Compute the nth Fibonacci number
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
	  
	; Convert the nth Fibonacci number into a ASCII array in the output buffer
	.int2ascii:
	  mov ecx, output_buffer; Pointer to the output buffer
	  mov eax,edx           ; Move the nth Fibonacci number (in EDX) into the EAX (quotient) register for division
	  mov ebx,10            ; Put the divisor (10) into EBX to prepare for division
	  xor edi,edi           ; Initialize stack count
	.peel_digits:
	  xor edx,edx           ; Clear the EDX (remainder) register to prepare for division
	  div ebx               ; Divide EAX by EBX. The quotient will be in EAX and the remainder in EDX
	  add dl, '0'           ; Convert the remainder to ASCII (lower 8 bits)
	  push rdx              ; Push RDX onto the stack - this is because digits are in reverse order
	  inc edi               ; Increment stack count
	  cmp eax,0             ; Check if any digits remain
	  jne .peel_digits      ; Unconditional jump to start of peel_digits loop
	  mov esi,edi           ; Store maximum stack size in aux register
	.reverse_digits:
	  pop rdx               ; Pop the next digit of the stack
	  mov [ecx], dl         ; Store the next digit in the output buffer
	  inc ecx               ; Increment the buffer pointer (ECX)
	  dec edi               ; Decrement stack count
    jge .reverse_digits   ; Conditional jump to start of the reverse_digits loop
	  
	.done:
	  ; Write the output message
	  mov eax,4             ; The system call for write (sys_write)
	  mov ebx,1             ; File descriptor 1 - standard output
	  mov ecx,outputMsg     ; Pointer to the output message
	  mov edx,outputMsgLen  ; Output message length
	  int 80h               ; Call the kernel
	  
	  ; Read user input
	  mov eax,4             ; The system call for write (sys_write)
	  mov ebx,1             ; File descriptor 1 - standard output
	  mov ecx,output_buffer ; Pointer to the output buffer
	  mov edx,esi           ; Maximum bytes to write - max stack size
	  int 80h               ; Call the kernel
	  
	  ; Write newline character
	  mov eax,4             ; The system call for write (sys_write)
	  mov ebx,1             ; File descriptor 1 - standard output
	  mov ecx,newline       ; Pointer to the newline character
	  mov edx,1             ; Bytes to write (1)
	  int 80h               ; Call the kernel
	
	  ; Exit program
	  mov eax,1             ; The system call for exit (sys_exit)
	  mov ebx,0             ; Exit with return "code" of 0 (no error)
	  int 80h;              ; Call the kernel