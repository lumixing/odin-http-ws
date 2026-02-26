#+vet explicit-allocators
package http

import "base:runtime"
import "core:fmt"
import "core:strings"

Allocator :: runtime.Allocator

dbg :: proc(s: $T, ss := #caller_expression(s), loc := #caller_location) {
	fmt.printfln("!! dbg @ %v\n%v = %q", loc, ss, s)
}

dbgstr :: proc(s: string, ss := #caller_expression(s), loc := #caller_location) {
	fmt.printfln("!! dbgstr @ %v\n%v = %q", loc, ss, s)
}

Method :: enum {
	GET,
	POST,
}

URL :: struct {
	//protocol: string,
	host: string,
	path: string,
	//params: map[string]string,
}

// https://open.spotify.com/collection/tracks
url_from_string :: proc(url_str: string) -> (url: URL) {
	assert(strings.starts_with(url_str, "https://"))
	url_str := url_str[len("https://"):]
	idx := strings.index_rune(url_str, '/')
	if idx != -1 {
		url.host = url_str[:idx]
		url.path = url_str[idx:]
	} else {
		url.host = url_str
		url.path = "/"
	}

	return
}
