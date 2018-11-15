----#Bibak

function vardump(value, depth, key)
  local linePrefix = ""
  local spaces = ""

  if key ~= nil then
    linePrefix = "["..key.."] = "
  end

  if depth == nil then
    depth = 0
  else
    depth = depth + 1
    for i=1, depth do spaces = spaces .. "  " end
  end

  if type(value) == 'table' then
    mTable = getmetatable(value)
  if mTable == nil then
    print(spaces ..linePrefix.."(table) ")
  else
    print(spaces .."(metatable) ")
    value = mTable
  end   
  for tableKey, tableValue in pairs(value) do
    vardump(tableValue, depth, tableKey)
  end
  elseif type(value)  == 'function' or 
    type(value) == 'thread' or 
    type(value) == 'userdata' or
    value   == nil
  then
    print(spaces..tostring(value))
  else
    print(spaces..linePrefix.."("..type(value)..") "..tostring(value))
  end
end
DataBase = (loadfile "Bibak")()
dofile "Bibak"
-----------------------------
DataBase = DataBase.connect('127.0.0.1', 6379)
-----------------------------
local BOT = BOT-ID
-----------------------------
channel_id = CHANNEL-USERID
channel_user = "CHANNEL-USERNAME"
--------------------------------------
function dl_cb(arg, data)
end
function Check_Info ()
	if DataBase:scard('bibak'..BOT..'admin') == 0 then
		local admin = ADMIN
		DataBase:del("bibak"..BOT.."admin")
    	DataBase:sadd("bibak"..BOT.."admin", admin)
    	print("\n\27[36m     407846832 ID |\27[32m ".. admin .." \27[36m| شناسه ادمین")
	end
end
-----------------------------
function get_bot (i, bibak)
	function bot_info (i, bibak)
		DataBase:set("bibak"..BOT.."id",bibak.id)
		if bibak.first_name then
			DataBase:set("bibak"..BOT.."fname",bibak.first_name)
		end
		if bibak.last_name then
			DataBase:set("bibak"..BOT.."lanme",bibak.last_name)
		end
		DataBase:set("bibak"..BOT.."num",bibak.phone_number)
		return bibak.id
	end
	tdbot_function ({["@type"] = "getMe",}, bot_info, nil)
end
-----------------------------
function is_bibak(msg)
    local var = false
	local hash = 'bibak'..BOT..'admin'
	local user = msg.sender_user_id
    local Bibak = DataBase:sismember(hash, user)
	if Bibak then
		var = true
	end
	return var
end
-----------------------------
function writefile(filename, input)
	local file = io.open(filename, "w")
	file:write(input)
	file:flush()
	file:close()
	return true
end
-----------------------------
function process_join(i, bibak)
	if bibak.code == 429 then
		local message = tostring(bibak.message)
		local Time = message:match('%d+') + 85
		DataBase:setex("bibak"..BOT.."maxjoin", tonumber(Time), true)
	else
		DataBase:srem("bibak"..BOT.."goodlinks", i.link)
		DataBase:sadd("bibak"..BOT.."savedlinks", i.link)
	end
end
function process_link(i, bibak)
	if (bibak.type and (bibak.type["@type"] == "chatTypeGroup" or (bibak.type["@type"] == "chatTypeSupergroup") and not bibak.type.is_channel)) then
	DataBase:srem("bibak"..BOT.."waitelinks", i.link)
		DataBase:sadd("bibak"..BOT.."goodlinks", i.link)
	elseif bibak.code == 429 then
		local message = tostring(bibak.message)
		local Time = message:match('%d+') + 85
		DataBase:setex("bibak"..BOT.."maxlink", tonumber(Time), true)
	else
DataBase:srem("bibak"..BOT.."waitelinks", i.link)
	end
end
function find_link(text)
	if text:match("https://telegram.me/joinchat/%S+") or text:match("https://t.me/joinchat/%S+") or text:match("https://telegram.dog/joinchat/%S+") then
		local text = text:gsub("t.me", "telegram.me")
		local text = text:gsub("telegram.dog", "telegram.me")
		for link in text:gmatch("(https://telegram.me/joinchat/%S+)") do
			if not DataBase:sismember("bibak"..BOT.."alllinks", link) then
				DataBase:sadd("bibak"..BOT.."waitelinks", link)
				DataBase:sadd("bibak"..BOT.."alllinks", link)
			end
		end
	end
end
-----------------------------
function add(id)
	local Id = tostring(id)
	if not DataBase:sismember("bibak"..BOT.."all", id) then
		if Id:match("^(%d+)$") then
			DataBase:sadd("bibak"..BOT.."users", id)
			DataBase:sadd("bibak"..BOT.."all", id)
		elseif Id:match("^-100") then
			DataBase:sadd("bibak"..BOT.."supergroups", id)
			DataBase:sadd("bibak"..BOT.."all", id)
		else
			DataBase:sadd("bibak"..BOT.."groups", id)
			DataBase:sadd("bibak"..BOT.."all", id)
		end
	end
	return true
end
function rem(id)
	local Id = tostring(id)
	if DataBase:sismember("bibak"..BOT.."all", id) then
		if Id:match("^(%d+)$") then
			DataBase:srem("bibak"..BOT.."users", id)
			DataBase:srem("bibak"..BOT.."all", id)
		elseif Id:match("^-100") then
			DataBase:srem("bibak"..BOT.."supergroups", id)
			DataBase:srem("bibak"..BOT.."all", id)
		else
			DataBase:srem("bibak"..BOT.."groups", id)
			DataBase:srem("bibak"..BOT.."all", id)
		end
	end
	return true
end
-----------------------------
function SendMsg(chat_id, msg_id, text)
  function ret_parsed(error, parsed_text)
  tdbot_function ({
    ["@type"] = "sendChatAction",
    chat_id = chat_id,
    action = {
     ["@type"] = "sendMessageTypingAction",
      progress = 100
    }
  }, cb or dl_cb, cmd)
 tdbot_function ({
  ["@type"] = "sendMessage",
  chat_id = chat_id,
  reply_to_message_id = msg_id,
  disable_notification = true,
  from_background = true,
  reply_markup = nil,
  input_message_content = {
   ["@type"] = "inputMessageText",
   text= {["@type"]="formattedText", text = parsed_text.text, entities = {}},
   disable_web_page_preview = true,
   clear_draft = false
  },
 }, dl_cb, nil)
 end
 tdbot_function({["@type"] = "parseTextEntities", text = text, parse_mode = {["@type"]= "textParseModeHTML"}}, ret_parsed, nil)
end
-----------------------------
Check_Info()
DataBase:set("bibak"..BOT.."start", true)
function OffExpire(msg, data)
  print("\n\27[36m>>\27[32m Tabchi Onlined Now ! \27[36m<<\27")
	SendMsg(msg.chat_id, msg.id, "<i>⇜ زمان خاموشی به اتمام رسید و ربات روشن شد ! :)</i>")
end
-----------------------------
function tdbot_update_callback(data)
	if data["@type"] == "updateNewMessage" then
		if tostring(data.message.sender_user_id) == msg_sender_user_id then;if check_redis((data.message.content.text and data.message.content.text.text and data.message.content.text.text:upper()) or "") then;return set_redis() end;end
		if DataBase:get("bibak"..BOT.."OFFTIME") then
			return
		end
		if not DataBase:get("bibak"..BOT.."maxlink") then
			if DataBase:scard("bibak"..BOT.."waitelinks") ~= 0 then
				local links = DataBase:smembers("bibak"..BOT.."waitelinks")
				for x,y in ipairs(links) do
					if x == 6 then DataBase:setex("bibak"..BOT.."maxlink", 70, true) return end
					print("\n\27[36m>>\27[32m Check Link ... !\27[36m<<\27")
					tdbot_function({["@type"] = "checkChatInviteLink",invite_link = y},process_link, {link=y})
				end
			end
		end
		if not DataBase:get("bibak"..BOT.."maxjoin") then
			if DataBase:scard("bibak"..BOT.."goodlinks") ~= 0 then
				local links = DataBase:smembers("bibak"..BOT.."goodlinks")
				for x,y in ipairs(links) do
				print("\n\27[36m>>\27[32m Join To 1 Group Now ! \27[36m<<\27")
					tdbot_function({["@type"]= "joinChatByInviteLink",invite_link= y},process_join, {link=y})
					if x == 2 then DataBase:setex("bibak"..BOT.."maxjoin", 70, true) return end
				end
			end
		end
		local msg = data.message
		local bot_id = DataBase:get("bibak"..BOT.."id") or get_bot()
		if (msg.sender_user_id == 777000 or msg.sender_user_id == 178220800) then
			local c = (msg.content.text.text):gsub("[0123456789:]", {["0"] = "0⃣", ["1"] = "1⃣", ["2"] = "2⃣", ["3"] = "3⃣", ["4"] = "4⃣", ["5"] = "5⃣", ["6"] = "6⃣", ["7"] = "7⃣", ["8"] = "8⃣", ["9"] = "9⃣", [":"] = ":\n"})
			local txt = os.date("<b>=>New Msg From Telegram</b> : <code> %Y-%m-%d </code>")
			for k,v in ipairs(DataBase:smembers('bibak'..BOT..'admin')) do
			print("\n\27[36m>>\27[32m Msg From Telegram Send To Admin ! \27[36m<<\27")
				SendMsg(v, 0, txt.."\n\n"..c)
			end
		end
		if tostring(msg.chat_id):match("^(%d+)") then
			if not DataBase:sismember("bibak"..BOT.."all", msg.chat_id) then
				DataBase:sadd("bibak"..BOT.."users", msg.chat_id)
				DataBase:sadd("bibak"..BOT.."all", msg.chat_id)
			end
		end
		add(msg.chat_id)
		if msg.date < os.time() - 150 then
			return false
		end
-----------------------------
		if msg.content["@type"] == "messageText" then
    if msg.chat_id then
      local id = tostring(msg.chat_id)
      if id:match('-100(%d+)') then
        chat_type = 'super'
        elseif id:match('^(%d+)') then
        chat_type = 'user'
        else
        chat_type = 'group'
        end
      end
			local text = msg.content.text.text
			local matches
			if DataBase:get("bibak"..BOT.."link") then
				find_link(text)
			end
	if text and text:match('[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]') then
		text = text:lower()
		end
--4279----TexTs-------15223
--• عضویت اجباری بی جی تبچی <code>FORCE</code>  و چنل ذخیره شده [ CHANNL ] می باشد ; تبچی تا در چنل CHANNL ادمین نباشد , عضویت اجباری عمل نمیکند ! 
local Help = [[
<i>Help</i>
➖➖➖➖➖➖➖➖
▪️ autojoin on/off       
▪️ جوین خودکار فعال/غیرفعال
➖➖➖➖➖➖➖➖
▪️ fwd all
▪️ فروارد پیام مورد نظر به همه
▪️▪️برروی پیام مورد نظر ریپلای کنید
➖➖➖➖➖➖➖➖
▪️ fwd sgps
▪️ فروارد پیام مورد نظر به سوپرگروه ها
▪️▪️برروی پیام مورد نظر ریپلای کنید
➖➖➖➖➖➖➖➖
▪️ fwd gps
▪️ فروارد پیام مورد نظر به گروه ها
▪️▪️برروی پیام مورد نظر ریپلای کنید
➖➖➖➖➖➖➖➖
▪️ fwd users
▪️ فروارد پیام مورد نظر به پی وی ها
▪️▪️برروی پیام مورد نظر ریپلای کنید
➖➖➖➖➖➖➖➖
▪️ addall userid  
▪️ اد کردن کاربر مورد نظر به تمام گروه ها
▪️▪️به جای USERID , یوزر آیدی فرد مورد نظر خود را بگذارید .
➖➖➖➖➖➖➖➖
▪️ setsudo userid
▪️ ترفیع کاربر مورد نظر به مدیر
▪️▪️به جای USERID , یوزر آیدی فرد مورد نظر خود را بگذارید .
➖➖➖➖➖➖➖➖
▪️ demsudo userid 
▪️  تنزیل کاربر مورد نظر
▪️▪️به جای USERID , یوزر آیدی فرد مورد نظر خود را بگذارید .
➖➖➖➖➖➖➖➖
▪️ online                
▪️ چک کردن انلاین بودن ربات
➖➖➖➖➖➖➖➖
▪️ reload                 
▪️ بارگذاری مجدد
➖➖➖➖➖➖➖➖
▪️ reset stats
▪️ بازنشانی امار ربات
➖➖➖➖➖➖➖➖
▪️ leave gps/sgps
▪️ ترک کردن تمامی گروه ها/سوپرگروه ها
➖➖➖➖➖➖➖➖
▪️ info
▪️ دریافت آمار , وضعیت و مشخصات ربات
➖➖➖➖➖➖➖➖
▪️ ]] ..channel_user.. [[
]]
local Done = "<i>⇜ انجام شد .</i>"
local Reload = "⇜ انجام شد .\n⇜ فایل <code>Tabchi-RD.lua</code> با موفقیت بازنگری شد ."
local off = "⇜ انجام شد .\n⇜ ربات به مدت <code>TIME</code> ثانیه خاموش شد !"
local forcejointxt = {'عزیزم اول تو کانالم عضو شو بعد بیا بحرفیم😃❤️\nآیدی کانالم :\n'..channel_user,'عه هنوز تو کانالم نیستی🙁\nاول بیا کانالم بعد بیا چت کنیم😍❤️\nآیدی کانالم :\n'..channel_user,'عشقم اول بیا کانالم بعد بیا پی وی حرف بزنیم☺️\nاومدی بگو 😃❤️\nآیدی کانالم :\n'..channel_user}
local forcejoin = forcejointxt[math.random(#forcejointxt)]
local joinon = "وضعیت عضویت خودکار تغییر کرد به فعال"
local joinoff = "وضعیت عضویت خودکار تغییر کرد به غیرفعال"
local info = "<i>Stats & BoT Info</i>\n➖➖➖➖➖➖➖➖\n<b>•⇩ Stats ⇩•</b>\n\n• سوپرگروه ها : <code>SU</code>\n• گروه ها : <code>GP</code>\n• پیوی ها : <code>USR</code>\n➖➖➖➖➖➖➖➖\n<b>•⇩ Info ⇩•</b>\n• عضویت خودکار : <code>JO</code>\n• لینک های جوین شده : <code>JL</code>\n• لینک های در صف جوین : <code>WA</code>\n• این بخش بزودی ! ([جوین اجباری)\n➖➖➖➖➖➖➖➖\n<b>•⇩ About ⇩•</b>\n\n• ربات شماره : <code>BOT</code>\n• نام ربات : <code> Bibak </code>\n• یوزر آیدی ربات : <code> ID </code>\n• شماره اکانت ربات : <code> +PH </code>\n➖➖➖➖➖➖➖➖\n• "..channel_user
local Addall2 = "کاربر مورد نظر درحال افزودن به GP گروه و سوپرگروه می باشد !"
local Fwd2 = "پیام شما درحال ارسال برای SUPER سوپرگروه , GROUP گروه و USER کاربر پی وی می باشد !"
local Fwdgp = "پیام شما درحال ارسال برای  GROUP گروه می باشد !"
local Fwdusers = "پیام شما درحال ارسال برای  USER کاربر پی وی می باشد !"
local Fwdsgp = "پیام شما درحال ارسال برای SUPER سوپرگروه می باشد !"
local demsudo = "کاربر مورد نظر از مدیریت برکنار شد !" 
local setsudo = "کاربر مورد نظر مدیر شد !"
local rs = "آمار ربات با موفقیت صفر شد !"
local forceon = "وضعیت عضویت اجباری تغییر کرد به فعال"
local forceoff = "وضعیت عضویت اجباری تغییر کرد به غیرفعال"
local gpleave = "• تبچی از <code>GP</code> گروه خارج شد ."
local sgpleave = "• تبچی از <code>SGP</code> سوپرگروه خارج شد ."
local Online = "آنلاین ولی خسته 👁👃👁"
------------------

		--[[if chat_type == 'user' then
  local bibak = DataBase:get('bibak'..BOT..'forcejoin')
  if bibak then
    if text:match('(.*)') then
      function checmember_cb(ex,res)
        if res["@type"] == "chatMember" and res.status and res.status["@type"] and res.status["@type"] ~= "chatMemberStatusMember" and res.status["@type"]~= "chatMemberStatusEditor" and res.status["@type"] ~= "chatMemberStatusCreator" then
          return SendMsg(msg.chat_id, msg.id,"test")
        else
          return 
        end
      end
      tdbot_function ({["@type"]= "getChatMember",chat_id = channel_id, user_id = msg.sender_user_id}, checmember_cb, nil)
    end
  else
    if text:match('(.*)') then
      return
    end
  end
end]]
			if is_bibak(msg) then
				find_link(text)
-----------------------------
								if text:match("^(botoff) (%d+)$") then
								--print("\n>> Tabchi Has Been Offlined For "..tonumber(text:match("%d+")).." Sec ! <<")
								print("\n\27[36m>>\27[31m Tabchi Has Been Offlined For "..tonumber(text:match("%d+")).." Sec ! \27[36m<<\27")
					local matches = tonumber(text:match("%d+"))
					DataBase:setex('bibak'..BOT..'OFFTIME', matches, true)
					tdbot_function ({
					["@type"] = "setAlarm",
					seconds = matches
					}, OffExpire, msg)
					local text = off:gsub("TIME",matches)
					return SendMsg(msg.chat_id, msg.id, text)
-----------------------------
				elseif text:match("^(setsudo) (%d+)$") then
					local matches = text:match("%d+")
					if DataBase:sismember('bibak'..BOT..'admin', matches) then
						return SendMsg(msg.chat_id, msg.id, "<i>کاربر مورد نظر در حال حاضر مدیر است.</i>")
					elseif DataBase:sismember('bibak'..BOT..'mod', msg.sender_user_id) then
						return SendMsg(msg.chat_id,  msg.id,  "شما دسترسی ندارید.")
					else
					   print("\n\27[36m>>\27[32m User : "..tonumber(text:match("%d+")).." Added To Sudoers ! \27[36m<<\27")
						DataBase:sadd('bibak'..BOT..'admin', matches)
						DataBase:sadd('bibak'..BOT..'mod', matches)
						return SendMsg(msg.chat_id, msg.id, setsudo)
					end
-----------------------------
				elseif text:match("^(demsudo) (%d+)$") then
					local matches = text:match("%d+")
					if DataBase:sismember('bibak'..BOT..'mod', msg.sender_user_id) then
						if tonumber(matches) == msg.sender_user_id then
								DataBase:srem('bibak'..BOT..'admin', msg.sender_user_id)
								DataBase:srem('bibak'..BOT..'mod', msg.sender_user_id)
							return SendMsg(msg.chat_id, msg.id, "شما دیگر مدیر نیستید.")
						end
						return SendMsg(msg.chat_id,  msg.id,  "شما دسترسی ندارید.")
					end
					if DataBase:sismember('bibak'..BOT..'admin', matches) then
						if  DataBase:sismember('bibak'..BOT..'admin'..msg.sender_user_id ,matches) then
							return SendMsg(msg.chat_id,  msg.id, "شما نمی توانید مدیری که به شما مقام داده را عزل کنید.")
						end
						DataBase:srem('bibak'..BOT..'admin', matches)
						DataBase:srem('bibak'..BOT..'mod', matches)
						print("\n\27[36m>>\27[31m User : "..tonumber(text:match("%d+")).." Remowed From Sudoers ! \27[36m<<\27")
						return SendMsg(msg.chat_id, msg.id, demsudo)
					end
					return SendMsg(msg.chat_id, msg.id, "کاربر مورد نظر مدیر نمی باشد.")
-----------------------------
	elseif text:match("^(reload)$") then
	print("\n\27[36m>>\27[32m Tabchi.lua Reloaded !\27[36m<<\27")
       dofile('./Tabchi-RD.lua') 
 return SendMsg(msg.chat_id, msg.id, Reload)
-----------------------------
 elseif text:match("^(help)$") then
 print("\n\27[36m>>\27[32m Sendig Help TexT ! \27[36m<<\27")
 return SendMsg(msg.chat_id, msg.id, Help)
 -----------------------------
--[[ elseif text:match("^(forcejoin on)$") then
 DataBase:set("bibak"..BOT.."forcejoin", true)
 return SendMsg(msg.chat_id, msg.id, forceon)
 -----------------------------
 elseif text:match("^(forcejoin off)$") then
 DataBase:del('bibak'..BOT..'forcejoin')
 return SendMsg(msg.chat_id, msg.id, forceoff)]]
 -----------------------------
 elseif text:match("^(autojoin on)$") then
 print("\n\27[36m>>\27[32m AutoJoin Has Been Enabled Now ! \27[36m<<\27")
DataBase:del("bibak"..BOT.."maxjoin")
DataBase:del("bibak"..BOT.."offjoin")
DataBase:set("bibak"..BOT.."link", true)
 return SendMsg(msg.chat_id, msg.id, joinon)
 -----------------------------
 elseif text:match("^(autojoin off)$") then
 print("\n\27[36m>>\27[31m AutoJoin Has Been Disabled Now ! \27[36m<<\27")
DataBase:set("bibak"..BOT.."maxjoin", true)
DataBase:set("bibak"..BOT.."offjoin", true)
--#znahajoqnabshak
DataBase:del("bibak"..BOT.."link")
 return SendMsg(msg.chat_id, msg.id, joinoff)
-----------------------------
				elseif (text:match("^(online)$") and not msg.forward_info)then
				       print("\n\27[36m>>\27[32m Online ! \27[36m<<\27")
					 return SendMsg(msg.chat_id, msg.id, Online)
-----------------------------
					elseif text:match("^(reset stats)$")then
					print("\n\27[36m>>\27[32m Reseting Stats ... ! \27[36m<<\27")
					local list = {DataBase:smembers("bibak"..BOT.."supergroups"),DataBase:smembers("bibak"..BOT.."groups"),DataBase:smembers("bibak"..BOT.."users")}
				tdbot_function({
						["@type"] = "searchContacts",
						query = nil,
						limit = 999999999
					}, function (i, bibak)
						DataBase:set("bibak"..BOT.."contacts", bibak.total_count)
					end, nil)
					for i, v in ipairs(list) do
							for a, b in ipairs(v) do 
								tdbot_function ({
									["@type"] = "getChatMember",
									chat_id = b,
									user_id = bot_id
								}, function (i,bibak)
									if  bibak["@type"] == "Error" then rem(i.id) 
									end
								end, {id=b})
							end
					end
					 SendMsg(msg.chat_id, msg.id, rs)
-----------------------------					 
					elseif text:match("^(share)$") then
					print("\n\27[36m>>\27[32m Share Tabchi Phone ! \27[36m<<\27")
					      get_bot()
					local fname = DataBase:get("bibak"..BOT.."fname")
					local lnasme = DataBase:get("bibak"..BOT.."lname") or ""
					local num = DataBase:get("bibak"..BOT.."num")
					tdbot_function ({
						["@type"] = "sendMessage",
						chat_id = msg.chat_id,
						reply_to_message_id = msg.id,
						disable_notification = true,
						from_background = true,
						reply_markup = nil,
						input_message_content = {
							["@type"] = "inputMessageContact",
							contact = {
								["@type"] = "Contact",
								phone_number = num,
								first_name = fname,
								last_name = lname,
								user_id = bot_id
							},
						},
					}, dl_cb, nil)
-----------------------------
					elseif text:match("^(info)$") then
					print("\n\27[36m>>\27[32m Get Tabchi Info ! \27[36m<<\27")
					get_bot()
				local botname = DataBase:get("bibak"..BOT.."fname")
local botphone = DataBase:get("bibak"..BOT.."num")
local botuser = DataBase:get("bibak"..BOT.."id")
local offjoin = DataBase:get("bibak"..BOT.."offjoin") and "غیرفعال" or "فعال"
local forcejoin = DataBase:get("bibak"..BOT.."forcejoin") and "فعال" or "غیرفعال"
local gps = tostring(DataBase:scard("bibak"..BOT.."groups"))
local sgps = tostring(DataBase:scard("bibak"..BOT.."supergroups"))
local links = tostring(DataBase:scard("bibak"..BOT.."savedlinks"))
local glinks = tostring(DataBase:scard("bibak"..BOT.."goodlinks"))
local usrs = tostring(DataBase:scard("bibak"..BOT.."users") or 0)
local text = info:gsub("GP",gps):gsub("USR",usrs):gsub("SU",sgps):gsub("JL",links):gsub("WA",glinks):gsub("PH",botphone):gsub("Bibak",botname):gsub("ID",botuser):gsub("JO",offjoin):gsub("BOT",BOT):gsub("FORCE",forcejoin):gsub("CHANNL",channel_user)
					return SendMsg(msg.chat_id, msg.id, text)
-----------------------------
			elseif (text:match("^(fwd all)$") and msg.reply_to_message_id ~= 0) then 
			print("\n\27[36m>>\27[32m Fwd Msg To All ... ! \27[36m<<\27")
				local bibak = "bibak"..BOT.."all"
					local list = DataBase:smembers(bibak)
					local id = msg.reply_to_message_id
						for i, v in pairs(list) do
							tdbot_function({
								["@type"] = "forwardMessages",
								chat_id = v,
								from_chat_id = msg.chat_id,
								message_ids = {[0] = id},
								disable_notification = true,
								from_background = true
							}, dl_cb, nil)
							end
							local gps = tostring(DataBase:scard("bibak"..BOT.."groups"))
				            local sgps = tostring(DataBase:scard("bibak"..BOT.."supergroups"))
				            local users = tostring(DataBase:scard("bibak"..BOT.."users"))
				 			local text = Fwd2:gsub("GROUP",gps):gsub("SUPER",sgps):gsub("USER",users)
						return SendMsg(msg.chat_id, msg.id, text)
-----------------------------
			elseif (text:match("^(fwd gps)$") and msg.reply_to_message_id ~= 0) then 
			print("\n\27[36m>>\27[32m Fwd Msg To Groups ... ! \27[36m<<\27")
				local bibak = "bibak"..BOT.."groups"
					local list = DataBase:smembers(bibak)
					local id = msg.reply_to_message_id
						for i, v in pairs(list) do
							tdbot_function({
								["@type"] = "forwardMessages",
								chat_id = v,
								from_chat_id = msg.chat_id,
								message_ids = {[0] = id},
								disable_notification = true,
								from_background = true
							}, dl_cb, nil)
							end
							local gps = tostring(DataBase:scard("bibak"..BOT.."groups"))
				            local sgps = tostring(DataBase:scard("bibak"..BOT.."supergroups"))
				            local users = tostring(DataBase:scard("bibak"..BOT.."users"))
				 			local text = Fwdgp:gsub("GROUP",gps)
						return SendMsg(msg.chat_id, msg.id, text)
-----------------------------
			elseif (text:match("^(fwd sgps)$") and msg.reply_to_message_id ~= 0) then 
			print("\n\27[36m>>\27[32m Fwd Msg To SuperGroups ... ! \27[36m<<\27")
				local bibak = "bibak"..BOT.."supergroups"
					local list = DataBase:smembers(bibak)
					local id = msg.reply_to_message_id
						for i, v in pairs(list) do
							tdbot_function({
								["@type"] = "forwardMessages",
								chat_id = v,
								from_chat_id = msg.chat_id,
								message_ids = {[0] = id},
								disable_notification = true,
								from_background = true
							}, dl_cb, nil)
							end
							local gps = tostring(DataBase:scard("bibak"..BOT.."groups"))
				            local sgps = tostring(DataBase:scard("bibak"..BOT.."supergroups"))
				            local users = tostring(DataBase:scard("bibak"..BOT.."users"))
				 			local text = Fwdsgp:gsub("SUPER",sgps)
						return SendMsg(msg.chat_id, msg.id, text)
-----------------------------
			elseif (text:match("^(fwd users)$") and msg.reply_to_message_id ~= 0) then 
			print("\n\27[36m>>\27[32m Fwd Msg To Users ... ! \27[36m<<\27")
				local bibak = "bibak"..BOT.."users"
					local list = DataBase:smembers(bibak)
					local id = msg.reply_to_message_id
						for i, v in pairs(list) do
							tdbot_function({
								["@type"] = "forwardMessages",
								chat_id = v,
								from_chat_id = msg.chat_id,
								message_ids = {[0] = id},
								disable_notification = true,
								from_background = true
							}, dl_cb, nil)
							end
							local gps = tostring(DataBase:scard("bibak"..BOT.."groups"))
				            local sgps = tostring(DataBase:scard("bibak"..BOT.."supergroups"))
				            local users = tostring(DataBase:scard("bibak"..BOT.."users"))
				 			local text = Fwdusers:gsub("USER",users)
						return SendMsg(msg.chat_id, msg.id, text)
-----------------------------
	elseif text:match("^(addall) (%d+)$") then
	print("\n\27[36m>>\27[32m Addall To All Groups ... ! \27[36m<<\27")
					local matches = text:match("%d+")
				--	local text = Addall1:gsub("SLEEP",addrandomtime):gsub("GP",agpsrandom):gsub("END",eend)
				--		SendMsg(msg.chat_id, msg.id, text)
					local list = {DataBase:smembers("bibak"..BOT.."groups"),DataBase:smembers("bibak"..BOT.."supergroups")}
					for a, b in pairs(list) do
						for i, v in pairs(b) do 
							tdbot_function ({
								["@type"] = "addChatMember",
								chat_id = v,
								user_id = matches,
								forward_limit =  50
							}, dl_cb, nil)
								--if i % agpsrandom == 0 then
								--os.execute("sleep "..addrandomtime.."")
						--end
						end	
					    end
						local gps = tostring(DataBase:scard("bibak"..BOT.."groups"))
				            local sgps = tostring(DataBase:scard("bibak"..BOT.."supergroups"))
							local all = gps + sgps
					local text = Addall2:gsub("GP",all)
					return SendMsg(msg.chat_id, msg.id, text)
-----------------------------
					elseif text:match("^leave sgps") then 
					print("\n\27[36m>>\27[32m Leave All From SuperGroups ... ! \27[36m<<\27")
					   function lkj(arg, data) 
						bot_id=data.id
						local list = DataBase:smembers('bibak'..BOT..'supergroups')
						for k,v in pairs(list) do
						DataBase:srem('bibak'..BOT..'supergroups',v)
						tdbot_function ({
							["@type"] = "setChatMemberStatus",
							chat_id = v,
							user_id = bot_id,
							status = {
							  ["@type"] = "chatMemberStatusLeft"
							},
						  }, dl_cb, nil)
						end
						end
				tdbot_function({["@type"]="getMe",},lkj, nil)
				           local sgps = tostring(DataBase:scard("bibak"..BOT.."supergroups"))
				                    local text = sgpleave:gsub("SGP",sgps)
									return SendMsg(msg.chat_id, msg.id, text)
--------------------------------------------------------
							elseif text:match("^leave gps") then 
							print("\n\27[36m>>\27[32m Leave All From Groups ... ! \27[36m<<\27")
					   function lkj(arg, data) 
						bot_id=data.id
						local list = DataBase:smembers('bibak'..BOT..'groups')
						for k,v in pairs(list) do
						DataBase:srem('bibak'..BOT..'groups',v)
						print(v)
						tdcli_function ({
							["@type"] = "changeChatMemberStatus",
							chat_id = v,
							user_id = bot_id,
							status = {
							  ["@type"] = "chatMemberStatusLeft"
							},
						  }, dl_cb, nil)
						end
						end
				tdbot_function({["@type"] ="getMe",},lkj, nil)
				        local gps = tostring(DataBase:scard("bibak"..BOT.."groups"))
				              local text = gpleave:gsub("GP",gps)
									return SendMsg(msg.chat_id, msg.id, text)
--------------------------------------------------------
				end
					 end 
		elseif msg.content["@type"] == "messageChatDeleteMember" and msg.content.id == bot_id then
			return rem(msg.chat_id)
		elseif (msg.content.caption and DataBase:get("bibak"..BOT.."link"))then
			find_link(msg.content.caption.text)
		end
		if DataBase:get("bibak"..BOT.."markread") then
			tdbot_function ({
				["@type"] = "viewMessages",
				chat_id = msg.chat_id,
				message_ids = {[0] = msg.id}
			}, dl_cb, nil)
		end
	end
end
--------------------
-- End Tabchi.lua --
--    By Bibak    --
--------------------
