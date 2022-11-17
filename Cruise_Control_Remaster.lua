script_name("Cruise Control Remaster")
script_author("Visage A.K.A. Ishaan Dunne")

local script_version = 6.76
local script_version_text = '6.76'

require "moonloader"
require "sampfuncs"
local https = require 'ssl.https'
local dlstatus = require('moonloader').download_status
local script_path = thisScript().path
local script_url = "https://raw.githubusercontent.com/Visaging/Cruise-Control-Remaster/main/Cruise_Control_Remaster.lua"
local update_url = "https://raw.githubusercontent.com/Visaging/Cruise-Control-Remaster/main/Cruise_Control_Remaster.txt"
local imgui = require 'imgui'
local imgui = require 'imgui'
local inicfg = require 'inicfg'
local vk = require 'vkeys'
local encoding = require "encoding"
encoding.default = 'CP1251'
u8 = encoding.UTF8

local enable = false
local hover = false
local mousepos = false
local mousepos2 = false
local font1 = nil
local window2img = 0
local fpos = {}
local fpos2 = {}

local ccontrol = inicfg.load({
    settings = 
    {
      togglekey = VK_RBUTTON,
      increasekey = VK_ADD,
      decreasekey = VK_SUBTRACT,
      hoverkey = VK_X
    },
    design =
    {
        xpos = 296,
        ypos = 202,
        xpos2 = 296,
        ypos2 = 202,
        fontsize = 10,
        font = "Arial",
        boxtoggle = false,
        togoverlay = true,
        nhtoggle = false,
        autosave = true,
        autoupdate = true,
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
local fntsize = imgui.ImInt(ccontrol.design.fontsize)
function imgui.OnDrawFrame()
  if main_window_state.v then
		width, height = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(width / 2, height / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(510, 230), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Cruise Control Settings", main_window_state, imgui.WindowFlags.NoResize)

        imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(1, 5)) buttonset() imgui.PushFont(fontsize20)
        imgui.SameLine(173)
        if imgui.Button(u8'Key Settings') then window2img = 0 end
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
				update_script(true)
			end
		    imgui.PopFont()
		    buttonend()
		    imgui.PopStyleVar()
        else
            if imgui.Checkbox(u8("Toggle Primary Overlay"), imgui.ImBool(ccontrol.design.togoverlay)) then
                ccontrol.design.togoverlay = not ccontrol.design.togoverlay
            end
            imgui.SameLine(nil, 10)
            if imgui.Checkbox(u8("Toggle Secondary Overlay"), imgui.ImBool(ccontrol.design.nhtoggle)) then
                ccontrol.design.nhtoggle = not ccontrol.design.nhtoggle
            end

            imgui.Text("Primary Overlay: ") imgui.SameLine()
            if imgui.Button(mousepos and u8'Cancel##1' or u8'Move with mouse##1', imgui.ImVec2(130, 20)) then
                mousepos = not mousepos
                if mousepos then
                    sampAddChatMessage('Press {FF0000}'..vk.id_to_name(vk.VK_LBUTTON)..' {FFFFFF}to save the position.', -1)
                end
            end
            imgui.SameLine(nil, 10)
            imgui.Text("Secondary Overlay: ") imgui.SameLine()
            if imgui.Button(mousepos2 and u8'Cancel##2' or u8'Move with mouse##2', imgui.ImVec2(130, 20)) then
                mousepos2 = not mousepos2
                if mousepos2 then
                    sampAddChatMessage('Press {FF0000}'..vk.id_to_name(vk.VK_LBUTTON)..' {FFFFFF}to save the position.', -1)
                end
            end

            fnt = imgui.ImBuffer(30)
            fnt.v = ccontrol.design.font
            imgui.Text("Font: ") imgui.SameLine() imgui.PushItemWidth(180)
            if imgui.InputText("##font", fnt, imgui.InputTextFlags.EnterReturnsTrue) then ccontrol.design.font = fnt.v applyfont() end
            imgui.SameLine(250)
            imgui.Text("Font Size: ") imgui.SameLine() imgui.PushItemWidth(180)
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
        end
        imgui.PopFont() imgui.PopStyleVar()
    	imgui.End()
  	end
end

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end
    if ccontrol.design.autoupdate then
            update_script(false)
    end
    sampAddChatMessage("{DFBD68}Cruise Control Remaster by {FFFF00}Visage. {FF0000}[/ccontrol] {FFFFFF}to change keys/settings.", 10944256)
    sampRegisterChatCommand("ccrversion", function()
            lua_thread.create(function()
                    sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} Current version: {00b7ff}[%s]{FFFFFF}. Click on 'Update Script' in menu to check for updates.", script.this.name, script_version_text), 10944256)
		end)
	end)
    sampRegisterChatCommand("ccontrol", function() main_window_state.v = not main_window_state.v window2img = 0 end)
    applyfont()
    while true do
        imgui.Process = main_window_state.v
        wait(0)
        if window2img == 1 then 
			if mousepos then 
				if isKeyJustPressed(vk.VK_LBUTTON) then 
					mousepos = false
                    local x, y = getCursorPos()
                    ccontrol.design.xpos = x
                    ccontrol.design.ypos = y
				else 
					fpos[1], fpos[2] = getCursorPos() 
				end 
            elseif mousepos2 then 
				if isKeyJustPressed(vk.VK_LBUTTON) then 
					mousepos2 = false
                    local x, y = getCursorPos()
                    ccontrol.design.xpos2 = x
                    ccontrol.design.ypos2 = y
				else 
					fpos2[1], fpos2[2] = getCursorPos() 
				end 
			end
		else
			if mousepos then mousepos = false end
            if mousepos2 then mousepos2 = false end
		end 
        if isCharInAnyCar(playerPed) then
            local s1 = getCarSpeed(storeCarCharIsInNoSave(playerPed))
            carhandle = storeCarCharIsInNoSave(playerPed)
            carhp = getCarHealth(carhandle)
            ds = getCarDoorLockStatus(carhandle)
            pdriver = getDriverOfCar(carhandle)
            carmodel = getCarModel(carhandle)
            carname = getGxtText(getNameOfVehicleModel(carmodel))

            if ds == 0 then
                doorStatus = "{FFCC0000}Unlocked"
            elseif ds == 2 then
                doorStatus = "{FF00CC00}Locked"
            end

            if carhp >= 750 then
                carhp = "{00ff40}"..carhp
            elseif carhp <= 750 and carhp > 400 then
                carhp = "{edf72a}"..carhp
            elseif carhp <= 400 then
                carhp = "{ff0000}"..carhp
            end

            if not (isPauseMenuActive() or sampIsScoreboardOpen()) then
                local text = ("Vehicle Name: {FFFFFF00}%s {FFCCCCCC}Vehicle Health: %s"):format(carname, carhp)
                if ccontrol.design.boxtoggle and ccontrol.design.nhtoggle then renderDrawBox(mousepos2 and fpos2[1] or ccontrol.design.xpos2, mousepos2 and fpos2[2] or ccontrol.design.ypos2, renderGetFontDrawTextLength(font, text) + 10, 20, 0xFF323232) end
                if ccontrol.design.nhtoggle then renderFontDrawText(font, text, mousepos2 and fpos2[1] + 2 or ccontrol.design.xpos2 + 2, mousepos2 and fpos2[2] or ccontrol.design.ypos2, 0xFFCCCCCC) end
            end
            if pdriver == 1 then
                if isCharInAnyHeli(playerPed) and not (isPauseMenuActive() or sampIsScoreboardOpen()) then
                    local text = ("Hover Mode: %s {FFCCCCCC}Speed: {FFFFFF00}%.0f {FFCCCCCC}Door Status: %s"):format(hover and "{FF00CC00}ON" or "{FFCC0000}OFF", s1 * 3, doorStatus)
                    if ccontrol.design.boxtoggle and ccontrol.design.togoverlay then renderDrawBox(mousepos and fpos[1] - 2 or ccontrol.design.xpos - 2, mousepos and fpos[2] - 20 or ccontrol.design.ypos - 20, renderGetFontDrawTextLength(font, text) + 10, 20, 0xFF323232) end
                    if ccontrol.design.togoverlay then renderFontDrawText(font, text, mousepos and fpos[1] + 2 or ccontrol.design.xpos + 2, mousepos and fpos[2] - 20 or ccontrol.design.ypos - 20, 0xFFCCCCCC) end
                elseif isCharInModel(playerPed, 574) and not (isPauseMenuActive() or sampIsScoreboardOpen()) then
                    local text = ("Cruise Control can not be used on this vehicle.")
                    if ccontrol.design.boxtoggle and ccontrol.design.togoverlay then renderDrawBox(mousepos and fpos[1] - 2 or ccontrol.design.xpos - 2, mousepos and fpos[2] - 20 or ccontrol.design.ypos - 20, renderGetFontDrawTextLength(font, text) + 10, 20, 0xFF323232) end
                    if ccontrol.design.togoverlay then renderFontDrawText(font, text, mousepos and fpos[1] + 2 or ccontrol.design.xpos + 2, mousepos and fpos[2] - 20 or ccontrol.design.ypos - 20, 0xFFCCCCCC) end
                else
                    if not (isPauseMenuActive() or sampIsScoreboardOpen()) then
                    local text = ("Cruise Control: %s {FFCCCCCC}Speed: {FFFFFF00}%.0f {FFCCCCCC}Door Status: %s"):format(enable and "{FF00CC00}ON" or "{FFCC0000}OFF", s1 * 3, doorStatus)
                    if ccontrol.design.boxtoggle and ccontrol.design.togoverlay then renderDrawBox(mousepos and fpos[1] - 2 or ccontrol.design.xpos - 2, mousepos and fpos[2] - 20 or ccontrol.design.ypos - 20, renderGetFontDrawTextLength(font, text) + 10, 20, 0xFF323232) end
                    if ccontrol.design.togoverlay then renderFontDrawText(font, text, mousepos and fpos[1] + 2 or ccontrol.design.xpos + 2, mousepos and fpos[2] - 20 or ccontrol.design.ypos - 20, 0xFFCCCCCC) end
                    end
                end
            else
                local text = ("{FFCCCCCC}Door Status: %s"):format(doorStatus)
                if ccontrol.design.boxtoggle and ccontrol.design.togoverlay then renderDrawBox(mousepos and fpos[1] + 215 or ccontrol.design.xpos + 215, mousepos and fpos[2] - 20 or ccontrol.design.ypos - 20, renderGetFontDrawTextLength(font, text) + 10, 20, 0xFF323232) end
                if ccontrol.design.togoverlay then renderFontDrawText(font, text, mousepos and fpos[1] + 220 or ccontrol.design.xpos + 220, mousepos and fpos[2] - 20 or ccontrol.design.ypos - 20, 0xFFCCCCCC) end
            end
            if not (sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() or isPauseMenuActive()) and enable then
                if wasKeyPressed(ccontrol.settings.increasekey) then speed = speed + 1 end
                if wasKeyPressed(ccontrol.settings.decreasekey) then speed = speed - 1 end
            end
            if enable then
                if getCarSpeed(storeCarCharIsInNoSave(playerPed)) < speed then
                    setGameKeyState(16, 150)
                elseif getCarSpeed(storeCarCharIsInNoSave(playerPed)) > speed + 0.6666666666666667 then
                    setGameKeyState(14, 80)
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
                if wasKeyPressed(ccontrol.settings.togglekey) and not isCharInAnyHeli(playerPed) and not isCharInModel(playerPed, 574) and s1 ~= 0 then
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
        if ccontrol.design.autosave then
		inicfg.save(ccontrol, 'cruise_control.ini')
        end
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
    colors[clr.WindowBg]                            = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ChildWindowBg]                       = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                             = ImVec4(0.05, 0.05, 0.05, 1.00)
    colors[clr.ComboBg]                             = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.Border]                              = ImVec4(0.80, 0.80, 0.83, 0.88)
    colors[clr.BorderShadow]                        = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]                             = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.FrameBgHovered]                      = ImVec4(0.00, 0.53, 0.76, 0.30)
    colors[clr.FrameBgActive]                       = ImVec4(0.00, 0.53, 0.76, 0.80)
    colors[clr.TitleBg]                				= ImVec4(0.09, 0.09, 0.09, 1.00)
    colors[clr.TitleBgActive]          				= ImVec4(0.09, 0.09, 0.09, 1.00)
    colors[clr.TitleBgCollapsed]       				= ImVec4(1.00, 0.98, 0.95, 0.75)
	colors[clr.MenuBarBg]                           = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarBg]                         = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]                       = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]                = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]                 = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CheckMark]                           = ImVec4(1.00, 0.42, 0.00, 0.53)
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

function update_script(noupdatecheck)
	local update_text = https.request(update_url)
	if update_text ~= nil then
		update_version = update_text:match("version: (.+)")
		if update_version ~= nil then
			if tonumber(update_version) > script_version then
				sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} New version found! The update is in progress.", script.this.name), 10944256)
				downloadUrlToFile(script_url, script_path, function(id, status)
					if status == dlstatus.STATUS_ENDDOWNLOADDATA then
						sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} The update was successful!", script.this.name), 10944256)
						lua_thread.create(function()
							wait(500) 
							thisScript():reload()
						end)
					end
				end)
			else
				if noupdatecheck then
					sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} No new version found.", script.this.name), 10944256)
				end
			end
		end
	end
end
