#+vet explicit-allocators
package http

import "core:strings"
import "core:fmt"
import "core:net"
import ssl "../openssl/wrapper"

fetch :: proc(
	req: ^Request,
	res: ^Response,
	allocator := context.allocator,
) -> (ok: bool) {
	url := url_from_string(req.url)
	// add necessary headers
	req.headers["Host"] = url.host
	headers_set_content_length(&req.headers, len(req.body), allocator)

	state: ssl.State
	ssl.init(&state)

	//fmt.println(url)
	socket, err := net.dial_tcp(fmt.aprintf("%s:443", url.host, allocator = allocator))
	assert(err == nil)

	ssl.connect(&state, socket, strings.clone_to_cstring(url.host, allocator))

	req_str := request_to_string(req, allocator)
	//fmt.println("===== built req", req_str, "\n=====")
	wrote := ssl.write(&state, transmute([]u8)req_str)
	if wrote < 0 {
		return
	}
	//recv_buf: [1024]u8
	recv_buf := make([]u8, 1024, allocator)  // leak
	read := ssl.read(&state, recv_buf[:])
	if read < 0 {
		return
	}
	//fmt.println(string(recv_buf[:read]))
	response_from_string(res, string(recv_buf[:read]), context.allocator)
	return true
}
