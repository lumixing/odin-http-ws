#+vet explicit-allocators
package ws

import "core:encoding/endian"

Frame :: struct {
	fin: bool,
	opcode: Opcode,
	masked: bool,
	length: uint,
	mask_key: u32,
	payload: []u8,
}

Opcode :: enum {
	Cont = 0,
	Text = 1,
	Binary = 2,
	Close = 8,
	Ping = 9,
	Pong = 10,
}

frame_decode :: proc(frame: ^Frame, buf: []u8) {
	cursor := 0

	byte := buf[cursor]
	cursor += 1
	frame.fin = bool((byte & 0b1000_0000) >> 7)
	frame.opcode = Opcode(byte & 0x0F)

	byte = buf[cursor]
	cursor += 1
	frame.masked = bool((byte & 0b1000_0000) >> 7)
	length := byte & 0b0111_1111

	switch length {
	case 0..=125:
		frame.length = uint(length)
	case 126:
		length, ok := endian.get_u16(buf[cursor:][:size_of(u16)], .Big)
		assert(ok)
		frame.length = uint(length)
		cursor += size_of(u16)
	case 127:
		length, ok := endian.get_u64(buf[cursor:], .Big)
		assert(ok)
		frame.length = uint(length)
		cursor += size_of(u64)
	}

	if frame.masked {
		ok: bool
		frame.mask_key, ok = endian.get_u32(buf[cursor:], .Big)
		assert(ok)
		cursor += size_of(u32)
	}

	frame.payload = buf[cursor:]
}
