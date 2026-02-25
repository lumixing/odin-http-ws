package main

import "core:fmt"
import "http"

main :: proc() {
	req: http.Request
	defer http.request_delete(&req, context.allocator)
	req.method = .GET
	req.url = "https://api.ipify.org"
	req.headers["Host"] = "api.ipify.org"

	res: http.Response
	defer http.response_delete(&res, context.allocator)
	ok := http.client_send_request(&req, &res, context.allocator)
	fmt.println(string(res.body))

	res2: http.Response
	defer http.response_delete(&res2, context.allocator)
	ok2 := http.client_send_request(&req, &res2, context.allocator)
	fmt.println(string(res2.body))
}
