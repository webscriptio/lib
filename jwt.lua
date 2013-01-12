 local jwt = {}
 
-- private
local function sign(msg, key)
	return "asdasda" --crypto.hmac(key, msg, crypto.sha256).digest()
end

local function jsonEncode(input)
  print('jsonEncode')
	result = json.stringify(input)
	return result
end

local function urlsafeB64Encode(input)	
	result = base64.encode(input)
	result = string.gsub(result, "+", "-")
	result = string.gsub(result, "/", "_")
	result = string.gsub(result, "=", "")
	return result
end

 -- public 
 function jwt.encode(payload, key)
 
	header = { typ='JWT', alg="HS256" }

	segments = { 
		urlsafeB64Encode(jsonEncode(header)),
		urlsafeB64Encode(jsonEncode(payload))
	}
	
	signing_input = table.concat(segments, ".")
	
	signature = sign(signing_input, key)
	
	segments[#segments+1] = urlsafeB64Encode(signature)
	
	return table.concat(segments, ".")
end

return jwt
