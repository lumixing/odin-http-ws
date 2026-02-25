#+vet explicit-allocators
package http

import "core:strings"
import "core:fmt"
import "base:runtime"
import "core:net"
import ssl "../openssl/wrapper"

client_send_request :: proc(
	req: ^Request,
	res: ^Response,
	allocator: runtime.Allocator,
) -> (ok: bool) {
	state: ssl.State
	ssl.init(&state)

	url := url_from_string(req.url)
	socket, err := net.dial_tcp(fmt.tprintf("%s:443", url.host))

	ssl.connect(&state, socket, strings.clone_to_cstring(url.host, allocator))

	req_str := request_to_string(req, allocator)
	wrote := ssl.write(&state, transmute([]u8)req_str)
	if wrote < 0 {
		return
	}
	recv_buf: [1024]u8
	read := ssl.read(&state, recv_buf[:])
	if read < 0 {
		return
	}
	fmt.println(string(recv_buf[:read]))
	return true
}
