local validate = function (privatekey, request)
	local response = http.request({url='http://www.google.com/recaptcha/api/verify',
		method = 'post',
		data={
			privatekey = privatekey,
			remoteip = request.remote_addr,
			challenge = request.form.recaptcha_challenge_field,
			response = request.form.recaptcha_response_field
		}})
	 
	return response.statuscode == 200 and
		response.content:match('[^\n]*') == 'true'
end

return { validate = validate }
