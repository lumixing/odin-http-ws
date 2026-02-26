#+vet explicit-allocators
package http

import "core:fmt"

Headers :: map[string]string

headers_get :: proc(headers: ^Headers, key: string) -> (value: string, ok: bool) {
	value, ok = headers[key]
	return
}

headers_set :: proc(headers: ^Headers, key, value: string) {
	headers[key] = value
}

ContentType :: enum {
	application_json,
}

@(rodata)
content_type_string := [ContentType]string {
	.application_json = "application/json",
}

headers_set_content_type :: proc(headers: ^Headers, content_type: ContentType) {
	headers["Content-Type"] = content_type_string[content_type]
}

headers_set_content_type_custom :: proc(headers: ^Headers, content_type: string) {
	headers["Content-Type"] = content_type
}

// doesnt work correctly for some reason...
//headers_set_content_type :: proc {
//	headers_set_content_type_common,
//	headers_set_content_type_string,
//}

headers_set_content_length :: proc(headers: ^Headers, #any_int content_length: int, allocator := context.allocator) {
	headers["Content-Length"] = fmt.aprintf("%d", content_length, allocator = allocator)
}
