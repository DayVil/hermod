package hermod

import "base:runtime"
import "core:fmt"
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

Error :: union {
	Hermod_Error,
	curl.code,
}

Hermod_Error :: enum {
	Failed_Init,
	Failed_Get,
}

destroy_hermod :: proc {
	destroy_header,
	destroy_requests,
	destroy_response,
}

// ========================================

Response :: struct {
	body:        [dynamic]byte,
	status_code: Status_Code,
}

destroy_response :: proc(response: ^Response) {
	delete(response.body)
}


// ========================================

http_get :: proc(
	url: string,
	headers: Maybe(Header) = nil,
	allocator := context.allocator,
) -> (
	Response,
	Error,
) {
	handle := curl.easy_init()
	if handle == nil {
		// There is no reason this should happen
		panic("Could not create the handle")
	}
	defer curl.easy_cleanup(handle)

	ctx := context
	ctx.allocator = allocator
	body: [dynamic]byte
	cb_data := _CB_Write_Data {
		data = &body,
		ctx  = ctx,
	}

	c_url := strings.clone_to_cstring(url, allocator)
	defer delete(c_url)

	header_unwrapped, ok := headers.(Header)
	if ok {
		curl.easy_setopt(handle, .HTTPHEADER, header_unwrapped)
	}
	curl.easy_setopt(handle, .URL, c_url)
	curl.easy_setopt(handle, .WRITEFUNCTION, _write_callback)
	curl.easy_setopt(handle, .WRITEDATA, &cb_data)

	curl_res := curl.easy_perform(handle)
	if curl_res != .E_OK {
		return {}, curl_res
	}

	status_code: i64
	curl.easy_getinfo(handle, .RESPONSE_CODE, &status_code)

	code := create_status_code(status_code)
	resp := Response {
		body        = body,
		status_code = code,
	}
	return resp, nil
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


Header :: struct {
	_elements: ^curl.slist,
}

Header_Error :: enum {
	No_Trailing_Semi_Or_Colon_After_Single_Token,
	Wrong_Seperator,
	More_Than_Two_Token,
	Could_Not_Append_To_SList,
}

destroy_header :: proc(header: ^Header) {
	curl.slist_free_all(header._elements)
}

create_header :: proc(
	header_elements: ..string,
	allocator := context.allocator,
) -> (
	res: Header,
	err: Header_Error,
) {
	for header_element in header_elements {
		trimmed_element := strings.trim(header_element, " ")

		pair := strings.split(trimmed_element, ": ")
		defer delete(pair)

		pair_len := len(pair)
		if pair_len > 2 {
			return {}, .More_Than_Two_Token
		} else if pair_len == 1 {
			last_element_count := len(trimmed_element) - 1
			last_element := trimmed_element[last_element_count]

			if last_element != ';' && last_element != ':' {
				return {}, .No_Trailing_Semi_Or_Colon_After_Single_Token
			}
		} else {
			first_element_idx := len(pair[0])
			split_char := trimmed_element[first_element_idx]

			if split_char != ':' do return {}, .Wrong_Seperator
		}

		sl := strings.clone_to_cstring(header_element, allocator)
		res._elements = curl.slist_append(res._elements, sl)
		if res._elements == nil {
			return {}, .Could_Not_Append_To_SList
		}
	}

	return
}

