gdt_start:
 ; mandatory null descriptor
gdt_null:
  dd 0x0
  dd 0x0

; code segment descriptor
gdt_code:
  dw 0xfff     ; limit (bits 0-15)
  dw 0x0       ; base (bits 0-15)
  db 0x0       ; base (bits 16-23)
  db 10011010b ; 1st flags:  present(1) | privilege(00)                | descriptor type(1) |
               ; type flags: code(1)    | conforming(0) | readable (1) | accessed (0)       |

  db 11001111b ; 2nd flags: granularity(1) | 32-bit default(1) | 64-bit seg(0) | AVL(0)
               ; limit (bits 16-19)
  db 0x0       ; base (bits 24-31)

; data segment descriptor
; Same as code segment except for type flags
gdt_data:
  dw 0xfff
  dw 0x0
  db 0x0
  db 10010010b
  db 11001111b
  db 0x0


gdt_end:

gdt_descriptor:
  dw gdt_end - gdt_start - 1
  dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
TEST:
  db "TEST"

; disable interrupts for switching into protected mode
cli

; load the GDT
lgdt [gdt_descriptor]

; set the first bit of CR0 to switch to 32-bit protected mode
mov eax, cr0
or eax, 0x1
mov cr0, eax

; trigger a far jump to switch cs register to our new code segment and flush the pipeline
jmp CODE_SEG:start_protected_mode

[bits 32] ; tell assembler to encode in 32-bit mode instructions



start_protected_mode:
  ; switch over all segment registers to our new data segment from old invalid real-mode segments
  mov ax, DATA_SEG
  mov ds, ax
  mov ss, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

 ; set stack position to top of free space
  mov ebp, 0x90000
  mov esp, ebp

  mov ebx, PM_MSG
  call print_string_pm
  mov ebx, 0xdeadface

  call KERNEL_OFFSET
  jmp $

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLOCK equ 0x0f
PM_MSG:
  dd 'Successfully booted into PM'

print_string_pm:
  pusha
  mov edx, VIDEO_MEMORY

print_string_pm_loop:
  mov al, [ebx]
  mov ah, WHITE_ON_BLOCK

  cmp al, 0
  je print_string_pm_end

  mov [edx], ax
  add ebx, 1
  add edx, 2

  jmp print_string_pm_loop

print_string_pm_end:
  popa
  ret
