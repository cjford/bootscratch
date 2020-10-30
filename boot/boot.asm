[org 0x7c00]
KERNEL_OFFSET equ 0x1000

mov [BOOT_DRIVE], dl

mov bx, HELLO_MSG
call print_string

mov bx, SPACE_MSG
call print_string

mov dx, 0xbeef
call print_hex

mov bx, SPACE_MSG
call print_string

mov bp, 0x8000
mov sp, bp

;load kernel from image into memory
mov bx, KERNEL_OFFSET
mov dh, 15
mov dl, [BOOT_DRIVE]
call disk_load

mov dx, [0x9000]
call print_hex

mov bx, SPACE_MSG
call print_string

mov dx, [0x9000 + 512]
call print_hex

mov bx, SPACE_MSG
call print_string

mov bx, DONE_MSG
call print_string

%include "boot/gdt.asm"
[bits 16]
%include "boot/print.asm"
%include "boot/disk.asm"

; Data
HELLO_MSG:
  db 'Hello, big world!', 0

DONE_MSG:
  db 'Switching 16 real to 32 bit protected...', 0

SPACE_MSG:
  db '        ', 0

BOOT_DRIVE: db 0
times 510-($-$$) db 0

dw 0xaa55
