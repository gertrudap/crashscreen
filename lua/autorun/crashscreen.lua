CrashScreen = CrashScreen or {}

if SERVER then
	util.AddNetworkString("CrashScreen.Pong")
	function CrashScreen.Ping(ply, cmd, args)
		if not ply.LastPing or ply.LastPing + 5 < CurTime() then
			ply.LastPing = CurTime()
			net.Start("CrashScreen.Pong")
			net.Send(ply)
		end
	end
	concommand.Add("checkping", CrashScreen.Ping)
	return
end

if CLIENT then
	RunConsoleCommand("cl_timeout", 600)
end

CrashScreen.LastMoveTime = CurTime() + 10
CrashScreen.Crashed = false
CrashScreen.CanSpawn = false
CrashScreen.SpawnTime = 0

function CrashScreen.CrashDetect()
	if not IsValid(LocalPlayer()) or not CrashScreen.CanSpawn or CrashScreen.Crashed or CrashScreen.SpawnTime > CurTime() or CrashScreen.LastMoveTime > CurTime() then
		return false
	end

	if not LocalPlayer():IsFrozen() then
		return true
	end
end

function CrashScreen.Pong(len)
	CrashScreen.LastMoveTime = CurTime() + 10
end

net.Receive("CrashScreen.Pong", CrashScreen.Pong)
function CrashScreen.Move()
	CrashScreen.LastMoveTime = CurTime() + 1
end

hook.Add("Move", "CrashScreen.Move", CrashScreen.Move)
function CrashScreen.InitPostEntity()
	CrashScreen.CanSpawn = true
	CrashScreen.SpawnTime = CurTime() + 5
end

hook.Add("InitPostEntity", "CrashScreen.InitPostEntity", CrashScreen.InitPostEntity)
function CrashScreen.Reconnect()
	RunConsoleCommand("retry")
end

function CrashScreen.Disconnect()
	RunConsoleCommand("disconnect")
end

function CrashScreen.ShowPanel()
	for k, v in ipairs(player.GetAll()) do
		v.CrashedPing = v:Ping()
	end

	if CrashScreen.Panel and IsValid(CrashScreen.Panel) then return end

	CrashScreen.Panel = vgui.Create("DHTML")
	CrashScreen.Panel:SetSize(ScrW(), ScrH())
	CrashScreen.Panel:SetPos(0, 0)
	CrashScreen.Panel:SetHTML([[
		<link href="https://fonts.googleapis.com/css2?family=Play:wght@400&display=swap" rel="stylesheet">
		<style>
		* {
		margin: 0;
		padding: 0;
		color: inherit;
		font-family: inherit;
		box-sizing: border-box;
		}
		@-webkit-keyframes fadein {
		0% {opacity: 0}
		100% {opacity: 1}
		}
		@keyframes fadein {
		0% {opacity: 0}
		100% {opacity: 1}
		}
		html, body {
		width: 100%;
		height: 100%;
		}
		body {
		position: relative;
		overflow: auto;
		font-family: 'Play', sans-serif;
		background-color: rgba(20, 20, 20, 0.7);
		opacity: 0;
		-webkit-animation: fadein 1.2s forwards;
		animation: fadein 1.2s forwards;
		}
		#center {
		position: absolute;
		left: 50%;
		top: 50%;
		text-align: center;
		-webkit-transform: translate(-50%, -50%);
		transform: translate(-50%, -50%);
		}
		@-webkit-keyframes lostconnection {
		0% {color: #ffffff}
		50% {color: #ff5555}
		100% {color: #ffffff}
		}
		@keyframes lostconnection {
		0% {color: #ffffff}
		50% {color: #ff5555}
		100% {color: #ffffff}
		}
		#icon {
		color: white;
		width: 128px;
		height: 128px;
		-webkit-animation: lostconnection 1.2s infinite;
		animation: lostconnection 1.2s infinite;
		}
		h1 {
		color: white;
		font-size: 48px;
		}
		p {
		color: #f2f2f2;
		font-size: 23px;
		}
		#buttons {
		margin-top: 48px;
		}
		#buttons button {
		color: #f2f2f2;
		padding: 12px 24px;
		font-size: 23px;
		outline: none;
		border: 1px solid #636363;
		background: rgba(20, 20, 20, 0.7);
		-webkit-transition: color 0.2s ease-in-out;
		transition: color 0.2s ease-in-out;
		}
		#buttons button + button {
		margin-left: 12px;
		}
		#buttons button:hover {
		color: #ff5555;
		}
		</style>
		<main id="center">
		<svg viewBox="0 0 640 512" id="icon">
		<path fill="currentColor" d="M324.2 320.4c-1.4-.1-2.8-.4-4.2-.4-44.2 0-80 35.8-80 80s35.8 80 80 80 80-35.8 80-80c0-8-1.5-15.5-3.7-22.8zM320 448c-26.5 0-48-21.5-48-48s21.5-48 48-48 48 21.5 48 48-21.5 48-48 48zM3.8 158c-4.9 4.7-5.1 12.5-.3 17.3l5.7 5.7c4.6 4.6 12.1 4.7 16.8.3 19.1-18.1 39.5-33.9 60.8-47.8l-26.4-20.8C40.8 126.3 21.7 141 3.8 158zM614 181.3c4.7 4.5 12.2 4.4 16.8-.3l5.7-5.7c4.8-4.8 4.7-12.6-.3-17.3C503.6 32.2 314.1.6 152.9 63.3l30.2 23.8C328.9 37.9 495.8 69.2 614 181.3zm-297.5 10.8l44.6 35.2c51.8 7.7 101.8 29.8 143.3 66.7 4.8 4.3 12.2 4 16.6-.7l5.5-5.8c4.7-4.9 4.4-12.7-.7-17.2-59.4-53-134.4-79-209.3-78.2zM637 485.2L23 1.8C19.6-1 14.5-.5 11.8 3l-10 12.5C-1 19-.4 24 3 26.7l614 483.5c3.4 2.8 8.5 2.2 11.2-1.2l10-12.5c2.8-3.5 2.3-8.5-1.2-11.3zM114 270.3c-5 4.5-5.3 12.3-.6 17.2l5.5 5.8c4.5 4.7 11.8 5 16.7.7 25.8-23 55.7-40.9 88.1-52.8L195 218.6c-29 12.7-56.4 29.8-81 51.7z"></path>
		</svg>
		<h1>Connection Lost</h1>
		<p>It seems like the connection to the server was interupted</p>
		<p>Please hold on while we try to establish a new connection</p>
		<div id="buttons">
		<button onclick="console.log('RUNLUA:CrashScreen.Reconnect()')">Reconnect</button>
		<button onclick="console.log('RUNLUA:CrashScreen.Disconnect()')">Disconnect</button>
		</div>
		</main>
	]])

	CrashScreen.Panel:SetAllowLua(true)
	CrashScreen.Panel:MakePopup()
	CrashScreen.Panel:DoModal()

	hook.Add("Think", "CrashRecover", function()
		for k, v in ipairs(player.GetAll()) do
			if v.CrashedPing ~= v:Ping() then
				hook.Remove("Think", "CrashRecover")
				CrashScreen.Crashed = false
				CrashScreen.LastMoveTime = CurTime() + 5
			end
		end

		if CrashScreen.LastMoveTime > CurTime() then
			hook.Remove("Think", "CrashRecover")
			CrashScreen.Crashed = false
			CrashScreen.HidePanel()
		end
	end)
end

function CrashScreen.HidePanel()
	if not CrashScreen.Panel or not IsValid(CrashScreen.Panel) then return end

	CrashScreen.Panel:Remove()
	CrashScreen.Panel = nil
end

function CrashScreen.Think()
	if not CrashScreen.Crashed and CrashScreen.CrashDetect() then
		RunConsoleCommand("checkping")
		if CrashScreen.LastMoveTime + 3 < CurTime() then
			CrashScreen.Crashed = true
			CrashScreen.ShowPanel()
		else
			CrashScreen.Crashed = false
		end
	end
end

hook.Add("Think", "CrashScreen.Think", CrashScreen.Think)