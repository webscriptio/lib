local jwt = require 'jwt'

local _scopes = {}
local _authToken = ""
local _accountSid = ""
local _clientName = ""

local initialize = function(accountSid, authToken)
	_authToken = authToken
	_accountSid = accountSid
end

local allowClientIncoming = function(clientName)
  if (clientName:match("%W")) then
		error("Only alphanumeric characters allowed in client name.")
	end    

  if (clientName:len() == 0) then
		error("Client name must not be a zero length string.")
	end

	_clientName = clientName
  allow("client", "incoming", nil)
end

local allowClientOutgoing = function(appSid, appParams)
	params = { ["appSid"]=appSid, ["appParams"]=appParams }
	allow("client", "outgoing",	params)
end

local generateToken = function(ttlSeconds)
	scopeStrings = {}
	
	for scopeCount=1, #_scopes do
		scope = _scopes[scopeCount]		
		scopeStrings[#scopeStrings+1] = scopeToString(scope, _clientName)	
	end
	
	payload = {
            scope = table.concat(scopeStrings, " "),
            iss = _accountSid,
            exp = os.time() + ttlSeconds
        }
	
  result = jwt.encode(payload, _authToken, "HS256");
	
	return result
end

function allow(service, privilage, params)
	_scopes[#_scopes+1] = { 
								["service"]=service, 
								["privilage"]=privilage,	
								["params"]=params 
	}
end

function scopeToString(scope, clientName)
	uri = string.format("scope:%s:%s", scope["service"], scope["privilage"])
	
	if (clientName~="") then
		
		if (scope["params"]==nil) then
			scope["params"] = { ["clientName"] = clientName }
		else
			params = scope["params"]
			params["clientName"] = clientName
		end
		
	end

	if (scope["params"]~=nil) then
	
		query = ""
		params = scope["params"]

		for key,item in pairs(params) do
			
			if (query~="") then
				query = query.."&"	
			end
			
			value = item
			
			if (type(item)=="table") then
			
				print("Getting nested")
				
				nestedValue = "";
				
				-- loop through the nested objects and create a new value
				for nestedKey,nestedItem in pairs(item) do
					
					-- if nestedValue is not empty append an &
					if (query~="") then
						nestedValue = nestedValue .. urlEncode("&")
					end
					
					nestedValue = string.format("%s%s=%s",nestedValue, nestedKey, neestedItem)
				end
				
				value = urlEncode(nestedValue)
			end
			
			query = string.format("%s%s=%s", query, key, value)
		end
		
		uri = uri .. "?" .. query
	end
	
	return uri
end

function urlEncode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end

return { initialize = initialize, 
	allowClientIncoming = allowClientIncoming, 
	allowClientOutgoing = allowClientOutgoing,
	generateToken = generateToken
	}