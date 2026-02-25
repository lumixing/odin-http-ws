package ssl

import "core:net"
import "../../openssl"

State :: struct {
	method: ^openssl.SSL_METHOD,
	ctx: ^openssl.SSL_CTX,
	ssll: ^openssl.SSL,
}

init :: proc(state: ^State) {
	state.method = openssl.TLS_client_method()
	state.ctx = openssl.SSL_CTX_new(state.method)
	state.ssll = openssl.SSL_new(state.ctx)
}

connect :: proc(state: ^State, socket: net.TCP_Socket, hostname: cstring) {
	openssl.SSL_set_fd(state.ssll, i32(socket))
	openssl.SSL_set_tlsext_host_name(state.ssll, hostname)
	openssl.SSL_connect(state.ssll)
}

write :: proc(state: ^State, buf: []u8) -> int {
	bytes_written := openssl.SSL_write(state.ssll, raw_data(buf), i32(len(buf)))
	return int(bytes_written)
}

read :: proc(state: ^State, buf: []u8) -> int {
	bytes_read := openssl.SSL_read(state.ssll, raw_data(buf), i32(len(buf)))
	return int(bytes_read)
}
