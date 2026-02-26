#+vet explicit-allocators
package ws

import "core:slice"
import "core:strings"
import "core:fmt"
import "core:net"
import "../http"
import ssl "../openssl/wrapper"
import "core:encoding/endian"

Client :: struct {
	state: ssl.State,
}

connect :: proc(client: ^Client, url_str: string, allocator := context.allocator) {
	url := http.url_from_string(url_str)

	//state: ssl.State
	ssl.init(&client.state)

	socket, err := net.dial_tcp(fmt.aprintf("%s:443", url.host, allocator = allocator))
	assert(err == nil)

	ssl.connect(&client.state, socket, strings.clone_to_cstring(url.host, allocator))

	req: http.Request
	req.url = url_str
	req.headers["Host"] = "gateway.discord.gg"
	req.headers["Upgrade"] = "websocket"
	req.headers["Connection"] = "Upgrade"
	req.headers["Sec-WebSocket-Key"] = "dGhlIHNhbXBsZSBub25jZQ=="
	req.headers["Sec-WebSocket-Version"] = "13"
	req_str := http.request_to_string(&req, allocator)
	ssl.write(&client.state, transmute([]u8)req_str)

	recv_buf: [1024]u8
	read := ssl.read(&client.state, recv_buf[:])
	res: http.Response
	http.response_from_string(&res, string(recv_buf[:read]), allocator)
}

read :: proc(client: ^Client, allocator := context.allocator) -> []u8 {
	recv_buf: [1024]u8
	read := ssl.read(&client.state, recv_buf[:])
	frame: Frame
	frame_decode(&frame, recv_buf[:read])
	return slice.clone(frame.payload, allocator)
}

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
