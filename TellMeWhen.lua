local oldprint = print
local function print(...)
	if (not TellMeWhen_Settings) or TellMeWhen_Settings["TESTON"] then
		oldprint("|cffff0000TMW:|r ", ...)
	end
end

local L = LibStub("AceLocale-3.0"):GetLocale("TellMeWhen", true)
local LBF = LibStub("LibButtonFacade", true)

if LBF then
	LBF:RegisterSkinCallback("TellMeWhen", TellMeWhen_SkinCallback, self);
end

TellMeWhen = {};
TELLMEWHEN_VERSION = "3.3.3.5a 2026";
TELLMEWHEN_MAXOLDGROUPS = 8; 
TELLMEWHEN_MAXGROUPS = 10;
TELLMEWHEN_MAXROWS = 7;
TELLMEWHEN_MAXCONDITIONS = 3;
TELLMEWHEN_ICONSPACING = 0;
TELLMEWHEN_UPDATE_INTERVAL = 0.05;
TELLMEWHEN_INITIALIZED = false

local GetSpellCooldown, GetSpellInfo, IsUsableSpell, IsSpellInRange = GetSpellCooldown, GetSpellInfo, IsUsableSpell, IsSpellInRange;
local GetItemCooldown, IsItemInRange = GetItemCooldown, IsItemInRange;
local GetInventorySlotInfo, GetWeaponEnchantInfo, GetTotemInfo = GetInventorySlotInfo, GetWeaponEnchantInfo, GetTotemInfo;
local CooldownFrame_SetTimer, GetSpellTexture = CooldownFrame_SetTimer, GetSpellTexture;
local SetValue, SetTexCoord, SetStatusBarColor, SetMinMaxValues = SetValue, SetTexCoord, SetStatusBarColor, SetMinMaxValues;
local SetVertexColor, SetAlpha, GetAlpha, GetTexture, SetTexture = SetVertexColor, SetAlpha, GetAlpha, GetTexture, SetTexture;
local UnitIsEnemy, UnitAura, UnitReaction, UnitExists, UnitPower, UnitHealth = UnitIsEnemy, UnitAura, UnitReaction, UnitExists, UnitPower, UnitHealth;
local GetPetHappiness, GetEclipseDirection, GetComboPoints = GetPetHappiness, GetEclipseDirection, GetComboPoints;

local _,pclass = UnitClass("Player")
local st, co, rc, mc, us, un, pr, ab, defaultSpell
local defaultSpells,chakra,TMW_CNDT,TMW_OP,TMW_AO = {},{},{},{},{}


TellMeWhen_Icon_Defaults = {
	BuffOrDebuff		= "HELPFUL",
	BuffShowWhen		= "present",
	CooldownShowWhen	= "usable",
	CooldownType		= "spell",
	Enabled				= false,
	Name				= "",
	OnlyMine			= false,
	ShowTimer			= false,
	ShowTimerText		= true,
	ShowPBar			= false,
	ShowCBar			= false,
	InvertBars			= false, 
	Type				= "",
	Unit				= "player",
	WpnEnchantType		= "mainhand",
	UnitReact			= 0,
	Conditions			= {},
	Alpha				= 1,
	UnAlpha				= 1,
	RangeCheck			= false,
	ManaCheck			= false,
	CooldownCheck		= false,
};

TellMeWhen_Group_Defaults = {
	Enabled			= false,
	Scale			= 2.0,
	Rows			= 1,
	Columns			= 4,
	Icons			= {},
	OnlyInCombat	= false,
	PrimarySpec		= true,
	SecondarySpec	= true,
	Stance			= {},
	Point			= {},
	LBF				= {},
};

TellMeWhen_Defaults = {
	Version 		= 	TELLMEWHEN_VERSION,
	Locked 			= 	false,
	Groups 			= 	{},
	Interval		=	TELLMEWHEN_UPDATE_INTERVAL,
	CDCOColor 		= 	{r=0,g=1,b=0,a=1},
	CDSTColor 		= 	{r=1,g=0,b=0,a=1},
	USEColor		=	{r=1,g=1,b=1,a=1},
	UNUSEColor		=	{r=1,g=1,b=1,a=1},
	PRESENTColor	=	{r=1,g=1,b=1,a=1},
	ABSENTColor		=	{r=1,g=0.35,b=0.35,a=1},
	OORColor		=	{r=0.5,g=0.5,b=0.5,a=1},
	OOMColor		=	{r=0.5,g=0.5,b=0.5,a=1},
	NumCondits 		= 	TELLMEWHEN_MAXCONDITIONS,
	Spacing			=	TELLMEWHEN_ICONSPACING,
--	NumGroups		=	TELLMEWHEN_MAXGROUPS,
	Texture			=	"Interface\\TargetingFrame\\UI-StatusBar",
	TextureName 	= 	"Blizzard",
	DrawEdge		=	false,
	TESTON 			= 	false;
};

TMW_BE = {
	debuffs = {
		["Bleeding"] = "9007;1822;1079;33745;1943;703;94009;43104",
		["Incapacitated"] = "1776;20066;49203",
		["StunnedOrIncapacitated"] = "1833;408;91800;5211;9005;22570;19577;56626;44572;82691;853;2812;64044;20549;46968;30283;20252;65929;7922;12809;50519;1776;20066;49203",
		["Stunned"] = "1833;408;91800;5211;9005;22570;19577;56626;44572;82691;853;2812;64044;20549;46968;30283;20252;65929;7922;12809;50519",
		["Disoriented"] = "19503;31661;2094;90337;51514",
		["Silenced"] = "47476;78675;34490;55021;18469;31935;15487;1330;19647;18498;25046;80483;50613;28730", -- 69179 BE WARRIOR ARCANE TORRENT FOR 
		["Disarmed"] = "51722;676;64058;50541;91644",
		["Rooted"] = "122;23694;58373;64695;19185;64803;4167;54706;50245;90327;16979;83301;83302",
		["PhysicalDmgTaken"] = "30070;58683;81326;50518;55749",
		["SpellDamageTaken"] = "93068;1490;65142;60433;34889;24844",
		["SpellCritTaken"] = "17800;22959",
		["BleedDamageTaken"] = "33878;33876;16511;46857;50271;35290;57386",
		["ReducedAttackSpeed"] = "6343;55095;58180;68055;8042;90314;50285",
		["ReducedCastingSpeed"] = "1714;5760;31589;73975;50274;50498",
		["ReducedArmor"] = "8647;50498;35387;91565;7386",
		["ReducedHealing"] = "12294;13218;56112;48301;82654;30213;54680",
		["ReducedPhysicalDone"] = "1160;99;26017;81130;702;24423",
	},
	buffs = {
		["ImmuneToStun"] = "642;45438;34471;19574;48792;1022;33786;710",
		["ImmuneToMagicCC"] = "642;45438;34471;19574;33786;710",
		["IncreasedStats"] = "79061;79063;90363",
		["IncreasedDamage"] = "75447;82930",
		["IncreasedCrit"] = "24932;29801;51701;51470;24604;90309",
		["IncreasedAP"] = "79102;53138;19506;30808",
		["IncreasedSPsix"] = "79058;52109",
		["IncreasedSPten"] = "77747;53646",
		["IncreasedSPboth"] = "79058;52109;77747;53646",
		["IncreasedPhysHaste"] = "55610;53290;8515",
		["IncreasedSpellHaste"] = "2895;24907;49868",
		["BurstHaste"] = "2825;32182;80353;90355",
		["BonusAgiStr"] = "6673;8076;57330;93435",
		["BonusStamina"] = "79105;469;6307;90364",
		["BonusArmor"] = "465;8072",
		["BonusMana"] = "79058;54424",
		["ManaRegen"] = "54424;79102;5677",
		["BurstManaRegen"] = "29166;16191;64901",
		["PushbackResistance"] = "19746;87717",
		["Resistances"] = "19891;8185",
	},
};

-- ---------------
-- EXECUTIVE FRAME
-- ---------------

function TellMeWhen_OnEvent(self, event,...)
	if ( event == 'VARIABLES_LOADED' ) then
		TellMeWhen_VarsLoaded()
	elseif ( event == "PLAYER_LOGIN" ) or ( event == "PLAYER_ENTERING_WORLD" ) then
		self:RegisterEvent("PLAYER_TALENT_UPDATE");
		self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
		self:RegisterEvent("LEARNED_SPELL_IN_TAB");
		TellMeWhen_Update();
	elseif ( event == "PLAYER_TALENT_UPDATE") then
		TellMeWhen_Update();
		blacklistevent = GetTime()
	elseif ( event == "LEARNED_SPELL_IN_TAB") then
		if GetTime() > blacklistevent+1 then
			TellMeWhen_Update();
		end
	--elseif ( event == "PET_BAR_UPDATE" ) then
	--	TellMeWhen_PetEvent()
	end
end

function TellMeWhen_VarsLoaded()
	SlashCmdList["TELLMEWHEN"] = TellMeWhen_SlashCommand;
	SLASH_TELLMEWHEN1 = "/tellmewhen";
	SLASH_TELLMEWHEN2 = "/tmw";
	if TellMeWhen_Settings then
		TELLMEWHEN_MAXCONDITIONS = TellMeWhen_Settings["NumCondits"] or TELLMEWHEN_MAXCONDITIONS
		TELLMEWHEN_ICONSPACING = TellMeWhen_Settings["Spacing"] or TELLMEWHEN_ICONSPACING
	--	TELLMEWHEN_MAXGROUPS = TellMeWhen_Settings["NumGroups"] or TELLMEWHEN_MAXGROUPS
	end
	for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
		TellMeWhen_Group_Defaults["Icons"][iconID] = TellMeWhen_Icon_Defaults;
	end;

	for groupID = 1, TELLMEWHEN_MAXGROUPS do
		TellMeWhen_Defaults["Groups"][groupID] = TellMeWhen_Group_Defaults;
		if (groupID == 1) then
			TellMeWhen_Defaults["Groups"][groupID].Enabled = true;
		end
	end
	if ( not TellMeWhen_Settings ) then
		TellMeWhen_Settings = CopyTable(TellMeWhen_Defaults);
		TellMeWhen_Settings["Groups"][1]["Enabled"] = true;
	elseif ( TellMeWhen_Settings["Version"] < TELLMEWHEN_VERSION ) then
	
		TellMeWhen_SafeUpgrade();
	end
	if LBF then
		LBF:RegisterSkinCallback("TellMeWhen111", TellMeWhen_SkinCallback, self);
	end
	TellMeWhen_ConditionEditor_CreateGroups()
	TellMeWhen_Options_Compile()
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("|cffff7d0aTMW|r от |cff69ccf0Дека|r 2026 /Amdir WoW","|cffff7d0aTellMeWhen")
	LibStub("AceConfig-3.0"):RegisterOptionsTable("|cffff7d0aTMW|r от |cff69ccf0Дека|r 2026 /Amdir WoW", TMWoptionsTable)
end

function TellMeWhen_SafeUpgrade()
	if (TellMeWhen_Settings["Version"] < "1.1.4") then
		TellMeWhen_Settings = CopyTable(TellMeWhen_Defaults);
		TellMeWhen_Settings["Groups"][1]["Enabled"] = true;
		TellMeWhen_Settings["Version"] = TELLMEWHEN_VERSION;
	elseif (TellMeWhen_Settings["Version"] < "1.2.0") then
	TellMeWhen_Settings = TellMeWhen_AddNewSettings(TellMeWhen_Settings, TellMeWhen_Defaults);
		for groupID = 1, TELLMEWHEN_MAXOLDGROUPS do
			if (groupID < 5) then
				oldgroupSettings = TellMeWhen_Settings["Spec"][1]["Groups"][groupID];
				TellMeWhen_Settings["Groups"][groupID]["SecondarySpec"] = false;
			else
				local temp_groupID = groupID-4;
				TellMeWhen_Settings["Groups"][groupID]["PrimarySpec"] = false;
				oldgroupSettings = TellMeWhen_Settings["Spec"][2]["Groups"][temp_groupID];
			end
			if (oldgroupSettings) then
				TellMeWhen_Settings["Groups"][groupID]["Enabled"] = oldgroupSettings.Enabled;
				TellMeWhen_Settings["Groups"][groupID]["Scale"] = oldgroupSettings.Scale;
				TellMeWhen_Settings["Groups"][groupID]["Rows"] = oldgroupSettings.Rows;
				TellMeWhen_Settings["Groups"][groupID]["Columns"] = oldgroupSettings.Columns;
				TellMeWhen_Settings["Groups"][groupID]["OnlyInCombat"] = oldgroupSettings.OnlyInCombat;
			end

			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				if (oldgroupSettings) then
					oldiconSettings = oldgroupSettings["Icons"][iconID];
					if (oldiconSettings) then
						iconSettings = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID];
						iconSettings.BuffOrDebuff = oldiconSettings.BuffOrDebuff;
						iconSettings.BuffShowWhen = oldiconSettings.BuffShowWhen;
						iconSettings.CooldownShowWhen = oldiconSettings.CooldownShowWhen;
						iconSettings.CooldownType = oldiconSettings.CooldownType;
						iconSettings.Enabled = oldiconSettings.Enabled;
						iconSettings.Name = oldiconSettings.Name;
						iconSettings.OnlyMine = oldiconSettings.OnlyMine;
						iconSettings.ShowTimer = oldiconSettings.ShowTimer;
						iconSettings.Type = oldiconSettings.Type;
						iconSettings.Unit = oldiconSettings.Unit;
						iconSettings.WpnEnchantType = oldiconSettings.WpnEnchantType;
					end
				end
				if (iconSettings.Name == "" and iconSettings.type ~= "wpnenchant") then
					TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Enabled"] = false;
				end
			end
		end
		TellMeWhen_Settings["Spec"] = nil;  -- Remove "Spec" {}
	end
	
	if (TellMeWhen_Settings["Version"] < "1.3.0") then
		TellMeWhen_Settings["Texture"] = "Interface\\TargetingFrame\\UI-StatusBar";
		TellMeWhen_Settings["TextureName"] = "Blizzard";
		for groupID = 1, TELLMEWHEN_MAXOLDGROUPS do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["ShowPBar"] = false;
				TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["ShowCBar"] = false;
				TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["InvertBars"] = false;
			end
		end
	end
	if (TellMeWhen_Settings["Version"] < "1.3.3") then
		for groupID = 1, TELLMEWHEN_MAXOLDGROUPS do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["UnitReact"] = 0;
			end
		end
	end
	if (TellMeWhen_Settings["Version"] < "1.4.0") then
		for groupID = 1, TELLMEWHEN_MAXOLDGROUPS do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				iconSettings = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID];
				if (iconSettings.Conditions == nil) then
					iconSettings.Conditions = {};
				end
				if (iconSettings.Alpha == nil) then
					iconSettings.Alpha = 1;
				end
			end
		end
	end
	if (TellMeWhen_Settings["Version"] < "1.4.1") then
		TellMeWhen_Settings["Interval"] = TELLMEWHEN_UPDATE_INTERVAL;
	end
	if (TellMeWhen_Settings["Version"] < "1.4.3") then
		for groupID = 1, TELLMEWHEN_MAXOLDGROUPS do
			TellMeWhen_Settings["Groups"][groupID]["Stance"] = {}
		end
	end
	if (TellMeWhen_Settings["Version"] < "1.4.4") then
		TellMeWhen_Settings["CDCOColor"] = {r=0,g=1,b=0,a=1}
		TellMeWhen_Settings["CDSTColor"] = {r=1,g=0,b=0,a=1}
	end
	if (TellMeWhen_Settings["Version"] < "1.4.5") then
		for groupID = 1, TELLMEWHEN_MAXOLDGROUPS do
			TellMeWhen_Settings["Groups"][groupID]["Point"] = {}
			local group = _G["TellMeWhen_Group"..groupID] or CreateFrame("Frame","TellMeWhen_Group"..groupID, UIParent, "TellMeWhen_GroupTemplate", groupID);
			group.p = TellMeWhen_Settings["Groups"][groupID]["Point"]
			group.p.point,_,group.p.relativePoint,group.p.x,group.p.y = group:GetPoint(1)
		end
	end
	if (TellMeWhen_Settings["Version"] < "1.4.6") then
		for groupID = 1, TELLMEWHEN_MAXOLDGROUPS do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["RangeCheck"] = false
				TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["ManaCheck"] = false
			end
		end
	end
	if (TellMeWhen_Settings["Version"] < "1.4.7") then
		TellMeWhen_Settings["DrawEdge"] = false
	end
	if (TellMeWhen_Settings["Version"] < "1.4.9.1") then
		TellMeWhen_Settings["OORColor"] = {r=0.5,g=0.5,b=0.5,a=1}
		TellMeWhen_Settings["OOMColor"] = {r=0.5,g=0.5,b=0.5,a=1}
	end
	if (TellMeWhen_Settings["Version"] < "1.5.3") then
		for groupID = 1, TELLMEWHEN_MAXOLDGROUPS do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				if TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Alpha"] and TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Alpha"] > 1 then
					TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Alpha"] = (TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Alpha"] / 100)
				else
					TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Alpha"] = 1
				end
				TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["UnAlpha"] = 1
			end
		end
	end
	if (TellMeWhen_Settings["Version"] < "1.5.4") then
		for groupID = 1, TELLMEWHEN_MAXOLDGROUPS do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				if TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Alpha"] == 0.01 then TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Alpha"] = 1 end
			end
		end
	end
	if (TellMeWhen_Settings["Version"] < "2.0.1") then
		TellMeWhen_Settings["TESTON"] 		= 	false;
		TellMeWhen_Settings["USEColor"] 	= 	TellMeWhen_Settings["USEColor"]		or 	{r=1,g=1,b=1};
		TellMeWhen_Settings["UNUSEColor"] 	= 	TellMeWhen_Settings["UNUSEColor"]	or	{r=1,g=1,b=1};
		TellMeWhen_Settings["PRESENTColor"]	= 	TellMeWhen_Settings["PRESENTColor"]	or	{r=1,g=1,b=1};
		TellMeWhen_Settings["ABSENTColor"] 	= 	TellMeWhen_Settings["ABSENTColor"]	or	{r=1,g=0.35,b=0.35};
		local needtowarn = false
		for groupID = TELLMEWHEN_MAXOLDGROUPS,TELLMEWHEN_MAXGROUPS do
			local group = _G["TellMeWhen_Group"..groupID] or CreateFrame("Frame","TellMeWhen_Group"..groupID, UIParent, "TellMeWhen_GroupTemplate",groupID);
			TellMeWhen_Settings["Groups"][groupID] = TellMeWhen_Settings["Groups"][groupID] or TellMeWhen_Group_Defaults;
			TellMeWhen_Settings["Groups"][groupID]["Enabled"] = TellMeWhen_Settings["Groups"][groupID]["Enabled"] or false;
		end
		for groupID = 1, TELLMEWHEN_MAXGROUPS do
			TellMeWhen_Settings["Groups"][groupID]["LBF"] = TellMeWhen_Settings["Groups"][groupID]["LBF"] or {}
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["ShowTimerText"] = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["ShowTimerText"] or TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["ShowTimer"]; --Inherit this
				TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Conditions"] = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Conditions"] or {}
				for k,v in pairs(TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Conditions"]) do
					v.ConditionLevel = tonumber(v.ConditionLevel) or 0
					if ((v.ConditionType == "SOUL_SHARDS") or (v.ConditionType == "HOLY_POWER")) and (v.ConditionLevel > 3) then
						needtowarn = true
						v.ConditionLevel = ceil((v.ConditionLevel/100)*3)
					end
				end
			end
		end
		
		TellMeWhen_Settings["NumCondits"] = TELLMEWHEN_MAXCONDITIONS
	--	TellMeWhen_Settings["NumGroups"] = TELLMEWHEN_MAXGROUPS
		if needtowarn then
			StaticPopup_Show("TELLMEWHEN_HPSS_WARN")
		end
	end
	if (TellMeWhen_Settings["Version"] < "2.0.2.1") then
		for groupID = 1, TELLMEWHEN_MAXGROUPS do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				for k,v in pairs(TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Conditions"]) do
					local isgood = false
					for z,x in pairs(TellMeWhen_IconMenu_SubMenus.Unit) do
						if v.ConditionUnit and v.ConditionUnit == x.value then
							isgood = true
						end
					end
					if not isgood then
						DEFAULT_CHAT_FRAME:AddMessage(format("TellMeWhen: Group %d, Icon %d had the unit to check for its conditions modified. You may wish to verify that the change is correct",groupID,iconID))--not worth localizing
						v.ConditionUnit = "player"
					end
				end
			end
		end				
	end
	
	--All Upgrades Complete
	TellMeWhen_Settings["Version"] = TELLMEWHEN_VERSION;
end

function TMW_CondtFix()
	for groupID = 1, TELLMEWHEN_MAXGROUPS do
		for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
			TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Conditions"] = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Conditions"] or {}
			for k,v in pairs(TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Conditions"]) do
				v.ConditionLevel = tonumber(v.ConditionLevel) or 0
			end
		end
	end
end

function TellMeWhen_AddNewSettings(settings, defaults)
	for k, v in pairs(defaults) do
		if ( not settings[k] ) then
			if ( type(v) == "table" ) then
				settings[k] = {};
				settings[k] = TellMeWhen_AddNewSettings(settings[k], defaults[k]);
			else
				settings[k] = v;
			end
		elseif ( type(v) == "table" ) then
			settings[k] = TellMeWhen_AddNewSettings(settings[k], defaults[k]);
		end
	end
	return settings;
end

function TellMeWhen_ColorUpdate()
	st = TellMeWhen_Settings["CDSTColor"]
	co = TellMeWhen_Settings["CDCOColor"]
	rc = TellMeWhen_Settings["OORColor"]
	mc = TellMeWhen_Settings["OOMColor"]
	us = TellMeWhen_Settings["USEColor"]
	un = TellMeWhen_Settings["UNUSEColor"]
	pr = TellMeWhen_Settings["PRESENTColor"]
	ab = TellMeWhen_Settings["ABSENTColor"]
end

function TellMeWhen_Update()
	TellMeWhen_ColorUpdate()
	TELLMEWHEN_ICONSPACING = TellMeWhen_Settings["Spacing"] or TELLMEWHEN_ICONSPACING
	for groupID = 1, TELLMEWHEN_MAXGROUPS do
		TellMeWhen_Group_Update(groupID);
	end
	TellMeWhen_ConditionEditor_CreateGroups()
	TELLMEWHEN_INITIALIZED = true
	TellMeWhen_CopyPanel_Update()
end

do
	local ver = select(4, GetBuildInfo());
	defaultSpells = {
		ROGUE=1752, -- sinister strike
		PRIEST=139, -- renew
		DRUID=774, -- rejuvenation
		WARRIOR=772, -- rend
		MAGE=133, -- fireball
		WARLOCK=687, -- demon armor
		PALADIN=20154, -- seal of righteousness
		SHAMAN=324, -- lightning shield
		HUNTER=1978, -- serpent sting
		DEATHKNIGHT=45462, -- plague strike
	}
	
	defaultSpell = defaultSpells[pclass] -- a much nicer way than indexing a table on every GetGCD() call
	chakra = {
		{abid = 88685, buffid = 81206}, 	-- sanctuary, prayer of healing,mending
		{abid = 88684, buffid = 81208},		-- serenity, heal
		{abid = 88682, buffid = 81207},		-- aspire, renew
	}
	
	--insert spells with duplicate spell names here
	TellMeWhen_DSN = {};
	TellMeWhen_DSN[16511] = true;	--hemo
	TellMeWhen_DSN[89775] = true;	-- glyph of hemo bleed
	
	local executiveFrame = CreateFrame("Frame", "TellMeWhen_ExecutiveFrame");
	executiveFrame:SetScript("OnEvent", TellMeWhen_OnEvent);
	executiveFrame:RegisterEvent("VARIABLES_LOADED");
	executiveFrame:RegisterEvent("PLAYER_LOGIN");
	executiveFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
end


-- -----------
-- GROUP FRAME
-- -----------

local function TellMeWhen_Stance_Check(group)
	if not group.correctspec then
		return
	end
	local groupID = group:GetID()
	local index = GetShapeshiftForm()

	if pclass == "WARLOCK" and index == 2 then  --UGLY HACK FOR METAMORPHOSIS, IT IS INDEX 2 FOR SOME REASON
		index = 1
	end
	if pclass == "ROGUE" and index >= 2 then	--UGLY FIX FOR ROGUES, VANISH AND SHADOW DANCE RETURN 3...
		index = 1							--WHEN ACTIVE, VANISH RETURNS 2 WHEN SHADOW DANCE ISNT LEARNED.
	end
	if index > GetNumShapeshiftForms() then --MANY CLASSES RETURN AN INVALID NUMBER ON LOGIN, BUT NOT ANYMORE!
		index = 0
	end
	if index == 0 then
		if not TellMeWhen_Settings["Groups"][groupID]["Stance"][0] then
			if group.combatcheck then
				if UnitAffectingCombat("player") then
					group:Show();
				elseif not UnitAffectingCombat("player") then
					group:Hide();
				end
			else
				group:Show()
			end
		else
			group:Hide();
		end
	elseif index ~= nil then
		local texture, name, isActive, isCastable = GetShapeshiftFormInfo(index)
		if not name then error("Uh oh! Something happened to the stance checks! Please send this error in Cybeloras' direction, as well as what you were doing at the time:" .. index .. ":" .. pclass .. ":") return end
		local _,_,ID = string.find(GetSpellLink(name), ":(%d+)")
		for k,v in pairs(TellMeWhen_CurrentStances) do
			if TellMeWhen_CurrentStances[k] == tonumber(ID) then
				if not TellMeWhen_Settings["Groups"][groupID]["Stance"][k] then
					if group.combatcheck then
						if UnitAffectingCombat("player") then
							group:Show();
						elseif not UnitAffectingCombat("player") then
							group:Hide();
						end
					else
						group:Show()
					end
				else
					group:Hide();
				end
			end
		end
	end
end

function TellMeWhen_Group_OnEvent(self, event,...)
	if (event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED") then
		if self.combatcheck then
			if UnitAffectingCombat("player") then
				self:Show();
			elseif not UnitAffectingCombat("player") then
				self:Hide();
			end
		end
	elseif (event == "UPDATE_SHAPESHIFT_FORM" or event == "UPDATE_SHAPESHIFT_FORMS") then
		TellMeWhen_Stance_Check(self)
	end
end

function TellMeWhen_Group_Update(groupID)
	local group = _G["TellMeWhen_Group"..groupID] or CreateFrame("Frame","TellMeWhen_Group"..groupID, UIParent, "TellMeWhen_GroupTemplate",groupID);
	TellMeWhen_Settings["Groups"][groupID] = TellMeWhen_Settings["Groups"][groupID] or TellMeWhen_Group_Defaults
	group.groupName = "TellMeWhen_Group"..groupID;
	group.resizeButton = _G[group.groupName.."_ResizeButton"];

	local locked = TellMeWhen_Settings["Locked"];
	group.genabled = TellMeWhen_Settings["Groups"][groupID]["Enabled"];
	group.scale = TellMeWhen_Settings["Groups"][groupID]["Scale"];
	group.rows = TellMeWhen_Settings["Groups"][groupID]["Rows"];
	group.columns = TellMeWhen_Settings["Groups"][groupID]["Columns"];
	group.onlyInCombat = TellMeWhen_Settings["Groups"][groupID]["OnlyInCombat"];
	
	local currentSpec = GetActiveTalentGroup();
	group.activePriSpec = TellMeWhen_Settings["Groups"][groupID]["PrimarySpec"];
	group.activeSecSpec = TellMeWhen_Settings["Groups"][groupID]["SecondarySpec"];
	group.correctspec = true
	if (currentSpec==1 and not group.activePriSpec) or (currentSpec==2 and not group.activeSecSpec) then
		group.genabled = false;
		group.correctspec = false
	end
	if LBF then
		TMWDONTRUN = true
		local lbfs = TellMeWhen_Settings["Groups"][groupID]["LBF"]
		LBF:Group("TellMeWhen", L["GROUP"] .. groupID)
		if lbfs.SkinID then
			LBF:Group("TellMeWhen", L["GROUP"] .. groupID):Skin(lbfs.SkinID,lbfs.Gloss,lbfs.Backdrop,lbfs.Colors)
		end
	end
	if (group.genabled) then
		for row = 1, group.rows do
			for column = 1, group.columns do
				local iconID = (row-1)*group.columns + column;
				local iconName = group.groupName.."_Icon"..iconID;
				local icon = _G[iconName] or CreateFrame("Button", iconName, group, "TellMeWhen_IconTemplate",iconID);
				local powerbarname = iconName.."_PowerBar";
				local cooldownbarname = iconName.."_CooldownBar";
				icon.powerbar = icon.powerbar or CreateFrame("StatusBar",powerbarname,icon)
				icon.cooldownbar = icon.cooldownbar or CreateFrame("StatusBar",cooldownbarname,icon)
				icon:Show();
				if ( column > 1 ) then
					icon:SetPoint("TOPLEFT", _G[group.groupName.."_Icon"..(iconID-1)], "TOPRIGHT", TELLMEWHEN_ICONSPACING, 0);
				elseif ( row > 1 ) and ( column == 1 ) then
					icon:SetPoint("TOPLEFT", _G[group.groupName.."_Icon"..(iconID-group.columns)], "BOTTOMLEFT", 0, -TELLMEWHEN_ICONSPACING);
				elseif ( iconID == 1 ) then
					icon:SetPoint("TOPLEFT", group, "TOPLEFT");
				end
				TellMeWhen_Icon_Update(icon, groupID, iconID);
				if ( not group.genabled ) then
					TellMeWhen_Icon_ClearScripts(icon);
				end
				
			end
		end
		for iconID = group.rows*group.columns+1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
			local icon = _G[group.groupName.."_Icon"..iconID];
			if icon then
				icon:Hide();
				TellMeWhen_Icon_ClearScripts(icon);
			end
		end

		group:SetScale(group.scale);
		group.p = TellMeWhen_Settings["Groups"][groupID]["Point"] or {}
		if group.p.x then
			group:ClearAllPoints()
			group:SetPoint(group.p.point,UIParent,group.p.relativePoint,group.p.x,group.p.y)
		else
			group:ClearAllPoints()
			if groupID > 16 then
				group:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 400, (-20 - (30*(groupID-16))));
			elseif groupID > 8 then
				group:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 250, (-20 - (30*(groupID-8))));
			else
				group:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 100, (-20 - (30*groupID)));
			end
			group.p.point,_,group.p.relativePoint,group.p.x,group.p.y = group:GetPoint(1)
		end
		local lastIcon = group.groupName.."_Icon"..(group.rows*group.columns);
		group.resizeButton:SetPoint("BOTTOMRIGHT", lastIcon, "BOTTOMRIGHT", 3, -3);
		if ( locked ) then
			group.resizeButton:Hide();
		else
			group.resizeButton:Show();
		end
		
		TellMeWhen_Stance_Check(group)
	end -- Enabled

	if ( group.onlyInCombat and group.genabled and locked ) then
		group:RegisterEvent("PLAYER_REGEN_ENABLED");
		group:RegisterEvent("PLAYER_REGEN_DISABLED");
		group:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
		group:RegisterEvent("UPDATE_SHAPESHIFT_FORMS");
		group.combatcheck = true
		group:Hide();
	elseif (group.genabled and locked) then
		group:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
		group:RegisterEvent("UPDATE_SHAPESHIFT_FORMS");
		group.combatcheck = false
		group:Show();
	else
		group:UnregisterAllEvents();
		group.combatcheck = false
		if ( group.genabled ) then
			group:Show();
		else
			group:Hide();
		end
	end
	
	group:SetScript("OnEvent", TellMeWhen_Group_OnEvent)
end


-- -------------
-- ICON FUNCTION
-- -------------
TellMeWhen_ConditionIcons = {}

function TellMeWhen_Icon_Update(icon, groupID, iconID)
	local iconSettings 		= TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID];
	local Enabled 			= iconSettings.Enabled;
	icon.iconType 			= iconSettings.Type;
	local CooldownType 		= iconSettings.CooldownType;
	icon.CooldownShowWhen 	= iconSettings.CooldownShowWhen;
	icon.BuffShowWhen 		= iconSettings.BuffShowWhen;
	local Conditions 		= iconSettings.Conditions;
	local ConditionPresent 	= false;
	icon.Name 				= iconSettings.Name;
	icon.Unit 				= iconSettings.Unit;
	icon.UnitReact 			= iconSettings.UnitReact;
	icon.ShowTimer 			= iconSettings.ShowTimer;
	icon.ShowTimerText		= iconSettings.ShowTimerText
	icon.ShowPBar 			= iconSettings.ShowPBar;
	icon.ShowCBar 			= iconSettings.ShowCBar;
	icon.InvertBars 		= iconSettings.InvertBars;
	icon.OnlyMine 			= iconSettings.OnlyMine;
	icon.BuffOrDebuff 		= iconSettings.BuffOrDebuff;
	icon.WpnEnchantType 	= iconSettings.WpnEnchantType;
	icon.RangeCheck			= iconSettings.RangeCheck;
	icon.ManaCheck			= iconSettings.ManaCheck;
	icon.Alpha 				= iconSettings.Alpha;
	icon.UnAlpha 			= iconSettings.UnAlpha;
	icon.StackMin			= iconSettings.StackMin or 0;
	icon.StackMax			= iconSettings.StackMax or 1000;
	icon.FakeHidden			= iconSettings.FakeHidden
	icon.CooldownCheck		= iconSettings.CooldownCheck
	icon.IsChakra			= nil
	icon.ChakraActive 		= true
	icon.Width				= icon.Width or 36 
	icon.Height				= icon.Height or 36 
	
	TellMeWhen_Settings["Interval"] = TellMeWhen_Settings["Interval"] or TELLMEWHEN_UPDATE_INTERVAL
	icon.updateTimer = TellMeWhen_Settings["Interval"];

	icon.texture = _G[icon:GetName().."Icon"];
	icon.countText = _G[icon:GetName().."Count"];
	icon.Cooldown = _G[icon:GetName().."Cooldown"];
	icon.Cooldown.noCooldownCount = not icon.ShowTimerText
	icon.Cooldown:SetFrameLevel(icon:GetFrameLevel() + 1)
	icon.Cooldown:SetDrawEdge(TellMeWhen_Settings["DrawEdge"])

	--LBF STUFF
	if LBF then
		TMWDONTRUN = true -- TellMeWhen_Update() is runned in the LBF skin callback, which just causes an infinite loop. This tells it not to
		local lbfs = TellMeWhen_Settings["Groups"][groupID]["LBF"]
		LBF:Group("TellMeWhen", L["GROUP"] .. groupID):AddButton(icon);
		local SkID = lbfs.SkinID or "Blizzard"
		local tab = LBF:GetSkins()
		if tab and SkID then
			if SkID == "Blizzard" then --blizzard needs custom overlay bar sizes because of the borders, other skins might like to use this too
				icon.Width = (tab[SkID].Icon.Width)*0.9
				icon.Height = (tab[SkID].Icon.Height)*0.9
			else
				icon.Width = tab[SkID].Icon.Width
				icon.Height = tab[SkID].Icon.Height
			end
		end
	else
		icon.Width = 36*0.9
		icon.Height = 36*0.9
	end
	
	icon:UnregisterAllEvents();
	icon.countText:Hide();
	
	if (Conditions ~= nil and #Conditions > 0) then
		ConditionPresent = true;
	end
	if (ConditionPresent) then
		icon.conditionPresent = ConditionPresent;
		icon.conditions = Conditions;
	else
		icon.conditionPresent = false;
	end
	if ( TellMeWhen_Settings["Locked"] and not Enabled) then
		TellMeWhen_Icon_ClearScripts(icon);
	else
		if Enabled then
			local isin = false
			for k,v in pairs(TellMeWhen_ConditionIcons) do
				if TellMeWhen_ConditionIcons[k] == icon:GetName() then
					isin = true
				end
			end
			if not isin then
				tinsert(TellMeWhen_ConditionIcons,icon:GetName())
			end
		end
		-- used by both cooldown and reactive icons
		if ( icon.CooldownShowWhen == "usable" ) then
			icon.usableAlpha = (1 * icon.Alpha);
			icon.unusableAlpha = (0 * icon.UnAlpha);
		elseif ( icon.CooldownShowWhen == "unusable" ) then
			icon.usableAlpha = (0 * icon.Alpha); --hey, you never know, multiplying by zero might become useful in the future
			icon.unusableAlpha = (1 * icon.UnAlpha);
		elseif ( icon.CooldownShowWhen == "always") then
			icon.usableAlpha = (1 * icon.Alpha);
			icon.unusableAlpha = (1 * icon.UnAlpha);
		else
			error("Alpha not assigned: "..icon.Name);
			icon.usableAlpha = (1 * icon.Alpha);
			icon.unusableAlpha = (1 * icon.UnAlpha);
		end
		-- used by both buff/debuff and wpnenchant icons
		if ( icon.BuffShowWhen == "present" ) then
			icon.presentAlpha = (1 * icon.Alpha);
			icon.absentAlpha = (0 * icon.UnAlpha);
		elseif ( icon.BuffShowWhen == "absent" ) then
			icon.presentAlpha = (0 * icon.Alpha);
			icon.absentAlpha = (1 * icon.UnAlpha);
		elseif ( icon.BuffShowWhen == "always") then
			icon.presentAlpha = (1 * icon.Alpha);
			icon.absentAlpha = (1 * icon.UnAlpha);
			--SendChatMessage("Alpha always assigned to: "..icon.Name);
		else
			error("Alpha not assigned: "..icon.Name);
			icon.presentAlpha = (1 * icon.Alpha);
			icon.absentAlpha = (1 * icon.UnAlpha);
		end


		if ( icon.iconType == "cooldown" ) then
-- --------------				
-- SPELL COOLDOWN
-- --------------			
			if ( CooldownType == "spell" ) then
				icon.namefirst = TellMeWhen_GetSpellNames(icon,icon.Name,1)
				icon.namename = TellMeWhen_GetSpellNames(icon,icon.Name,1,true)
				
				icon.texture:SetTexture(GetSpellTexture(icon.namefirst) or "Interface\\Icons\\INV_Misc_QuestionMark");
				icon:SetScript("OnUpdate", TellMeWhen_Icon_SpellCooldown_OnUpdate);
				TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
			--	icon:RegisterEvent("PET_BAR_UPDATE");
				icon:RegisterEvent("ACTIONBAR_UPDATE_USABLE");
				icon:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
				icon:SetScript("OnEvent", TellMeWhen_Icon_SpellCooldown_OnEvent);
				TellMeWhen_Icon_StatusCheck(icon, icon.iconType, CooldownType);
-- --------------				
-- ITEM COOLDOWN
-- --------------					
			elseif ( CooldownType == "item" ) then
				icon.namefirst = TellMeWhen_GetItemIDs(icon,icon.Name,1)
				icon.ShowPBar = false;
				icon.powerbar:Hide();
				TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
				if not icon.namefirst then
					return  --silently error, this will be recalled again and everything should be fine.
				end
				local itemName, itemLink, _, _, _, _, _, _, _, itemTexture = GetItemInfo(icon.namefirst)
				icon:SetScript("OnUpdate", TellMeWhen_Icon_ItemCooldown_OnUpdate)
				if ( itemName ) then
					icon.texture:SetTexture(itemTexture);
					if (icon.ShowTimer) then
						icon:RegisterEvent("BAG_UPDATE_COOLDOWN");
						icon:SetScript("OnEvent", TellMeWhen_Icon_ItemCooldown_OnEvent);
					else
						icon:SetScript("OnEvent", nil);
					end
				else
					TellMeWhen_Icon_ClearScripts(icon);
					icon.learnedTexture = false;
					icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
				end
			end
			icon.Cooldown:SetReverse(false);
			TellMeWhen_Icon_StatusCheck(icon, icon.iconType, CooldownType);
-- --------------				
-- BUFF
-- --------------
		elseif ( icon.iconType == "buff" ) then
			icon.namefirst = TellMeWhen_GetSpellNames(icon,icon.Name,1)
			icon.namename = TellMeWhen_GetSpellNames(icon,icon.Name,1,1)
			icon.namelist = TellMeWhen_GetSpellNames(icon,icon.Name)
			icon.filter = icon.BuffOrDebuff;
			if icon.OnlyMine then icon.filter = icon.filter.."|PLAYER" end
			TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
			icon:SetScript("OnUpdate",TellMeWhen_Icon_Buff_OnUpdate)
			local name = icon.namefirst
			icon.countText:Show()
			if ( icon.Name == "" ) then
				icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
			elseif ( GetSpellTexture(name) ) then
				icon.texture:SetTexture(GetSpellTexture(name));
			elseif ( not icon.learnedTexture ) then
				icon.texture:SetTexture("Interface\\Icons\\INV_Misc_PocketWatch_01");
			end
			icon.Cooldown:SetReverse(true);
			TellMeWhen_Icon_StatusCheck(icon, icon.iconType);
-- --------------				
-- REACTIVE
-- --------------
		elseif ( icon.iconType == "reactive" ) then
			icon.namefirst = TellMeWhen_GetSpellNames(icon,icon.Name,1)
			icon.namename = TellMeWhen_GetSpellNames(icon,icon.Name,1,true)

			TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
			if ( GetSpellTexture(icon.namefirst) ) then
				icon.texture:SetTexture(GetSpellTexture(icon.namefirst));
				icon:SetScript("OnUpdate", TellMeWhen_Icon_Reactive_OnUpdate);
			else
				TellMeWhen_Icon_ClearScripts(icon);
				icon.learnedTexture = false;
				icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
			end
		--	icon:RegisterEvent("PET_BAR_UPDATE");
			icon:RegisterEvent("ACTIONBAR_UPDATE_USABLE");
			icon:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
			icon:SetScript("OnEvent", TellMeWhen_Icon_SpellCooldown_OnEvent);
			TellMeWhen_Icon_StatusCheck(icon, icon.iconType);

		
-- --------------				
-- WEP ENCHANT
-- --------------	
		elseif ( icon.iconType == "wpnenchant" ) then	
			icon.namefirst = TellMeWhen_GetSpellNames(icon,icon.Name,1)
			
			icon.ShowPBar = false;
			icon.ShowCBar = false;			
			TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
			icon:RegisterEvent("UNIT_INVENTORY_CHANGED");
			local slotID;
			icon.countText:Show()
			if ( icon.WpnEnchantType == "mainhand" ) then
				slotID = GetInventorySlotInfo("MainHandSlot");
			elseif ( icon.WpnEnchantType == "offhand" ) then
				slotID = GetInventorySlotInfo("SecondaryHandSlot");
			end
			local wpnTexture = GetInventoryItemTexture("player", slotID);
			if ( wpnTexture ) then
				icon.texture:SetTexture(wpnTexture);
				icon:SetScript("OnEvent", TellMeWhen_Icon_WpnEnchant_OnEvent);
				icon:SetScript("OnUpdate", TellMeWhen_Icon_WpnEnchant_OnUpdate);
			else
				TellMeWhen_Icon_ClearScripts(icon);
				icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
			end
	
-- --------------				
-- TOTEM
-- --------------	
		elseif ( icon.iconType == "totem" ) then
			icon.namefirst = TellMeWhen_GetSpellNames(icon,icon.Name,1)
			icon.namename = TellMeWhen_GetSpellNames(icon,icon.Name,1,true)
			icon.namelist = TellMeWhen_GetSpellNames(icon,icon.Name)
		
			icon.ShowPBar = false;
			TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
		
		
			icon:SetScript("OnUpdate", TellMeWhen_Icon_Totem_OnUpdate);
			TellMeWhen_Icon_Totem_OnUpdate(icon);
			if ( icon.Name == "" ) then
				icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
				icon.learnedTexture = false;
			elseif ( GetSpellTexture(icon.namefirst) ) then
				icon.texture:SetTexture(GetSpellTexture(icon.namefirst));
			elseif ( not icon.learnedTexture ) then
				icon.texture:SetTexture("Interface\\Icons\\INV_Misc_PocketWatch_01");
			end

		else
			icon.ShowPBar = false;
			icon.ShowCBar = false;
			TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
			TellMeWhen_Icon_ClearScripts(icon);
			if ( icon.Name ~= "" ) then
				icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
			else
				icon.texture:SetTexture(nil);
			end
		end
	end -- Enabled CHECK

	
	icon.Cooldown:Hide();


	
	
	if ( Enabled ) then
		icon:SetAlpha(1.0);
	else
		icon:SetAlpha(0.4);
		TellMeWhen_Icon_ClearScripts(icon);
	end

	icon:Show();
	if ( TellMeWhen_Settings["Locked"] ) then
		icon:DisableDrawLayer("BACKGROUND")
		icon:EnableMouse(0);
		if ( not Enabled ) then
			icon:Hide();
			icon.powerbar:Hide();
			icon.cooldownbar:Hide();
		elseif (icon.Name == "") and ( icon.iconType ~= "wpnenchant" ) then
			icon:Hide();
		end
		icon.powerbar:SetValue(0);
		icon.cooldownbar:SetValue(0);
		icon.powerbar:SetAlpha(.9)

	
	else
		if ( not icon.texture:GetTexture() ) then
			icon:EnableDrawLayer("BACKGROUND")
		else
			icon:DisableDrawLayer("BACKGROUND")
		end
		if not icon.cooldownbar.texture then
			icon.cooldownbar.texture = icon.cooldownbar:CreateTexture()
		end
		if not icon.powerbar.texture then
			icon.powerbar.texture = icon.powerbar:CreateTexture()
		end
		icon.cooldownbar:SetMinMaxValues(0,  1)
		icon.cooldownbar:SetValue(2000000)
		icon.cooldownbar:SetStatusBarColor(0, 1, 0, 0.5)
		icon.cooldownbar.texture:SetTexCoord(0, 1, 0, 1)
		icon.powerbar:SetValue(20000)
		icon.powerbar:SetAlpha(.5)
		icon.powerbar.texture:SetTexCoord(0, 1, 0, 1)
		icon:EnableMouse(1);
		icon.texture:SetVertexColor(1, 1, 1, 1);
		TellMeWhen_Icon_ClearScripts(icon);
	end
end

function TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
	local iconSettings = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID];
	if icon.ShowPBar or icon.ShowCBar then
		local groupName = "TellMeWhen_Group"..groupID;
		local iconName = groupName.."_Icon"..iconID;
		local genabled = TellMeWhen_Settings["Groups"][groupID]["Enabled"];
		local locked = TellMeWhen_Settings["Locked"];
		local onlyInCombat = TellMeWhen_Settings["Groups"][groupID]["OnlyInCombat"];
		local width, height = icon:GetSize()
		local scale = TellMeWhen_Settings["Groups"][groupID]["Scale"];
		if not TellMeWhen_Settings["Texture"] then
			TellMeWhen_Settings["Texture"] = "Interface\\TargetingFrame\\UI-StatusBar";
		end
		if not TellMeWhen_Settings["TextureName"] then
			TellMeWhen_Settings["TextureName"] = "Blizzard";
		end
		local tex = TellMeWhen_Settings["Texture"]
		if icon.ShowPBar then
			local _,_,_,cost,_,powerType = GetSpellInfo(icon.namefirst);
			if cost == nil then cost = 0 end
			local powerbarname = iconName.."_PowerBar";
			if not icon.powerbar then
				icon.powerbar = CreateFrame("StatusBar",powerbarname,icon)
			end
			icon.powerbar:SetSize(width*(icon.Width/36), ((height / 2)*(icon.Height/36))-0.5);
			icon.powerbar:SetPoint("BOTTOM",icon,"CENTER",0,0.5)--(((height/2)*(icon.Height/36))-(icon.cooldownbar:GetHeight() )));
			if cost then
				icon.powerbar:SetMinMaxValues(0, cost);
			end
			if not icon.powerbar.texture then
				icon.powerbar.texture = icon.powerbar:CreateTexture()
			end
			icon.powerbar.texture:SetTexture(tex);
			if powerType then
				local colorinfo = PowerBarColor[powerType];
				icon.powerbar.texture:SetVertexColor(colorinfo.r, colorinfo.g, colorinfo.b, 0.9);
			end
			icon.powerbar:SetStatusBarTexture(icon.powerbar.texture);
			icon.powerbar:SetFrameLevel(icon:GetFrameLevel() + 2);
		end
		if icon.ShowCBar then
			local cooldownbarname = iconName.."_CooldownBar";
			icon.cooldownbar = icon.cooldownbar or CreateFrame("StatusBar",cooldownbarname,icon);
			icon.cooldownbar:SetSize(width*(icon.Width/36), ((height / 2)*(icon.Height/36))-0.5);
			icon.cooldownbar:SetPoint("TOP",icon,"CENTER",0,-0.5)---(((height/2)*(icon.Height/36))-(icon.cooldownbar:GetHeight() )));
			icon.cooldownbar.texture = icon.cooldownbar.texture or icon.cooldownbar:CreateTexture();
			icon.cooldownbar.texture:SetTexture(tex);
			icon.cooldownbar:SetStatusBarTexture(icon.cooldownbar.texture);
			icon.cooldownbar:SetFrameLevel(icon:GetFrameLevel() + 2);
			icon.cooldownbar:SetMinMaxValues(0,  1)
		end
	end
	if not icon.ShowPBar then
		icon.powerbar:Hide();
	else
		icon.powerbar:Show()
	end
	if not icon.ShowCBar then
		icon.cooldownbar:Hide();
	else
		icon.cooldownbar:Show()
	end
end

local function Reaction(unit)
	local reaction = UnitIsEnemy("player", unit);
	local react = UnitReaction("player", unit) or 5;
	if (reaction) or (react <= 4) then
		return 1;
	else
		return 2;
	end
end

function TellMeWhen_Icon_ClearScripts(icon)
	icon:SetScript("OnEvent", nil);
	icon:SetScript("OnUpdate", nil);
end

local function GetGCD()
	local _,ret=GetSpellCooldown(defaultSpell)
	return ret
end

local function ConditionCheck(icon)
	local retCode = true;
	for i=1,#icon.conditions do
		retCode = TMW_AO[icon.conditions[i].ConditionAndOr](retCode,TMW_CNDT[icon.conditions[i].ConditionType](icon.conditions[i])) -- have fun figuring this one out
	end
	return retCode;
end

function TellMeWhen_Icon_StatusCheck(icon, iconType, CooldownType)
	-- this function is so OnEvent-based icons can do a check when the addon is locked
	-- the 1s trick it into thinking that it has been a long time since the last onupdate and so it will run the whole function.
	if ( iconType == "reactive" ) then
		TellMeWhen_Icon_Reactive_OnUpdate(icon,1)
	elseif ( iconType == "buff" ) then
		TellMeWhen_Icon_Buff_OnUpdate(icon,1);
	elseif ( iconType == "cooldown" ) then
		if (CooldownType == "spell") then
			TellMeWhen_Icon_SpellCooldown_OnUpdate(icon,1);
			TellMeWhen_Icon_SpellCooldown_OnEvent(icon)
		elseif (CooldownType == "item") then
			TellMeWhen_Icon_ItemCooldown_OnUpdate(icon,1);
			TellMeWhen_Icon_ItemCooldown_OnEvent(icon)
		end
	end
end

local function CDBarUpdate(icon,startTime,duration,buff)
	local percentcomplete = 1
	local OnGCD = GetGCD() == duration and duration > 0;
	if OnGCD and not buff and not TellMeWhen_Settings["BarGCD"] then
		duration = 0
	end
	if not icon.InvertBars then
		if (duration == 0) then
			icon.cooldownbar:SetMinMaxValues(0,  1)
			icon.cooldownbar:SetValue(0)
		else
			percentcomplete = ((GetTime() - startTime) / duration)
			icon.cooldownbar:SetMinMaxValues(0,  duration)
			icon.cooldownbar:SetValue(duration - (GetTime() - startTime))
			icon.cooldownbar.texture:SetTexCoord(0, min((1-percentcomplete),1), 0, 1)
			icon.cooldownbar:SetStatusBarColor(
				(co.r*percentcomplete) + (st.r * (1-percentcomplete)),
				(co.g*percentcomplete) + (st.g * (1-percentcomplete)),
				(co.b*percentcomplete) + (st.b * (1-percentcomplete)),
				(co.a*percentcomplete) + (st.a * (1-percentcomplete))
			)
		end
	else
		--inverted
		if (duration == 0) then
			icon.cooldownbar:SetMinMaxValues(0,  1)
			icon.cooldownbar:SetValue(1)
			icon.cooldownbar:SetStatusBarColor(co.r, co.g, co.b, co.a)
			icon.cooldownbar.texture:SetTexCoord(0, 1, 0, 1)
		else
			percentcomplete = (((GetTime() - startTime) / duration))
			icon.cooldownbar:SetMinMaxValues(0,  duration)
			icon.cooldownbar:SetValue(GetTime() - startTime)
			icon.cooldownbar.texture:SetTexCoord(0, min(percentcomplete,1), 0, 1)
			icon.cooldownbar:SetStatusBarColor(
				(co.r*percentcomplete) + (st.r * (1-percentcomplete)),
				(co.g*percentcomplete) + (st.g * (1-percentcomplete)),
				(co.b*percentcomplete) + (st.b * (1-percentcomplete)),
				(co.a*percentcomplete) + (st.a * (1-percentcomplete))
			)
		end
	end
end

local function PwrUpdate(icon,name)
	local _,_,_,cost,_,powerType = GetSpellInfo(name)
	if cost == nil then cost = 0 end
	icon.powerbar:SetMinMaxValues(0, cost);
	if not icon.InvertBars then
		icon.powerbar:SetValue(cost - UnitPower("player",powerType))
		icon.powerbar.texture:SetTexCoord(0, max(0,min(((cost - UnitPower("player",powerType)) / cost),1)), 0, 1) --more cheats
	else
		icon.powerbar:SetValue(UnitPower("player",powerType))
		icon.powerbar.texture:SetTexCoord(0, max(0,min((UnitPower("player",powerType) / cost),1)), 0, 1)			--more cheats
	end
end

function TellMeWhen_Icon_SpellCooldown_OnEvent(icon)
	local startTime, duration = GetSpellCooldown(icon.namefirst);
	if not (icon.ShowTimer) or (not TellMeWhen_Settings["ClockGCD"]) and (GetGCD() == duration and duration > 0) then return end
	if ( duration ) then
		CooldownFrame_SetTimer(icon.Cooldown, startTime, duration, 1);
	end
end
	
function TellMeWhen_Icon_SpellCooldown_OnUpdate(icon, elapsed)
	icon.updateTimer = icon.updateTimer - elapsed;
	local name = icon.namefirst
	local startTime, duration = GetSpellCooldown(name);
	if duration then
		if ( icon.conditionPresent and not ConditionCheck(icon) ) then
			icon:SetAlpha(0);
			icon.CondtShown = 0
			return;
		end
		icon.texture:SetTexture(GetSpellTexture(name));
		if icon.ShowPBar then
			PwrUpdate(icon,name)
		end
		if icon.ShowCBar then
			CDBarUpdate(icon,startTime,duration)
		end
		if ( icon.updateTimer <= 0 ) then
			icon.updateTimer = TellMeWhen_Settings["Interval"];
			
			local reaction
			if not (icon.UnitReact == 0) then
				reaction = Reaction("target");
			end
			if (icon.UnitReact == 0) or (icon.UnitReact == reaction) then
				if icon.IsChakra then
					if UnitAura("player",GetSpellInfo(chakra[icon.IsChakra]["buffid"])) then
						icon.ChakraActive = true
					else
						icon.ChakraActive = false
					end
				end
				local inrange = IsSpellInRange(icon.namename, "target");
				local _, nomana = IsUsableSpell(name);
				local OnGCD = GetGCD() == duration and duration > 0;
				local _,_,_,_,_,_,_,minRange,maxRange = GetSpellInfo(name);
				if ( not icon.RangeCheck or not maxRange or inrange == nil ) then
					inrange = 1;
				end
				if not icon.ManaCheck then
					nomana = nil
				end
				
				if ( (duration == 0 or OnGCD) and inrange == 1 and not nomana and icon.ChakraActive) then
					icon.texture:SetVertexColor(1, 1, 1, 1);
					icon:SetAlpha(icon.usableAlpha);
				elseif ( icon.usableAlpha ~= 0 and icon.ChakraActive) then
					if inrange ~= 1 then
						icon.texture:SetVertexColor(rc.r, rc.g, rc.b, 1);
						icon:SetAlpha(icon.unusableAlpha*rc.a);
					elseif nomana then
						icon.texture:SetVertexColor(mc.r, mc.g, mc.b, 1);
						icon:SetAlpha(icon.unusableAlpha*mc.a);
					elseif not icon.ShowTimer then
						icon.texture:SetVertexColor(0.5, 0.5, 0.5, 1);
						icon:SetAlpha(icon.unusableAlpha);
					else
						icon.texture:SetVertexColor(1, 1, 1, 1);
						icon:SetAlpha(icon.unusableAlpha);
					end
				else
					icon.texture:SetVertexColor(1, 1, 1, 1);
					icon:SetAlpha(icon.unusableAlpha);
				end
			else
				icon:SetAlpha(0)
			end
		end
		icon.CondtShown = icon:GetAlpha()
		if icon.FakeHidden then
			icon:SetAlpha(0)
		end
	end
end

function TellMeWhen_Icon_ItemCooldown_OnEvent(icon)
	local startTime, duration = GetItemCooldown(icon.namefirst);
	if (not TellMeWhen_Settings["ClockGCD"]) and (GetGCD() == duration and duration > 0) then return end
	if ( duration ) then
		CooldownFrame_SetTimer(icon.Cooldown, startTime, duration, 1);
	end
end

function TellMeWhen_Icon_ItemCooldown_OnUpdate(icon, elapsed)
	icon.updateTimer = icon.updateTimer - elapsed;
	local startTime, duration = GetItemCooldown(icon.namefirst);
	if icon.ShowCBar then
		CDBarUpdate(icon,startTime,duration)
	end
	if ( icon.updateTimer <= 0 ) and duration then
		icon.updateTimer = TellMeWhen_Settings["Interval"];
		if ( icon.conditionPresent and not ConditionCheck(icon) ) then
			icon:SetAlpha(0);
			icon.CondtShown = icon:GetAlpha()
			return;
		end
		local reaction
		if not (icon.UnitReact == 0) then
			reaction = Reaction("target");
		end
		if (icon.UnitReact == 0) or (icon.UnitReact == reaction) then
			local inrange = IsItemInRange(icon.namefirst, "target");
			if ( not icon.RangeCheck or inrange == nil ) then
				inrange = 1;
			end
			if ( duration == 0 or GetGCD() == duration ) and inrange == 1 then
				icon.texture:SetVertexColor(1, 1, 1, 1);
				icon:SetAlpha(icon.usableAlpha);
			elseif ( icon.usableAlpha ~= 0 ) then
				if inrange ~= 1 then
					icon.texture:SetVertexColor(rc.r, rc.g, rc.b, 1);
					icon:SetAlpha(icon.unusableAlpha*rc.a);
				elseif not icon.ShowTimer then
					icon.texture:SetVertexColor(0.5, 0.5, 0.5, 1);
					icon:SetAlpha(icon.unusableAlpha);
				else
					icon.texture:SetVertexColor(1, 1, 1, 1);
					icon:SetAlpha(icon.unusableAlpha);
				end
			else
				icon.texture:SetVertexColor(1, 1, 1, 1);
				icon:SetAlpha(icon.unusableAlpha);
			end
		else
			icon:SetAlpha(0)
		end
		icon.CondtShown = icon:GetAlpha()
		if icon.FakeHidden then
			icon:SetAlpha(0)
		end
	end
end

local id
function TellMeWhen_Icon_Buff_OnUpdate(icon, elapsed)
	local reaction
	if not (icon.UnitReact == 0) then
		reaction = Reaction(icon.Unit);
	end
	if (icon.UnitReact == 0) or (icon.UnitReact == reaction) then 
		if ( icon.conditionPresent and not ConditionCheck(icon) ) then
			icon:SetAlpha(0);
			icon.CondtShown = icon:GetAlpha()
			return;
		end
		for i, iName in ipairs(icon.namelist) do
			if tonumber(iName) then -- UnitAura requires a spell name, numbers are treated as an aura index on the unit instead of IDs.
				iNamen = GetSpellInfo(iName);
			else
				iNamen = iName;
			end
			local buffName, _, iconTexture, count, _, duration, expirationTime = UnitAura(icon.Unit, iNamen, nil, icon.filter);
			if TellMeWhen_DSN[iName] then
				for z=1,60 do --60 because i can and it breaks when there are no more buffs anyway
					buffName, _, iconTexture, count, _, duration, expirationTime,_,_,_,id = UnitAura(icon.Unit, z, icon.filter);
					if (not id) or (id == iName) then
						break;
					end
				end
			end
			if icon.ShowPBar then
				PwrUpdate(icon,iName);
			end
			if ( buffName ) then
				if count and not (icon.StackMin <= count and count <= icon.StackMax) then
					icon:SetAlpha(0);
					icon.CondtShown = 0
					return;
				end
				icon.CondtShown = icon.presentAlpha
				if icon.FakeHidden then
					icon:SetAlpha(0)
					return;
				end
				if ( icon.texture:GetTexture() ~= iconTexture) then
					icon.texture:SetTexture(iconTexture);
					icon.learnedTexture = true;
				end
				icon:SetAlpha(icon.presentAlpha);
				
				if ( icon.presentAlpha~= 0 ) and ( icon.absentAlpha~= 0) then
					icon.texture:SetVertexColor(pr.r, pr.g, pr.b, 1);
				else
					icon.texture:SetVertexColor(1, 1, 1, 1);
				end
				if ( count > 1 ) then
					icon.countText:SetText(count);
				else
					icon.countText:SetText("");
				end
				if ( icon.ShowTimer and not UnitIsDead(icon.Unit)) then
					CooldownFrame_SetTimer(icon.Cooldown, expirationTime - duration, duration, 1);
				end
				if icon.ShowCBar then
					CDBarUpdate(icon, expirationTime - duration, duration,true)
				end
				return;
			end
		end						

		icon.cooldownbar:SetValue(-1)
		
		icon:SetAlpha(icon.absentAlpha);
		if ( icon.presentAlpha~= 0 ) and ( icon.absentAlpha~= 0) then
			icon.texture:SetVertexColor(ab.r, ab.g, ab.b, 1);
		else
			icon.texture:SetVertexColor(1, 1, 1, 1);
		end

		icon.countText:SetText("");
		if ( icon.ShowTimer  ) then
			CooldownFrame_SetTimer(icon.Cooldown, 0, 0, 0);
		end
	else
		icon:SetAlpha(0);
		CooldownFrame_SetTimer(icon.Cooldown, 0, 0, 0);
	end
	icon.CondtShown = icon:GetAlpha()
	if icon.FakeHidden then
		icon:SetAlpha(0)
	end
end

function TellMeWhen_Icon_Reactive_OnUpdate(icon,elapsed)
	icon.updateTimer = icon.updateTimer - elapsed;
	local name = icon.namefirst
	local startTime, duration = GetSpellCooldown(name);
	if duration then
		if icon.ShowPBar then
			PwrUpdate(icon,name)
		end
		if icon.ShowCBar then
			CDBarUpdate(icon,startTime,duration)
		end
		if ( icon.updateTimer <= 0 ) and duration then
			icon.updateTimer = TellMeWhen_Settings["Interval"];
			if ( icon.conditionPresent and not ConditionCheck(icon) ) then
				icon:SetAlpha(0);
				icon.CondtShown = icon:GetAlpha()
				return;
			end
			local reaction
			if not (icon.UnitReact == 0) then
				reaction = Reaction("target");
			end
			if (icon.UnitReact == 0) or (icon.UnitReact == reaction) then
				local usable, nomana = IsUsableSpell(name);
				if icon.IsChakra then
					if UnitAura("player",GetSpellInfo(chakra[icon.IsChakra]["buffid"])) then
						usable = true
					else
						usable = false
					end
				end
				local inrange = IsSpellInRange(icon.namename, "target");
				local OnGCD = GetGCD() == duration and duration > 0;
				if ( not icon.RangeCheck or inrange == nil ) then
					inrange = 1
				end
				if not icon.ManaCheck then
					nomana = nil
				end
				local CD = false
				if icon.CooldownCheck then
					if not (duration == 0 or OnGCD) then
						CD = true
					end
				end
				if ( usable and not CD) then
					if( inrange == 1 and not nomana  ) then
						icon.texture:SetVertexColor(1,1,1,1)
						icon:SetAlpha(icon.usableAlpha)
					elseif ( inrange ~= 1 or nomana ) then
						if inrange ~= 1 then
							icon.texture:SetVertexColor(rc.r, rc.g, rc.b, 1);
							icon:SetAlpha(icon.usableAlpha*rc.a);
						elseif nomana then
							icon.texture:SetVertexColor(mc.r, mc.g, mc.b, 1);
							icon:SetAlpha(icon.usableAlpha*mc.a);
						end
					else
						icon.texture:SetVertexColor(1,1,1,1)
						icon:SetAlpha(icon.unusableAlpha)
					end
				else
					icon.texture:SetVertexColor(0.5,0.5,0.5,1)
					icon:SetAlpha(icon.unusableAlpha)
				end
			else
				icon:SetAlpha(0)
			end
		end
		icon.CondtShown = icon:GetAlpha()
		if icon.FakeHidden then
			icon:SetAlpha(0)
		end
	end
end

function TellMeWhen_Icon_WpnEnchant_OnEvent(icon, event, ...)
	if ( event == "UNIT_INVENTORY_CHANGED" ) and (... == "player" ) then
		local slotID;
		if ( icon.WpnEnchantType == "mainhand" ) then
			slotID = GetInventorySlotInfo("MainHandSlot");
		elseif ( icon.WpnEnchantType == "offhand" ) then
			slotID = GetInventorySlotInfo("SecondaryHandSlot");
		end
		local wpnTexture = GetInventoryItemTexture("player", slotID);
		if ( wpnTexture ) then
			icon.texture:SetTexture(wpnTexture);
		else
			icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
		end
		icon.startTime = GetTime();
	end
end

function TellMeWhen_Icon_WpnEnchant_OnUpdate(icon, elapsed)
	icon.updateTimer = icon.updateTimer - elapsed;
	if ( icon.updateTimer <= 0 ) then
		icon.updateTimer = TellMeWhen_Settings["Interval"];
		local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges, hasThrownEnchant, thrownExpiration, thrownCharges  = GetWeaponEnchantInfo();
		if ( icon.WpnEnchantType == "mainhand" ) and ( hasMainHandEnchant ) then
			if ( icon.presentAlpha~= 0 ) and ( icon.absentAlpha~= 0) then
				icon.texture:SetVertexColor(pr.r, pr.g, pr.b, 1);
			else
				icon.texture:SetVertexColor(1, 1, 1, 1);
			end
			icon:SetAlpha(icon.presentAlpha);
			if ( mainHandCharges > 1 ) then
				icon.countText:SetText(mainHandCharges);
			else
				icon.countText:SetText("");
			end
			if (icon.ShowTimer) then
				if ( icon.startTime ~= nil ) then
					CooldownFrame_SetTimer(icon.Cooldown, GetTime(), mainHandExpiration/1000, 1);
				else
					icon.startTime = GetTime();
				end
			end
		elseif ( icon.WpnEnchantType == "offhand" ) and ( hasOffHandEnchant ) then
			if ( icon.presentAlpha~= 0 ) and ( icon.absentAlpha~= 0) then
				icon.texture:SetVertexColor(pr.r, pr.g, pr.b, 1);
			else
				icon.texture:SetVertexColor(1, 1, 1, 1);
			end
			icon:SetAlpha(icon.presentAlpha);
			if ( offHandCharges > 1 ) then
				icon.countText:SetText(offHandCharges);
			else
				icon.countText:SetText("");
			end
			if (icon.ShowTimer) then
				if ( icon.startTime ~= nil ) then
					CooldownFrame_SetTimer(icon.Cooldown, GetTime(), offHandExpiration/1000, 1);
				else
					icon.startTime = GetTime();
				end
			end
		elseif ( icon.WpnEnchantType == "thrown" ) and ( hasThrownEnchant ) then
			if ( icon.presentAlpha~= 0 ) and ( icon.absentAlpha~= 0) then
				icon.texture:SetVertexColor(pr.r, pr.g, pr.b, 1);
			else
				icon.texture:SetVertexColor(1, 1, 1, 1);
			end
			icon:SetAlpha(icon.presentAlpha);
			if ( thrownCharges > 1 ) then
				icon.countText:SetText(thrownCharges);
			else
				icon.countText:SetText("");
			end
			if (icon.ShowTimer) then
				if ( icon.startTime ~= nil ) then
					CooldownFrame_SetTimer(icon.Cooldown, GetTime(), thrownExpiration/1000, 1);
				else
					icon.startTime = GetTime();
				end
			end
		else
			if ( icon.presentAlpha~= 0 ) and ( icon.absentAlpha~= 0) then
				icon.texture:SetVertexColor(ab.r, ab.g, ab.b, 1);
			else
				icon.texture:SetVertexColor(1, 1, 1, 1);
			end
			icon:SetAlpha(icon.absentAlpha);
			CooldownFrame_SetTimer(icon.Cooldown, 0, 0, 0);
		end
		icon.CondtShown = icon:GetAlpha()
		if icon.FakeHidden then
			icon:SetAlpha(0)
		end
	end
end

function TellMeWhen_Icon_Totem_OnUpdate(icon, event, ...)
	local foundTotem = false
	for iSlot=1, 4 do
		local _, totemName, startTime, totemDuration, totemIcon = GetTotemInfo(iSlot)
		for i, iName in ipairs(icon.namelist) do
			if ( totemName and totemName:find(iName) ) then
				if icon.ShowPBar then
					PwrUpdate(icon,iName)
				end
				if icon.ShowCBar then
					CDBarUpdate(icon,startTime,totemDuration,1)
				end
				foundTotem = true;
				if ( icon.presentAlpha~= 0 ) and ( icon.absentAlpha~= 0) then
					icon.texture:SetVertexColor(pr.r, pr.g, pr.b, 1);
				else
					icon.texture:SetVertexColor(1, 1, 1, 1);
				end
				icon:SetAlpha(icon.presentAlpha);

				if ( icon.texture:GetTexture() ~= totemIcon ) then
					icon.texture:SetTexture( totemIcon );
					icon.learnedTexture = true;
				end

				if ( icon.ShowTimer ) then
					CooldownFrame_SetTimer(icon.Cooldown, startTime, totemDuration, 1);
				end
				break
			end
		end
	end
	if (not foundTotem) then
		icon.texture:SetTexture( GetSpellTexture(icon.namename) );
		if ( icon.presentAlpha~= 0 ) and ( icon.absentAlpha~= 0) then
			icon.texture:SetVertexColor(ab.r, ab.g, ab.b, 1);
		else
			icon.texture:SetVertexColor(1, 1, 1, 1);
		end
		icon:SetAlpha(icon.absentAlpha);
		CooldownFrame_SetTimer(icon.Cooldown, 0, 0, 0);
	end
	icon.CondtShown = icon:GetAlpha()
	if icon.FakeHidden then
		icon:SetAlpha(0)
	end
end



do
	TMW_CNDT.HEALTH = function(condition)
		local percent = 100 * UnitHealth(condition.ConditionUnit)/UnitHealthMax(condition.ConditionUnit);
		return TMW_OP[condition.ConditionOperator](condition.ConditionLevel, percent);
	end
	TMW_CNDT.DEFAULT = function(condition)
		local percent = 100 * UnitPower(condition.ConditionUnit)/UnitPowerMax(condition.ConditionUnit);
		return TMW_OP[condition.ConditionOperator](condition.ConditionLevel, percent);
	end
	TMW_CNDT.MANA = function(condition)
		local percent = 100 * UnitPower(condition.ConditionUnit,0)/UnitPowerMax(condition.ConditionUnit,0);
		return TMW_OP[condition.ConditionOperator](condition.ConditionLevel, percent);
	end
	TMW_CNDT.RAGE = function(condition)
		local percent = 100 * UnitPower(condition.ConditionUnit,1)/UnitPowerMax(condition.ConditionUnit,1);
		return TMW_OP[condition.ConditionOperator](condition.ConditionLevel, percent);
	end
	TMW_CNDT.FOCUS = function(condition)
		local percent = 100 * UnitPower(condition.ConditionUnit,2)/UnitPowerMax(condition.ConditionUnit,2);
		return TMW_OP[condition.ConditionOperator](condition.ConditionLevel, percent);
	end
	TMW_CNDT.ENERGY = function(condition)
		local percent = 100 * UnitPower(condition.ConditionUnit,3)/UnitPowerMax(condition.ConditionUnit,3);
		return TMW_OP[condition.ConditionOperator](condition.ConditionLevel, percent);
	end
	TMW_CNDT.RUNIC_POWER = function(condition)
		local percent = 100 * UnitPower(condition.ConditionUnit,6)/UnitPowerMax(condition.ConditionUnit,6);
		return TMW_OP[condition.ConditionOperator](condition.ConditionLevel, percent);
	end
	TMW_CNDT.HAPPINESS = function(condition)
		local number = GetPetHappiness() or 0
		return TMW_OP[condition.ConditionOperator](condition.ConditionLevel, number);
	end
	TMW_CNDT.SOUL_SHARDS = function(condition)
		local number = UnitPower("player",7);
		return TMW_OP[condition.ConditionOperator](condition.ConditionLevel, number);
	end
	TMW_CNDT.ECLIPSE = function(condition)
		local percent = 100 * UnitPower(condition.ConditionUnit,8)/UnitPowerMax(condition.ConditionUnit,8);
		return TMW_OP[condition.ConditionOperator](condition.ConditionLevel, percent);
	end
	TMW_CNDT.HOLY_POWER = function(condition)
		local number = UnitPower("player",9);
		return TMW_OP[condition.ConditionOperator](condition.ConditionLevel, number);
	end
	TMW_CNDT.ECLIPSE_DIRECTION = function(condition)
		if condition.ConditionLevel < 0 then return GetEclipseDirection() == "moon"
		elseif condition.ConditionLevel > 0 then return GetEclipseDirection() == "sun"
		else return false end
	end
	TMW_CNDT.ICON = function(condition)
		local icon = _G[condition.ConditionIcon]
		if icon then return (icon:GetParent():IsShown() and ((icon.CondtShown or 0) > 0)) else return false end
	end
	TMW_CNDT.COMBO = function(condition)
		local number = GetComboPoints("player",condition.ConditionUnit)
		return TMW_OP[condition.ConditionOperator](condition.ConditionLevel, number);
	end
	TMW_CNDT.EXISTS = function(condition)
		return UnitExists(condition.ConditionUnit)
	end
	TMW_CNDT.ALIVE = function(condition)
		return not UnitIsDeadOrGhost(condition.ConditionUnit)
	end
	
	
	TMW_OP["=="] = function(level, percent)
		return percent == level;
	end
	TMW_OP["<"] = function(level, percent)
		return percent < level;
	end
	TMW_OP["<="] = function(level, percent)
		return percent <= level;
	end
	TMW_OP[">"] = function(level, percent)
		return percent > level;
	end
	TMW_OP[">="] = function(level, percent)
		return percent >= level;
	end
	TMW_OP["~="] = function(level, percent)
		return percent ~= level;
	end
	
	TMW_AO["OR"] = function(old,new)
		return (old or new)
	end
	TMW_AO["AND"] = function(old,new)
		return (old and new)
	end
end


function TellMeWhen_GetSpellNames(icon,buffName,firstOnly,toname)
	local buffNames = {}
	if (TMW_BE.buffs[buffName]) then
		 buffNames = TellMeWhen_SplitNames(TMW_BE.buffs[buffName],"spell");
	elseif (TMW_BE.debuffs[buffName]) then
		buffNames = TellMeWhen_SplitNames(TMW_BE.debuffs[buffName],"spell");
	else
		 buffNames = TellMeWhen_SplitNames(buffName,"spell")
	end
	for k,v in pairs(buffNames) do
		buffNames[k] = tonumber(buffNames[k]) or buffNames[k]
	end
	icon.IsChakra = nil
	for k,v in pairs(chakra) do
		if GetSpellInfo(v.abid) == buffNames[1] then
			buffNames[1] = v.abid
			icon.IsChakra = k
		end
		if v.abid == tonumber(buffNames[1]) then
			icon.IsChakra = k
		end
	end
	if toname then
		return GetSpellInfo(buffNames[1])
	end
	if ( firstOnly ) then
		return buffNames[1]
	end
	return buffNames
end

function TellMeWhen_GetItemIDs(icon,buffName,firstOnly)
	local buffNames = {}
	buffNames = TellMeWhen_SplitNames(buffName,"item")
	if ( firstOnly ) then
		return buffNames[1]
	end
	return buffNames
end

function TellMeWhen_SpaceRemove(str)
	if strfind(str, "^ ") then
		str = gsub(str,"^ ","")
	end
	if strfind(str, " $") then
		str = gsub(str," $","")
	end
	local beg = strfind(str, "^ ")
	local last = strfind(str, " $")
	if (not beg) and (not last) then
		return str 
	else
		return TellMeWhen_SpaceRemove(str)
	end
end

function TellMeWhen_SplitNames(buffName,convertIDs)
	local buffNames = {}
	-- If buffName contains one or more semicolons, split the list into parts
	if (buffName:find(";") ~= nil) then
		buffNames = { strsplit(";", buffName) }
	else
		buffNames = { buffName }
	end
	for a,b in pairs(buffNames) do --remove spaces from the beginning and end of each name
		local new = strtrim(tostring(b)) or error("Error removing spaces from:" .. a .. ":" .. b ..":.")
		buffNames[a] = tonumber(new) or tostring(new)
	end
	if (convertIDs == "item") then
		for k,v in ipairs(buffNames) do
			if (tonumber( v ) == nil) then
				local _,itemLink = GetItemInfo(v)
				local itemID
				if itemLink then
					_, _, itemID = string.find(itemLink, ":(%d+)")
				end
				buffNames[k] = itemID
			end
		end
	end
	return buffNames
end

function TellMeWhen_SkinCallback(arg, SkinID, Gloss, Backdrop, Group, Button, Colors)
	
	if Group and SkinID then
		local groupID = tonumber(strmatch(Group,"%d+")) --Group is a string like "Group 5", so cant use :GetID()
		TellMeWhen_Settings["Groups"][groupID]["LBF"]["SkinID"] = SkinID
		TellMeWhen_Settings["Groups"][groupID]["LBF"]["Gloss"] = Gloss
		TellMeWhen_Settings["Groups"][groupID]["LBF"]["Backdrop"] = Backdrop
		TellMeWhen_Settings["Groups"][groupID]["LBF"]["Colors"] = Colors
	end
	if not TMWDONTRUN then
		TellMeWhen_Update()
	else
		TMWDONTRUN = false
	end
end














