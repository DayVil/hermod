package hermod

import "core:fmt"
create_status_code :: proc(status: i64) -> Status_Code {
	switch status {
	case 100:
		return .Continue
	case 101:
		return .Switching_Protocol
	case 200:
		return .Ok
	case 201:
		return .Created
	case 300:
		return .Multiple_Choices
	case 400:
		return .Bad_Request
	case 401:
		return .Unauthorized
	case 500:
		return .Server_Error
	case 501:
		return .Not_Implemented
	case 502:
		return .Bad_Request
	case 503:
		return .Service_Unavailable
	}

	// We should implement more
	content := fmt.tprintfln("Code: %d not implemented", status)
	panic(content)
}

Status_Code :: union {
	Info,
	Success,
	Redirection,
	Client_Error,
	Server_Error,
}

Info :: enum i64 {
	Continue           = 100,
	Switching_Protocol = 101,
}

Success :: enum i64 {
	Ok      = 200,
	Created = 201,
	// TODO complete
}

Redirection :: enum i64 {
	Multiple_Choices = 300,
	// TODO complete
}

Client_Error :: enum i64 {
	Bad_Request  = 400,
	Unauthorized = 401,
	// TODO complete
}

Server_Error :: enum i64 {
	Server_Error        = 500,
	Not_Implemented     = 501,
	Bad_Gateway         = 502,
	Service_Unavailable = 503,
	// TODO complete
}

