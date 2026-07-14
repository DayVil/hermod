package hermod

import "base:runtime"
import "core:strings"
import "vendor:curl"

// ========================================

init_requests :: proc() -> curl.code {
	return curl.global_init(curl.GLOBAL_ALL)
}

destroy_requests :: proc() {
	curl.global_cleanup()
}

// ========================================

Curl_Error :: enum {
	Failed_Init,
	Failed_Get,
}

// ========================================

http_get :: proc(url: string, allocator := context.allocator) -> (res: Response, err: Curl_Error) {
	handle := curl.easy_init()
	if handle == nil {
		return Response{}, Curl_Error.Failed_Init
	}
	defer curl.easy_cleanup(handle)

	ctx := context
	ctx.allocator = allocator
	body: [dynamic]byte
	cb_data := _CB_Write_Data {
		data = &body,
		ctx  = ctx,
	}

	c_url := strings.clone_to_cstring(url)
	defer delete(c_url)

	curl.easy_setopt(handle, .URL, c_url)
	curl.easy_setopt(handle, .WRITEFUNCTION, _write_callback)
	curl.easy_setopt(handle, .WRITEDATA, &cb_data)

	curl_res := curl.easy_perform(handle)
	if curl_res != .E_OK {
		return Response{}, Curl_Error.Failed_Get
	}

	return Response{body = body}, nil
}

_CB_Write_Data :: struct {
	data: ^[dynamic]byte,
	ctx:  runtime.Context,
}

_write_callback :: proc "c" (contents: rawptr, size: uint, nmemb: uint, userdata: rawptr) -> uint {
	cb_data := cast(^_CB_Write_Data)userdata
	context = cb_data.ctx

	real_size := size * nmemb
	if real_size == 0 do return 0

	bytes := cast([^]byte)contents
	append(cb_data.data, ..bytes[:real_size])
	return real_size
}

// ========================================

Response :: struct {
	body: [dynamic]byte,
}

destroy_response :: proc(response: ^Response) {
	delete(response.body)
}

// ========================================

Header :: struct {
	_elements: [dynamic]SList_Element,
}

SList_Element :: union {
	Pair,
	string,
}

Pair :: struct {
	first:  string,
	second: string,
}

