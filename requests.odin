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

http_get :: proc(
	url: string,
	headers: Maybe(Header) = nil,
	allocator := context.allocator,
) -> (
	res: Response,
	err: Curl_Error,
) {
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

	curl_slist: ^curl.slist
	headers, ok := headers.(Header)
	defer {
		if ok {
			curl.slist_free_all(curl_slist)
		}
	}
	if ok {
		curl_slist = _into_slist(&headers) or_return
		curl.easy_setopt(handle, .HTTPHEADER, curl_slist)
	}
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
	_elements: [dynamic]cstring,
}

Header_Error :: enum {
	No_Trailing_Semi_Or_Colon_After_Single_Token,
	Wrong_Seperator,
	More_Than_Two_Token,
}

destroy_header :: proc(header: ^Header) {
	defer delete(header._elements)
	for ele in header._elements {
		delete(ele)
	}
}

create_header :: proc(
	header_elements: ..string,
	allocator := context.allocator,
) -> (
	res: Header,
	err: Header_Error,
) {
	res._elements = make([dynamic]cstring, allocator)
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
		append(&res._elements, sl)
	}

	return
}

_into_slist :: proc(header: ^Header) -> (res: ^curl.slist, err: Curl_Error) {
	for h in header._elements {
		new_res := curl.slist_append(res, h)
		if new_res == nil {
			curl.slist_free_all(res)
			return nil, .Failed_Init
		}
		res = new_res
	}
	return
}

