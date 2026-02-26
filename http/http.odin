#+vet explicit-allocators
package http

import "core:fmt"
import "core:strings"
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
