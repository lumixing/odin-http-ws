## odin-http-ws
a simple http(1.1)/websocket client/server library for odin. uses [laytan's openssl bindings](https://github.com/laytan/odin-http/tree/main/openssl) for secure connections.

> [!IMPORTANT]  
> currently under development!

> [!WARNING]  
> this is made for personal use, might not work as expected, use with caution!  
> you might want to check out https://github.com/laytan/odin-http.

### http client example
a simple discord webhook:
```odin
package main

import "http"

main :: proc() {
	URL :: `https://discord.com/api/webhooks/.../...`
	BODY :: `{"content":"hello, world! :D"}`

	req: http.Request
	defer request_delete(&req)
	res: http.Response
	defer response_delete(&res)

	http.headers_set_content_type(&req.headers, .application_json)
	http.post(&req, &res, URL, BODY)
}
```

## roadmap
- http client
  - [x] secure connections using openssl
  - [ ] all methods working
  - [ ] json support
  - [ ] complete memory management
  - [ ] chunked responses
  - [ ] no blocking
- http server
- ws client
  - [ ] json support
  - [ ] chunked responses
  - [ ] no blocking
- ws server
