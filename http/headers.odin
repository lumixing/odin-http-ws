#+vet explicit-allocators
package http

Headers :: map[string]string

headers_get :: proc(headers: ^Headers, key: string) -> (value: string, ok: bool) {
	value, ok = headers[key]
	return
}

headers_set :: proc(headers: ^Headers, key, value: string) {
	headers[key] = value
}
