
collectgarbage()
----------------------------------------------------------------------
-- Locals for the application
local appName="T-Status"
local sid, sparam, switch, senso
local sensoLalist = {"..."}
local sensoIdlist = {"..."}
local sensoPalist = {"..."}
local iStatus = -1

--global:
Global_TurbineState = ""

----------------------------------------------------------------------------------------------------
-- Here you have to change the Status Number, the text which will be shown and the announcement file
-- if you don't have a wave file, delete the entry.
-- also you can add some lines or delete them if you don't need them:

function GetStatusString(iValue)
    --if     iValue == 0 then return "No Status"
    if     iValue == 0 then return "TempHigh","Temperature_high.wav"
    elseif iValue == 1 then return "Trim Low","Trim_low.wav"
    elseif iValue == 2 then return "SetIdle!","Set_Idle.wav"
    elseif iValue == 3 then return "Ready","Ready.wav"
    elseif iValue == 4 then return "Ignition","Ignition.wav"
    elseif iValue == 5 then return "FuelRamp","Fuel_ramp.wav"
    elseif iValue == 6 then return "Glow Test","glow_test.wav"
    elseif iValue == 7 then return "Running","running.wav"
    elseif iValue == 8 then return "Stop","stop.wav"
    elseif iValue == 9 then return "FlameOut","flame_out.wav"
    elseif iValue == 10 then return "SpeedLow","speed_low.wav"
    elseif iValue == 11 then return "Cooling","cooling.wav"
    elseif iValue == 12 then return "Ignitor Bad","ignitor_bad.wav"
    elseif iValue == 13 then return "Starter Bad","starter_bad.wav"
    elseif iValue == 14 then return "Weak Gas","weak_gas.wav"
    elseif iValue == 15 then return "Start On","start_on.wav"
    elseif iValue == 16 then return "User Off","user_off.wav"
    elseif iValue == 17 then return "Failsafe","failsafe.wav"
    elseif iValue == 18 then return "Low RPM","low_rotation.wav"
    elseif iValue == 19 then return "Reset","reset.wav"
    elseif iValue == 20 then return "Rx PwFail","receiver_power_fail.wav"
    elseif iValue == 21 then return "Pre Heat","pre_heat.wav"
    elseif iValue == 22 then return "Battery!","turbine_batterie.wav"
    elseif iValue == 23 then return "Time Out","time_out.wav"
    elseif iValue == 24 then return "Overload","overload.wav"
    elseif iValue == 25 then return "Ign.Fail","ignition_fail.wav"
    elseif iValue == 26 then return "BurnerOn","burner_on.wav"
    elseif iValue == 27 then return "Starting","starting.wav"
    elseif iValue == 28 then return "SwitchOv","switch_over.wav"
    elseif iValue == 29 then return "Cal.Pump","call_pump.wav"
    elseif iValue == 30 then return "Pump Limit","pump_limit.wav"
    elseif iValue == 31 then return "NoEngine","no_engine.wav"
    elseif iValue == 32 then return "PwrBoost","power_boost.wav"
    elseif iValue == 33 then return "Run-Idle","run_idle.wav"
    elseif iValue == 34 then return "Run-Max","run_max.wav"
    elseif iValue == 35 then return "Restart","restart.wav"
    else return string.format("Value:%d", iValue)
    end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Draw telemetry-window
local function printsStatus()
	--lcd.drawText(2,6,"T-Status:",FONT_MINI)
	lcd.drawText(75-lcd.getTextWidth(FONT_BIG,Global_TurbineState)/2,1,Global_TurbineState,FONT_BIG)
end
--------------------------------------------------------------------------------
-- Read available sensors for user to select
local sensors = system.getSensors()
for i,sensor in ipairs(sensors) do
	if (sensor.label ~= "") then
		table.insert(sensoLalist, string.format("%s", sensor.label))
		table.insert(sensoIdlist, string.format("%s", sensor.id))
		table.insert(sensoPalist, string.format("%s", sensor.param))
    end
end
----------------------------------------------------------------------
-- Store settings when changed by user
local function sensorChanged(value)
	senso=value
	system.pSave("senso",value)
	sid = string.format("%s", sensoIdlist[value])
	sparam = string.format("%s", sensoPalist[value])
	if (sid == "...") then
		sid = 0
		sparam = 0
    end
	system.pSave("sid", sid)
	system.pSave("sparam", sparam)
end

local function switchChanged(value)
	switch = value
	system.pSave("switch",value)
end

----------------------------------------------------------------------
-- Draw the main form (Application inteface)
local function initForm()
    
	form.addRow(2)
	form.addLabel({label="Sensor:"})
	form.addSelectbox(sensoLalist,senso,true,sensorChanged)
    
	form.addRow(2)
	form.addLabel({label="Announcement:"})
	form.addInputbox(switch, true, switchChanged)
    
	form.addRow(1)
	form.addLabel({label="dit71 v."..TStatusVersion.." ",font=FONT_MINI, alignRight=true})
    collectgarbage()
end
----------------------------------------------------------------------
-- Runtime functions
local function loop()
	local sense = system.getSensorByID(sid, sparam)
	local Ansage 
	local switchValue
	
	if(sense and sense.valid) then
		if sense.value ~= iStatus then
			iStatus = sense.value
			Global_TurbineState,Ansage = GetStatusString(iStatus)
			switchValue = system.getInputsVal(switch)
			if Ansage and switchValue==1 then system.playFile(Ansage,AUDIO_QUEUE) end
		end
	end
    collectgarbage()
end
----------------------------------------------------------------------
-- Application initialization
local function init()
	system.registerForm(1,MENU_APPS,"T-Status",initForm)
	senso = system.pLoad("senso",0)
	sid = system.pLoad("sid",0)
	sparam = system.pLoad("sparam",0)
	switch = system.pLoad("switch")
	system.registerTelemetry(1,appName,1,printsStatus)
	local i
	local j = 0
	local Test = ""
	for i=-30,51,1 do
	if string.sub(GetStatusString(i),1,6) ~="Value:" then
		Test = Test..i.."-"..GetStatusString(i).."  "
		j=j+1
		if j==4 then
		  j=0
		  Test = Test.."\n"
		end
	end
	end
	print(Test)
	collectgarbage()
end
----------------------------------------------------------------------
TStatusVersion = "1.0"
collectgarbage()
return {init=init, loop=loop, author="dit71", version=TStatusVersion, name=appName}