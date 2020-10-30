#include "display.h"

#define VGA_CTL_REGISTER 0x3D4
#define VGA_DATA_REGISTER 0x3D5
#define VGA_CURSOR_POS_HIGH 0xE
#define VGA_CURSOR_POS_LOW 0xF

#define VIDEO_ADDRESS 0xb8000
#define MAX_ROWS 25
#define MAX_COLS 80
#define WHITE_ON_BLACK 0x0f

int get_cursor_position() {
  int offset = 0;
  port_byte_out(VGA_CTL_REGISTER, 0xE);
  offset |= port_byte_in(VGA_DATA_REGISTER) << 8;

  port_byte_out(VGA_CTL_REGISTER, 0xF);
  offset |= port_byte_in(VGA_DATA_REGISTER);

  return offset * 2;
}

void set_cursor_position(int offset) {
  offset /= 2;

  port_byte_out(VGA_CTL_REGISTER, 14);
  port_byte_out(VGA_DATA_REGISTER, (unsigned char)(offset >> 8));
  port_byte_out(VGA_CTL_REGISTER, 15);
  port_byte_out(VGA_DATA_REGISTER, (unsigned char)offset);
}

void print_char(const char character, const int col, const int row, int attribute_byte) {
  int mem_offset;

  if (!attribute_byte) { attribute_byte = WHITE_ON_BLACK; }

  if (col >= 0 && row >= 0) {
    mem_offset = (((MAX_COLS * row) + col) * 2);
  } else {
    mem_offset = get_cursor_position();
 }

  char *video_memory = (char*) VIDEO_ADDRESS;
  video_memory[mem_offset] = character;
  video_memory[(int)(mem_offset + 1)] = attribute_byte;

  set_cursor_position(mem_offset + 2);
}

void clear_screen() {
  for(int x = 0; x < MAX_COLS; x++) {
    for(int y = 0; y < MAX_ROWS; y++){
      print_char(' ', x, y, WHITE_ON_BLACK);
    }
  }
}

void print_at(char *str, int col, int row) {
  int i = 0;
  int wrapped_rows = 0;

  while(str[i] != 0) {
    if(col + i == MAX_COLS) {
      wrapped_rows += 1;
    }

    print_char(str[i], (col + i) % MAX_COLS, row + wrapped_rows, WHITE_ON_BLACK);
    i++;
  }
}

void print(char *str) {
  print_at(str, -1, -1);
}

char* int_to_hex_str(int hex, char* output_str) {
  int hex_digit;

  output_str[0] = '0';
  output_str[1] = 'x';
  output_str[10] = '\0';

  for(int i = 7; i >= 0; i--) {
    hex_digit = hex & 0xf;

     if(hex_digit >= 0xa)
      hex_digit += 87;
    else {
      hex_digit += 48;
    }

    output_str[i + 2] = hex_digit;

    hex = hex >> 4;
  }

  return output_str;
}

void print_hex_at(int hex, int col, int row) {
  char* output_str;
  int_to_hex_str(hex, output_str);

  print_at(output_str, col, row);
}

void print_hex(int hex) {
  char* output_str;
  int_to_hex_str(hex, output_str);

  print(output_str);
}
