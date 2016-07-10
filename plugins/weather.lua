?-- https://telegram.me/plugin_ch
local function temps(K)
	local F = (K*1.8)-459.67
	local C = K-273.15
	return F,C
end

local function run(msg, matches)
	local res = http.request("http://api.openweathermap.org/data/2.5/weather?q="..URL.escape(matches[2]).."&appid=269ed82391822cc692c9afd59f4aabba")
	local jtab = JSON.decode(res)
	if jtab.name then
		if jtab.weather[1].main == "Thunderstorm" then
			status = "ØæİÇäí"
		elseif jtab.weather[1].main == "Drizzle" then
			status = "äãäã ÈÇÑÇä"
		elseif jtab.weather[1].main == "Rain" then
			status = "ÈÇÑÇäí"
		elseif jtab.weather[1].main == "Snow" then
			status = "ÈÑİí"
		elseif jtab.weather[1].main == "Atmosphere" then
			status = "ãå - ÛÈÇÒ ÂáæÏ"
		elseif jtab.weather[1].main == "Clear" then
			status = "ÕÇİ"
		elseif jtab.weather[1].main == "Clouds" then
			status = "ÇÈÑí"
		elseif jtab.weather[1].main == "Extreme" then
			status = "-------"
		elseif jtab.weather[1].main == "Additional" then
			status = "-------"
		else
			status = "-------"
		end
		local F1,C1 = temps(jtab.main.temp)
		local F2,C2 = temps(jtab.main.temp_min)
		local F3,C3 = temps(jtab.main.temp_max)
		send_document(get_receiver(msg), "file/weatherIcon/"..jtab.weather[1].icon..".webp", ok_cb, false)
		if jtab.rain then
			rain = jtab.rain["3h"].." ãíáíãÊÑ"
		else
			rain = "-----"
		end
		if jtab.snow then
			snow = jtab.snow["3h"].." ãíáíãÊÑ"
		else
			snow = "-----"
		end
		today = "åã Ç˜äæä ÏãÇí åæÇ ÏÑ "..jtab.name.."\n"
		.."     "..C1.."° ÏÑÌå ÓÇäÊíÑÇÏ (ÓáÓíæÓ)\n"
		.."     "..F1.."° İÇÑäåÇíÊ\n"
		.."     "..jtab.main.temp.."° ˜áæíä\n"
		.."ÈæÏå æ åæÇ "..status.." ãíÈÇÔÏ\n\n"
		.."ÍÏÇŞá ÏãÇí ÇãÑæÒ: C"..C2.."°   F"..F2.."°   K"..jtab.main.temp_min.."°\n"
		.."ÍÏÇ˜ËÑ ÏãÇí ÇãÑæÒ: C"..C3.."°   F"..F3.."°   K"..jtab.main.temp_max.."°\n"
		.."ÑØæÈÊ åæÇ: "..jtab.main.humidity.."% ÏÑÕÏ\n"
		.."ãŞÏÇÑ ÇÈÑ ÂÓãÇä: "..jtab.clouds.all.."% ÏÑÕÏ\n"
		.."ÓÑÚÊ ÈÇÏ: "..(jtab.wind.speed or "------").."m/s ãÊÑ ÈÑ ËÇäíå\n"
		.."ÌåÊ ÈÇÏ: "..(jtab.wind.deg or "------").."° ÏÑÌå\n"
		.."İÔÇÑ åæÇ: "..(jtab.main.pressure/1000).." ÈÇÑ (ÇÊãÓİÑ)\n"
		.."ÈÇÑäÏí 3ÓÇÚÊ ÇÎíÑ: "..rain.."\n"
		.."ÈÇÑÔ ÈÑİ 3ÓÇÚÊ ÇÎíÑ: "..snow.."\n\n"
		after = ""
		local res = http.request("http://api.openweathermap.org/data/2.5/forecast?q="..URL.escape(matches[2]).."&appid=269ed82391822cc692c9afd59f4aabba")
		local jtab = JSON.decode(res)
		for i=1,5 do
			local F1,C1 = temps(jtab.list[i].main.temp_min)
			local F2,C2 = temps(jtab.list[i].main.temp_max)
			if jtab.list[i].weather[1].main == "Thunderstorm" then
				status = "ØæİÇäí"
			elseif jtab.list[i].weather[1].main == "Drizzle" then
				status = "äãäã ÈÇÑÇä"
			elseif jtab.list[i].weather[1].main == "Rain" then
				status = "ÈÇÑÇäí"
			elseif jtab.list[i].weather[1].main == "Snow" then
				status = "ÈÑİí"
			elseif jtab.list[i].weather[1].main == "Atmosphere" then
				status = "ãå - ÛÈÇÒ ÂáæÏ"
			elseif jtab.list[i].weather[1].main == "Clear" then
				status = "ÕÇİ"
			elseif jtab.list[i].weather[1].main == "Clouds" then
				status = "ÇÈÑí"
			elseif jtab.list[i].weather[1].main == "Extreme" then
				status = "-------"
			elseif jtab.list[i].weather[1].main == "Additional" then
				status = "-------"
			else
				status = "-------"
			end
			local file = io.open("./file/weatherIcon/"..jtab.list[i].weather[1].icon..".char")
			if file then
				local file = io.open("./file/weatherIcon/"..jtab.list[i].weather[1].icon..".char", "r")
				icon = file:read("*all")
			else
				icon = ""
			end
			if i == 1 then
				day = "İÑÏÇ åæÇ "
			elseif i == 2 then
				day = "Ó İÑÏÇ åæÇ "
			elseif i == 3 then
				day = "3ÑæÒ ÈÚÏ åæÇ "
			elseif i == 4 then
				day = "4ÑæÒ ÈÚÏ åæÇ "
			elseif i == 5 then
				day = "5ÑæÒ ÈÚÏ åæÇ "
			end
			after = after.."- "..day..status.." ãíÈÇÔÏ. "..icon.."\n??C"..C2.."°  -  F"..F2.."°\n??C"..C1.."°  -  F"..F1.."°\n"
		end
		
		return today.."æÖÚíÊ ÂÈ æ åæÇ ÏÑ äÌ ÑæÒ ÂíäÏå:\n"..after
	else
		return "ã˜Çä æÇÑÏ ÔÏå ÕÍíÍ äíÓÊ"
	end
end

return {
	description = "Weather Status",
	usagehtm = '<tr><td align="center">weather ÔåÑ</td><td align="right">Çíä áÇíä Èå ÔãÇ Çíä Çã˜Çä ÑÇ ãíÏåÏ ˜å Èå ˜ÇãáÊÑíä Ô˜á ãã˜ä ÇÒ æÖÚíÊ ÂÈ æ åæÇí ÔåÑ ãæÑÏ äÙÑ ÂÇå ÔæíÏ åãäíä ÇØáÇÚÇÊ ÂÈ æ åæÇí äÌÌ ÑæÒ ÂíäÏå äíÒ ÇÑÇå ãíÔæÏ. ÏŞÊ ˜äíÏ äÇã ÔåÑ ÑÇ áÇÊíä æÇÑÏ ˜äíÏ</td></tr>',
	usage = {"weather (city) : æÖÚíÊ ÂÈ æ åæÇ"},
	patterns = {"^[!/#]([Ww]eather) (.*)$"},
	run = run,
}

-- https://telegram.me/plugin_ch
