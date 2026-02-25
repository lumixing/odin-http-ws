#+vet explicit-allocators
package http

import "base:runtime"
import "core:strings"
import "core:fmt"

Request :: struct {
	method: Method,
	url: string,
	headers: Headers,
	body: []u8,
}

request_delete :: proc(req: ^Request, allocator: runtime.Allocator) {
	delete(req.headers)
	delete(req.body, allocator)
}

request_to_string :: proc(req: ^Request, allocator: runtime.Allocator) -> string {
	sb: strings.Builder
	strings.builder_init_none(&sb, allocator)

	fmt.sbprintf(&sb, "%v %s HTTP/1.1\r\n", req.method, "/")
	for key, value in req.headers {
		fmt.sbprintf(&sb, "%s: %s\r\n", key, value)
	}
	fmt.sbprintf(&sb, "\r\n")

	return strings.to_string(sb)
}
