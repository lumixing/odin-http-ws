#+vet explicit-allocators
package http

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
	idx := index_nth(url_str, '/', 3)
	if idx != -1 {
		url.host = url_str[len("https://"):idx]
		url.path = url_str[idx:]
	} else {
		url.host = url_str[len("https://"):]
		url.path = "/"
	}

	return

	index_nth :: proc(s: string, c: rune, n: uint) -> int {
		idx := 1
		for cc, i in s {
			if cc == c {
				if i == idx {
					return i
				}
				idx += 1
			}
		}
		return -1
	}
}
