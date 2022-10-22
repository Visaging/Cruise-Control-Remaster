script_name("Cruise Control Remaster")
script_author("Visage A.K.A. Ishaan Dunne")

local script_version = 6.5
local script_version_text = '6.5'

require "moonloader"
require "sampfuncs"
local effil_res, effil = pcall(require, 'effil')
local script_path = thisScript().path
local script_url = "https://raw.githubusercontent.com/Visaging/Cruise-Control-Remaster/main/Cruise_Control_Remaster.lua"
local update_url = "https://raw.githubusercontent.com/Visaging/Cruise-Control-Remaster/main/Cruise_Control_Remaster.txt"
local imgui = require 'imgui'
local inicfg = require 'inicfg'
local vk = require 'vkeys'
local encoding = require "encoding"
encoding.default = 'CP1251'
u8 = encoding.UTF8

local enable = false
local hover = false
local font1 = nil
local window2img = 0

local ccontrol = inicfg.load({
    settings = 
    {
      togglekey = VK_RBUTTON,
      increasekey = VK_OEM_PLUS,
      decreasekey = VK_OEM_MINUS,
      hoverkey = VK_X
    },
    design =
    {
        xpos = 1355,
        ypos = 1080,
        fontsize = 10,
        font = "Arial",
        boxtoggle = false,
        togoverlay = true,
        autosave = true,
        autoupdate = false,
    }
}, 'cruise_control.ini')

function imgui.BeforeDrawFrame()
    if font1 == nil then
        font1 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 15.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
end

local main_window_state = imgui.ImBool(false)
local ctogkey = false
local cikey = false
local cdkey = false
local chk = false
local posx = imgui.ImInt(ccontrol.design.xpos)
local posy = imgui.ImInt(ccontrol.design.ypos)
local fntsize = imgui.ImInt(ccontrol.design.fontsize)
function imgui.OnDrawFrame()
  if main_window_state.v then
		width, height = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(width / 2, height / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(510, 230), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Cruise Control Settings", main_window_state, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize)
        imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(1, 5)) buttonset() imgui.PushFont(fontsize20)
        imgui.SameLine(130)
        if imgui.Button(u8'Cruise Key Settings') then window2img = 0 end
        imgui.SameLine(260)
        if imgui.Button(u8'Overlay Settings') then window2img = 1 end
        imgui.PopFont() buttonend() imgui.PopStyleVar()
        imgui.Separator()
        imgui.PushFont(font1) imgui.CenterTextColoredRGB(string.format("{FFFFFF}%s {FFFFFF}( {9E9EFF}%s {FFFFFF})", thisScript().name, table.concat(thisScript().authors, ", "))) imgui.PopFont()
        imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(1, 5)) imgui.PushFont(fontsize20)

        if window2img == 0 then
		imgui.NewLine()

        imgui.Text("Change Toggle Key: ") imgui.SameLine() imgui.PushItemWidth(100)
        if imgui.Button(ctogkey and 'Press any key' or vk.id_to_name(ccontrol.settings.togglekey)) then
			ctogkey = true
			lua_thread.create(function()
				while ctogkey do wait(0)
					local keydown, result = getDownKeys()
					if result then
						ccontrol.settings.togglekey = keydown
						ctogkey = false
					end
				end
			end)
		end

        imgui.SameLine(270)
		
        imgui.Text("Change Hover Key: ") imgui.SameLine() imgui.PushItemWidth(100)
        if imgui.Button(chk and 'Press any key' or vk.id_to_name(ccontrol.settings.hoverkey)) then
			chk = true
			lua_thread.create(function()
				while chk do wait(0)
					local keydown, result = getDownKeys()
					if result then
						ccontrol.settings.hoverkey = keydown
						chk = false
					end
				end
			end)
		end
        
        imgui.NewLine()
        imgui.Text("Change Speed Increase Key: ") imgui.SameLine() imgui.PushItemWidth(100)
        if imgui.Button(cikey and 'Press any key' or vk.id_to_name(ccontrol.settings.increasekey)) then
			cikey = true
			lua_thread.create(function()
				while cikey do wait(0)
					local keydown, result = getDownKeys()
					if result then
						ccontrol.settings.increasekey = keydown
						cikey = false
					end
				end
			end)
		end
			
        imgui.SameLine(270)

        imgui.Text("Change Speed Decrease Key: ") imgui.SameLine() imgui.PushItemWidth(100)
        if imgui.Button(cdkey and 'Press any key' or vk.id_to_name(ccontrol.settings.decreasekey)) then
			cdkey = true
			lua_thread.create(function()
				while cdkey do wait(0)
					local keydown, result = getDownKeys()
					if result then
						ccontrol.settings.decreasekey = keydown
						cdkey = false
					end
				end
			end)
		end

			imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(1, 5)) buttonset() imgui.PushFont(fontsize20)
            imgui.NewLine() imgui.NewLine()
			imgui.SameLine(10)
			if imgui.Button(u8'Save Config', imgui.ImVec2(240, 40)) then
                inicfg.save(ccontrol, 'cruise_control.ini')
                sampAddChatMessage("Cruise Control: {00ff51}Config Saved!", 10944256)
			end
            imgui.SameLine(260)
            if imgui.Button("Update Script", imgui.ImVec2(240, 40)) then
				update_script(false, false)
			end
		    imgui.PopFont()
		    buttonend()
		    imgui.PopStyleVar()
        else
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(190)
            if imgui.Checkbox(u8("Toggle Overlay"), imgui.ImBool(ccontrol.design.togoverlay)) then
                ccontrol.design.togoverlay = not ccontrol.design.togoverlay
            end

            imgui.Text("Left/Right: ") imgui.SameLine(135) imgui.PushItemWidth(100)
            if imgui.DragInt("##xpos", posx) then ccontrol.design.xpos = posx.v end
            imgui.SameLine(300)
            imgui.Text("Up/Down: ") imgui.PushItemWidth(100) imgui.SameLine()
            if imgui.DragInt("##ypos", posy) then ccontrol.design.ypos = posy.v end

            fnt = imgui.ImBuffer(30)
            fnt.v = ccontrol.design.font
            imgui.Text("Font: ") imgui.SameLine(135) imgui.PushItemWidth(100)
            if imgui.InputText("##font", fnt, imgui.InputTextFlags.EnterReturnsTrue) then ccontrol.design.font = fnt.v applyfont() end
            imgui.SameLine(300)
            imgui.Text("Font Size: ") imgui.SameLine() imgui.PushItemWidth(100)
            if imgui.DragInt("##fontsize", fntsize, imgui.InputTextFlags.EnterReturnsTrue) then ccontrol.design.fontsize = fntsize.v applyfont() end

            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(10)
            if imgui.Checkbox(u8("Box Around the overlay"), imgui.ImBool(ccontrol.design.boxtoggle)) then
                ccontrol.design.boxtoggle = not ccontrol.design.boxtoggle
            end
            imgui.SameLine(230)
            if imgui.Checkbox(u8("Auto Save"), imgui.ImBool(ccontrol.design.autosave)) then
                ccontrol.design.autosave = not ccontrol.design.autosave
                inicfg.save(ccontrol, 'cruise_control.ini')
            end
            imgui.SameLine(370)
            if imgui.Checkbox(u8("Auto Update Script"), imgui.ImBool(ccontrol.design.autoupdate)) then
                ccontrol.design.autoupdate = not ccontrol.design.autoupdate
            end
            if ccontrol.design.autosave then inicfg.save(ccontrol, 'cruise_control.ini') end
        end
        imgui.PopFont() imgui.PopStyleVar()
    	imgui.End()
  	end
end

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end
    if ccontrol.design.autoupdate then
        if effil_res then
            update_script(false, false)
        end
    end
    sampAddChatMessage("{DFBD68}Cruise Control Remaster by {FFFF00}Visage. {FF0000}[/ccontrol] {FFFFFF}to change cruise and hover keys.", 10944256)
    sampRegisterChatCommand("ccontrol", function() main_window_state.v = not main_window_state.v end)
    applyfont()
    while true do
        imgui.Process = main_window_state.v
        wait(0)
        if isCharInAnyCar(playerPed) then
            local s1 = getCarSpeed(storeCarCharIsInNoSave(playerPed))
            carhandle = storeCarCharIsInNoSave(playerPed)
            _, carid = sampGetVehicleIdByCarHandle(carhandle)
            ds = getCarDoorLockStatus(carhandle)
            pdriver = getDriverOfCar(carhandle)
            
            if ds == 0 then
                doorStatus = "{FFCC0000}Unlocked"
            elseif ds == 2 then
                doorStatus = "{FF00CC00}Locked"
            end

            local _, y = getScreenResolution()
            if pdriver == 1 then
                if isCharInAnyHeli(playerPed) and not (isPauseMenuActive() or sampIsScoreboardOpen()) then
                    local text = ("Hover Mode: %s {FFCCCCCC}Speed: {FFFFFF00}%.0f {FFCCCCCC}Door Status: %s"):format(hover and "{FF00CC00}ON" or "{FFCC0000}OFF", s1 * 3, doorStatus)
                    if ccontrol.design.boxtoggle and ccontrol.design.togoverlay then renderDrawBox(ccontrol.design.xpos - 2, ccontrol.design.ypos - 20, renderGetFontDrawTextLength(font, text) + 10, 20, 0xFF323232) end
                    if ccontrol.design.togoverlay then renderFontDrawText(font, text, ccontrol.design.xpos + 2, ccontrol.design.ypos - 20, 0xFFCCCCCC) end
                elseif isCharInModel(playerPed, 574) and not (isPauseMenuActive() or sampIsScoreboardOpen()) then
                    local text = ("Cruise Control can not be used on this vehicle.")
                    if ccontrol.design.boxtoggle and ccontrol.design.togoverlay then renderDrawBox(ccontrol.design.xpos - 2, ccontrol.design.ypos - 20, renderGetFontDrawTextLength(font, text) + 10, 20, 0xFF323232) end
                    if ccontrol.design.togoverlay then renderFontDrawText(font, text, ccontrol.design.xpos + 2, ccontrol.design.ypos - 20, 0xFFCCCCCC) end
                else
                    if not (isPauseMenuActive() or sampIsScoreboardOpen()) then
                    local text = ("Cruise Control: %s {FFCCCCCC}Speed: {FFFFFF00}%.0f {FFCCCCCC}Door Status: %s"):format(enable and "{FF00CC00}ON" or "{FFCC0000}OFF", s1 * 3, doorStatus)
                    if ccontrol.design.boxtoggle and ccontrol.design.togoverlay then renderDrawBox(ccontrol.design.xpos - 2, ccontrol.design.ypos - 20, renderGetFontDrawTextLength(font, text) + 10, 20, 0xFF323232) end
                    if ccontrol.design.togoverlay then renderFontDrawText(font, text, ccontrol.design.xpos + 2, ccontrol.design.ypos - 20, 0xFFCCCCCC) end
                    end
                end
            else
                local text = ("{FFCCCCCC}Door Status: %s"):format(doorStatus)
                if ccontrol.design.boxtoggle and ccontrol.design.togoverlay then renderDrawBox(ccontrol.design.xpos + 215, ccontrol.design.ypos - 20, renderGetFontDrawTextLength(font, text) + 10, 20, 0xFF323232) end
                renderFontDrawText(font, text, ccontrol.design.xpos + 220, ccontrol.design.ypos - 20, 0xFFCCCCCC)
            end
            if not (sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() or isPauseMenuActive()) and speed ~= 0 then
                if wasKeyPressed(ccontrol.settings.increasekey) then speed = speed + 1 end
                if wasKeyPressed(ccontrol.settings.decreasekey) then speed = speed - 1 end
            end
            if enable then
                if getCarSpeed(storeCarCharIsInNoSave(playerPed)) < speed then
                    setGameKeyState(16, 150)
                elseif getCarSpeed(storeCarCharIsInNoSave(playerPed)) > speed + 0.6666666666666667 then
                    setGameKeyState(16, -80)
                end
                if not (sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() or isPauseMenuActive()) then
                    if isKeyDown(87) or isKeyDown(83) or s1 < 1 then
                        enable = not enable
                    end
                end
            end
            if hover then
                setCarForwardSpeed(carhandle, (s1-0.01/33))
                if not (sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() or isPauseMenuActive()) then
                    if isKeyDown(87) or isKeyDown(83) then
                        hover = not hover
                    end
                end
            end
            if not (sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() or isPauseMenuActive()) then
                if wasKeyPressed(ccontrol.settings.togglekey) and not isCharInAnyHeli(playerPed) and not isCharInModel(playerPed, 574) and speed ~= 0 then
                    enable = not enable
                    speed = s1
                end
                if wasKeyPressed(ccontrol.settings.hoverkey) and isCharInAnyHeli(playerPed) then
                    if s1 <= 3.333333333333333 then
                        hover = not hover
                    else
                        sampAddChatMessage("{FF0000}Hover mode could not be engaged as the aircraft is flying too fast.", 10944256)
                        sampAddChatMessage("{00FFFF}Required speed: 10 MPH or below.", 10944256)
                    end
                end
            end
        else
            enable = false
            hover = false
        end
    end
end

function onScriptTerminate(scr, quitGame) 
	if scr == script.this then 
		showCursor(false) 
		inicfg.save(ccontrol, 'cruise_control.ini')
	end
end

function getDownKeys()
    local keyslist = nil
    local bool = false
    for k, v in pairs(vk) do
        if isKeyDown(v) then
            keyslist = v
            bool = true
        end
    end
    return keyslist, bool
end

function style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

   	style.WindowPadding 		= imgui.ImVec2(8, 8)
    style.WindowRounding 		= 6
    style.ChildWindowRounding 	= 5
    style.FramePadding 			= imgui.ImVec2(5, 3)
    style.FrameRounding 		= 3.0
    style.ItemSpacing 			= imgui.ImVec2(5, 4)
    style.ItemInnerSpacing 		= imgui.ImVec2(4, 4)
    style.IndentSpacing 		= 21
    style.ScrollbarSize 		= 10.0
    style.ScrollbarRounding 	= 13
    style.GrabMinSize 			= 8
    style.GrabRounding			= 1
    style.WindowTitleAlign 		= imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign 		= imgui.ImVec2(0.5, 0.5)

    colors[clr.Text]                                = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]                        = ImVec4(0.30, 0.30, 0.30, 1.00)
    colors[clr.WindowBg]                            = ImVec4(0.09, 0.09, 0.09, 1.00)
    colors[clr.ChildWindowBg]                       = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                             = ImVec4(0.05, 0.05, 0.05, 1.00)
    colors[clr.ComboBg]                             = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.Border]                              = ImVec4(0.43, 0.43, 0.50, 0.10)
    colors[clr.BorderShadow]                        = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]                             = ImVec4(0.30, 0.30, 0.30, 0.10)
    colors[clr.FrameBgHovered]                      = ImVec4(0.00, 0.53, 0.76, 0.30)
    colors[clr.FrameBgActive]                       = ImVec4(0.00, 0.53, 0.76, 0.80)
    colors[clr.TitleBg]                				= ImVec4(0.09, 0.09, 0.09, 1.00)
    colors[clr.TitleBgActive]          				= ImVec4(0.09, 0.09, 0.09, 1.00)
    colors[clr.TitleBgCollapsed]       				= ImVec4(0.09, 0.09, 0.09, 1.00)
	colors[clr.MenuBarBg]                           = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarBg]                         = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]                       = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]                = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]                 = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CheckMark]                           = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.SliderGrab]                          = ImVec4(0.28, 0.28, 0.28, 1.00)
    colors[clr.SliderGrabActive]                    = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.Button]                              = ImVec4(0.26, 0.26, 0.26, 0.30)
    colors[clr.ButtonHovered]                       = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.ButtonActive]                        = ImVec4(0.00, 0.43, 0.76, 1.00)
    colors[clr.Header]                              = ImVec4(0.12, 0.12, 0.12, 0.94)
    colors[clr.HeaderHovered]                       = ImVec4(0.34, 0.34, 0.35, 0.89)
    colors[clr.HeaderActive]                        = ImVec4(0.12, 0.12, 0.12, 0.94)
    colors[clr.Separator]                           = ImVec4(0.30, 0.30, 0.30, 1.00)
    colors[clr.SeparatorHovered]                    = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]                     = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]                          = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]                   = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]                    = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.CloseButton]           				= ImVec4(0.50, 0.00, 0.00, 1.00)
    colors[clr.CloseButtonHovered]     				= ImVec4(1.70, 0.70, 0.90, 0.60)
    colors[clr.CloseButtonActive]     				= ImVec4(1.70, 0.70, 0.70, 1.00)
    colors[clr.PlotLines]                           = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]                    = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]                       = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]                = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]                      = ImVec4(0.00, 0.43, 0.76, 1.00)
    colors[clr.ModalWindowDarkening]                = ImVec4(0.20, 0.20, 0.20,  0.0)
end

function imgui.CenterTextColoredRGB(text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    function explode_argb(argb)
      local a = bit.band(bit.rshift(argb, 24), 0xFF)
      local r = bit.band(bit.rshift(argb, 16), 0xFF)
      local g = bit.band(bit.rshift(argb, 8), 0xFF)
      local b = bit.band(argb, 0xFF)
      return a, r, g, b
    end
    
    function colorRgbToHex(rgb)
        local hexadecimal = ''
        for key, value in pairs(rgb) do
            local hex = ''
            while(value > 0)do
                local index = math.fmod(value, 16) + 1
                value = math.floor(value / 16)
                hex = string.sub('0123456789ABCDEF', index, index) .. hex
            end
            if(string.len(hex) == 0)then hex = '00'
            elseif(string.len(hex) == 1)then hex = '0' .. hex end
            hexadecimal = hexadecimal .. hex
        end
        return hexadecimal
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(u8(w))
            end
        end
    end
    render_text(text)
end

function buttonset()
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0, 0, 0, 0.8))
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.988, 0.725, 0, 1))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.729, 0.552, 0.015, 1))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.467, 0.00, 1, 0.8))
end
function buttonend()
    imgui.PopStyleColor(4)
    style()
end

function applyfont()
    font = renderCreateFont(ccontrol.design.font, ccontrol.design.fontsize, 9)
end

function hasid(tab, val)
    for index, value in ipairs(tab) do
        if tonumber(value) == val then
            return true
        end
    end

    return false
end

function update_script(noupdatecheck, noerrorcheck)
	asyncHttpRequest('GET', update_url, nil,
		function(response)
			if response.text ~= nil then
				update_version = response.text:match("version: (.+)")
				if update_version ~= nil then
					if tonumber(update_version) > script_version then
						local dlstatus = require('moonloader').download_status
						sampAddChatMessage(string.format("{ABB2B9}[%s]{FFFFFF} New version found! The update is in progress..", script.this.name), -1)
						downloadUrlToFile(script_url, script_path, function(id, status)
							if status == dlstatus.STATUS_ENDDOWNLOADDATA then
								sampAddChatMessage(string.format("{ABB2B9}[%s]{FFFFFF} Download complete, reloading the script..", script.this.name), -1)
                                lua_thread.create(function()
                                    wait(500)    
                                end)
								thisScript():reload()
							end
						end)
					else
						if noupdatecheck then
							sampAddChatMessage(string.format("{ABB2B9}[%s]{FFFFFF} No new version found..", script.this.name), -1)
						end
					end
				end
			end
		end,
		function(err)
			if noerrorcheck then
				sampAddChatMessage(string.format("{ABB2B9}[%s]{FFFFFF} %s", script.this.name, err), -1)
			end
		end
	)
end

function asyncHttpRequest(method, url, args, resolve, reject)
    local request_thread = effil.thread(function (method, url, args)
       local requests = require 'requests'
       local result, response = pcall(requests.request, method, url, args)
       if result then
          response.json, response.xml = nil, nil
          return true, response
       else
          return false, response
       end
    end)(method, url, args)
    if not resolve then resolve = function() end end
    if not reject then reject = function() end end
    lua_thread.create(function()
       local runner = request_thread
       while true do
          local status, err = runner:status()
          if not err then
             if status == 'completed' then
                local result, response = runner:get()
                if result then
                   resolve(response)
                else
                   reject(response)
                end
                return
             elseif status == 'canceled' then
                return reject(status)
             end
          else
             return reject(err)
          end
          wait(0)
       end
    end)
 end
