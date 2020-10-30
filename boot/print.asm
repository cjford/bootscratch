print_char:
  pusha
  mov ah, 0x0e
  int 0x10
  popa
  ret

print_string:
  pusha
print_string_loop:
  mov al, [bx]
  cmp al, 0
  je print_string_end
  call print_char
  add bx, 1
  jmp print_string_loop
print_string_end:
  popa
  ret

; todo: put this in a loop instead of repeating w/hardcoded offsets
print_hex:
  pusha
  mov ax, dx
  and ax, 0xf000
  shr ax, 12

  cmp ax, 0x000a
  jl add_num_offset
  add_char_offset:
    add ax, 0x37
    jmp end_offset
  add_num_offset:
    add ax, 0x30
  end_offset:

  call print_char

  mov ax, dx
  shl ax, 4
  and ax, 0xf000
  shr ax, 12

  cmp ax, 0x000a
  jl add_num_offset_2
  add_char_offset_2:
    add ax, 0x37
    jmp end_offset_2
  add_num_offset_2:
    add ax, 0x30
  end_offset_2:

  call print_char

  mov ax, dx
  shl ax, 8
  and ax, 0xf000
  shr ax, 12

  cmp ax, 0x000a
  jl add_num_offset_3
  add_char_offset_3:
    add ax, 0x37
    jmp end_offset_3
  add_num_offset_3:
    add ax, 0x30
  end_offset_3:

  call print_char

  mov ax, dx
  shl ax, 12
  and ax, 0xf000
  shr ax, 12

  cmp ax, 0x000a
  jl add_num_offset_4
  add_char_offset_4:
    add ax, 0x37
    jmp end_offset_4
  add_num_offset_4:
    add ax, 0x30
  end_offset_4:

  call print_char

  popa
  ret
