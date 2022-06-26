local client = game:GetService("Players").LocalPlayer
local genv = getgenv()

--// Compatability
local getcustomasset do
	--getcustomasset or getsynasset
	if genv.getcustomasset then
		getcustomasset = genv.getcustomasset
	elseif getsynasset then
		getcustomasset = getsynasset
	end
end

local request do
	--syn and syn.request or request
	if syn and syn.request then
		request = syn.request
	elseif genv.request then
		request = genv.request
	end
end



--// Fastish base64
local base64 = {} do
	-- Fork from: https://devforum.roblox.com/t/can-you-do-this-in-roblox/1316555
	-- Original : https://github.com/iskolbin/lbase64/blob/master/base64.lua
	local extract = bit32.extract

	function base64.makeencoder( s62, s63, spad )
		local encoder = {}
		for b64code, char in pairs{[0]='A','B','C','D','E','F','G','H','I','J',
			'K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y',
			'Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n',
			'o','p','q','r','s','t','u','v','w','x','y','z','0','1','2',
			'3','4','5','6','7','8','9',s62 or '+',s63 or'/',spad or'='} do
			encoder[b64code] = char:byte()
		end
		return encoder
	end

	function base64.makedecoder( s62, s63, spad )
		local decoder = {}
		for b64code, charcode in pairs( base64.makeencoder( s62, s63, spad )) do
			decoder[charcode] = b64code
		end
		return decoder
	end

	local DEFAULT_ENCODER = base64.makeencoder()
	local DEFAULT_DECODER = base64.makedecoder()

	local char, concat = string.char, table.concat

	function base64.encode( str, encoder, usecaching )
		encoder = encoder or DEFAULT_ENCODER
		local t, k, n = {}, 1, #str
		local lastn = n % 3
		local cache = {}
		for i = 1, n-lastn, 3 do
			local a, b, c = str:byte( i, i+2 )
			local v = a*0x10000 + b*0x100 + c
			local s
			if usecaching then
				s = cache[v]
				if not s then
					s = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[extract(v,0,6)])
					cache[v] = s
				end
			else
				s = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[extract(v,0,6)])
			end
			t[k] = s
			k = k + 1
		end
		if lastn == 2 then
			local a, b = str:byte( n-1, n )
			local v = a*0x10000 + b*0x100
			t[k] = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[64])
		elseif lastn == 1 then
			local v = str:byte( n )*0x10000
			t[k] = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[64], encoder[64])
		end
		return concat( t )
	end

	function base64.decode( b64, decoder, usecaching )
		decoder = decoder or DEFAULT_DECODER
		local pattern = '[^%w%+%/%=]'
		if decoder then
			local s62, s63
			for charcode, b64code in pairs( decoder ) do
				if b64code == 62 then s62 = charcode
				elseif b64code == 63 then s63 = charcode
				end
			end
			pattern = ('[^%%w%%%s%%%s%%=]'):format( char(s62), char(s63) )
		end
		b64 = b64:gsub( pattern, '' )
		local cache = usecaching and {}
		local t, k = {}, 1
		local n = #b64
		local padding = b64:sub(-2) == '==' and 2 or b64:sub(-1) == '=' and 1 or 0
		for i = 1, padding > 0 and n-4 or n, 4 do
			local a, b, c, d = b64:byte( i, i+3 )
			local s
			if usecaching then
				local v0 = a*0x1000000 + b*0x10000 + c*0x100 + d
				s = cache[v0]
				if not s then
					local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 + decoder[d]
					s = char( extract(v,16,8), extract(v,8,8), extract(v,0,8))
					cache[v0] = s
				end
			else
				local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 + decoder[d]
				s = char( extract(v,16,8), extract(v,8,8), extract(v,0,8))
			end
			t[k] = s
			k = k + 1
		end
		if padding == 1 then
			local a, b, c = b64:byte( n-3, n-1 )
			local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40
			t[k] = char( extract(v,16,8), extract(v,8,8))
		elseif padding == 2 then
			local a, b = b64:byte( n-3, n-2 )
			local v = decoder[a]*0x40000 + decoder[b]*0x1000
			t[k] = char( extract(v,16,8))
		end
		return concat( t )
	end
end



local file = {files = {
	["connectionTerminated.mp3"] = "https://raw.githubusercontent.com/2567-rblx/____/main/files/connectionTerminated.mp3.base64",
	["aughhh.ogg"] = "https://raw.githubusercontent.com/2567-rblx/____/main/files/aughhh.ogg.base64",
}} do
	function file.create(path, fileName)
		path = ("%s/%s"):format(path, fileName)
		if isfile(path) then
			return path
		end

		local resp = request({
			Url = file.files[fileName]
		})

		writefile(path, base64.decode(resp.Body))
		return path
	end
end



local kicks = {} do
	function kicks.connectionTerminated()
		local soundPlayer = Instance.new("Sound")
		soundPlayer.Parent = workspace
		soundPlayer.SoundId = getcustomasset(file.create("./", "connectionTerminated.mp3"))
		soundPlayer.Volume = math.huge
		soundPlayer:Play()

		client:Kick("\n\n\n\n\n\nConnection terminated. I'm sorry to interrupt you, Elizabeth, if you still even remember that name, But I'm afraid you've been misinformed. You are not here to receive a gift, nor have you been called here by the individual you assume, although, you have indeed been called. You have all been called here, into a labyrinth of sounds and smells, misdirection and misfortune. A labyrinth with no exit, a maze with no prize. You don't even realize that you are trapped. Your lust for blood has driven you in endless circles, chasing the cries of children in some unseen chamber, always seeming so near, yet somehow out of reach, but you will never find them. None of you will. This is where your story ends. And to you, my brave volunteer, who somehow found this job listing not intended for you, although there was a way out planned for you, I have a feeling that's not what you want. I have a feeling that you are right where you want to be. I am remaining as well. I am nearby. This place will not be remembered, and the memory of everything that started this can finally begin to fade away. As the agony of every tragedy should. And to you monsters trapped in the corridors, be still and give up your spirits. They don't belong to you. For most of you, I believe there is peace and perhaps more waiting for you after the smoke clears. Although, for one of you, the darkest pit of Hell has opened to swallow you whole, so don't keep the devil waiting, old friend. My daughter, if you can hear me, I knew you would return as well. It's in your nature to protect the innocent. I'm sorry that on that day, the day you were shut out and left to die, no one was there to lift you up into their arms the way you lifted others into yours, and then, what became of you. I should have known you wouldn't be content to disappear, not my daughter. I couldn't save you then, so let me save you now. It's time to rest - for you, and for those you have carried in your arms. This ends for all of us. End communication.\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
	end

	function kicks.aughhh()
		local soundPlayer = Instance.new("Sound")
		soundPlayer.Parent = workspace
		soundPlayer.SoundId = getcustomasset(file.create("./", "aughhh.ogg"))
		soundPlayer.Volume = math.huge
		soundPlayer:Play()
		soundPlayer.Ended:Wait()
		game:Shutdown()
	end


	kicks.array = {kicks.connectionTerminated, kicks.aughhh}
end


kicks.array[math.random(1, #kicks.array)]()
