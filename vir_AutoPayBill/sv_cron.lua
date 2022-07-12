local Tasks = {}
local UpdatedTime = nil

local function RunTask(hours, minutes, callback)
	Tasks[#Tasks + 1] = {h = hours, m = minutes, cb = callback}
	if Config.Debug then print("Task inserted and ready to run at "..hours..':'..minutes) end
end

local function GetTime()
	local timestamp = os.time()
	local days = os.date("*t", timestamp).wday
	local hours = tonumber(os.date("%H", timestamp))
	local minutes = tonumber(os.date("%M", timestamp))

	return {d = days, h = hours, m = minutes}
end

local function OnTime(days, hours, minutes)
	for i = 1, #Tasks, 1 do
		if Tasks[i].h == hours and Tasks[i].m == minutes then
			Tasks[i].cb(days, hours, minutes)
		end
	end
end

local function Tick()
	local time = GetTime()
	if time.h ~= UpdatedTime.h or time.m ~= UpdatedTime.m then
		OnTime(time.d, time.h, time.m)
		UpdatedTime = time
	end
	SetTimeout(60000, Tick)
end

UpdatedTime = GetTime()
Tick()
exports('RunTask', RunTask)
