#+vet explicit-allocators
package ws

import "core:slice"
import "core:strings"
import "core:fmt"
import "core:net"
import "../http"
import ssl "../openssl/wrapper"

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
