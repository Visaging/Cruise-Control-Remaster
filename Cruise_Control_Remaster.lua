script_name("Cruise Control Remaster")
script_author("Visage A.K.A. Ishaan Dunne")

local script_version = 6.78
local script_version_text = '6.78'

require "moonloader"
require "sampfuncs"
local https = require 'ssl.https'
local dlstatus = require('moonloader').download_status
local script_path = thisScript().path
local script_url = "https://raw.githubusercontent.com/Visaging/Cruise-Control-Remaster/main/Cruise_Control_Remaster.lua"
local update_url = "https://raw.githubusercontent.com/Visaging/Cruise-Control-Remaster/main/Cruise_Control_Remaster.txt"
local imgui, ffi = require 'mimgui', require 'ffi'
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
local inicfg = require 'inicfg'
local gkeys  = require 'game.keys'
local vk = require 'vkeys'
local encoding = require "encoding"
local enable, hover, mousepos, mousepos2, windno, fpos, fpos2, _menu, ctogkey, cikey, cdkey, chk = false, false, false, false, 0, {}, {}, false, false, false, false, false
moto, bike = {[448] = true, [461] = true, [462] = true, [463] = true, [468] = true, [471] = true, [521] = true, [522] = true, [523] = true, [581] = true, [586] = true}, {[481] = true, [509] = true, [510] = true}
encoding.default = 'CP1251'
u8 = encoding.UTF8

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
    },
    boxcolor = {r = 0.55, g = 0.21, b = 1, a = 1},
}, 'cruise_control.ini')

local preset = {boxcolor = imgui.new.float[4](ccontrol.boxcolor.r, ccontrol.boxcolor.g, ccontrol.boxcolor.b, ccontrol.boxcolor.a)}

imgui.OnInitialize(function()
	imgui.GetIO().IniFilename = nil
    style()
end)

imgui.OnFrame(function() return _menu and not isGamePaused() end,
function()
    width, height = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(width / 2, height / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(500, 330), imgui.Cond.FirstUseEver)
    imgui.BeginCustomTitle(u8"Cruise Control Remaster", 30, main_win, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar)

        imgui.BeginChild("##1", imgui.ImVec2(130, 100), true)
            imgui.SetCursorPos(imgui.ImVec2(27, 5))
            imgui.Text("Main Settings")
            imgui.Separator()
            if imgui.Button(u8'Key Settings', imgui.ImVec2(120, 20)) then windno = 0 end imgui.Spacing()
            if imgui.Button(u8'Overlay Settings', imgui.ImVec2(120, 20)) then windno = 1 end
        imgui.EndChild()

        imgui.SetCursorPos(imgui.ImVec2(5, 140))

        imgui.BeginChild("##2", imgui.ImVec2(130, 185), true)
            imgui.SetCursorPos(imgui.ImVec2(27, 5))
            imgui.Text("Script Settings")
            imgui.Separator()
            if imgui.Button(u8'Update Script', imgui.ImVec2(120, 20)) then update_script(true) end
            if imgui.Button(u8'Save Config', imgui.ImVec2(120, 20)) then SaveIni() sampAddChatMessage(string.format("{DFBD68}[%s]{FFFFFF} Config Saved!", script.this.name), -1) end
            if imgui.Button(u8'Reload Script', imgui.ImVec2(120, 20)) then SaveIni() thisScript():reload() end imgui.Spacing()
            if imgui.Checkbox("Auto Update", new.bool(ccontrol.design.autoupdate)) then ccontrol.design.autoupdate = not ccontrol.design.autoupdate end imgui.Spacing()
            if imgui.Checkbox("Auto Save", new.bool(ccontrol.design.autosave)) then ccontrol.design.autosave = not ccontrol.design.autosave end
        imgui.EndChild()

        imgui.SetCursorPos(imgui.ImVec2(140, 35))

        imgui.BeginChild("##3", imgui.ImVec2(355, 290), true)
            if windno == 0 then
                imgui.Text("Change Cruise Key: ") imgui.SameLine() imgui.PushItemWidth(100)
                if imgui.Button(ctogkey and 'Press any key' or vk.id_to_name(ccontrol.settings.togglekey)) then ctogkey = true lua_thread.create(function() while ctogkey do wait(0) local keydown, result = getDownKeys() if result then ccontrol.settings.togglekey = keydown ctogkey = false end end end) end imgui.Spacing()
                
                imgui.Text("Change Hover Key: ") imgui.SameLine() imgui.PushItemWidth(100)
                if imgui.Button(chk and 'Press any key' or vk.id_to_name(ccontrol.settings.hoverkey)) then chk = true lua_thread.create(function() while chk do wait(0) local keydown, result = getDownKeys() if result then ccontrol.settings.hoverkey = keydown chk = false end end end) end imgui.Spacing()
                
                imgui.Text("Change Speed Increase Key: ") imgui.SameLine() imgui.PushItemWidth(100)
                if imgui.Button(cikey and 'Press any key' or vk.id_to_name(ccontrol.settings.increasekey)) then cikey = true lua_thread.create(function() while cikey do wait(0) local keydown, result = getDownKeys() if result then ccontrol.settings.increasekey = keydown cikey = false end end end) end imgui.Spacing()

                imgui.Text("Change Speed Decrease Key: ") imgui.SameLine() imgui.PushItemWidth(100)
                if imgui.Button(cdkey and 'Press any key' or vk.id_to_name(ccontrol.settings.decreasekey)) then cdkey = true lua_thread.create(function() while cdkey do wait(0) local keydown, result = getDownKeys() if result then ccontrol.settings.decreasekey = keydown cdkey = false end end end) end

            elseif windno == 1 then
                if imgui.Checkbox(u8("Toggle Primary Overlay"), new.bool(ccontrol.design.togoverlay)) then ccontrol.design.togoverlay = not ccontrol.design.togoverlay end imgui.SameLine(nil, 15)
                
                if imgui.Checkbox(u8("Toggle Secondary Overlay"), new.bool(ccontrol.design.nhtoggle)) then ccontrol.design.nhtoggle = not ccontrol.design.nhtoggle end imgui.NewLine()

                imgui.Text("Primary Overlay: ") imgui.SameLine() 
                if imgui.Button(mousepos and u8'Cancel##1' or u8'Move with mouse##1', imgui.ImVec2(130, 20)) then mousepos = not mousepos if mousepos then sampAddChatMessage('Press {FF0000}'..vk.id_to_name(vk.VK_LBUTTON)..' {FFFFFF}to save the position.', -1) end end

                imgui.Text("Secondary Overlay: ") imgui.SameLine()
                if imgui.Button(mousepos2 and u8'Cancel##2' or u8'Move with mouse##2', imgui.ImVec2(130, 20)) then mousepos2 = not mousepos2 if mousepos2 then sampAddChatMessage('Press {FF0000}'..vk.id_to_name(vk.VK_LBUTTON)..' {FFFFFF}to save the position.', -1) end end

                fnt = new.char[256](ccontrol.design.font)
                imgui.Text("Font: ") imgui.SameLine() imgui.PushItemWidth(120)
                if imgui.InputText('##font', fnt, sizeof(fnt), imgui.InputTextFlags.EnterReturnsTrue) then ccontrol.design.font = u8:decode(str(fnt)) applyfont() end imgui.SameLine(nil, 10)

                fntsize = new.int(ccontrol.design.fontsize)
                imgui.Text("Font Size: ") imgui.SameLine() imgui.PushItemWidth(50)
                if imgui.DragInt("##fontsize", fntsize, imgui.InputTextFlags.EnterReturnsTrue) then ccontrol.design.fontsize = fntsize.v applyfont() end

                imgui.Spacing() imgui.Separator() imgui.Spacing()
                if imgui.Checkbox(u8("Box Around the overlay"), new.bool(ccontrol.design.boxtoggle)) then ccontrol.design.boxtoggle = not ccontrol.design.boxtoggle end
                if ccontrol.design.boxtoggle then imgui.Text("Box Color: ") imgui.SameLine() imgui.ColorEdit4('##presettings.dc', preset.boxcolor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.AlphaBar) end
            end
        imgui.EndChild()
    imgui.End()
end)

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
    sampRegisterChatCommand("ccontrol", function() _menu = not _menu windno = 0 end)
    applyfont()
    while true do
        wait(0)
        if windno == 1 then 
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
            local carhandle = storeCarCharIsInNoSave(playerPed)
            local s1, carhp, ds, pdriver, carname = getCarSpeed(carhandle), getCarHealth(carhandle), getCarDoorLockStatus(carhandle), getDriverOfCar(carhandle), getGxtText(getNameOfVehicleModel(getCarModel(carhandle)))
            local doorStatus, carhp = ds == 0 and "{FFCC0000}Unlocked" or ds == 2 and "{FF00CC00}Locked", carhp >= 750 and "{00ff40}"..carhp or carhp <= 750 and carhp > 400 and "{edf72a}"..carhp or carhp <= 400 and "{ff0000}"..carhp
            if not (isPauseMenuActive() or sampIsScoreboardOpen()) then
                text2 = ("Vehicle Name: {FFFFFF00}%s {FFCCCCCC}Vehicle Health: %s"):format(carname, carhp)
                if pdriver == 1 then
                    if isCharInAnyHeli(playerPed) then
                        text = ("Hover Mode: %s {FFCCCCCC}Speed: {FFFFFF00}%.0f {FFCCCCCC}Door Status: %s"):format(hover and "{FF00CC00}ON" or "{FFCC0000}OFF", s1 * 3, doorStatus)
                    elseif isCharInModel(playerPed, 574) then
                        text = ("Cruise Control can not be used on this vehicle.")
                    else
                        text = ("Cruise Control: %s {FFCCCCCC}Speed: {FFFFFF00}%.0f {FFCCCCCC}Door Status: %s"):format(enable and "{FF00CC00}ON" or "{FFCC0000}OFF", s1 * 3, doorStatus)
                    end
                else
                    text = ("{FFCCCCCC}Door Status: %s"):format(doorStatus)
                end
                if ccontrol.design.boxtoggle and ccontrol.design.togoverlay then renderDrawBox(mousepos and fpos[1] - 5 or ccontrol.design.xpos - 5, mousepos and fpos[2] - 1 or ccontrol.design.ypos - 1, renderGetFontDrawTextLength(font, text) + 10, 20, '0xFF'..string.sub(bit.tohex(join_argb(preset.boxcolor[3] * 255, preset.boxcolor[0] * 255, preset.boxcolor[1] * 255, preset.boxcolor[2] * 255)), 3, 8)) end
                if ccontrol.design.togoverlay then renderFontDrawText(font, text, mousepos and fpos[1] or ccontrol.design.xpos, mousepos and fpos[2] or ccontrol.design.ypos, 0xFFCCCCCC) end
                if ccontrol.design.boxtoggle and ccontrol.design.nhtoggle then renderDrawBox(mousepos2 and fpos2[1] - 5 or ccontrol.design.xpos2 - 5, mousepos2 and fpos2[2] - 1 or ccontrol.design.ypos2 - 1, renderGetFontDrawTextLength(font, text2) + 10, 20, '0xFF'..string.sub(bit.tohex(join_argb(preset.boxcolor[3] * 255, preset.boxcolor[0] * 255, preset.boxcolor[1] * 255, preset.boxcolor[2] * 255)), 3, 8)) end
                if ccontrol.design.nhtoggle then renderFontDrawText(font, text2, mousepos2 and fpos2[1] or ccontrol.design.xpos2, mousepos2 and fpos2[2] or ccontrol.design.ypos2, 0xFFCCCCCC) end
            end

            if not (sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() or isPauseMenuActive()) and enable then
                if wasKeyPressed(ccontrol.settings.increasekey) then speed = speed + 1 end
                if wasKeyPressed(ccontrol.settings.decreasekey) then speed = speed - 1 end
            end
            if enable then
                if getCarSpeed(storeCarCharIsInNoSave(playerPed)) < speed then
                    setGameKeyState(gkeys.vehicle.ACCELERATE, 150)
                elseif getCarSpeed(storeCarCharIsInNoSave(playerPed)) > speed + 0.6666666666666667 then
                    setGameKeyState(gkeys.vehicle.BRAKE, 80)
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
		SaveIni()
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

function imgui.BeginCustomTitle(title, titleSizeY, var, flags)
    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
    imgui.PushStyleVarFloat(imgui.StyleVar.WindowBorderSize, 0)
    imgui.Begin(title, var, imgui.WindowFlags.NoTitleBar + (flags or 0))
    imgui.SetCursorPos(imgui.ImVec2(0, 0))
    local p = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddRectFilled(p, imgui.ImVec2(p.x + imgui.GetWindowSize().x, p.y + titleSizeY), imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.TitleBgActive]), imgui.GetStyle().WindowRounding, 1 + 2)
    imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(title).x / 2, titleSizeY / 2 - imgui.CalcTextSize(title).y / 2))
    imgui.Text(title)
    imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowSize().x - (titleSizeY - 10) - 5, 5))
    imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, imgui.GetStyle().WindowRounding)
    if imgui.Button('X##CLOSEBUTTON.WINDOW.'..title, imgui.ImVec2(titleSizeY - 10, titleSizeY - 10)) then _menu = false end
    imgui.SetCursorPos(imgui.ImVec2(5, titleSizeY + 5))
    imgui.PopStyleVar(3)
    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(5, 5))
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

function SaveIni()
    ccontrol.boxcolor.r, ccontrol.boxcolor.g, ccontrol.boxcolor.b, ccontrol.boxcolor.a = preset.boxcolor[0], preset.boxcolor[1], preset.boxcolor[2], preset.boxcolor[3]
    inicfg.save(ccontrol, 'cruise_control.ini')
end

function setGameKeyUpDown(key, value)
	setGameKeyState(key, value)
	setGameKeyState(key, 0)
end

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function style()
    imgui.SwitchContext()
    --==[ STYLE ]==--
    imgui.GetStyle().WindowPadding = imgui.ImVec2(8, 8)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 2)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(4, 4)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().IndentSpacing = 5
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10

    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 0
    imgui.GetStyle().ChildBorderSize = 1
    imgui.GetStyle().PopupBorderSize = 0
    imgui.GetStyle().FrameBorderSize = 0
    imgui.GetStyle().TabBorderSize = 0

    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 5
    imgui.GetStyle().ChildRounding = 5
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().ScrollbarRounding = 5
    imgui.GetStyle().GrabRounding = 5
    imgui.GetStyle().TabRounding = 5

    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    --==[ COLORS ]==--
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
end
