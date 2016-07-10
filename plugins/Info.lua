local function callback_reply(extra, success, result)
	--icon & rank ------------------------------------------------------------------------------------------------
	userrank = "Member"
	if tonumber(result.from.id) == 175636120 then
		userrank = "Master ????"
		send_document(org_chat_id,"umbrella/stickers/master.webp", ok_cb, false)
	elseif is_sudo(result) then
		userrank = "Sudo ?????"
		send_document(org_chat_id,"umbrella/stickers/sudo.webp", ok_cb, false)
	elseif is_admin2(result.from.id) then
		userrank = "Admin ???"
		send_document(org_chat_id,"umbrella/stickers/admin.webp", ok_cb, false)
	elseif is_owner2(result.from.id, result.to.id) then
		userrank = "Owner ??"
		send_document(org_chat_id,"umbrella/stickers/leader.webp", ok_cb, false)
	elseif is_momod2(result.from.id, result.to.id) then
		userrank = "Moderator ?"
		send_document(org_chat_id,"umbrella/stickers/mod.webp", ok_cb, false)
	elseif tonumber(result.from.id) == tonumber(our_id) then
		userrank = "Signal ??????"
		send_document(org_chat_id,"umbrella/stickers/umb.webp", ok_cb, false)
	elseif result.from.username then
		if string.sub(result.from.username:lower(), -3) == "bot" then
			userrank = "API Bot"
			send_document(org_chat_id,"umbrella/stickers/api.webp", ok_cb, false)
		end
	end
	--custom rank ------------------------------------------------------------------------------------------------
	local file = io.open("./info/"..result.from.id..".txt", "r")
	if file ~= nil then
		usertype = file:read("*all")
	else
		usertype = "-----"
	end
	--cont ------------------------------------------------------------------------------------------------
	local user_info = {}
	local uhash = 'user:'..result.from.id
	local user = redis:hgetall(uhash)
	local um_hash = 'msgs:'..result.from.id..':'..result.to.id
	user_info.msgs = tonumber(redis:get(um_hash) or 0)
	--msg type ------------------------------------------------------------------------------------------------
	if result.media then
		if result.media.type == "document" then
			if result.media.text then
				msg_type = "ÇÓÊí˜Ñ"
			else
				msg_type = "ÓÇíÑ İÇíáåÇ"
			end
		elseif result.media.type == "photo" then
			msg_type = "İÇíá Ú˜Ó"
		elseif result.media.type == "video" then
			msg_type = "İÇíá æíÏÆæíí"
		elseif result.media.type == "audio" then
			msg_type = "İÇíá ÕæÊí"
		elseif result.media.type == "geo" then
			msg_type = "ãæŞÚíÊ ã˜Çäí"
		elseif result.media.type == "contact" then
			msg_type = "ÔãÇÑå Êáİä"
		elseif result.media.type == "file" then
			msg_type = "İÇíá"
		elseif result.media.type == "webpage" then
			msg_type = "íÔ äãÇíÔ ÓÇíÊ"
		elseif result.media.type == "unsupported" then
			msg_type = "İÇíá ãÊÍÑ˜"
		else
			msg_type = "äÇÔäÇÎÊå"
		end
	elseif result.text then
		if string.match(result.text, '^%d+$') then
			msg_type = "ÚÏÏ"
		elseif string.match(result.text, '%d+') then
			msg_type = "ÔÇãá ÚÏÏ æ ÍÑæİ"
		elseif string.match(result.text, '^@') then
			msg_type = "íæÒÑäíã"
		elseif string.match(result.text, '@') then
			msg_type = "ÔÇãá íæÒÑäíã"
		elseif string.match(result.text, '[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]') then
			msg_type = "áíä˜ ÊáÑÇã"
		elseif string.match(result.text, '[Hh][Tt][Tt][Pp]') then
			msg_type = "áíä˜ ÓÇíÊ"
		elseif string.match(result.text, '[Ww][Ww][Ww]') then
			msg_type = "áíä˜ ÓÇíÊ"
		elseif string.match(result.text, '?') then
			msg_type = "ÑÓÔ"
		else
			msg_type = "ãÊä"
		end
	end
	--hardware ------------------------------------------------------------------------------------------------
	if result.text then
		inputtext = string.sub(result.text, 0,1)
		if result.text then
			if string.match(inputtext, "[a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z]") then
				hardware = "˜ÇãíæÊÑ"
			elseif string.match(inputtext, "[A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z]") then
				hardware = "ãæÈÇíá"
			else
				hardware = "-----"
			end
		else
			hardware = "-----"
		end
	else
		hardware = "-----"
	end
	--phone ------------------------------------------------------------------------------------------------
	if access == 1 then
		if result.from.phone then
			number = "+"..string.sub(result.from.phone, 3)
			if string.sub(result.from.phone, 0,2) == '98' then
				number = number.."\n˜ÔæÑ: ÌãåæÑí ÇÓáÇãí ÇíÑÇä"
				if string.sub(result.from.phone, 0,4) == '9891' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: åãÑÇå Çæá"
				elseif string.sub(result.from.phone, 0,5) == '98932' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÊÇáíÇ"
				elseif string.sub(result.from.phone, 0,4) == '9893' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÇíÑÇäÓá"
				elseif string.sub(result.from.phone, 0,4) == '9890' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÇíÑÇäÓá"
				elseif string.sub(result.from.phone, 0,4) == '9892' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÑÇíÊá"
				else
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÓÇíÑ"
				end
			else
				number = number.."\n˜ÔæÑ: ÎÇÑÌ\näæÚ Óíã˜ÇÑÊ: ãÊİÑŞå"
			end
		else
			number = "-----"
		end
	elseif access == 0 then
		if result.from.phone then
			number = "ÔãÇ ãÌÇÒ äíÓÊíÏ"
			if string.sub(result.from.phone, 0,2) == '98' then
				number = number.."\n˜ÔæÑ: ÌãåæÑí ÇÓáÇãí ÇíÑÇä"
				if string.sub(result.from.phone, 0,4) == '9891' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: åãÑÇå Çæá"
				elseif string.sub(result.from.phone, 0,5) == '98932' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÊÇáíÇ"
				elseif string.sub(result.from.phone, 0,4) == '9893' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÇíÑÇäÓá"
				elseif string.sub(result.from.phone, 0,4) == '9890' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÇíÑÇäÓá"
				elseif string.sub(result.from.phone, 0,4) == '9892' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÑÇíÊá"
				else
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÓÇíÑ"
				end
			else
				number = number.."\n˜ÔæÑ: ÎÇÑÌ\näæÚ Óíã˜ÇÑÊ: ãÊİÑŞå"
			end
		else
			number = "-----"
		end
	end
	--info ------------------------------------------------------------------------------------------------
			local url , res = http.request('http://api.gpmod.ir/time/')
            if res ~= 200 then return "No connection" end
            local jdat = json:decode(url)
			local info = "äÇã ˜Çãá: "..string.gsub(msg.from.print_name, "_", " ").."\n"
					.."äÇã ˜æ˜: "..(msg.from.first_name or "-----").."\n"
					.."äÇã ÎÇäæÇÏí: "..(msg.from.last_name or "-----").."\n\n"
					.."ÔãÇÑå ãæÈÇíá: "..number.."\n"
					.."íæÒÑäíã: @"..(msg.from.username or "-----").."\n\n"
					.."ÓÇÚÊ: "..jdat.FAtime.."\n"
					.."ÊÇÑíÎ: "..jdat.FAdate.."\n"
					.."Âí Ïí: "..msg.from.id.."\n\n"
					.."ãŞÇã: "..usertype.."\n"
					.."ÌÇíÇå: "..userrank.."\n\n"
					.."ÑÇÈØ ˜ÇÑÈÑí: "..hardware.."\n"
					.."ÊÚÏÇÏ íÇãåÇ: "..user_info.msgs.."\n\n"
					.."äÇã Ñæå: "..string.gsub(msg.to.print_name, "_", " ").."\n"
					.."Âí Ïí Ñæå: "..msg.to.id
	send_large_msg(org_chat_id, info)
end

local function callback_res(extra, success, result)
	if success == 0 then
		return send_large_msg(org_chat_id, "íæÒÑäíã æÇÑÏ ÔÏå ÇÔÊÈÇå ÇÓÊ")
	end
	--icon & rank ------------------------------------------------------------------------------------------------
	if tonumber(result.id) == 175636120 then
		userrank = "Master ????"
		send_document(org_chat_id,"umbrella/stickers/master.webp", ok_cb, false)
	elseif is_sudo(result) then
		userrank = "Sudo ?????"
		send_document(org_chat_id,"umbrella/stickers/sudo.webp", ok_cb, false)
	elseif is_admin2(result.id) then
		userrank = "Admin ???"
		send_document(org_chat_id,"umbrella/stickers/admin.webp", ok_cb, false)
	elseif is_owner2(result.id, extra.chat2) then
		userrank = "Owner ??"
		send_document(org_chat_id,"umbrella/stickers/leader.webp", ok_cb, false)
	elseif is_momod2(result.id, extra.chat2) then
		userrank = "Moderator ?"
		send_document(org_chat_id,"umbrella/stickers/mod.webp", ok_cb, false)
	elseif tonumber(result.id) == tonumber(our_id) then
		userrank = "Signal ??????"
		send_document(org_chat_id,"umbrella/stickers/umb.webp", ok_cb, false)
	elseif result.from.username then
		if string.sub(result.from.username:lower(), -3) == "bot" then
			userrank = "API Bot"
			send_document(org_chat_id,"umbrella/stickers/api.webp", ok_cb, false)
	else
		userrank = "Member"
	end
	end
	--custom rank ------------------------------------------------------------------------------------------------
	local file = io.open("./info/"..result.id..".txt", "r")
	if file ~= nil then
		usertype = file:read("*all")
	else
		usertype = "-----"
	end
	--phone ------------------------------------------------------------------------------------------------
	if access == 1 then
		if result.phone then
			number = "+"..string.sub(result.phone, 3)
			if string.sub(result.phone, 0,2) == '98' then
				number = number.."\n˜ÔæÑ: ÌãåæÑí ÇÓáÇãí ÇíÑÇä"
				if string.sub(result.phone, 0,4) == '9891' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: åãÑÇå Çæá"
				elseif string.sub(result.phone, 0,5) == '98932' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÊÇáíÇ"
				elseif string.sub(result.phone, 0,4) == '9893' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÇíÑÇäÓá"
				elseif string.sub(result.phone, 0,4) == '9890' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÇíÑÇäÓá"
				elseif string.sub(result.phone, 0,4) == '9892' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÑÇíÊá"
				else
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÓÇíÑ"
				end
			else
				number = number.."\n˜ÔæÑ: ÎÇÑÌ\näæÚ Óíã˜ÇÑÊ: ãÊİÑŞå"
			end
		else
			number = "-----"
		end
	elseif access == 0 then
		if result.phone then
			number = "ÔãÇ ãÌÇÒ äíÓÊíÏ"
			if string.sub(result.phone, 0,2) == '98' then
				number = number.."\n˜ÔæÑ: ÌãåæÑí ÇÓáÇãí ÇíÑÇä"
				if string.sub(result.phone, 0,4) == '9891' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: åãÑÇå Çæá"
				elseif string.sub(result.phone, 0,5) == '98932' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÊÇáíÇ"
				elseif string.sub(result.phone, 0,4) == '9893' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÇíÑÇäÓá"
				elseif string.sub(result.phone, 0,4) == '9890' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÇíÑÇäÓá"
				elseif string.sub(result.phone, 0,4) == '9892' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÑÇíÊá"
				else
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÓÇíÑ"
				end
			else
				number = number.."\n˜ÔæÑ: ÎÇÑÌ\näæÚ Óíã˜ÇÑÊ: ãÊİÑŞå"
			end
		else
			number = "-----"
		end
	end
	--info ------------------------------------------------------------------------------------------------
	info = "äÇã ˜Çãá: "..string.gsub(result.print_name, "_", " ").."\n"
	.."äÇã ˜æ˜: "..(result.first_name or "-----").."\n"
	.."äÇã ÎÇäæÇÏí: "..(result.last_name or "-----").."\n\n"
	.."ÔãÇÑå ãæÈÇíá: "..number.."\n"
	.."íæÒÑäíã: @"..(result.username or "-----").."\n"
	.."Âí Ïí: "..result.id.."\n\n"
	.."ãŞÇã: "..usertype.."\n"
	.."ÌÇíÇå: "..userrank.."\n\n"
	send_large_msg(org_chat_id, info)
end

local function callback_info(extra, success, result)
	if success == 0 then
		return send_large_msg(org_chat_id, "Âí Ïí æÇÑÏ ÔÏå ÇÔÊÈÇå ÇÓÊ")
	end
	--icon & rank ------------------------------------------------------------------------------------------------
	if tonumber(result.id) == 175636120 then
		userrank = "Master ????"
		send_document(org_chat_id,"umbrella/stickers/master.webp", ok_cb, false)
	elseif is_sudo(result) then
		userrank = "Sudo ?????"
		send_document(org_chat_id,"umbrella/stickers/sudo.webp", ok_cb, false)
	elseif is_admin2(result.id) then
		userrank = "Admin ???"
		send_document(org_chat_id,"umbrella/stickers/admin.webp", ok_cb, false)
	elseif is_owner2(result.id, extra.chat2) then
		userrank = "Owner ??"
		send_document(org_chat_id,"umbrella/stickers/leader.webp", ok_cb, false)
	elseif is_momod2(result.id, extra.chat2) then
		userrank = "Moderator ?"
		send_document(org_chat_id,"umbrella/stickers/mod.webp", ok_cb, false)
	elseif tonumber(result.id) == tonumber(our_id) then
		userrank = "Signal ??????"
		send_document(org_chat_id,"umbrella/stickers/umb.webp", ok_cb, false)
	elseif result.from.username then
		if string.sub(result.from.username:lower(), -3) == "bot" then
			userrank = "API Bot"
			send_document(org_chat_id,"umbrella/stickers/api.webp", ok_cb, false)
	else
		userrank = "Member"
	end
	end
	--custom rank ------------------------------------------------------------------------------------------------
	local file = io.open("./info/"..result.id..".txt", "r")
	if file ~= nil then
		usertype = file:read("*all")
	else
		usertype = "-----"
	end
	--phone ------------------------------------------------------------------------------------------------
	if access == 1 then
		if result.phone then
			number = "+"..string.sub(result.phone, 3)
			if string.sub(result.phone, 0,2) == '98' then
				number = number.."\n˜ÔæÑ: ÌãåæÑí ÇÓáÇãí ÇíÑÇä"
				if string.sub(result.phone, 0,4) == '9891' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: åãÑÇå Çæá"
				elseif string.sub(result.phone, 0,5) == '98932' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÊÇáíÇ"
				elseif string.sub(result.phone, 0,4) == '9893' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÇíÑÇäÓá"
				elseif string.sub(result.phone, 0,4) == '9890' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÇíÑÇäÓá"
				elseif string.sub(result.phone, 0,4) == '9892' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÑÇíÊá"
				else
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÓÇíÑ"
				end
			else
				number = number.."\n˜ÔæÑ: ÎÇÑÌ\näæÚ Óíã˜ÇÑÊ: ãÊİÑŞå"
			end
		else
			number = "-----"
		end
	elseif access == 0 then
		if result.phone then
			number = "ÔãÇ ãÌÇÒ äíÓÊíÏ"
			if string.sub(result.phone, 0,2) == '98' then
				number = number.."\n˜ÔæÑ: ÌãåæÑí ÇÓáÇãí ÇíÑÇä"
				if string.sub(result.phone, 0,4) == '9891' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: åãÑÇå Çæá"
				elseif string.sub(result.phone, 0,5) == '98932' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÊÇáíÇ"
				elseif string.sub(result.phone, 0,4) == '9893' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÇíÑÇäÓá"
				elseif string.sub(result.phone, 0,4) == '9890' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÇíÑÇäÓá"
				elseif string.sub(result.phone, 0,4) == '9892' then
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÑÇíÊá"
				else
					number = number.."\näæÚ Óíã˜ÇÑÊ: ÓÇíÑ"
				end
			else
				number = number.."\n˜ÔæÑ: ÎÇÑÌ\näæÚ Óíã˜ÇÑÊ: ãÊİÑŞå"
			end
		else
			number = "-----"
		end
	end
	--name ------------------------------------------------------------------------------------------------
	if string.len(result.print_name) > 15 then
		fullname = string.sub(result.print_name, 0,15).."..."
	else
		fullname = result.print_name
	end
	if result.first_name then
		if string.len(result.first_name) > 15 then
			firstname = string.sub(result.first_name, 0,15).."..."
		else
			firstname = result.first_name
		end
	else
		firstname = "-----"
	end
	if result.last_name then
		if string.len(result.last_name) > 15 then
			lastname = string.sub(result.last_name, 0,15).."..."
		else
			lastname = result.last_name
		end
	else
		lastname = "-----"
	end
	--info ------------------------------------------------------------------------------------------------
	info = "äÇã ˜Çãá: "..string.gsub(result.print_name, "_", " ").."\n"
	.."äÇã ˜æ˜: "..(result.first_name or "-----").."\n"
	.."äÇã ÎÇäæÇÏí: "..(result.last_name or "-----").."\n\n"
	.."ÔãÇÑå ãæÈÇíá: "..number.."\n"
	.."íæÒÑäíã: @"..(result.username or "-----").."\n"
	.."ÓÇÚÊ: "..msg.from.time.."\n"
	.."Âí Ïí: "..result.id.."\n\n"
	.."ãŞÇã: "..usertype.."\n"
	.."ÌÇíÇå: "..userrank.."\n\n"
	send_large_msg(org_chat_id, info)
end

local function run(msg, matches)
	local data = load_data(_config.moderation.data)
	org_channel_id = "channel#id"..msg.to.id
	if is_sudo(msg) then
		access = 1
	else
		access = 0
	end
	if matches[1] == 'infodel' and is_sudo(msg) then
		azlemagham = io.popen('rm ./info/'..matches[2]..'.txt'):read('*all')
		return 'ÇÒ ãŞÇã ÎæÏ ÚÒá ÔÏ'
	elseif matches[1] == 'Info' and is_sudo(msg) then
		local name = string.sub(matches[2], 1, 50)
		local text = string.sub(matches[3], 1, 10000000000)
		local file = io.open("./info/"..name..".txt", "w")
		file:write(text)
		file:flush()
		file:close() 
		return "ãŞÇã ËÈÊ ÔÏ"
	elseif #matches == 2 then
		local cbres_extra = {chatid = msg.to.id}
		if string.match(matches[2], '^%d+$') then
			return user_info('user#id'..matches[2], callback_info, cbres_extra)
		else
			return res_user(matches[2]:gsub("@",""), callback_res, cbres_extra)
		end
	else
		--custom rank ------------------------------------------------------------------------------------------------
		local file = io.open("./info/"..msg.from.id..".txt", "r")
		if file ~= nil then
			usertype = file:read("*all")
		else
			usertype = "-----"
		end
		--hardware ------------------------------------------------------------------------------------------------
		if matches[1] == "info" then
			hardware = "˜ÇãíæÊÑ"
		else
			hardware = "ãæÈÇíá"
		end
		if not msg.reply_id then
			--contor ------------------------------------------------------------------------------------------------
			local user_info = {}
			local uhash = 'user:'..msg.from.id
			local user = redis:hgetall(uhash)
			local um_hash = 'msgs:'..msg.from.id..':'..msg.to.id
			user_info.msgs = tonumber(redis:get(um_hash) or 0)
			--icon & rank ------------------------------------------------------------------------------------------------
			if tonumber(msg.from.id) == 175636120 then
				userrank = "Master ????"
				send_document("chat#id"..msg.to.id,"umbrella/stickers/master.webp", ok_cb, false)
			elseif is_sudo(msg) then
				userrank = "Sudo ?????"
				send_document("chat#id"..msg.to.id,"umbrella/stickers/sudo.webp", ok_cb, false)
			elseif is_admin(msg) then
				userrank = "Admin ???"
				send_document("chat#id"..msg.to.id,"umbrella/stickers/admin.webp", ok_cb, false)
			elseif is_owner(msg) then
				userrank = "Owner ??"
				send_document("chat#id"..msg.to.id,"umbrella/stickers/leader.webp", ok_cb, false)
			elseif is_momod(msg) then
				userrank = "Moderator ?"
				send_document("chat#id"..msg.to.id,"umbrella/stickers/mod.webp", ok_cb, false)
			else
				userrank = "Member"
			end
			--number ------------------------------------------------------------------------------------------------
			if msg.from.phone then
				numberorg = string.sub(msg.from.phone, 3)
				number = "****+"..string.sub(numberorg, 0,6)
				if string.sub(msg.from.phone, 0,2) == '98' then
					number = number.."\n˜ÔæÑ: ÌãåæÑí ÇÓáÇãí ÇíÑÇä"
					if string.sub(msg.from.phone, 0,4) == '9891' then
						number = number.."\näæÚ Óíã˜ÇÑÊ: åãÑÇå Çæá"
					elseif string.sub(msg.from.phone, 0,5) == '98932' then
						number = number.."\näæÚ Óíã˜ÇÑÊ: ÊÇáíÇ"
					elseif string.sub(msg.from.phone, 0,4) == '9893' then
						number = number.."\näæÚ Óíã˜ÇÑÊ: ÇíÑÇäÓá"
					elseif string.sub(msg.from.phone, 0,4) == '9890' then
						number = number.."\näæÚ Óíã˜ÇÑÊ: ÇíÑÇäÓá"
					elseif string.sub(msg.from.phone, 0,4) == '9892' then
						number = number.."\näæÚ Óíã˜ÇÑÊ: ÑÇíÊá"
					else
						number = number.."\näæÚ Óíã˜ÇÑÊ: ÓÇíÑ"
					end
				else
					number = number.."\n˜ÔæÑ: ÎÇÑÌ\näæÚ Óíã˜ÇÑÊ: ãÊİÑŞå"
				end
			else
				number = "-----"
			end
			--time ------------------------------------------------------------------------------------------------
			local url , res = http.request('http://api.gpmod.ir/time/')
            if res ~= 200 then return "No connection" end
            local jdat = json:decode(url)
			local info = "äÇã ˜Çãá: "..string.gsub(msg.from.print_name, "_", " ").."\n"
					.."äÇã ˜æ˜: "..(msg.from.first_name or "-----").."\n"
					.."äÇã ÎÇäæÇÏí: "..(msg.from.last_name or "-----").."\n\n"
					.."ÔãÇÑå ãæÈÇíá: "..number.."\n"
					.."íæÒÑäíã: @"..(msg.from.username or "-----").."\n\n"
					.."ÓÇÚÊ : "..jdat.FAtime.."\n"
					.."ÊÇÑíÎ :"..jdat.FAdate.."\n"
					.."Âí Ïí: "..msg.from.id.."\n\n"
					.."ãŞÇã: "..usertype.."\n"
					.."ÌÇíÇå: "..userrank.."\n\n"
					.."ÑÇÈØ ˜ÇÑÈÑí: "..hardware.."\n"
					.."ÊÚÏÇÏ íÇãåÇ: "..user_info.msgs.."\n\n"
					.."äÇã Ñæå: "..string.gsub(msg.to.print_name, "_", " ").."\n"
					.."Âí Ïí Ñæå: "..msg.to.id
			return info
		else
			get_message(msg.reply_id, callback_reply, false)
		end
	end
end

return {
	description = "User Infomation",
	usage = {
		user = {
			"/info: ÇØáÇÚÇÊ ÔãÇ",
			"/info (reply): ÇØáÇÚÇÊ ÏíÑÇä",
			},
		sudo = {
			"Info (id) (txt) : ÇÚØÇí ãŞÇã",
			"infodel : ÍĞİ ãŞÇã",
			},
		},
	patterns = {
		"^(infodel) (.*)$",
		"^(Info) ([^%s]+) (.*)$",
		"^[!/#](info) (.*)$",
		"^[!/#](info)$",
		"^[!/#](Info)$",
	},
	run = run,
}
