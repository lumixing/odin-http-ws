//#+vet explicit-allocators unused
package main

import "core:fmt"
import "http"

main :: proc() {
	req: http.Request
	res: http.Response
	url := `https://discord.com/api/webhooks/1273228426580590602/Y9F3jA8w6g0lC2ufcWTSSglkkIsAMHxb-aPEL1IkDsMj9ubwp-vgI6IQ4lylaH6f1hHr`
	body := `{"content":"hello, world! :D"}`
	http.headers_set_content_type(&req.headers, .application_json)
	http.post(&req, &res, url, body)
	fmt.println(res)
}

main3 :: proc() {
	req: http.Request
	defer http.request_delete(&req)
	req.method = .POST
	req.url = "https://discord.com/api/webhooks/1273228426580590602/Y9F3jA8w6g0lC2ufcWTSSglkkIsAMHxb-aPEL1IkDsMj9ubwp-vgI6IQ4lylaH6f1hHr"
	body := `{"content":"hello, world! :D"}`
	req.body = transmute([]u8)string(body)
	http.headers_set_content_type(&req.headers, .application_json)

	res: http.Response
	defer http.response_delete(&res)
	http.fetch(&req, &res)
	fmt.println(res)
}

main2 :: proc() {
	req: http.Request
	defer http.request_delete(&req)
	req.method = .GET
	req.url = "https://api.ipify.org"
	req.headers["Host"] = "api.ipify.org"

	res: http.Response
	defer http.response_delete(&res)
	http.fetch(&req, &res)
	//fmt.println(string(res.body))
	fmt.println(res)
}
