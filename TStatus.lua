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

-- setmetatable(_G, {
	-- __newindex = function(array, key, value)
		-- print(string.format("Changed _G: %s = %s", tostring(key), tostring(value)));
		-- rawset(array, key, value);
	-- end
-- });


collectgarbage()
----------------------------------------------------------------------
-- Locals for the application
local appName="T-Status"
local sid, sparam, switch, senso
local sid2, sparam2, switch2, senso2
local sensoLalist = {"..."}
local sensoIdlist = {"..."}
local sensoPalist = {"..."}
local iStatus, iStatus2 = -999, -999
local allstat
local tSel = {}
local Turbine, Turbine2
local Tnum, Tnum2 = 1,1
local trans, sound
local TStatusVersion = "1.5"
local labelStates = {}
local labelStates2 = {}
local imax = 1

--global:
Global_TurbineState = ""
Global_TurbineState2 = ""
--------------------------------------------------------------------------------
-- Draw telemetry-window
local function printsStatus()
	--lcd.drawText(2,6,"T-Status:",FONT_MINI)
	lcd.drawText(75-lcd.getTextWidth(FONT_BIG,Global_TurbineState)/2,1,Global_TurbineState,FONT_BIG)
end

local function printsStatus2()
	--lcd.drawText(2,6,"T-Status:",FONT_MINI)
	lcd.drawText(75-lcd.getTextWidth(FONT_BIG,Global_TurbineState2)/2,1,Global_TurbineState2,FONT_BIG)
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

local function sensorChanged2(value)
	senso2=value
	system.pSave("senso2",value)
	sid2 = string.format("%s", sensoIdlist[value])
	sparam2 = string.format("%s", sensoPalist[value])
	if (sid2 == "...") then
		sid2 = 0
		sparam2 = 0
		Global_TurbineState2 = ""
    end
	system.pSave("sid2", sid2)
	system.pSave("sparam2", sparam2)
	collectgarbage()
end

local function printvalues()
	local i=0
	local a = {}
	if Turbine ~= "" then
		for n in pairs(allstat[Turbine]) do table.insert(a, tonumber(n)) end
		table.sort(a)
		for key, value in ipairs(a) do
			i = i+1
			form.setProperties(labelStates[i],{label = string.format("% 3s.",value).." - "..allstat[Turbine][tostring(value)]})
		end
		for j = i+1,imax do
			form.setProperties(labelStates[j],{label = ""})
		end
	end
	collectgarbage()
end

local function printvalues2()
	local i=0
	local a = {}
	if Turbine2 ~= "" then
		for n in pairs(allstat[Turbine2]) do table.insert(a, tonumber(n)) end
		table.sort(a)
		for key, value in ipairs(a) do
			i = i+1
			form.setProperties(labelStates2[i],{label = string.format("% 3s.",value).." - "..allstat[Turbine2][tostring(value)]})
		end
		for j = i+1,imax do
			form.setProperties(labelStates2[j],{label = ""})
		end
	end
	collectgarbage()
end


----------------------------------------------------------------------
-- Draw the main form (Application inteface)
local function initForm()
	form.setTitle("T - 1         T-Status         T - 2")
	form.addRow(2)
	form.addSelectbox(tSel,Tnum,true,
		function (value)
			Tnum = value
			Turbine = tSel[Tnum]
			system.pSave("Turbine",Turbine)
			iStatus = -999
			Global_TurbineState = ""
			printvalues()
		end, {alignRight = false})
		
	form.addSelectbox(tSel,Tnum2,true,
		function (value)
			Tnum2 = value
			Turbine2 = tSel[Tnum2]
			system.pSave("Turbine2",Turbine2)
			iStatus2 = -999
			Global_TurbineState2 = ""
			printvalues2()
		end, {alignRight = false})
		
	form.addRow(1)	
	form.addLabel({label=trans.TSensor, width = 160 + lcd.getTextWidth(FONT_NORMAL,trans.TSensor)/2, alignRight = true})
	form.addRow(2)
	form.addSelectbox(sensoLalist,senso,true,sensorChanged, {alignRight = false})
    form.addSelectbox(sensoLalist,senso2,true,sensorChanged2, {alignRight = false})
	
	form.addRow(1)
	form.addLabel({label=trans.announcement, width = 160 + lcd.getTextWidth(FONT_NORMAL,trans.announcement)/2, alignRight = true})
	form.addRow(2)
	form.addInputbox(switch, true,
		function (value)
			switch = value
			system.pSave("switch",value) 
		end)
	form.addInputbox(switch2, true,
		function (value)
			switch2 = value
			system.pSave("switch2",value) 
		end)	
	
	--form.addSpacer(300,20)
	
	for i=1,imax do	
		form.addRow(2)
		labelStates[i] = form.addLabel({label="",font=FONT_MINI})
		labelStates2[i] = form.addLabel({label="",font=FONT_MINI})
	end		
	
	form.addRow(1)
	form.addLabel({label="dit71 v."..TStatusVersion.." ",font=FONT_MINI, alignRight=true})
	printvalues()
	printvalues2()
    collectgarbage()
end
----------------------------------------------------------------------
-- Runtime functions
local function loop()
	local sense = system.getSensorByID(sid, sparam) 
	local sense2 = system.getSensorByID(sid2, sparam2)
	local switchValue
	local switchValue2
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
	if(sense2 and sense2.valid) then
		if sense2.value ~= iStatus2 then
			iStatus2 = sense2.value
			if Turbine2 ~= "" then 
				Global_TurbineState2 = allstat[Turbine2][tostring(math.floor(iStatus2))]
				if Global_TurbineState2 then
					switchValue2 = system.getInputsVal(switch2)
					if Global_TurbineState2 ~= Global_TurbineState and sound[Global_TurbineState2] and switchValue2==1 then system.playFile(sound[Global_TurbineState2],AUDIO_QUEUE) end
				else
					Global_TurbineState2 = string.format("Value: %d", iStatus2)
				end
			end
			
		end
	end
    collectgarbage()
end
----------------------------------------------------------------------
-- Application initialization
local function init()
	system.registerForm(1,MENU_APPS,appName,initForm)
	senso = system.pLoad("senso",0)
	sid = system.pLoad("sid",0)
	sparam = system.pLoad("sparam",0)
	switch = system.pLoad("switch")
	Turbine = system.pLoad("Turbine","")
	
	senso2 = system.pLoad("senso2",0)
	sid2 = system.pLoad("sid2",0)
	sparam2 = system.pLoad("sparam2",0)
	switch2 = system.pLoad("switch2")
	Turbine2 = system.pLoad("Turbine2","")
	
	system.registerTelemetry(1,appName.." 1 - "..Turbine,1,printsStatus)
	system.registerTelemetry(2,appName.." 2 - "..Turbine2,1,printsStatus2)
	
	local i = 0
	local file
	local lng = system.getLocale()
	local j
	
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
		j = 0
		for i in pairs(value) do
			j = j + 1
		end
		if j > imax then imax = j end
	end
	table.sort(tSel)
	
	for _,key in pairs(tSel) do
		i = i + 1
		if key == Turbine then Tnum = i end
		if key == Turbine2 then Tnum2 = i end
	end
		
	collectgarbage()
end
----------------------------------------------------------------------

collectgarbage()
return {init=init, loop=loop, author="dit71", version=TStatusVersion, name=appName}