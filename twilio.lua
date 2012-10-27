local underscore = require('webscriptio/lib/underscore.lua')

local verify = function (request, authToken)
	local sts = request.scheme .. '://' .. request.headers.Host .. request.path
	for k in underscore.sort(underscore.keys(request.form)) do
		sts = sts .. k .. request.form[k]
	end

	hmac = crypto.hmac(authToken, sts, crypto.sha1).digest()
	return request.headers['X-Twilio-Signature'] == base64.encode(hmac)
end

return { verify = verify }
