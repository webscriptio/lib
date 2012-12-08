local underscore = require('underscore')

-- Verify that an incoming request came from Twilio
local verify = function (request, authtoken)
	-- Start with the full URL
	local sts = request.scheme .. '://' .. request.headers.Host .. request.path
	-- Including the querystring (if any)
	if request.querystring ~= nil then
		sts = sts .. '?' .. request.querystring
	end
	if request.method == 'POST' then
		-- Add any POST fields
		local params = request.form or request.query
		for i,k in ipairs(underscore.sort(underscore.keys(request.form))) do
			sts = sts .. k .. request.form[k]
		end
	end

	hmac = crypto.hmac(authtoken, sts, crypto.sha1).digest()
	return request.headers['X-Twilio-Signature'] == base64.encode(hmac)
end

local sms = function (accountsid, authtoken, from, to, body)
	return http.request {
		method = 'POST',
		url = string.format('https://api.twilio.com/2010-04-01/Accounts/%s/SMS/Messages.json', accountsid),
		data = { From=from, To=to, Body=body },
		auth = {accountsid, authtoken}
	}
end

local call = function (accountsid, authtoken, from, to, url)
	return http.request {
		method = 'POST',
		url = string.format('https://api.twilio.com/2010-04-01/Accounts/%s/Calls.json', accountsid),
		data={ From=from, To=to, Url=url },
		auth={accountsid, authtoken}
	}
end

return { verify = verify, sms = sms, call = call }
