; 注册已设置的 Shadowsocks 快捷键
RegisterShadowsocksHotkey()
{
	Process, Wait, Shadowsocks.exe ; 等待 Shadowsocks 启动。此函数主要用于开机时自动设置。

	Loop, 60 {
		TrayIcon_Button("Shadowsocks.exe", "R") ; 点击托盘图标右键
		WinWait, ahk_class #32768 ahk_exe Shadowsocks.exe,, 2 ; 等待右键菜单出现
		if !ErrorLevel
			Break
	}

	; 点击“编辑快捷键...”菜单
	acc := Acc_ObjectFromWindow( WinExist("") )
	Loop, % Acc_Children(acc).MaxIndex() {
		if RegExMatch( acc.accName(A_Index), "编辑快捷键|編輯快速鍵|Edit Hotkeys", m ) {
			acc.accDoDefaultAction(A_Index)
			Break
		}
	}

	WinWait, %m%... ahk_exe Shadowsocks.exe ; 等待“编辑快捷键...”窗口出现
	ControlSend, ahk_parent, {Enter} ; 发送回车键
}
