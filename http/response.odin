#+vet explicit-allocators
package http

import "core:fmt"
import "core:slice"
import "core:strings"
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

response_from_string :: proc(res: ^Response, str: string, allocator: runtime.Allocator) {
	fmt.println("===== parsing res", str, "\n=====")
	lines := strings.split_lines(str, allocator)
	status_line := lines[0]
	idx, ok := slice.linear_search(lines, "")
	assert(ok)

	//fmt.println(status_line)
	assert(strings.starts_with(status_line, "HTTP/1.1"))
	res.status = status_line[len("HTTP/1.1")+1:]
	if res.status[0] == '2' {
		res.ok = true
	}
	fmt.println(res.status)

	//fmt.println(lines[1:idx])
	for line in lines[1:idx] {
		tokens := strings.split(line, ": ", allocator)
		assert(len(tokens) == 2)
		key := tokens[0]
		value := tokens[1]
		res.headers[key] = value
	}
	fmt.println(res.headers)

	//fmt.println(lines[idx+1:])
	idx2 := strings.index(str, "\r\n\r\n")
	assert(idx2 != -1)
	res.body = transmute([]u8)str[idx2+len("\r\n\r\n"):]
	fmt.println(len(res.body), string(res.body))
	fmt.println(res)
}
