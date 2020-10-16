--[[
	----------------------------------------------------------------------------
	App using a numeric Sensor Data to display as text
	----------------------------------------------------------------------------
	MIT License
   
	Hiermit wird unentgeltlich jeder Person, die eine Kopie der Software und der
	zugehörigen Dokumentationen (die "Software") erhält, die Erlaubnis erteilt,
	sie uneingeschränkt zu nutzen, inklusive und ohne Ausnahme mit dem Recht, sie
	zu verwenden, zu kopieren, zu verändern, zusammenzufügen, zu veröffentlichen,
	zu verbreiten, zu unterlizenzieren und/oder zu verkaufen, und Personen, denen
	diese Software überlassen wird, diese Rechte zu verschaffen, unter den
	folgenden Bedingungen: 
	Der obige Urheberrechtsvermerk und dieser Erlaubnisvermerk sind in allen Kopien
	oder Teilkopien der Software beizulegen. 
	DIE SOFTWARE WIRD OHNE JEDE AUSDRÜCKLICHE ODER IMPLIZIERTE GARANTIE BEREITGESTELLT,
	EINSCHLIEßLICH DER GARANTIE ZUR BENUTZUNG FÜR DEN VORGESEHENEN ODER EINEM
	BESTIMMTEN ZWECK SOWIE JEGLICHER RECHTSVERLETZUNG, JEDOCH NICHT DARAUF BESCHRÄNKT.
	IN KEINEM FALL SIND DIE AUTOREN ODER COPYRIGHTINHABER FÜR JEGLICHEN SCHADEN ODER
	SONSTIGE ANSPRÜCHE HAFTBAR ZU MACHEN, OB INFOLGE DER ERFÜLLUNG EINES VERTRAGES,
	EINES DELIKTES ODER ANDERS IM ZUSAMMENHANG MIT DER SOFTWARE ODER SONSTIGER
	VERWENDUNG DER SOFTWARE ENTSTANDEN. 
	----------------------------------------------------------------------------
--]]

collectgarbage()
----------------------------------------------------------------------
-- Locals for the application
local appName="T-Status"
local sid, sparam, switch, senso
local sensoLalist = {"..."}
local sensoIdlist = {"..."}
local sensoPalist = {"..."}
local iStatus = -999
local allstat
local tSel = {}
local Turbine
local Tnum = 1
local trans, sound

--global:
Global_TurbineState = ""

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
		Global_TurbineState = ""
    end
	system.pSave("sid", sid)
	system.pSave("sparam", sparam)
	collectgarbage()
end

local function printvalues()
	local key, value, n
	local i=0
	local a = {}
	local Tvalues = "\n\n"
	if Turbine ~= "" then
		for n in pairs(allstat[Turbine]) do table.insert(a, tonumber(n)) end
		table.sort(a)
		for key, value in ipairs(a) do
			i = i+1
			Tvalues = Tvalues..value.." - "..allstat[Turbine][tostring(value)]
			if i < 3 then 
				Tvalues = Tvalues..",  "
			else
				Tvalues = Tvalues.."\n"
				i=0
			end
		end
		print(Tvalues)
	end
	collectgarbage()
end


----------------------------------------------------------------------
-- Draw the main form (Application inteface)
local function initForm()
	
	form.addRow(2)
	form.addLabel({label="Turbine:"})
	form.addSelectbox(tSel,Tnum,true,
		function (value)
			Tnum = value
			Turbine = tSel[Tnum]
			system.pSave("Turbine",Turbine)
			iStatus = -999
			printvalues()
			Global_TurbineState = ""
		end)

	form.addRow(2)
	form.addLabel({label="Sensor:"})
	form.addSelectbox(sensoLalist,senso,true,sensorChanged)
    
	form.addRow(2)
	form.addLabel({label="Announcement:"})
	form.addInputbox(switch, true,
		function (value)
			switch = value
			system.pSave("switch",value) 
		end)
    
	form.addRow(1)
	form.addLabel({label="dit71 v."..TStatusVersion.." ",font=FONT_MINI, alignRight=true})
    collectgarbage()
end
----------------------------------------------------------------------
-- Runtime functions
local function loop()
	local sense = system.getSensorByID(sid, sparam) 
	local switchValue
	if(sense and sense.valid) then
		if sense.value ~= iStatus then
			iStatus = sense.value
			if Turbine ~= "" then 
				Global_TurbineState = allstat[Turbine][tostring(math.floor(iStatus))]
				if Global_TurbineState then
					switchValue = system.getInputsVal(switch)
					if sound[Global_TurbineState] and switchValue==1 then system.playFile(sound[Global_TurbineState],AUDIO_QUEUE) end
				else
					Global_TurbineState = string.format("Value: %d", iStatus)
				end
			end
			
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
	Turbine = system.pLoad("Turbine","")
	system.registerTelemetry(1,appName,1,printsStatus)
	
	local key, value
	local i = 0
	local file
	local lng = system.getLocale()
	
	file = io.readall("Apps/TStatus/Tlang.jsn")
	local obj = json.decode(file)
	if(obj) then
		trans = obj[lng] or obj[obj.default]
		sound = obj["sound"]
	end
	
	file = io.readall("Apps/TStatus/TStatus.jsn")
	if file then
		local objT = json.decode(file)
		if objT then 
			allstat = objT
		end
	end

	for key,value in pairs(allstat) do
		table.insert(tSel,key)
		i = i + 1
		if key == Turbine then Tnum = i end
	end
	printvalues()

	collectgarbage()
end
----------------------------------------------------------------------
TStatusVersion = "1.2"
collectgarbage()
return {init=init, loop=loop, author="dit71", version=TStatusVersion, name=appName}