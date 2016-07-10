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
			status = "������"
		elseif jtab.weather[1].main == "Drizzle" then
			status = "���� �����"
		elseif jtab.weather[1].main == "Rain" then
			status = "������"
		elseif jtab.weather[1].main == "Snow" then
			status = "����"
		elseif jtab.weather[1].main == "Atmosphere" then
			status = "�� - ���� ����"
		elseif jtab.weather[1].main == "Clear" then
			status = "���"
		elseif jtab.weather[1].main == "Clouds" then
			status = "����"
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
			rain = jtab.rain["3h"].." �������"
		else
			rain = "-----"
		end
		if jtab.snow then
			snow = jtab.snow["3h"].." �������"
		else
			snow = "-----"
		end
		today = "�� ǘ��� ���� ��� �� "..jtab.name.."\n"
		.."     "..C1.."� ���� �������� (������)\n"
		.."     "..F1.."� ��������\n"
		.."     "..jtab.main.temp.."� �����\n"
		.."���� � ��� "..status.." ������\n\n"
		.."����� ���� �����: C"..C2.."�   F"..F2.."�   K"..jtab.main.temp_min.."�\n"
		.."��ǘ�� ���� �����: C"..C3.."�   F"..F3.."�   K"..jtab.main.temp_max.."�\n"
		.."����� ���: "..jtab.main.humidity.."% ����\n"
		.."����� ��� �����: "..jtab.clouds.all.."% ����\n"
		.."���� ���: "..(jtab.wind.speed or "------").."m/s ��� �� �����\n"
		.."��� ���: "..(jtab.wind.deg or "------").."� ����\n"
		.."���� ���: "..(jtab.main.pressure/1000).." ��� (������)\n"
		.."����ϐ� 3���� ����: "..rain.."\n"
		.."���� ��� 3���� ����: "..snow.."\n\n"
		after = ""
		local res = http.request("http://api.openweathermap.org/data/2.5/forecast?q="..URL.escape(matches[2]).."&appid=269ed82391822cc692c9afd59f4aabba")
		local jtab = JSON.decode(res)
		for i=1,5 do
			local F1,C1 = temps(jtab.list[i].main.temp_min)
			local F2,C2 = temps(jtab.list[i].main.temp_max)
			if jtab.list[i].weather[1].main == "Thunderstorm" then
				status = "������"
			elseif jtab.list[i].weather[1].main == "Drizzle" then
				status = "���� �����"
			elseif jtab.list[i].weather[1].main == "Rain" then
				status = "������"
			elseif jtab.list[i].weather[1].main == "Snow" then
				status = "����"
			elseif jtab.list[i].weather[1].main == "Atmosphere" then
				status = "�� - ���� ����"
			elseif jtab.list[i].weather[1].main == "Clear" then
				status = "���"
			elseif jtab.list[i].weather[1].main == "Clouds" then
				status = "����"
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
				day = "���� ��� "
			elseif i == 2 then
				day = "�� ���� ��� "
			elseif i == 3 then
				day = "3��� ��� ��� "
			elseif i == 4 then
				day = "4��� ��� ��� "
			elseif i == 5 then
				day = "5��� ��� ��� "
			end
			after = after.."- "..day..status.." ������. "..icon.."\n??C"..C2.."�  -  F"..F2.."�\n??C"..C1.."�  -  F"..F1.."�\n"
		end
		
		return today.."����� �� � ��� �� ��� ��� �����:\n"..after
	else
		return "��� ���� ��� ���� ����"
	end
end

return {
	description = "Weather Status",
	usagehtm = '<tr><td align="center">weather ���</td><td align="right">��� ��ǐ�� �� ��� ��� ���� �� ����� �� �� �������� Ԙ� ��� �� ����� �� � ���� ��� ���� ��� �� ���� ����� ������� �� � ���� ���� ��� ����� ��� ���� �����. ��� ���� ��� ��� �� ����� ���� ����</td></tr>',
	usage = {"weather (city) : ����� �� � ���"},
	patterns = {"^[!/#]([Ww]eather) (.*)$"},
	run = run,
}

-- https://telegram.me/plugin_ch
