#+vet explicit-allocators
package http

import "core:fmt"
import "base:runtime"
import "core:net"
import ssl "openssl"

client_send_request :: proc(
	req: ^Request,
	res: ^Response,
	allocator: runtime.Allocator,
) -> (ok: bool) {
	method := ssl.TLS_client_method()
	ctx := ssl.SSL_CTX_new(method)
	ssll := ssl.SSL_new(ctx)

	url := url_from_string(req.url)
	fmt.println(url)
	socket, err := net.dial_tcp(fmt.tprintf("%s:443", url.host))
	//socket, err := net.dial_tcp("api.ipify.org:443")
	assert(err == nil)
	num := ssl.SSL_set_fd(ssll, i32(socket))
	assert(num >= 0)
	num = ssl.SSL_set_tlsext_host_name(ssll, "api.ipify.org")
	assert(num >= 0)
	num = ssl.SSL_connect(ssll)
	fmt.println(num)
	//ssl.ERR_print_errors_stderr()
	assert(num >= 0)

	req_str := request_to_string(req, allocator)
	fmt.println(req_str)
	//num, err := net.send(client.socket, transmute([]u8)req_str)
	num = ssl.SSL_write(ssll, raw_data(req_str), i32(len(req_str)))
	fmt.println("write", num)
	assert(num >= 0)
	if num < 0 {
		return
	}
	//num, err = net.recv(client.socket, client.recv_buf[:])
	recv_buf: [1024]u8
	num = ssl.SSL_read(ssll, raw_data(recv_buf[:]), 1024)
	fmt.println("read", num)
	assert(num >= 0)
	if num < 0 {
		return
	}
	fmt.println(string(recv_buf[:num]))
	return true
}
