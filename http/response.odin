#+vet explicit-allocators
package http

import "base:runtime"

Response :: struct {
	status: string,
	headers: Headers,
	body: []u8,

	ok: bool,
}

response_delete :: proc(req: ^Response, allocator: runtime.Allocator) {
	delete(req.headers)
	delete(req.body, allocator)
}
