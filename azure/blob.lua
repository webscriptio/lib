function formattime(time)
	return os.date('!%Y-%m-%dT%H:%M:%SZ', time)
end

function signature(account, key, params, container, path)
	local sts = string.format('%s\n%s\n%s\n/%s/%s/%s\n',
		params.sp, params.st or '', params.se, account, container,
		path)
	return base64.encode(
		crypto.hmac(base64.decode(key), sts, crypto.sha256).digest())
end

-- get a Shared Access Signature URL for a blob with the given
--	permissions ('r', 'w', or 'rw') valid for the given
--	duration (in seconds)
function sas(account, key, container, path, permissions, duration)
	params = { sp = permissions, se = formattime(os.time()+duration), sr = 'b' }
	params.sig = signature(account, key, params, container, path)
	return string.format('https://%s.blob.core.windows.net/%s/%s?%s',
		account, container, path, http.qsencode(params))
end

return { sas = sas }
