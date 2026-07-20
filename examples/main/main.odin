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
	defer hermod.destroy_hermod(&header)

	fmt.printfln("Requesting to: %s", URL)
	req, code := hermod.http_get(URL, header)
	defer hermod.destroy_hermod(&req)

	_, success := code.(hermod.Success)
	if !success {
		fmt.eprintfln("Server error %d %v", success, success)
		return
	}

	fmt.printfln("%s", req.body[:])
}

