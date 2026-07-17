package main

import "../.."
import "core:fmt"

URL :: "https://httpbin.org/headers"

main :: proc() {
	init_err := hermod.init_requests()
	if init_err != .E_OK {
		fmt.eprintfln("%v", init_err)
		return
	}
	defer hermod.destroy_requests()

	header, err := hermod.create_header(
		"Accept:",
		"Another: yes",
		"Host: example.com",
		"X-silly-header;",
	)
	if err != nil {
		fmt.eprintfln("%v", err)
		return
	}
	defer hermod.destroy_header(&header)

	req, err_get := hermod.http_get(URL, header)
	if err_get != nil {
		fmt.eprintfln("%v", err_get)
		return
	}
	defer hermod.destroy_response(&req)

	fmt.printfln("%s", req.body[:])
}

