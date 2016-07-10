package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'

require("./bot/utils")

local f = assert(io.popen('/usr/bin/git describe --tags', 'r'))
VERSION = assert(f:read('*a'))
f:close()

-- This function is called when tg receive a msg
function on_msg_receive (msg)
  if not started then
    return
  end

  msg = backward_msg_format(msg)

  local receiver = get_receiver(msg)
  print(receiver)
  --vardump(msg)
  --vardump(msg)
  msg = pre_process_service_msg(msg)
  if msg_valid(msg) then
    msg = pre_process_msg(msg)
    if msg then
      match_plugins(msg)
      if redis:get("bot:markread") then
        if redis:get("bot:markread") == "on" then
          mark_read(receiver, ok_cb, false)
        end
      end
    end
  end
end

function ok_cb(extra, success, result)

end

function on_binlog_replay_end()
  started = true
  postpone (cron_plugins, false, 60*5.0)
  -- See plugins/isup.lua as an example for cron

  _config = load_config()

  -- load plugins
  plugins = {}
  load_plugins()
end

function msg_valid(msg)
  -- Don't process outgoing messages
  if msg.out then
    print('\27[36mNot valid: msg from us\27[39m')
    return false
  end

  -- Before bot was started
  if msg.date < os.time() - 5 then
    print('\27[36mNot valid: old msg\27[39m')
    return false
  end

  if msg.unread == 0 then
    print('\27[36mNot valid: readed\27[39m')
    return false
  end

  if not msg.to.id then
    print('\27[36mNot valid: To id not provided\27[39m')
    return false
  end

  if not msg.from.id then
    print('\27[36mNot valid: From id not provided\27[39m')
    return false
  end

  if msg.from.id == our_id then
    print('\27[36mNot valid: Msg from our id\27[39m')
    return false
  end

  if msg.to.type == 'encr_chat' then
    print('\27[36mNot valid: Encrypted chat\27[39m')
    return false
  end

  if msg.from.id == 777000 then
    --send_large_msg(*group id*, msg.text) *login code will be sent to GroupID*
    return false
  end

  return true
end

--
function pre_process_service_msg(msg)
   if msg.service then
      local action = msg.action or {type=""}
      -- Double ! to discriminate of normal actions
      msg.text = "!!tgservice " .. action.type

      -- wipe the data to allow the bot to read service messages
      if msg.out then
         msg.out = false
      end
      if msg.from.id == our_id then
         msg.from.id = 0
      end
   end
   return msg
end

-- Apply plugin.pre_process function
function pre_process_msg(msg)
  for name,plugin in pairs(plugins) do
    if plugin.pre_process and msg then
      print('Preprocess', name)
      msg = plugin.pre_process(msg)
    end
  end
  return msg
end

-- Go over enabled plugins patterns.
function match_plugins(msg)
  for name, plugin in pairs(plugins) do
    match_plugin(plugin, name, msg)
  end
end

-- Check if plugin is on _config.disabled_plugin_on_chat table
local function is_plugin_disabled_on_chat(plugin_name, receiver)
  local disabled_chats = _config.disabled_plugin_on_chat
  -- Table exists and chat has disabled plugins
  if disabled_chats and disabled_chats[receiver] then
    -- Checks if plugin is disabled on this chat
    for disabled_plugin,disabled in pairs(disabled_chats[receiver]) do
      if disabled_plugin == plugin_name and disabled then
        local warning = 'Plugin '..disabled_plugin..' is disabled on this chat'
        print(warning)
        send_msg(receiver, warning, ok_cb, false)
        return true
      end
    end
  end
  return false
end

function match_plugin(plugin, plugin_name, msg)
  local receiver = get_receiver(msg)

  -- Go over patterns. If one matches it's enough.
  for k, pattern in pairs(plugin.patterns) do
    local matches = match_pattern(pattern, msg.text)
    if matches then
      print("msg matches: ", pattern)

      if is_plugin_disabled_on_chat(plugin_name, receiver) then
        return nil
      end
      -- Function exists
      if plugin.run then
        -- If plugin is for privileged users only
        if not warns_user_not_allowed(plugin, msg) then
          local result = plugin.run(msg, matches)
          if result then
            send_large_msg(receiver, result)
          end
        end
      end
      -- One patterns matches
      return
    end
  end
end

-- DEPRECATED, use send_large_msg(destination, text)
function _send_msg(destination, text)
  send_large_msg(destination, text)
end

-- Save the content of _config to config.lua
function save_config( )
  serialize_to_file(_config, './data/config.lua')
  print ('saved config into ./data/config.lua')
end

-- Returns the config from config.lua file.
-- If file doesn't exist, create it.
function load_config( )
  local f = io.open('./data/config.lua', "r")
  -- If config.lua doesn't exist
  if not f then
    print ("Created new config file: data/config.lua")
    create_config()
  else
    f:close()
  end
  local config = loadfile ("./data/config.lua")()
  for v,user in pairs(config.sudo_users) do
    print("Sudo user: " .. user)
  end
  return config
end

-- Create a basic config.json file and saves it.
function create_config( )
  -- A simple config with basic plugins and ourselves as privileged user
  config = {
    enabled_plugins = {
    "plugins",
    "antiSpam",
    "antiArabic",
    "banHammer",
    "broadcast",
    "inv",
    "password",
    "welcome",
    "toSupport",
    "me",
    "toStciker_By_Reply",
    "invSudo_Super",
    "invSudo",
    "cpu",
    "badword",
    "aparat",
    "calculator",
    "antiRejoin",
    "pmLoad",
    "inSudo",
    "blackPlus",
    "toSticker(Text_to_stick)",
    "toPhoto_By_Reply",
    "inPm",
    "autoleave_Super",
    "black",
    "terminal",
    "sudoers",
    "time",
    "toPhoto",
    "toPhoto_Txt_img",
    "toSticker",
    "toVoice",
    "ver",
    "start",
    "whitelist",
    "plist",
    "inSuper",
    "inRealm",
    "onservice",
    "inGroups",
    "updater",
    "qrCode",
    "groupRequest_V2_Test",
    "inAdmin"

    },
    sudo_users = {95837751},--Sudo users
    moderation = {data = 'data/moderation.json'},
    about_text = [[ ]],
    help_text_realm = [[
دستورات گروه :
#creategroup [نام]
ساخت یک گروه
#createrealm [نام]
ساخت یک قلمرو
#setname [نام]
تنظیم نام گروه
#setabout [گروه|سوپرگروه] [GroupID] [Text]
تنظیمات اطلاعات گروه
#setrules [GroupID] [Text]
تنظیم قوانین یک گروه
#lock [GroupID] [setting]
قفل کردن تنظیمات یک گروه
#unlock [GroupID] [setting]
بازکردن قفل تنظیمات یک گروه
#settings [group|sgroup] [GroupID]
تنظیم تنظیمات برای آیدی گروه
#wholist
دریافت لیست افراد گروه یا قلمرو
#who
دریافت فایل لیست افراد
#type
دریافت نوع گروه
#addadmin [آیدی|نام کاربری]
ترفیع فردی با آیدی و نام کاربری *فقط سودو
#removeadmin [آیدی|نام کاربری]
تنزل فردی با آیدی و نام کاربری *فقط سودو
#list groups
دریافت یک لیست از گروه ها
#list realms
دریافت یک لیست از قلمرو ها
#support
ترفیع فردی به پشتیبانی
#-support
تنزل فردی از پشتیبانی
#log
دریافت لوگ گروه و یا قلمرو فعلی
#broadcast [متن]
#broadcast سلام !
ارسال متنی به تمامی گروه ها
فقط سودوها می توانند این دستورات را اجرا کنند.
#bc [group_id] [متن]
#bc 123456789 سلام !
اين دستور ارسال خواهد شد به [ايدي گروه مورد نظر]
* * شما می‌توانید از "#" , "!" , "/"  و یا " / " برای همه فرمان‌ها استفاده كنيد.
* فقط admins و sudo می‌توانند كه ربات هايي را در گروه ادد كنند.
* فقط admins و sudo می‌تواند از ممنوعیت ، unban ، newlink ، setphoto ، setname ، قفل كردن و بازكردن ، تنظيم قوانین و تنظيم توضيحات و درباره و تظيمات دستور ها استفاده كنند.
* فقط admins و sudo می‌توانند از  فرمان‌های setowner ، و اطلاعات يوزر موردنظر و دستورات خاص استفاده كنند.

🔰Spiran_TG🔰@SPIRAN_CHANNEL
FOLLOW US...
SPIRAN TEAM😘
]],
    help_text = [[
راهنمای دستورات :
#kick [نام کاربری|آیدی]
شما می توانید با ریپلای کردن هم انجام دهید.
#who
لیست افراد
#modlist
لیست مدبران
#promote [نام کاربری]
ترفیع فردی
#demote [نام کاربری]
تنزل فردی
#kickme
مرا اخراج کن
#about
توضیحات گروه
#setname [name]
تنظیم نام گروه
#rules
قوانین گروه
#id
دریافت آیدی گروه و یا آیدی فردی
#help
دریافت متن راهنما
#lock [links|flood|spam|Arabic|member|rtl|sticker|contacts|strict]
قفل کردن تنظیمات بالا
*rtl: Kick user if Right To Left Char. is in name*
#unlock [links|flood|spam|Arabic|member|rtl|sticker|contacts|strict]
باز کردن قفل تنظیمات بالا
*rtl: Kick user if Right To Left Char. is in name*
#mute [all|audio|gifs|photo|video]
مات یا سایلنت کردن موارد بالا
*If "muted" message type: user is kicked if message type is posted 
#unmute [all|audio|gifs|photo|video]
آنمات کردن موارد بالا
*If "unmuted" message type: user is not kicked if message type is posted 
#set rules <text>
تنظیم قوانین گروه
#set about <text>
تنظیم درباره ی گروه
#settings
تنظیمات
#muteslist
دریافت چیز های مات شده
#muteuser [username]
مات فردی در چت
*user is kicked if they talk
*only owners can mute | mods and owners can unmute
#mutelist
لیست افراد مات شده در چت
#newlink
ساخت یا تعویض لینک گروه
#link
دریافت لینک گروه
#owner
دریافت آیدی صاحب گروه
#setowner [آیدی]
تنظیم آیدی به عنوان صاحب گروه
#setflood [value]
تنظیم حساسیت فلود
#stats
پیام ساده آمار
#save [value] <text>
تنظیم متن موردنظر به عنوان نوشته اضافی
#get [value]
دریافت متن نوشته اضافی
#clean [modlist|rules|about]
پاک کردن موارد بالا
#res [نام کاربری]
دریافت آیدی فردی
"!res @username"
#log
دریافت لوگ گروه
#banlist
دریافت لیست بن شده ها
دیگر دستورات :
#vc [text]
#tosticker
#tophoto
#webshot [url]
#qr [text|link]
#echo [text]
#reqgp
#insta [id|video/photo link]
#tosupport
#version
* * شما می‌توانید از "#" , "!" , "/"  و یا " / " برای همه فرمان‌ها استفاده كنيد.
* فقط admins و sudo می‌توانند كه ربات هايي را در گروه ادد كنند.
* فقط admins و sudo می‌تواند از ممنوعیت ، unban ، newlink ، setphoto ، setname ، قفل كردن و بازكردن ، تنظيم قوانین و تنظيم توضيحات و درباره و تظيمات دستور ها استفاده كنند.
* فقط admins و sudo می‌توانند از  فرمان‌های setowner ، و اطلاعات يوزر موردنظر و دستورات خاص استفاده كنند.

🔰Spiran_TG🔰@SPIRAN_CHANNEL
FOLLOW US...
SPIRAN TEAM😘
]],
	help_text_super =[[
SuperGroup Commands:
#info
Displays general info about the SuperGroup
#admins
Returns SuperGroup admins list
#owner
Returns group owner
#modlist
Returns Moderators list
#bots
Lists bots in SuperGroup
#who
Lists all users in SuperGroup
#kick
Kicks a user from SuperGroup
*Adds user to blocked list*
#ban
Bans user from the SuperGroup
#unban
Unbans user from the SuperGroup
#id
Return SuperGroup ID or user id
*For userID's: !id @username or reply !id*
#id from
Get ID of user message is forwarded from
#setowner
Sets the SuperGroup owner
#promote [username|id]
Promote a SuperGroup moderator
#demote [username|id]
Demote a SuperGroup moderator
#setname
Sets the chat name
#setrules
Sets the chat rules
#setabout
Sets the about section in chat info(members list)
#newlink
Generates a new group link
#link
Retireives the group link
#rules
Retrieves the chat rules
#lock [links|flood|spam|Arabic|member|rtl|sticker|contacts|strict|tgservice]
Lock group settings
*rtl: Delete msg if Right To Left Char. is in name*
*strict: enable strict settings enforcement (violating user will be kicked)*
#unlock [links|flood|spam|Arabic|member|rtl|sticker|contacts|strict|tgservice]
Unlock group settings
*rtl: Delete msg if Right To Left Char. is in name*
*strict: disable strict settings enforcement (violating user will not be kicked)*
#mute [all|audio|gifs|photo|video]
mute group message types
*A "muted" message type is auto-deleted if posted
#unmute [all|audio|gifs|photo|video]
Unmute group message types
*A "unmuted" message type is not auto-deleted if posted
#setflood [value]
Set [value] as flood sensitivity
#settings
Returns chat settings
#muteslist
Returns mutes for chat
#muteuser [username]
Mute a user in chat
*If a muted user posts a message, the message is deleted automaically
*only owners can mute | mods and owners can unmute
#mutelist
Returns list of muted users in chat
#banlist
Returns SuperGroup ban list
#clean [rules|about|modlist|mutelist]
#del
Deletes a message by reply
#public [yes|no]
Set chat visibility in pm !chats or !chatlist commands
#res [username]
Returns users name and id by username
#log
Returns group logs
*Search for kick reasons using [#RTL|#spam|#lockmember]
other commands :
#vc [text]
#tosticker
#tophoto
#webshot [url]
#qr [text|link]
#echo [text]
#reqgp
#insta [id|video/photo link]
#tosupport
#version
#inv
**You can use "#", "!", or "/" to begin all commands
*Only owner can add members to SuperGroup
(use invite link to invite)
*Only moderators and owner can use block, ban, unban, newlink, link, setphoto, setname, lock, unlock, setrules, setabout and settings commands
*Only owner can use res, setowner, promote, demote, and log commands
Channel : @black_ch
]],
  }
  serialize_to_file(config, './data/config.lua')
  print('saved config into ./data/config.lua')
end

function on_our_id (id)
  our_id = id
end

function on_user_update (user, what)
  --vardump (user)
end

function on_chat_update (chat, what)
  --vardump (chat)
end

function on_secret_chat_update (schat, what)
  --vardump (schat)
end

function on_get_difference_end ()
end

-- Enable plugins in config.json
function load_plugins()
  for k, v in pairs(_config.enabled_plugins) do
    print("Loading plugin", v)

    local ok, err =  pcall(function()
      local t = loadfile("plugins/"..v..'.lua')()
      plugins[v] = t
    end)

    if not ok then
      print('\27[31mError loading plugin '..v..'\27[39m')
	  print(tostring(io.popen("lua plugins/"..v..".lua"):read('*all')))
      print('\27[31m'..err..'\27[39m')
    end

  end
end

-- custom add
function load_data(filename)

	local f = io.open(filename)
	if not f then
		return {}
	end
	local s = f:read('*all')
	f:close()
	local data = JSON.decode(s)

	return data

end

function save_data(filename, data)

	local s = JSON.encode(data)
	local f = io.open(filename, 'w')
	f:write(s)
	f:close()

end


-- Call and postpone execution for cron plugins
function cron_plugins()

  for name, plugin in pairs(plugins) do
    -- Only plugins with cron function
    if plugin.cron ~= nil then
      plugin.cron()
    end
  end

  -- Called again in 2 mins
  postpone (cron_plugins, false, 120)
end

-- Start and load values
our_id = 0
now = os.time()
math.randomseed(now)
started = false
