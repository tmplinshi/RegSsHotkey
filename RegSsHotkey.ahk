;@Ahk2Exe-SetVersion 1.0.0.0
;-----------------------------------------

#NoEnv
#SingleInstance Force
#KeyHistory 0
SetBatchLines -1
ListLines Off

CreateTrayMenu()

if 1 != -NoGui
{
	Process, Exist, Shadowsocks.exe
	if !ErrorLevel {
		MsgBox, 48,, % uiText("没有找到进程 Shadowsocks.exe。程序将退出。")
		ExitApp
	}
}

RegisterShadowsocksHotkey()

if 1 = -NoGui
	ExitApp
else
	ShowGui()
return

ShowGui() {
	global RunOnBoot

	Gui, Font, s30
	Gui, Add, Text, w350 h100 cGreen 0x201 +HWNDhText1, % uiText("注册成功！")

	Gui, Font, s12
	Gui, Add, Checkbox, % "xm +HWNDhCtrl vRunOnBoot gRunOnBoot Checked" IsRunOnBoot(), % uiText("开机自动运行")
	Gui, Add, Text, x+10 Disabled +HWNDhText2, % uiText("(自动运行不会显示此窗口)")

	KillFocus(hCtrl)
	Gosub, ResizeText1
	Gui, Show,, % uiText("注册 Shadowsocks 快捷键")
	Return

	RunOnBoot:
		GuiControlGet, RunOnBoot
		if RunOnBoot
			Startup_Add()
		else
			Startup_Remove()
	return

	ResizeText1:
		GuiControlGet, v, Pos, %hText2%
		NewWidth := vX + vW
		GuiControl, Move, %hText1%, w%NewWidth%
	return
	
	GuiClose:
	GuiEscape:
	ExitApp
}

Startup_Add() {
	val := """" . A_ScriptFullPath . """" . " -NoGui"
	RegWrite, REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, RegShadowsocksHotkey, %val%
}

Startup_Remove() {
	RegDelete, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, RegShadowsocksHotkey
}

IsRunOnBoot() {
	RegRead, val, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, RegShadowsocksHotkey
	return !!InStr(val, A_ScriptFullPath)
}

KillFocus(HCTRL) {
	PostMessage, 0x0008, 0, 0, , % "ahk_id " HCTRL ; WM_KILLFOCUS := 0x0008
}

uiText(str) {
	static lang := uiText_InitUILanguage()
	static oText := uiText_Strings()
	return oText[str].HasKey(lang) ? oText[str][lang] : str
}

uiText_InitUILanguage() {
	LANGID := DllCall("GetUserDefaultUILanguage") ; 简体中文=2052 繁体中文=1028 英文=1033
	return (LANGID = 1028) ? "cht"
	     : (LANGID = 2052) ? "chs"
	     : "en"
}

uiText_Strings() {
	oText := 
	(LTrim Join
		{
		  "注册成功！": {
		    "cht": "註冊成功！",
		    "en": "Register Successful!"
		  },
		  "开机自动运行": {
		    "cht": "開機自動運行",
		    "en": "Run on Windows startup"
		  },
		  "(自动运行不会显示此窗口)": {
		    "cht": "(自動運行不會顯示此窗口)",
		    "en": "(This window will not be displayed in auto-run mode)"
		  },
		  "注册 Shadowsocks 快捷键": {
		    "cht": "註冊 Shadowsocks 快速鍵",
		    "en": "Register Shadowsocks Hotkeys"
		  },
		  "关于": {
		    "cht": "關於",
		    "en": "About"
		  },
		  "退出": {
		    "cht": "退出",
		    "en": "Exit"
		  },
		  "没有找到进程 Shadowsocks.exe。程序将退出。": {
		    "cht": "沒有找到進程 Shadowsocks.exe。程序將退出。",
		    "en": "The process Shadowsocks.exe was not found. The program will exit now."
		  }
		}
	)
	return oText
}

CreateTrayMenu() {
	Menu, Tray, NoStandard
	Menu, Tray, Add, RegSsHotkey v1.00, TrayMenu_Exit
	Menu, Tray, Disable, RegSsHotkey v1.00
	Menu, Tray, Add
	Menu, Tray, Add, % uiText("关于"), TrayMenu_About
	Menu, Tray, Add, % uiText("退出"), TrayMenu_Exit
	return

	TrayMenu_About:
		Run, https://github.com/tmplinshi/RegSsHotkey
	return

	TrayMenu_Exit:
		ExitApp
	return
}