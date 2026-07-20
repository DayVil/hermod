package hermod

import "core:fmt"
create_status_code :: proc(status: i64) -> Status_Code {
	switch status {
	case 100:
		return .Continue
	case 101:
		return .Switching_Protocol
	case 102:
		return .Processing
	case 103:
		return .Early_Hints
	case 100 ..< 200:
		return Info.Unknown

	case 200:
		return .Ok
	case 201:
		return .Created
	case 202:
		return .Accepted
	case 203:
		return .Non_Authoritative_Information
	case 204:
		return .No_Content
	case 205:
		return .Reset_Content
	case 206:
		return .Partial_Content
	case 207:
		return .Multi_Status
	case 208:
		return .Already_Reported
	case 200 ..< 300:
		return Success.Unknown

	case 300:
		return .Multiple_Choices
	case 301:
		return .Moved_Permanently
	case 302:
		return .Found
	case 303:
		return .See_Other
	case 304:
		return .Not_Modified
	case 305:
		return .Temporary_Redirect
	case 306:
		return .Permanent_Redirect
	case 300 ..< 400:
		return Redirection.Unknown

	case 400:
		return .Bad_Request
	case 401:
		return .Unauthorized
	case 402:
		return .Payment_Required
	case 403:
		return .Forbidden
	case 404:
		return .Not_Found
	case 405:
		return .Method_Not_Allowed
	case 406:
		return .Not_Acceptable
	case 407:
		return .Proxy_Authentication_Required
	case 408:
		return .Request_Timeout
	case 409:
		return .Conflict
	case 410:
		return .Gone
	case 411:
		return .Length_Required
	case 412:
		return .Precondition_Failed
	case 413:
		return .Payload_Too_Large
	case 414:
		return .URI_Too_Long
	case 415:
		return .Unsupported_Media_Type
	case 416:
		return .Range_Not_Satisfiable
	case 417:
		return .Expectation_Failed
	case 418:
		return .Im_A_Teapot
	case 422:
		return .Unprocessable_Entity
	case 425:
		return .Too_Early
	case 426:
		return .Upgrade_Required
	case 428:
		return .Precondition_Required
	case 429:
		return .Too_Many_Requests
	case 431:
		return .Request_Header_Fields_Too_Large
	case 451:
		return .Unavailable_For_Legal_Reasons
	case 400 ..< 500:
		return Client_Error.Unknown


	case 500:
		return .Server_Error
	case 501:
		return .Not_Implemented
	case 502:
		return .Bad_Request
	case 503:
		return .Service_Unavailable
	case 504:
		return .Gateway_Timeout
	case 505:
		return .HTTP_Version_Not_Supported
	case 507:
		return .Insufficient_Storage
	case 508:
		return .Loop_Detected
	case 511:
		return .Network_Authentication_Required
	case 500 ..< 600:
		return Server_Error.Unknown
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
	Continue = 100,
	Switching_Protocol = 101,
	Processing = 102,
	Early_Hints = 103,
	Unknown,
}

Success :: enum i64 {
	Ok = 200,
	Created = 201,
	Accepted = 202,
	Non_Authoritative_Information = 203,
	No_Content = 204,
	Reset_Content = 205,
	Partial_Content = 206,
	Multi_Status = 207,
	Already_Reported = 208,
	Unknown,
}

Redirection :: enum i64 {
	Multiple_Choices = 300,
	Moved_Permanently = 301,
	Found = 302,
	See_Other = 303,
	Not_Modified = 304,
	Temporary_Redirect = 305,
	Permanent_Redirect = 306,
	Unknown,
}

Client_Error :: enum i64 {
	Bad_Request = 400,
	Unauthorized = 401,
	Payment_Required = 402,
	Forbidden = 403,
	Not_Found = 404,
	Method_Not_Allowed = 405,
	Not_Acceptable = 406,
	Proxy_Authentication_Required = 407,
	Request_Timeout = 408,
	Conflict = 409,
	Gone = 410,
	Length_Required = 411,
	Precondition_Failed = 412,
	Payload_Too_Large = 413,
	URI_Too_Long = 414,
	Unsupported_Media_Type = 415,
	Range_Not_Satisfiable = 416,
	Expectation_Failed = 417,
	Im_A_Teapot = 418,
	Unprocessable_Entity = 422,
	Too_Early = 425,
	Upgrade_Required = 426,
	Precondition_Required = 428,
	Too_Many_Requests = 429,
	Request_Header_Fields_Too_Large = 431,
	Unavailable_For_Legal_Reasons = 451,
	Unknown,
}

Server_Error :: enum i64 {
	Server_Error = 500,
	Not_Implemented = 501,
	Bad_Gateway = 502,
	Service_Unavailable = 503,
	Gateway_Timeout = 504,
	HTTP_Version_Not_Supported = 505,
	Insufficient_Storage = 507,
	Loop_Detected = 508,
	Network_Authentication_Required = 511,
	Unknown,
}

