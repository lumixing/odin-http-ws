#+vet explicit-allocators
package http

import "core:strconv"
import "core:strings"

Response :: struct {
	status_code: uint,
	status_message: string,
	headers: Headers,
	body: []u8,

	ok: bool,
}

response_delete :: proc(req: ^Response, allocator: Allocator) {
	delete(req.headers)
	delete(req.body, allocator)
}

// todo: return ok
response_from_string :: proc(res: ^Response, str: string, allocator: Allocator) {
	SPACE :: len(" ")

	first_newline_idx := strings.index(str, "\r\n")
	assert(first_newline_idx != -1)
	empty_line_idx := strings.index(str, "\r\n\r\n")
	empty_line_idx_after: int = ---  // safely set below
	if empty_line_idx == -1 {
		empty_line_idx = len(str)
		empty_line_idx_after = len(str)
	} else {
		empty_line_idx_after = empty_line_idx + len("\r\n\r\n")
	}

	status_line := str[:first_newline_idx]
	assert(strings.starts_with(status_line, "HTTP/1.1"))
	status_line = status_line[len("HTTP/1.1")+SPACE:]
	status_code_str := status_line[:len("100")]  // all status codes are 3 chars long
	ok: bool
	res.status_code, ok = strconv.parse_uint(status_code_str)
	assert(ok)
	res.status_message = status_line[len("100")+SPACE:]
	if status_code_str[0] == '2' {
		res.ok = true
	}

	first_newline_idx_after := first_newline_idx + len("\r\n")
	headers_str := str[first_newline_idx_after:empty_line_idx]
	headers_lines := strings.split(headers_str, "\r\n", allocator)
	for line in headers_lines {
		colon_idx := strings.index_rune(line, ':')
		assert(colon_idx != -1)
		key := line[:colon_idx]
		key = strings.trim_space(key)
		value := line[colon_idx+1:]
		value = strings.trim_space(value)
		res.headers[key] = value
	}

	res.body = transmute([]u8)str[empty_line_idx_after:]
}
