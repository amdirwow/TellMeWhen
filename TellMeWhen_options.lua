local LSM = LibStub("LibSharedMedia-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TellMeWhen", true)
local oldprint = print

local function print(...)
	if not TellMeWhen_Settings or TellMeWhen_Settings["TESTON"] then
		oldprint("|cffff0000TMW:|r ", ...)
	end
end

function TellMeWhen_SlashCommand(cmd)
	if ( cmd == L["CMD_RESET"] ) then
		TellMeWhen_Reset();
	elseif (cmd == L["CMD_OPTIONS"]) then
		TellMeWhen_ShowConfig();
	else
		TellMeWhen_LockToggle();
	end
end


-- -----------------------
-- ПАНЕЛИ ОПЦИЙ
-- -----------------------



--ADD ANY NEW STANCES THE THE >>>END<<< OF EACH CLASSES' SECTION
--STANCES WILL NEED TO BE RESET FOR A CLASS IF THEY LOSE A STANCE
TellMeWhen_Stances = {
	{class = "WARRIOR", name = "Battle Stance", id = 2457},
	{class = "WARRIOR", name = "Defensive Stance", id = 71},
	{class = "WARRIOR", name = "Berserker Stance", id = 2458},
	
	{class = "DRUID", name = "Bear Form", id = 5487},
	{class = "DRUID", name = "Cat Form", id = 768},
	{class = "DRUID", name = "Aquatic Form", id = 1066},
	{class = "DRUID", name = "Travel Form", id = 783},
	{class = "DRUID", name = "Moonkin Form", id = 24858},
	{class = "DRUID", name = "Tree of Life", id = 33891},
	{class = "DRUID", name = "Flight Form", id = 33943},
	{class = "DRUID", name = "Swift Flight Form", id = 40120},
	
	{class = "PRIEST", name = "Shadowform", id = 15473},
	
	{class = "ROGUE", name = "Stealth", id = 1784},

	{class = "HUNTER", name = "Aspect of the Fox", id = 82661},
	{class = "HUNTER", name = "Aspect of the Hawk", id = 13165},
	{class = "HUNTER", name = "Aspect of the Cheetah", id = 5118},
	{class = "HUNTER", name = "Aspect of the Pack", id = 13159},
	{class = "HUNTER", name = "Aspect of the Wild", id = 20043},
	
	{class = "DEATHKNIGHT", name = "Blood Presence", id = 48263},
	{class = "DEATHKNIGHT", name = "Frost Presence", id = 48266},
	{class = "DEATHKNIGHT", name = "Unholy Presence", id = 48265},
	
	{class = "PALADIN", name = "Concentration Aura", id = 19746},
	{class = "PALADIN", name = "Crusader Aura", id = 32223},
	{class = "PALADIN", name = "Devotion Aura", id = 465},
	{class = "PALADIN", name = "Resistance Aura", id = 19891},
	{class = "PALADIN", name = "Retribution Aura", id = 7294},
	
	{class = "WARLOCK", name = "Metamorphosis", id = 47241},
}

TellMeWhen_CurrentStances = {
	[0] = 0,
}

local _,pclass = UnitClass("Player")

TellMeWhen_CurrentStancesn = {
	[0] = L["NONE"],
}
if pclass == "DRUID" then
	TellMeWhen_CurrentStancesn[0] = L["CASTERFORM"]
end


for k,v in pairs(TellMeWhen_Stances) do
	if TellMeWhen_Stances[k]["class"] == pclass then
		local zz = GetSpellInfo(TellMeWhen_Stances[k]["id"])
		tinsert(TellMeWhen_CurrentStances,TellMeWhen_Stances[k]["id"])
		tinsert(TellMeWhen_CurrentStancesn,zz)
	end
end

function TellMeWhen_GroupPositionReset_OnClick(groupID)
	local group = _G["TellMeWhen_Group"..groupID];
	TellMeWhen_Settings["Groups"][groupID]["Scale"] = 2.0
	TellMeWhen_Update();
	group:SetPoint("CENTER", "UIParent", "CENTER", 0, 0);
	group.p = TellMeWhen_Settings["Groups"][groupID]["Point"]
	group.p.point,_,group.p.relativePoint,group.p.x,group.p.y = group:GetPoint(1)
	DEFAULT_CHAT_FRAME:AddMessage(format(L["GROUPRESETMSG"],groupID));
end

function TellMeWhen_LockToggle()
	if not UnitAffectingCombat("player") then
		if ( TellMeWhen_Settings["Locked"] ) then
			TellMeWhen_Settings["Locked"] = false;
		else
			TellMeWhen_Settings["Locked"] = true;
		end
		PlaySound("UChatScrollButton");
		TellMeWhen_Update();
	else
		DEFAULT_CHAT_FRAME:AddMessage(L["CMD_ERROR"])
	end
end

function TellMeWhen_Reset()
--	local oldmax = TellMeWhen_Settings["NumGroups"]
	TellMeWhen_Settings = CopyTable(TellMeWhen_Defaults);
	for groupID = 1, TELLMEWHEN_MAXGROUPS do
		local group = _G["TellMeWhen_Group"..groupID] or CreateFrame("Frame","TellMeWhen_Group"..groupID, UIParent, "TellMeWhen_GroupTemplate",groupID);
		group:ClearAllPoints()
		if groupID > 16 then
			group:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 400, (-20 - (30*(groupID-16))));
		elseif groupID > 8 then
			group:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 250, (-20 - (30*(groupID-8))));
		else
			group:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 100, (-20 - (30*groupID)));
		end
		group.p = TellMeWhen_Settings["Groups"][groupID]["Point"]
		group.p.point,_,group.p.relativePoint,group.p.x,group.p.y = group:GetPoint(1)
		TellMeWhen_Settings["Groups"][groupID]["Enabled"] = false;
		group:Hide()
	end
	--if oldmax ~= TellMeWhen_Settings["NumGroups"] then
--		StaticPopup_Show("TELLMEWHEN_RELOADNEEDED")
	--end
	TellMeWhen_Settings["Groups"][1]["Enabled"] = true;
	TellMeWhen_Update();			-- default setting is unlocked?
	DEFAULT_CHAT_FRAME:AddMessage("[TellMeWhen]: Groups have been Reset");
end

function TellMeWhen_ShowConfig()
	local uIPanel = _G["InterfaceOptionsTellMeWhenPanel"];
	InterfaceOptionsFrame_OpenToCategory(uIPanel);
end

function TellMeWhen_Options_Compile()
	TMWoptionsTable = {
		type = "group",
		args = {
			main = {
				type = "group",
				name = L["UIPANEL_MAINOPT"],
				order = 1,
				args = {
					header = {
						name = L["ICON_TOOLTIP1"] .. " " .. TELLMEWHEN_VERSION,
						type = "header",
						order = 1,
					},
					togglelock = {
						name = L["UIPANEL_LOCKUNLOCK"],
						desc = L["UIPANEL_SUBTEXT2"],
						type = "toggle",
						order = 2,
						set = function(info,val)
							TellMeWhen_Settings["Locked"] = val;
							TellMeWhen_Update();
						end,
						get = function(info) return TellMeWhen_Settings["Locked"] end
					},
					bartexture = {
						name = L["UIPANEL_BARTEXTURE"],
						type = "select",
						order = 3,
						dialogControl = 'LSM30_Statusbar',
						values = LSM:HashTable("statusbar"),
						set = function(info,val)
							TellMeWhen_Settings["Texture"] = LSM:Fetch("statusbar",val)
							TellMeWhen_Settings["TextureName"] = val
							TellMeWhen_Update()
						end,
						get = function(info) return TellMeWhen_Settings["TextureName"] end
					},
					updinterval = {
						name = L["UIPANEL_UPDATEINTERVAL"],
						desc = L["UIPANEL_TOOLTIP_UPDATEINTERVAL"],
						type = "range",
						order = 9,
						min = 0,
						max = 1,
						step = 0.01,
						bigStep = 0.01,
						set = function(info,val)
						TellMeWhen_Settings["Interval"] = val;
						TellMeWhen_Update()
						end,
						get = function(info) return TellMeWhen_Settings["Interval"] end
							
					},
					numconditions = {
						name = L["UIPANEL_NUMCONDTS"],
						desc = L["UIPANEL_NUMCONDTS_DESC"],
						type = "range",
						order = 10,
						min = 2,
						max = 8,
						step = 1,
						bigStep = 1,
						set = function(info,val)
							TellMeWhen_ConditionPanel_NumCheck(val)
						end,
						get = function(info) return TellMeWhen_Settings["NumCondits"] end
					},
					iconspacing = {
						name = L["UIPANEL_ICONSPACING"],
						desc = L["UIPANEL_ICONSPACING_DESC"],
						type = "range",
						order = 10,
						min = 0,
						softMax = 20,
						step = 0.1,
						bigStep = 1,
						set = function(info,val)
							TellMeWhen_Settings["Spacing"] = val
							TELLMEWHEN_ICONSPACING = TellMeWhen_Settings["Spacing"] or TELLMEWHEN_ICONSPACING
							TellMeWhen_Update()
						end,
						get = function(info) return TELLMEWHEN_ICONSPACING end
					},
					barignoregcd = {
						name = L["UIPANEL_BARIGNOREGCD"],
						desc = L["UIPANEL_BARIGNOREGCD_DESC"],
						type = "toggle",
						order = 21,
						set = function(info,val)
							TellMeWhen_Settings["BarGCD"] = not val;
							TellMeWhen_Update();
						end,
						get = function(info) return not TellMeWhen_Settings["BarGCD"] end
					},
					clockignoregcd = {
						name = L["UIPANEL_CLOCKIGNOREGCD"],
						desc = L["UIPANEL_CLOCKIGNOREGCD_DESC"],
						type = "toggle",
						order = 22,
						set = function(info,val)
							TellMeWhen_Settings["ClockGCD"] = not val;
							TellMeWhen_Update();
						end,
						get = function(info) return not TellMeWhen_Settings["ClockGCD"] end
					},
					drawedge = {
						name = L["UIPANEL_DRAWEDGE"],
						desc = L["UIPANEL_DRAWEDGE_DESC"],
						type = "toggle",
						order = 40,
						set = function(info,val)
							TellMeWhen_Settings["DrawEdge"] = val;
							TellMeWhen_Update();
						end,
						get = function(info) return TellMeWhen_Settings["DrawEdge"] end
					},
					resetall = {
						name = L["UIPANEL_ALLRESET"],
						desc = L["UIPANEL_TOOLTIP_ALLRESET"],
						type = "execute",
						order = 50,
						confirm = true,
						func = function() TellMeWhen_Reset() end,
					},
					coloropts = {
						type = "group",
						name = L["UIPANEL_COLORS"],
						order = 3,
						args = {
							cdstcolor = {
								name = L["UIPANEL_COLOR_STARTED"],
								desc = L["UIPANEL_COLOR_STARTED_DESC"],
								type = "color",
								order = 31,
								hasAlpha = true,
								set = function(info,nr,ng,nb,na) local c = TellMeWhen_Settings["CDSTColor"] c.r = nr c.g = ng c.b = nb c.a = na TellMeWhen_ColorUpdate(); end,
								get = function(info) local c = TellMeWhen_Settings["CDSTColor"]  return c.r, c.g, c.b, c.a end,
							},
							cdcocolor = {
								name = L["UIPANEL_COLOR_COMPLETE"],
								desc = L["UIPANEL_COLOR_COMPLETE_DESC"],
								type = "color",
								order = 32,
								hasAlpha = true,
								set = function(info,nr,ng,nb,na) local c = TellMeWhen_Settings["CDCOColor"] c.r = nr c.g = ng c.b = nb c.a = na TellMeWhen_ColorUpdate(); end,
								get = function(info) local c = TellMeWhen_Settings["CDCOColor"]  return c.r, c.g, c.b, c.a end,
							},
							oorcolor = {
								name = L["UIPANEL_COLOR_OOR"],
								desc = L["UIPANEL_COLOR_OOR_DESC"],
								type = "color",
								order = 37,
								hasAlpha = true,
								set = function(info,nr,ng,nb,na) local c = TellMeWhen_Settings["OORColor"] c.r = nr c.g = ng c.b = nb c.a = na TellMeWhen_ColorUpdate(); end,
								get = function(info) local c = TellMeWhen_Settings["OORColor"]  return c.r, c.g, c.b, c.a end,
							},
							oomcolor = {
								name = L["UIPANEL_COLOR_OOM"],
								desc = L["UIPANEL_COLOR_OOM_DESC"],
								type = "color",
								order = 38,
								hasAlpha = true,
								set = function(info,nr,ng,nb,na) local c = TellMeWhen_Settings["OOMColor"] c.r = nr c.g = ng c.b = nb c.a = na TellMeWhen_ColorUpdate(); end,
								get = function(info) local c = TellMeWhen_Settings["OOMColor"]  return c.r, c.g, c.b, c.a end,
							},
							desc = {
								name = L["UIPANEL_COLOR_DESC"],
								type = "description",
								order = 40,
							},
							--[[usablecolor = {
								name = L["UIPANEL_COLOR_COMPLETE"],
								desc = L["UIPANEL_COLOR_COMPLETE_DESC"],
								type = "color",
								order = 41,
								hasAlpha = false,
								set = function(info,nr,ng,nb) local c = TellMeWhen_Settings["USEColor"] c.r = nr c.g = ng c.b = nb TellMeWhen_ColorUpdate(); end,
								get = function(info) local c = TellMeWhen_Settings["USEColor"] return c.r, c.g, c.b end,
							},				
							unusablecolor = {
								name = L["UIPANEL_COLOR_COMPLETE"],
								desc = L["UIPANEL_COLOR_COMPLETE_DESC"],
								type = "color",
								order = 43,
								hasAlpha = false,
								set = function(info,nr,ng,nb) local c = TellMeWhen_Settings["UNUSEColor"] c.r = nr c.g = ng c.b = nb TellMeWhen_ColorUpdate(); end,
								get = function(info) local c = TellMeWhen_Settings["UNUSEColor"] return c.r, c.g, c.b end,
							},]]
							presentcolor = {
								name = L["UIPANEL_COLOR_PRESENT"],
								desc = L["UIPANEL_COLOR_PRESENT_DESC"],
								type = "color",
								order = 45,
								hasAlpha = false,
								set = function(info,nr,ng,nb) local c = TellMeWhen_Settings["PRESENTColor"] c.r = nr c.g = ng c.b = nb TellMeWhen_ColorUpdate(); end,
								get = function(info) local c = TellMeWhen_Settings["PRESENTColor"] return c.r, c.g, c.b end,
							},
							absentcolor = {
								name = L["UIPANEL_COLOR_ABSENT"],
								desc = L["UIPANEL_COLOR_ABSENT_DESC"],
								type = "color",
								order = 47,
								hasAlpha = false,
								set = function(info,nr,ng,nb) local c = TellMeWhen_Settings["ABSENTColor"] c.r = nr c.g = ng c.b = nb TellMeWhen_ColorUpdate(); end,
								get = function(info) local c = TellMeWhen_Settings["ABSENTColor"] return c.r, c.g, c.b end,
							},
						},
					},
				},
			},
			groups = {
				type = "group",
				name = L["UIPANEL_GROUPS"],
				order = 2,
				args = {
			--[[		desc = {
						name = L["UIPANEL_NUMGROUPS_DESC"],
						type = "description",
						order = 1,
					},
					numgroups = {
						name = L["UIPANEL_NUMGROUPS"],
						desc = L["UIPANEL_NUMGROUPS_DESC"],
						type = "range",
						order = 10,
						min = 1,
						max = TELLMEWHEN_MAXGROUPS,
						step = 1,
						bigStep = 1,
						set = function(info,val)
						TellMeWhen_Settings["NumGroups"] = val;
						end,
						get = function(info) return TellMeWhen_Settings["NumGroups"] end
					},
					reload = {
						name = L["UIPANEL_RELOAD"],
						desc = L["UIPANEL_RELOAD"],
						type = "execute",
						order = 13,
						func = function() ReloadUI() end
					},]]
				}
			}
		}
	}

	for zz=1,TELLMEWHEN_MAXGROUPS do
		RunScript([[
		local L = LibStub("AceLocale-3.0"):GetLocale("TellMeWhen", true)
		TMWoptionsTable.args.groups.args.group]].. zz ..[[ = {
			type = "group",
			name = L["UIPANEL_ICONGROUP"] .. ]]..zz..[[,
			order = ]]..zz..[[,
			args = {
				enable = {
					name = L["UIPANEL_ENABLEGROUP"],
					desc = L["UIPANEL_TOOLTIP_ENABLEGROUP"],
					type = "toggle",
					order = 1,
					set = function(info,val)
						TellMeWhen_Settings["Groups"][]]..zz..[[]["Enabled"] = val;
						TellMeWhen_Group_Update(]]..zz..[[)
					end,
					get = function(info) return TellMeWhen_Settings["Groups"][]]..zz..[[]["Enabled"] end
				},
				columns = {
					name = L["UIPANEL_COLUMNS"],
					desc = L["UIPANEL_TOOLTIP_COLUMNS"],
					type = "range",
					order = 10,
					min = 1,
					max = TELLMEWHEN_MAXROWS,
					step = 1,
					bigStep = 1,
					set = function(info,val)
						TellMeWhen_Settings["Groups"][]]..zz..[[]["Columns"] = val;
						TellMeWhen_Group_Update(]]..zz..[[)
					end,
					get = function(info) return TellMeWhen_Settings["Groups"][]]..zz..[[]["Columns"] end
					
				},
				rows = {
					name = L["UIPANEL_ROWS"],
					desc = L["UIPANEL_TOOLTIP_ROWS"],
					type = "range",
					order = 11,
					min = 1,
					max = TELLMEWHEN_MAXROWS,
					step = 1,
					bigStep = 1,
					set = function(info,val)
						TellMeWhen_Settings["Groups"][]]..zz..[[]["Rows"] = val;
						TellMeWhen_Group_Update(]]..zz..[[)
					end,
					get = function(info) return TellMeWhen_Settings["Groups"][]]..zz..[[]["Rows"] end
					
				},
				combat = {
					name = L["UIPANEL_ONLYINCOMBAT"],
					desc = L["UIPANEL_TOOLTIP_ONLYINCOMBAT"],
					type = "toggle",
					order = 2,
					set = function(info,val)
						TellMeWhen_Settings["Groups"][]]..zz..[[]["OnlyInCombat"] = val;
						TellMeWhen_Group_Update(]]..zz..[[);
					end,
					get = function(info) return TellMeWhen_Settings["Groups"][]]..zz..[[]["OnlyInCombat"] end
				},
				mainspec = {
					name = L["UIPANEL_PRIMARYSPEC"],
					desc = L["UIPANEL_TOOLTIP_PRIMARYSPEC"],
					type = "toggle",
					order = 3,
					set = function(info,val)
						TellMeWhen_Settings["Groups"][]]..zz..[[]["PrimarySpec"] = val;
						TellMeWhen_Group_Update(]]..zz..[[);
					end,
					get = function(info) return TellMeWhen_Settings["Groups"][]]..zz..[[]["PrimarySpec"] end
				},
				offspec = {
					name = L["UIPANEL_SECONDARYSPEC"],
					desc = L["UIPANEL_TOOLTIP_SECONDARYSPEC"],
					type = "toggle",
					order = 4,
					set = function(info,val)
						TellMeWhen_Settings["Groups"][]]..zz..[[]["SecondarySpec"] = val;
						TellMeWhen_Group_Update(]]..zz..[[);
					end,
					get = function(info) return TellMeWhen_Settings["Groups"][]]..zz..[[]["SecondarySpec"] end
				},
				reset = {
					name = L["UIPANEL_GROUPRESET"],
					desc = L["UIPANEL_TOOLTIP_GROUPRESET"],
					type = "execute",
					order = 13,
					func = function() TellMeWhen_GroupPositionReset_OnClick(]]..zz..[[) end
				},
				stance = {
					type = "multiselect",
					name = L["UIPANEL_STANCE"],
					order = 12,
					values = TellMeWhen_CurrentStancesn,
					set = function(info,key,val)		--true values are stances that are hidden, this way i dont have to define every single stance as true and make the config file even bigger.
						TellMeWhen_Settings["Groups"][]]..zz..[[]["Stance"][key] = not val
						TellMeWhen_Group_Update(]]..zz..[[);
					end,
					get = function(info,key)
						return not TellMeWhen_Settings["Groups"][]]..zz..[[]["Stance"][key]
					end,
				},
			}
		}]]
		)
	end
end

-- --------
-- ICON GUI
-- --------

local tiptemp = {}
function TellMeWhen_Equivs_GenerateTips(BoD,equiv)
	local r = ""
	local tab = TellMeWhen_SplitNames(TMW_BE[BoD][equiv],"spell");
	for k,v in pairs(tab) do
		local name = GetSpellInfo(v)
		if not tiptemp[name] then --prevents display of the same name twice when there are multiple ranks.
			if not (k == #tab) then
				if k == 10 or k == 20 or k == 30 then --makes it not one big long line
					r = r .. GetSpellInfo(v) .. ",\r\n" 
				else
					r = r .. GetSpellInfo(v) .. ", " 
				end
			else 
				r = r .. GetSpellInfo(v) .. " " 
			end
		end
		tiptemp[name] = true
	end
	wipe(tiptemp)
	return r
end

TellMeWhen_CurrentIcon = { groupID = 1, iconID = 1 };		-- a dirty hack, i know.
TellMeWhen_CurrentCopyIcon = { groupID = 1, iconID = 1 };		

StaticPopupDialogs["TELLMEWHEN_CHOOSENAME_DIALOG"] = {
	text = L["CHOOSENAME_DIALOG"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 200,
	OnShow = function(icon)
		local groupID = TellMeWhen_CurrentIcon["groupID"];
		local iconID = TellMeWhen_CurrentIcon["iconID"];
		local text = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Name"];
		_G[icon:GetName().."EditBox"]:SetText(text);
		_G[icon:GetName().."EditBox"]:SetFocus();
	end,
	OnAccept = function(icon)
		local base = icon:GetName()
		local editbox = _G[(base .. "EditBox")]
		TellMeWhen_IconMenu_ChooseName(editbox:GetText())
	end,
	EditBoxOnEnterPressed = function(icon)
		local base = icon:GetParent():GetName()
		local editbox = _G[(base .. "EditBox")]
		TellMeWhen_IconMenu_ChooseName(editbox:GetText())
		icon:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function(icon)
		icon:GetParent():Hide();
	end,
	OnHide = function(icon)
		if ( ChatFrameEditBox and ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		local base = icon:GetName()
		local editbox = _G[(base .. "EditBox")]
		editbox:SetText("");
		_G["TellMeWhen_EquivSelectDropdown"]:Hide()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["TELLMEWHEN_HPSS_WARN"] = {
	text = L["ICON_TOOLTIP1"] .. "\r\n\r\n" ..L["HPSSWARN"],
	button1 = ACCEPT,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["TELLMEWHEN_CONDT_WARN"] = {
	text = L["ICON_TOOLTIP1"] .. "\r\n\r\n" ..L["CONDTWARN"],
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
	OnAccept = function(icon,data)
		TellMeWhen_Settings["NumCondits"] = data
		TellMeWhen_Update()
		LibStub("AceConfigRegistry-3.0"):NotifyChange("TellMeWhen Options")
	end,
};

StaticPopupDialogs["TELLMEWHEN_RELOADNEEDED"] = {
	text = L["ICON_TOOLTIP1"] .. "\r\n\r\n" ..L["RLWARN"],
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
	OnAccept = function(icon,data)
		ReloadUI()
	end,
};


TellMeWhen_IconMenu_CooldownOptions = {
	{ value = "ShowTimer", 			text = L["ICONMENU_SHOWTIMER"], 																	},
	{ value = "ShowTimerText", 		text = L["ICONMENU_SHOWTIMERTEXT"], 					desc = L["ICONMENU_SHOWTIMERTEXT_DESC"],	},
	{ value = "CooldownType", 		text = L["ICONMENU_COOLDOWNTYPE"], 	HasSubmenu = true,												},
	{ value = "CooldownShowWhen",	text = L["ICONMENU_SHOWWHEN"], 		HasSubmenu = true,												},
	{ value = "RangeCheck", 		text = L["ICONMENU_RANGECHECK"], 						desc = L["ICONMENU_SHOWTIMERTEXT_DESC"],	},
	{ value = "ManaCheck", 			text = L["ICONMENU_MANACHECK"], 						desc = L["ICONMENU_SHOWTIMERTEXT_DESC"],	},
	{ value = "UnitReact", 			text = L["ICONMENU_REACT"], 		HasSubmenu = true,												},
	{ value = "Bars", 				text = L["ICONMENU_BARS"], 			HasSubmenu = true,												},
};

TellMeWhen_IconMenu_ReactiveOptions = {
	{ value = "ShowTimer", 			text = L["ICONMENU_SHOWTIMER"],																		},
	{ value = "ShowTimerText", 		text = L["ICONMENU_SHOWTIMERTEXT"], 					desc = L["ICONMENU_SHOWTIMERTEXT_DESC"],	},
	{ value = "CooldownShowWhen", 	text = L["ICONMENU_SHOWWHEN"], 		HasSubmenu = true,												},
	{ value = "CooldownCheck", 		text = L["ICONMENU_COOLDOWNCHECK"], 																},
	{ value = "RangeCheck", 			text = L["ICONMENU_RANGECHECK"],																},
	{ value = "ManaCheck", 			text = L["ICONMENU_MANACHECK"], 																	},
	{ value = "UnitReact", 			text = L["ICONMENU_REACT"], 		HasSubmenu = true,												},
	{ value = "Bars", 				text = L["ICONMENU_BARS"], 			HasSubmenu = true,												},
};

TellMeWhen_IconMenu_BuffOptions = {
	{ value = "ShowTimer", 			text = L["ICONMENU_SHOWTIMER"], 																	},
	{ value = "ShowTimerText", 		text = L["ICONMENU_SHOWTIMERTEXT"],						desc = L["ICONMENU_SHOWTIMERTEXT_DESC"],	},
	{ value = "OnlyMine", 			text = L["ICONMENU_ONLYMINE"],																		},
	{ value = "BuffOrDebuff", 		text = L["ICONMENU_BUFFTYPE"], 		HasSubmenu = true,												},
	{ value = "Unit",				text = L["ICONMENU_UNIT"], 			HasSubmenu = true,												},
	{ value = "BuffShowWhen", 		text = L["ICONMENU_BUFFSHOWWHEN"], 	HasSubmenu = true,												},
	{ value = "UnitReact", 			text = L["ICONMENU_REACT"], 		HasSubmenu = true,												},
	{ value = "Bars", 				text = L["ICONMENU_BARS"], 			HasSubmenu = true,												},
};

TellMeWhen_IconMenu_WpnEnchantOptions = {
	{ value = "ShowTimer", 			text = L["ICONMENU_SHOWTIMER"],																		},
	{ value = "ShowTimerText", 		text = L["ICONMENU_SHOWTIMERTEXT"],						desc = L["ICONMENU_SHOWTIMERTEXT_DESC"],	},
	{ value = "WpnEnchantType", 	text = L["ICONMENU_WPNENCHANTTYPE"],HasSubmenu = true,												},
	{ value = "BuffShowWhen", 		text = L["ICONMENU_SHOWWHEN"], 		HasSubmenu = true,												},
};

TellMeWhen_IconMenu_TotemOptions = {
	{ value = "ShowTimer", 			text = L["ICONMENU_SHOWTIMER"],																		},
	{ value = "ShowTimerText", 		text = L["ICONMENU_SHOWTIMERTEXT"], 					desc = L["ICONMENU_SHOWTIMERTEXT_DESC"],	},
	{ value = "BuffShowWhen", 		text = L["ICONMENU_SHOWWHEN"], 		HasSubmenu = true,												},
	{ value = "Bars", 				text = L["ICONMENU_BARS"], 			HasSubmenu = true,												},
};


	
TellMeWhen_IconMenu_SubMenus = {
	-- the keys on this table need to match the settings variable names
	Type = {
		{ value = "cooldown", text = L["ICONMENU_COOLDOWN"] },
		{ value = "buff", text = L["ICONMENU_BUFFDEBUFF"] },
		{ value = "reactive", text = L["ICONMENU_REACTIVE"] },
		{ value = "wpnenchant", text = L["ICONMENU_WPNENCHANT"] },
		{ value = "totem", text = L["ICONMENU_TOTEM"] },
	},
	CooldownType = {
		{ value = "spell", text = L["ICONMENU_SPELL"] },
		{ value = "item", text = L["ICONMENU_ITEM"] },
	},
	BuffOrDebuff = {
		{ value = "HELPFUL", text = L["ICONMENU_BUFF"], color = "|cFF00FF00" },
		{ value = "HARMFUL", text = L["ICONMENU_DEBUFF"], color = "|cFFFF0000" },
	},
	Unit = {	
		{ value = "player", text = PLAYER },
		{ value = "target", text = TARGET },
		{ value = "targettarget", text = L["ICONMENU_TARGETTARGET"] },
		{ value = "focus", text = FOCUS },
		{ value = "focustarget", text = L["ICONMENU_FOCUSTARGET"] },
		{ value = "pet", text = PET },
		{ value = "pettarget", text = L["ICONMENU_PETTARGET"] },
		{ value = "mouseover", text = L["ICONMENU_MOUSEOVER"] },
		{ value = "mouseovertarget", text = L["ICONMENU_MOUSEOVERTARGET"]  },
		{ value = "vehicle", text = L["ICONMENU_VEHICLE"] },
	},
	BuffShowWhen = {
		{ value = "present", text = L["ICONMENU_PRESENT"], color = "|cFF00FF00" },
		{ value = "absent", text = L["ICONMENU_ABSENT"], color = "|cFFFF0000" },
		{ value = "always", text = L["ICONMENU_ALWAYS"] },
	},
	CooldownShowWhen = {
		{ value = "usable", text = L["ICONMENU_USABLE"], color = "|cFF00FF00"  },
		{ value = "unusable", text = L["ICONMENU_UNUSABLE"], color = "|cFFFF0000"  },
		{ value = "always", text = L["ICONMENU_ALWAYS"] },
	},
	WpnEnchantType = {
		{ value = "mainhand", text = L["ICONMENU_MAINHAND"] },
		{ value = "offhand", text = L["ICONMENU_OFFHAND"] },
		{ value = "thrown", text = L["ICONMENU_THROWN"] },
	},
	Bars = {
		{ value = "ShowPBar", text = L["ICONMENU_SHOWPBAR"] },
		{ value = "ShowCBar", text = L["ICONMENU_SHOWCBAR"] },
		{ value = "InvertBars", text = L["ICONMENU_INVERTBARS"] },
	},
	UnitReact = {
		{ value = 0, text = L["ICONMENU_EITHER"] },
		{ value = 2, text = L["ICONMENU_FRIEND"], color = "|cFF00FF00"  },
		{ value = 1, text = L["ICONMENU_HOSTILE"], color = "|cFFFF0000"  },
	},
};

function TellMeWhen_IconConfig_StacksCreate()
	TellMeWhen_Settings["Groups"][TellMeWhen_CurrentStackIcon["groupID"]]["Icons"][TellMeWhen_CurrentStackIcon["iconID"]]["StackMin"] = 
	TellMeWhen_Settings["Groups"][TellMeWhen_CurrentStackIcon["groupID"]]["Icons"][TellMeWhen_CurrentStackIcon["iconID"]]["StackMin"] or 0;
	
	TellMeWhen_Settings["Groups"][TellMeWhen_CurrentStackIcon["groupID"]]["Icons"][TellMeWhen_CurrentStackIcon["iconID"]]["StackMax"] = 
	TellMeWhen_Settings["Groups"][TellMeWhen_CurrentStackIcon["groupID"]]["Icons"][TellMeWhen_CurrentStackIcon["iconID"]]["StackMax"] or 1000;
	local stackoptions = {
		type = "group",
		name = L["ICON_TOOLTIP1"],
		args = {
			header = {
				name = format(L["ICONMENU_STACKS_HEADER"],TellMeWhen_CurrentStackIcon["groupID"], TellMeWhen_CurrentStackIcon["iconID"]),
				type = "header",
				order = 1,
			},
			mintext = {
				name = L["ICONMENU_STACKS_MIN"],
				desc = L["ICONMENU_STACKS_MIN_DESC"],
				type = "range",
				softMin = 0,
				softMax = 100,
				step = 1,
				bigStep = 1,
				order = 2,
				set = function(info,val)
				TellMeWhen_Settings["Groups"][TellMeWhen_CurrentStackIcon["groupID"]]["Icons"][TellMeWhen_CurrentStackIcon["iconID"]]["StackMin"] = val;
				TellMeWhen_Update();
				end,
				get = function(info) return TellMeWhen_Settings["Groups"][TellMeWhen_CurrentStackIcon["groupID"]]["Icons"][TellMeWhen_CurrentStackIcon["iconID"]]["StackMin"] end,
			},
			maxtext = {
				name = L["ICONMENU_STACKS_MAX"],
				desc = L["ICONMENU_STACKS_MAX_DESC"],
				type = "range",
				softMin = 0,
				softMax = 100,
				step = 1,
				bigStep = 1,
				order = 3,
				set = function(info,val)
				TellMeWhen_Settings["Groups"][TellMeWhen_CurrentStackIcon["groupID"]]["Icons"][TellMeWhen_CurrentStackIcon["iconID"]]["StackMax"] = val;
				TellMeWhen_Update();
				end,
				get = function(info) return TellMeWhen_Settings["Groups"][TellMeWhen_CurrentStackIcon["groupID"]]["Icons"][TellMeWhen_CurrentStackIcon["iconID"]]["StackMax"] end,
			},
		}
	}

	LibStub("AceConfig-3.0"):RegisterOptionsTable("TellMeWhen Icon Stacks", stackoptions)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("TellMeWhen Icon Stacks",380,150)
end

function TellMeWhen_IconConfig_AlphaCreate()
	local alphaoptions = {
		type = "group",
		name = L["ICON_TOOLTIP1"],
		args = {
			header = {
				name = format(L["ICONMENU_ALPHA"],TellMeWhen_CurrentAlphaIcon["groupID"],TellMeWhen_CurrentAlphaIcon["iconID"]),
				type = "header",
				order = 1,
			},
			unalpha = {
				name = L["ICONALPHAPANEL_UNALPHA"],
				desc = L["ICONALPHAPANEL_UNALPHA_DESC"],
				type = "range",
				min = 0,
				max = 1,
				softMin = 0,
				softMax = 1,
				order = 2,
				isPercent = true,
				set = function(info,val)
				TellMeWhen_Settings["Groups"][TellMeWhen_CurrentAlphaIcon["groupID"]]["Icons"][TellMeWhen_CurrentAlphaIcon["iconID"]]["UnAlpha"] = val;
			--	TellMeWhen_Update();
				end,
				get = function(info) return TellMeWhen_Settings["Groups"][TellMeWhen_CurrentAlphaIcon["groupID"]]["Icons"][TellMeWhen_CurrentAlphaIcon["iconID"]]["UnAlpha"] end,
			},
			alpha = {
				name = L["ICONALPHAPANEL_ALPHA"],
				desc = L["ICONALPHAPANEL_ALPHA_DESC"],
				type = "range",
				min = 0,
				max = 1,
				softMin = 0,
				softMax = 1,
				order = 3,
				isPercent = true,
				set = function(info,val)
				TellMeWhen_Settings["Groups"][TellMeWhen_CurrentAlphaIcon["groupID"]]["Icons"][TellMeWhen_CurrentAlphaIcon["iconID"]]["Alpha"] = val;
			--	TellMeWhen_Update();
				end,
				get = function(info) return TellMeWhen_Settings["Groups"][TellMeWhen_CurrentAlphaIcon["groupID"]]["Icons"][TellMeWhen_CurrentAlphaIcon["iconID"]]["Alpha"] end,
			},
			fakehidden = {
				name = L["ICONALPHAPANEL_FAKEHIDDEN"],
				desc = L["ICONALPHAPANEL_FAKEHIDDEN_DESC"],
				type = "toggle",
				order = 50,
				set = function(info,val)
					TellMeWhen_Settings["Groups"][TellMeWhen_CurrentAlphaIcon["groupID"]]["Icons"][TellMeWhen_CurrentAlphaIcon["iconID"]]["FakeHidden"] = val;
					TellMeWhen_Update();
				end,
				get = function(info) return TellMeWhen_Settings["Groups"][TellMeWhen_CurrentAlphaIcon["groupID"]]["Icons"][TellMeWhen_CurrentAlphaIcon["iconID"]]["FakeHidden"] end
			},
		}
	}

	LibStub("AceConfig-3.0"):RegisterOptionsTable("TellMeWhen Icon Alpha", alphaoptions)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("TellMeWhen Icon Alpha",380,180)
end

function TellMeWhen_Equiv_Click(self,frame,three)
	TMWOPENDIALOG.editBox:SetText(self.value)
	local color
	if three == "buffs" then
		color = "|cFF00FF00";
	elseif three == "debuffs" then
		color = "|cFFFF0000";
	else
		color = "|cFF000000"

	end



	UIDropDownMenu_SetText(frame,color .. L[self.value] .. "|r")
	CloseDropDownMenus();
end

function TellMeWhen_Equiv_OnEnter(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	GameTooltip:AddLine(L["CHOOSENAME_EQUIVS_TOOLTIP"], 1, 1, 1, 1);
	GameTooltip:Show()
end

function TellMeWhen_EquivSelect(frame)
	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		for z,x in pairs(TMW_BE[UIDROPDOWNMENU_MENU_VALUE]) do
			local info = UIDropDownMenu_CreateInfo();
			info.func = TellMeWhen_Equiv_Click;
			info.text = L[z];
			info.tooltipTitle = L[z];
			local text = TellMeWhen_Equivs_GenerateTips(UIDROPDOWNMENU_MENU_VALUE,z);
			info.tooltipText = text;
			info.tooltipOnButton = true;
			info.value = z;
			info.arg1 = frame;
			info.arg2 = UIDROPDOWNMENU_MENU_VALUE;
			info.notCheckable = true;
			UIDropDownMenu_AddButton(info,2);
		end;
		return;
	end;
	local info = UIDropDownMenu_CreateInfo();
	info.text = "Buffs";
	info.value = "buffs";
	info.hasArrow = true;
	info.colorCode = "|cFF00FF00";
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);
	
	--some stuff is reused for this one
	info.text = "Debuffs";
	info.value = "debuffs";
	info.colorCode = "|cFFFF0000";
	UIDropDownMenu_AddButton(info);
	

	UIDropDownMenu_JustifyText( frame, "LEFT" );
end

function TellMeWhen_Icon_OnEnter(icon, motion)
	GameTooltip_SetDefaultAnchor(GameTooltip, icon);
	GameTooltip:AddLine(L["ICON_TOOLTIP1"] .. " " .. format(L["GROUPICON"],icon:GetParent():GetID(),icon:GetID()), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
	GameTooltip:AddLine(L["ICON_TOOLTIP2"], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
	GameTooltip:Show();
end

function TellMeWhen_Icon_OnMouseDown(icon, button)
	if ( button == "RightButton" ) then
 		PlaySound("UChatScrollButton");
		TellMeWhen_CurrentIcon["iconID"] = icon:GetID();		-- yay for dirty hacks
		TellMeWhen_CurrentIcon["groupID"] = icon:GetParent():GetID();
		ToggleDropDownMenu(1, nil, _G[icon:GetName().."DropDown"], "cursor", 0, 0);
 	end
end

function TellMeWhen_IconMenu_Initialize(self)

	local groupID = TellMeWhen_CurrentIcon["groupID"];
	local iconID = TellMeWhen_CurrentIcon["iconID"];

	local name = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Name"];
	local iconType = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Type"];
	local enabled = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Enabled"];
	local conditions = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Conditions"];

	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		local subMenus = TellMeWhen_IconMenu_SubMenus;
		for index, value in ipairs(subMenus[UIDROPDOWNMENU_MENU_VALUE]) do
			-- here, UIDROPDOWNMENU_MENU_VALUE is the setting name
			local info = UIDropDownMenu_CreateInfo();
			if subMenus[UIDROPDOWNMENU_MENU_VALUE][index]["value"] == "ShowTimerText" then
				if IsAddOnLoaded("OmniCC") then
					info.disabled = false
				else
					info.disabled = true
				end
			end
			info.text = subMenus[UIDROPDOWNMENU_MENU_VALUE][index]["text"];
			info.value = subMenus[UIDROPDOWNMENU_MENU_VALUE][index]["value"];
			if subMenus[UIDROPDOWNMENU_MENU_VALUE][index]["desc"] then
				info.tooltipTitle = subMenus[UIDROPDOWNMENU_MENU_VALUE][index]["text"];
				info.tooltipText = subMenus[UIDROPDOWNMENU_MENU_VALUE][index]["desc"];
				info.tooltipOnButton = true;
			end
			info.colorCode = subMenus[UIDROPDOWNMENU_MENU_VALUE][index]["color"];
			if UIDROPDOWNMENU_MENU_VALUE == "Bars" then	
				info.checked = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID][info.value];
				info.func = TellMeWhen_IconMenu_ToggleSetting;
				info.keepShownOnClick = true;
			else
				info.checked = ( info.value == TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID][UIDROPDOWNMENU_MENU_VALUE] );
				info.func = TellMeWhen_IconMenu_ChooseSetting;
			end
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		end
		return;
	end

	-- show name
	local info = UIDropDownMenu_CreateInfo();
	if ( name ) and ( name ~= "" ) then
		info = UIDropDownMenu_CreateInfo();
		info.text = name;
		info.isTitle = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info);
	end

	-- choose name
	if ( iconType ~= "wpnenchant" ) then
		info = UIDropDownMenu_CreateInfo();
		info.value = L["ICONMENU_CHOOSENAME"];
		info.text = L["ICONMENU_CHOOSENAME"];
		info.func = TellMeWhen_IconMenu_ShowNameDialog;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info);
	end

	-- enable icon
	info = UIDropDownMenu_CreateInfo();
	info.value = "Enabled";
	info.text = L["ICONMENU_ENABLE"];
	info.checked = enabled;
	info.func = TellMeWhen_IconMenu_ToggleSetting;
	info.keepShownOnClick = true;
	UIDropDownMenu_AddButton(info);

	-- icon type
	info = UIDropDownMenu_CreateInfo();
	info.value = "Type";
	info.text = L["ICONMENU_TYPE"];
	info.hasArrow = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);

	-- icon alpha
	info = UIDropDownMenu_CreateInfo();
	info.value = "Set Alpha";
	if TellMeWhen_Settings["Groups"][TellMeWhen_CurrentIcon["groupID"]]["Icons"][TellMeWhen_CurrentIcon["iconID"]]["Alpha"] ~= 1 or 
	TellMeWhen_Settings["Groups"][TellMeWhen_CurrentIcon["groupID"]]["Icons"][TellMeWhen_CurrentIcon["iconID"]]["UnAlpha"] ~= 1 or
	TellMeWhen_Settings["Groups"][TellMeWhen_CurrentIcon["groupID"]]["Icons"][TellMeWhen_CurrentIcon["iconID"]]["FakeHidden"] == true then
		info.text = L["ICONMENU_SETALPHAMOD"];
	else	
		info.text = L["ICONMENU_SETALPHA"];
	end
	info.hasArrow = false;
	info.notCheckable = true;
	info.func = function()
		TellMeWhen_CurrentAlphaIcon = { groupID = TellMeWhen_CurrentIcon["groupID"], iconID = TellMeWhen_CurrentIcon["iconID"] };	
		TellMeWhen_IconConfig_AlphaCreate() LibStub("AceConfigDialog-3.0"):Open("TellMeWhen Icon Alpha")
	end;
	UIDropDownMenu_AddButton(info);

	-- icon condition
	info = UIDropDownMenu_CreateInfo();
	if ( #conditions > 0 ) then
		info.text = L["ICONMENU_EDITCONDITION"];
		info.value = "Edit condition";
		info.func = TellMeWhen_LoadConditionDialog;
	else
		info.text = L["ICONMENU_ADDCONDITION"];
		info.value = "Add condition";
		info.func = TellMeWhen_ClearConditionDialog;
	end
	info.hasArrow = false;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);
	

	info = UIDropDownMenu_CreateInfo();
	info.disabled = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);
		
	-- additional options
	if ( iconType == "cooldown" )
	or ( iconType == "buff" )
	or ( iconType == "reactive" )
	or ( iconType == "wpnenchant" )
	or ( iconType == "totem" )
	then


		local moreOptions;
		if ( iconType == "cooldown" ) then
			moreOptions = TellMeWhen_IconMenu_CooldownOptions;
		elseif ( iconType == "buff" ) then
			moreOptions = TellMeWhen_IconMenu_BuffOptions;
		elseif ( iconType == "reactive" ) then
			moreOptions = TellMeWhen_IconMenu_ReactiveOptions;
		elseif ( iconType == "wpnenchant" ) then
			moreOptions = TellMeWhen_IconMenu_WpnEnchantOptions;
		elseif ( iconType == "totem" ) then
			moreOptions = TellMeWhen_IconMenu_TotemOptions;
		end

		if ( iconType == "buff" ) then
			info = UIDropDownMenu_CreateInfo();
			local sets = TellMeWhen_Settings["Groups"][TellMeWhen_CurrentIcon["groupID"]]["Icons"][TellMeWhen_CurrentIcon["iconID"]]
			if ((sets["StackMin"] ~= nil) and (sets["StackMin"] ~= 0)) or ((sets["StackMin"] ~= nil) and (sets["StackMax"] < 100)) then 
				info.text = L["ICONMENU_STACKSMOD"];
			else
				info.text = L["ICONMENU_STACKS"];
			end
			info.hasArrow = false;
			info.notCheckable = true;
			info.func = function()
				TellMeWhen_CurrentStackIcon = { groupID = TellMeWhen_CurrentIcon["groupID"], iconID = TellMeWhen_CurrentIcon["iconID"] };	
				TellMeWhen_IconConfig_StacksCreate()
				LibStub("AceConfigDialog-3.0"):Open("TellMeWhen Icon Stacks")
			end;
			UIDropDownMenu_AddButton(info);
		end
		
		for index, value in ipairs(moreOptions) do
			info = UIDropDownMenu_CreateInfo();
			info.hasArrow = moreOptions[index]["HasSubmenu"];
			if moreOptions[index]["desc"] then
				info.tooltipTitle = moreOptions[index]["text"];
				info.tooltipText = moreOptions[index]["desc"];
				info.tooltipOnButton = true;
			end
			info.text = moreOptions[index]["text"];
			info.value = moreOptions[index]["value"];
			
			if not info.hasArrow then
				info.func = TellMeWhen_IconMenu_ToggleSetting;
				info.checked = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID][info.value];
				info.notCheckable = false;
			else
				info.notCheckable = true;
			end
			info.keepShownOnClick = true;
			UIDropDownMenu_AddButton(info);
		end

	else
		info = UIDropDownMenu_CreateInfo();
		info.text = L["ICONMENU_OPTIONS"];
		info.disabled = true;
		UIDropDownMenu_AddButton(info);
	end

	if (( name ) and ( name ~= "" )) or ( iconType ~= "" ) then
		info = UIDropDownMenu_CreateInfo();
		info.disabled = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info);
	end

	--copy settings	
	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	info.text = L["COPYSETTINGS"];
	info.func = function()
		TellMeWhen_CurrentCopyIcon["iconID"] = TellMeWhen_CurrentIcon["iconID"];
		TellMeWhen_CurrentCopyIcon["groupID"] = TellMeWhen_CurrentIcon["groupID"];
		TellMeWhen_CopyPanel_Update();
		TellMeWhen_CopyFrame:Show();
		CloseDropDownMenus(); end;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);


	-- clear settings
	if (( name ) and ( name ~= "" )) or ( iconType ~= "" ) then
		info = UIDropDownMenu_CreateInfo();
		info.text = L["ICONMENU_CLEAR"];
		info.func = TellMeWhen_IconMenu_ClearSettings;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info);
	end
end

function TellMeWhen_IconMenu_ShowNameDialog()
	local dialog = StaticPopup_Show("TELLMEWHEN_CHOOSENAME_DIALOG");
	TMWOPENDIALOG = dialog
	local groupID = TellMeWhen_CurrentIcon["groupID"];
	local iconID = TellMeWhen_CurrentIcon["iconID"];
	local icon = _G["TellMeWhen_Group"..groupID.."_Icon"..iconID]
	if dialog and (( icon.iconType == "buff") or (icon.iconType == "")) then
		dialog:SetHeight(190)
		local dd = _G["TellMeWhen_EquivSelectDropdown"]
		dd:SetParent(dialog)
		dd:ClearAllPoints()
		dd:SetPoint("CENTER",dialog,"CENTER",0,-5)
		dd:Show()
		
		
		if TMW_BE.buffs[icon.Name] or TMW_BE.debuffs[icon.Name] then
			local color
			if TMW_BE.buffs[icon.Name] then
				color = "|cFF00FF00";
			elseif TMW_BE.debuffs[icon.Name] then
				color = "|cFFFF0000";
			end
			UIDropDownMenu_SetText(dd,color .. L[icon.Name] .. "|r")
		else
			UIDropDownMenu_SetText(dd,L["CHOOSENAME_DIALOG_DDDEFAULT"])
		end
	else
		_G["TellMeWhen_EquivSelectDropdown"]:Hide()
	end
	
end

function TellMeWhen_IconMenu_ChooseName(text)
	local groupID = TellMeWhen_CurrentIcon["groupID"];
	local iconID = TellMeWhen_CurrentIcon["iconID"];
	TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Name"] = text;
	_G["TellMeWhen_Group"..groupID.."_Icon"..iconID].learnedTexture = nil;
	TellMeWhen_Icon_Update(_G["TellMeWhen_Group"..groupID.."_Icon"..iconID], groupID, iconID);
end

function TellMeWhen_IconMenu_ToggleSetting(icon)
	local groupID = TellMeWhen_CurrentIcon["groupID"];
	local iconID = TellMeWhen_CurrentIcon["iconID"];
	TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID][icon.value] = icon.checked;
	TellMeWhen_Icon_Update(_G["TellMeWhen_Group"..groupID.."_Icon"..iconID], groupID, iconID);
end

function TellMeWhen_IconMenu_ChooseSetting(icon)

	local groupID = TellMeWhen_CurrentIcon["groupID"];
	local iconID = TellMeWhen_CurrentIcon["iconID"];
	TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID][UIDROPDOWNMENU_MENU_VALUE] = icon.value;
	TellMeWhen_Icon_Update(_G["TellMeWhen_Group"..groupID.."_Icon"..iconID], groupID, iconID);
	if ( UIDROPDOWNMENU_MENU_VALUE == "Type" ) then
		CloseDropDownMenus();
	end
end

function TellMeWhen_IconMenu_ClearSettings()
	local groupID = TellMeWhen_CurrentIcon["groupID"];
	local iconID = TellMeWhen_CurrentIcon["iconID"];
	TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID] = CopyTable(TellMeWhen_Icon_Defaults);
	TellMeWhen_Icon_Update(_G["TellMeWhen_Group"..groupID.."_Icon"..iconID], groupID, iconID);
	CloseDropDownMenus();
end


-- -------------
-- RESIZE BUTTON
-- -------------

function TellMeWhen_GUIButton_OnEnter(self, shortText, longText)
	local tooltip = _G["GameTooltip"];
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(tooltip, self);
		tooltip:AddLine(L[shortText], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
		tooltip:AddLine(L[longText], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		tooltip:Show();
	else
		tooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
		tooltip:SetText(L[shortText]);
	end
end

function TellMeWhen_StartSizing(self, button)
	local scalingFrame = self:GetParent();
	scalingFrame.oldScale = scalingFrame:GetScale();
	self.oldCursorX, self.oldCursorY = GetCursorPosition(UIParent);
	scalingFrame.oldX = scalingFrame:GetLeft();
	scalingFrame.oldY = scalingFrame:GetTop();
	self:SetScript("OnUpdate", TellMeWhen_SizeUpdate);
end

function TellMeWhen_SizeUpdate(self)
	local uiScale = UIParent:GetScale();
	local scalingFrame = self:GetParent();
	local cursorX, cursorY = GetCursorPosition(UIParent);

	-- calculate new scale
	local newXScale = scalingFrame.oldScale * (cursorX/uiScale - scalingFrame.oldX*scalingFrame.oldScale) / (self.oldCursorX/uiScale - scalingFrame.oldX*scalingFrame.oldScale) ;
	local newYScale = scalingFrame.oldScale * (cursorY/uiScale - scalingFrame.oldY*scalingFrame.oldScale) / (self.oldCursorY/uiScale - scalingFrame.oldY*scalingFrame.oldScale) ;
	local newScale = max(0.6, newXScale, newYScale);
	scalingFrame:SetScale(newScale);

	-- calculate new frame position
	local newX = scalingFrame.oldX * scalingFrame.oldScale / newScale;
	local newY = scalingFrame.oldY * scalingFrame.oldScale / newScale;
	scalingFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", newX, newY);
end

function TellMeWhen_StopSizing(self, button)
	self:SetScript("OnUpdate", nil)
	local scalingFrame = self:GetParent()
	TellMeWhen_Settings["Groups"][scalingFrame:GetID()]["Scale"] = scalingFrame:GetScale();
	local p = TellMeWhen_Settings["Groups"][scalingFrame:GetID()]["Point"]
	p.point,_,p.relativePoint,p.x,p.y = scalingFrame:GetPoint(1)

end

function TellMeWhen_StopMoving(self, button)
	local scalingFrame = self:GetParent()
	scalingFrame:StopMovingOrSizing();
	local p = TellMeWhen_Settings["Groups"][scalingFrame:GetID()]["Point"]
	p.point,_,p.relativePoint,p.x,p.y = scalingFrame:GetPoint(1)
end


-- -----------------------
-- CONDITION EDITOR DIALOG
-- -----------------------

local _,pclass = UnitClass("Player")

TellMeWhen_CondtMenu_ConditionTypes = {
	{ text = HEALTH, 					value = "HEALTH", 			percent = true,		min=0,		max=100,												},
	{ text = L["CONDITIONPANEL_POWER"], value = "DEFAULT", 			percent = true,		min=0,		max=100, 	tooltip = L["CONDITIONPANEL_POWER_DESC"],	},
	{ text = MANA, 						value = "MANA",				percent = true,		min=0,		max=100,												},
	{ text = ENERGY, 					value = "ENERGY",			percent = true,		min=0,		max=100,												},
	{ text = RAGE, 						value = "RAGE",				percent = true,		min=0,		max=100,												},
	{ text = FOCUS, 					value = "FOCUS",			percent = true,		min=0,		max=100,												},
	{ text = RUNIC_POWER, 				value = "RUNIC_POWER",		percent = true,		min=0,		max=100,												},
	{ text = L["CONDITIONPANEL_EXISTS"],value = "EXISTS",			percent = false,	min=0,		max=1,		noslide = true, nooperator = true,	tooltip = L["CONDITIONPANEL_EXISTS_DESC"], 	},
	{ text = L["CONDITIONPANEL_ALIVE"],	value = "ALIVE",			percent = false, 	min=0,		max=1,		noslide = true, nooperator = true,	tooltip = L["CONDITIONPANEL_ALIVE_DESC"], 	},
	{ text = L["CONDITIONPANEL_ICON"], 	value = "ICON",				percent = false,	min=0,		max=100, 	isicon = true, noslide = true, nooperator = true, tooltip = L["CONDITIONPANEL_ICON_DESC"], },
};	

if pclass == "WARLOCK" then
	tinsert(TellMeWhen_CondtMenu_ConditionTypes,{ text = SOUL_SHARDS, value = "SOUL_SHARDS", percent = false, min=0, max=3, unit = PLAYER,})
elseif pclass == "DRUID" then
	tinsert(TellMeWhen_CondtMenu_ConditionTypes,{ text = ECLIPSE, value = "ECLIPSE", percent = false, min=-100, max=100, unit = PLAYER, tooltip = L["CONDITIONPANEL_ECLIPSE_DESC"], })
	tinsert(TellMeWhen_CondtMenu_ConditionTypes,{ text = L["ECLIPSE_DIRECTION"], value = "ECLIPSE_DIRECTION",percent = false, min=-1, max=1, unit = PLAYER, nooperator = true, tooltip = L["ECLIPSE_DIRECTION_DESC"], })
	tinsert(TellMeWhen_CondtMenu_ConditionTypes,{ text = L["CONDITIONPANEL_COMBO"], value = "COMBO", percent = false, min=0, max=5, })
elseif pclass == "HUNTER" then
	tinsert(TellMeWhen_CondtMenu_ConditionTypes,{ text = HAPPINESS, value = "HAPPINESS", percent = false, min=1, max=3, unit = PET })
elseif pclass == "ROGUE" then
	tinsert(TellMeWhen_CondtMenu_ConditionTypes,{ text = L["CONDITIONPANEL_COMBO"], value = "COMBO", percent = false, min=0, max=5, })
elseif pclass == "PALADIN" then
	tinsert(TellMeWhen_CondtMenu_ConditionTypes,{ text = HOLY_POWER, value = "HOLY_POWER", percent = false, min=0, max=3, unit = PLAYER, })
end

--[[TellMeWhen_CondtMenu_ConditionUnits = {	 --the iconmenu unit submenu is used now because i cheat, but keep this anyway.
	{ value = "player", text = PLAYER },
	{ value = "target", text = TARGET },
	{ value = "targettarget", text = L["ICONMENU_TARGETTARGET"] },
	{ value = "focus", text = FOCUS },
	{ value = "focustarget", text = L["ICONMENU_FOCUSTARGET"] },
	{ value = "pet", text = PET },
	{ value = "pettarget", text = L["ICONMENU_PETTARGET"] },
	{ value = "mouseover", text = L["ICONMENU_MOUSEOVER"] },
	{ value = "mouseovertarget", text = L["ICONMENU_MOUSEOVERTARGET"]  },
	{ value = "vehicle", text = L["ICONMENU_VEHICLE"] },
}]]

TellMeWhen_CondtMenu_Operators = {
	{ text = L["CONDITIONPANEL_EQUALS"], value = "==" },
	{ text = L["CONDITIONPANEL_NOTEQUAL"], value = "~=" },
	{ text = L["CONDITIONPANEL_LESS"], value = "<" },
	{ text = L["CONDITIONPANEL_LESSEQUAL"], value = "<=" },
	{ text = L["CONDITIONPANEL_GREATER"], value = ">" },
	{ text = L["CONDITIONPANEL_GREATEREQUAL"], value = ">=" },
};

TellMeWhen_CondtMenu_ConditionAndOrs = {
	{ text = L["CONDITIONPANEL_AND"], value = "AND" },
	{ text = L["CONDITIONPANEL_OR"], value = "OR" },
};

	
function TellMeWhen_TypeMenuOnClick(self, frame, i)
	UIDropDownMenu_SetSelectedValue(frame, self.value);
	local num = frame:GetParent():GetID()
	local showval = TellMeWhen_Conditions_Typecheck(num,TellMeWhen_CondtMenu_ConditionTypes[i].unit,TellMeWhen_CondtMenu_ConditionTypes[i].isicon, TellMeWhen_CondtMenu_ConditionTypes[i].nooperator, TellMeWhen_CondtMenu_ConditionTypes[i].noslide)
	
	if showval then
		TellMeWhen_ConditionPanel_SetValText(_G["TellMeWhen_ConditionEditorGroup" .. num .. "Slider"])
	else
		_G["TellMeWhen_ConditionEditorGroup" .. num .. "ValText"]:SetText("")
	end
	TellMeWhen_ConditionPanel_SetSliderMinMax(_G["TellMeWhen_ConditionEditorGroup" .. num .. "Slider"])
end

function TellMeWhen_TypeMenu(frame)
	for i=1,#TellMeWhen_CondtMenu_ConditionTypes do
		local info = UIDropDownMenu_CreateInfo();
		info.func = TellMeWhen_TypeMenuOnClick;
		info.text = TellMeWhen_CondtMenu_ConditionTypes[i].text;
		info.tooltipTitle = TellMeWhen_CondtMenu_ConditionTypes[i].text;
		info.tooltipText = TellMeWhen_CondtMenu_ConditionTypes[i].tooltip;
		info.tooltipOnButton = true;
		info.value = TellMeWhen_CondtMenu_ConditionTypes[i].value ;
		info.arg1 = frame;
		info.arg2 = i;
		UIDropDownMenu_AddButton(info);
	end
	UIDropDownMenu_JustifyText( frame, "LEFT" );
end

function TellMeWhen_UnitMenuOnClick(self, frame)
	UIDropDownMenu_SetSelectedValue(frame, self.value);
end

function TellMeWhen_UnitMenu(frame)
	for i=1,#TellMeWhen_IconMenu_SubMenus.Unit do
		local info = UIDropDownMenu_CreateInfo();
		info.func = TellMeWhen_UnitMenuOnClick;
		info.text = TellMeWhen_IconMenu_SubMenus.Unit[i].text;
		info.value = TellMeWhen_IconMenu_SubMenus.Unit[i].value ;
		info.arg1 = frame;
		UIDropDownMenu_AddButton(info);
	end
	UIDropDownMenu_JustifyText( frame, "LEFT" );
end

function TellMeWhen_IconMenuOnClick(self, frame)
	UIDropDownMenu_SetSelectedValue(frame, self.value);
end

function TellMeWhen_IconMenu(frame)
	for i=1,#TellMeWhen_ConditionIcons do
		local info = UIDropDownMenu_CreateInfo();
		info.func = TellMeWhen_IconMenuOnClick;
		info.text = _G[TellMeWhen_ConditionIcons[i]].Name;
		info.value = TellMeWhen_ConditionIcons[i];
		info.tooltipTitle = _G[TellMeWhen_ConditionIcons[i]].Name;
		local text = string.format(L["GROUPICON"], string.match(TellMeWhen_ConditionIcons[i], "TellMeWhen_Group(%d+)_Icon(%d+)")) 
		info.tooltipText = text
		info.tooltipOnButton = true;
		info.arg1 = frame;
		UIDropDownMenu_AddButton(info);
	end
	UIDropDownMenu_JustifyText( frame, "LEFT" );
end

function TellMeWhen_OperatorMenuOnClick(self, frame)
	UIDropDownMenu_SetSelectedValue(frame, self.value);
end

function TellMeWhen_OperatorMenu(frame)
	for i=1,#TellMeWhen_CondtMenu_Operators do
		local info = UIDropDownMenu_CreateInfo();
		info.func = TellMeWhen_OperatorMenuOnClick;
		info.text = TellMeWhen_CondtMenu_Operators[i].text;
		info.value = TellMeWhen_CondtMenu_Operators[i].value ;
		info.arg1 = frame;
		UIDropDownMenu_AddButton(info);
	end
	UIDropDownMenu_JustifyText( frame, "LEFT" );
end

function TellMeWhen_AndOrMenuOnClick(self, frame)
	UIDropDownMenu_SetSelectedValue(frame, self.value);
end

function TellMeWhen_AndOrMenu(frame)
	for i=1,#TellMeWhen_CondtMenu_ConditionAndOrs do
		local info = UIDropDownMenu_CreateInfo();
		info.func = TellMeWhen_AndOrMenuOnClick;
		info.text = TellMeWhen_CondtMenu_ConditionAndOrs[i].text;
		info.value = TellMeWhen_CondtMenu_ConditionAndOrs[i].value ;
		info.arg1 = frame;
		UIDropDownMenu_AddButton(info);
	end
	UIDropDownMenu_JustifyText( frame, "CENTER" );
end

function TellMeWhen_ConditionCheckboxHandler()
	for i=1,TELLMEWHEN_MAXCONDITIONS do
		if i < TELLMEWHEN_MAXCONDITIONS then
			if ( _G["TellMeWhen_ConditionEditorGroup" .. i .. "Check"]:GetChecked() ) then
				_G["TellMeWhen_ConditionEditorGroup" .. i]:Show();
				_G["TellMeWhen_ConditionEditorGroup" .. i+1 .. "Check"]:Show();
			else
				_G["TellMeWhen_ConditionEditorGroup" .. i]:Hide();
				_G["TellMeWhen_ConditionEditorGroup" .. i+1 .. "Check"]:Hide();
				_G["TellMeWhen_ConditionEditorGroup" .. i+1 .. "Check"]:SetChecked(false);
			end
		else
			if ( _G["TellMeWhen_ConditionEditorGroup" .. i .. "Check"]:GetChecked() ) then
				_G["TellMeWhen_ConditionEditorGroup" .. i]:Show();
			else
				_G["TellMeWhen_ConditionEditorGroup" .. i]:Hide();
			end
		end
	end
end

function TellMeWhen_ConditionEditorResetOnClick()
	TellMeWhen_ClearConditionDialog();
end

local conditionstemp = {};
function TellMeWhen_CondtOk(i,conditionstemp)
	if ( _G["TellMeWhen_ConditionEditorGroup" .. i .. "Check"]:GetChecked() ) then
		local condition = {
			ConditionType		= "HEALTH",
			ConditionUnit		= "player",
			ConditionOperator	= "==",
			ConditionLevel		= 0,
			ConditionIcon		= "",
			ConditionAndOr		= "AND",
		};
		condition.ConditionType = UIDropDownMenu_GetSelectedValue(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Type"]) or "HEALTH";
		condition.ConditionUnit = UIDropDownMenu_GetSelectedValue(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Unit"]) or "player";
		condition.ConditionOperator = UIDropDownMenu_GetSelectedValue(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Operator"]) or "==";
		condition.ConditionIcon = UIDropDownMenu_GetSelectedValue(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Icon"]) or "";
		condition.ConditionLevel = tonumber(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Slider"]:GetValue()) or 0;
		condition.ConditionAndOr = UIDropDownMenu_GetSelectedValue(_G["TellMeWhen_ConditionEditorGroup" .. i .. "AndOr"]) or "AND";
		
		table.insert(conditionstemp, condition);
		i=i+1
		if (i <= TELLMEWHEN_MAXCONDITIONS) and ( _G["TellMeWhen_ConditionEditorGroup" .. i .. "Check"]:GetChecked() ) then
			return TellMeWhen_CondtOk(i,conditionstemp)
		else
			return conditionstemp or {}
		end
	else
		return conditionstemp or {}
	end
end

function TellMeWhen_ConditionEditorOkayOnClick()
	local groupID = TellMeWhen_CurrentIcon["groupID"];
	local iconID = TellMeWhen_CurrentIcon["iconID"];
	conditionstemp = {};
	local conditions = TellMeWhen_CondtOk(1,conditionstemp)
	TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Conditions"] = conditions;
end

function TellMeWhen_LoadCondt(i,conditions)
	if ( #conditions >= i ) then
		TellMeWhen_SetUIDropdownText(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Type"], conditions[i].ConditionType, TellMeWhen_CondtMenu_ConditionTypes);
		TellMeWhen_SetUIDropdownText(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Unit"], conditions[i].ConditionUnit, TellMeWhen_IconMenu_SubMenus.Unit);
		TellMeWhen_SetUIDropdownText(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Icon"], conditions[i].ConditionIcon, TellMeWhen_ConditionIcons);
		TellMeWhen_SetUIDropdownText(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Operator"], conditions[i].ConditionOperator, TellMeWhen_CondtMenu_Operators);
		_G["TellMeWhen_ConditionEditorGroup" .. i .. "Slider"]:SetValue(conditions[i].ConditionLevel);
		_G["TellMeWhen_ConditionEditorGroup" .. i .. "Check"]:SetChecked(true);
		if i > 1 then
			TellMeWhen_SetUIDropdownText(_G["TellMeWhen_ConditionEditorGroup" .. i .. "AndOr"], conditions[i].ConditionAndOr, TellMeWhen_CondtMenu_ConditionAndOrs);
		end
	end
	i=i+1
	if ( #conditions >= i ) and (i <= TELLMEWHEN_MAXCONDITIONS) then
		TellMeWhen_LoadCondt(i,conditions)
	end
end

function TellMeWhen_ConditionEditor_CreateGroups()
	TELLMEWHEN_MAXCONDITIONS = TellMeWhen_Settings["NumCondits"] or TELLMEWHEN_MAXCONDITIONS
	for i=2,TELLMEWHEN_MAXCONDITIONS do
		local condtgrp = _G["TellMeWhen_ConditionEditorGroup"..i] or CreateFrame("Frame","TellMeWhen_ConditionEditorGroup"..i,TellMeWhen_ConditionEditorFrame,"TellMeWhen_ConditionEditorGroup",i)

		condtgrp:SetPoint("TOPLEFT",_G["TellMeWhen_ConditionEditorGroup"..i-1],"BOTTOMLEFT",0,0)
	end
	TellMeWhen_SetText(); 
	TellMeWhen_ConditionEditorFrame:SetHeight(70+(TELLMEWHEN_MAXCONDITIONS*90))
	for i=1,TELLMEWHEN_MAXCONDITIONS do
		UIDropDownMenu_Initialize(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Icon"], TellMeWhen_IconMenu, "DROPDOWN");
	end
end

function TellMeWhen_LoadConditionDialog()
	local groupID = TellMeWhen_CurrentIcon["groupID"];
	local iconID = TellMeWhen_CurrentIcon["iconID"];
	local conditions = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Conditions"] or {};

	TellMeWhen_LoadCondt(1,conditions)

	TellMeWhen_ConditionCheckboxHandler();
	TellMeWhen_ConditionEditorFrame:Show();
end

function TellMeWhen_ClearConditionDialog()
	for i=1,TELLMEWHEN_MAXCONDITIONS do
		UIDropDownMenu_SetSelectedValue(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Type"], "HEALTH");
		UIDropDownMenu_SetSelectedValue(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Unit"], "player");
		UIDropDownMenu_SetSelectedValue(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Icon"], "");
		UIDropDownMenu_SetSelectedValue(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Operator"], "==");
		UIDropDownMenu_SetText(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Type"], "");
		UIDropDownMenu_SetText(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Unit"], "");
		UIDropDownMenu_SetText(_G["TellMeWhen_ConditionEditorGroup" .. i .. "Operator"], "");
		_G["TellMeWhen_ConditionEditorGroup" .. i .. "Slider"]:SetValue(0);
		_G["TellMeWhen_ConditionEditorGroup" .. i .. "Check"]:SetChecked(false);
		_G["TellMeWhen_ConditionEditorGroup" .. i .. "Unit"]:Show()
		_G["TellMeWhen_ConditionEditorGroup" .. i .. "Operator"]:Show()
		_G["TellMeWhen_ConditionEditorGroup" .. i .. "Icon"]:Hide()
	end
	for i=2,TELLMEWHEN_MAXCONDITIONS do
		UIDropDownMenu_SetSelectedValue(_G["TellMeWhen_ConditionEditorGroup" .. i .. "AndOr"], "AND");
		UIDropDownMenu_SetText(_G["TellMeWhen_ConditionEditorGroup" .. i .. "AndOr"], "");
	end
	TellMeWhen_ConditionCheckboxHandler();
	TellMeWhen_ConditionEditorFrame:Show();
	TellMeWhen_SetText()
end

function TellMeWhen_SetUIDropdownText(frame, value, tab)
	UIDropDownMenu_SetSelectedValue(frame, value);
	local num = frame:GetParent():GetID()
	TellMeWhen_ConditionPanel_SetSliderMinMax(_G["TellMeWhen_ConditionEditorGroup" .. num .. "Slider"])
	if tab == TellMeWhen_CondtMenu_ConditionTypes then
		for i=1,#tab do
			if (tab[i].value == value) then
				TellMeWhen_Conditions_Typecheck(num,tab[i].unit, tab[i].isicon, tab[i].nooperator, tab[i].noslide)
			end
		end
	end
	if tab == TellMeWhen_ConditionIcons then
		for i=1,#tab do
			if ( tab[i] == value ) then
				UIDropDownMenu_SetText(frame, _G[tab[i]].Name);
				return;
			end
		end
	end
	for i=1,#tab do
		if ( tab[i].value == value ) then
			UIDropDownMenu_SetText(frame, tab[i].text);
			return;
		end
	end
	UIDropDownMenu_SetText(frame, "");
end

function TellMeWhen_SetText(num)
	TellMeWhen_ConditionEditorFrameCancelButton:SetText(L["CANCEL"]);
	TellMeWhen_ConditionEditorFrameOkayButton:SetText(L["OKAY"]);
	TellMeWhen_ConditionEditorFrameResetButton:SetText(L["CONDITIONPANEL_RESET"]);
	TellMeWhen_ConditionEditorFS1:SetText(L["CONDITIONPANEL_TITLE"])
	TellMeWhen_ConditionEditorFS2:SetText(L["CONDITIONPANEL_ANDOR"])
	for i=1,TELLMEWHEN_MAXCONDITIONS do
		if num then i=num end
		if not _G["TellMeWhen_ConditionEditorGroup" .. i .. "TextType"] then return end
		_G["TellMeWhen_ConditionEditorGroup" .. i .. "TextType"]:SetText(L["CONDITIONPANEL_TYPE"])
		_G["TellMeWhen_ConditionEditorGroup" .. i .. "TextUnitOrIcon"]:SetText(L["CONDITIONPANEL_UNIT"])
		_G["TellMeWhen_ConditionEditorGroup" .. i .. "TextUnitDef"]:SetText("")
		_G["TellMeWhen_ConditionEditorGroup" .. i .. "TextOperator"]:SetText(L["CONDITIONPANEL_OPERATOR"])
		_G["TellMeWhen_ConditionEditorGroup" .. i .. "TextValue"]:SetText(L["CONDITIONPANEL_VALUEN"])
		if num then break end
	end
end

function TellMeWhen_ConditionPanel_SetValText(self)
	if TELLMEWHEN_INITIALIZED then
		local val = self:GetValue()
		local type = UIDropDownMenu_GetSelectedValue(_G[self:GetParent():GetName() .. "Type"])
		if type == "ECLIPSE_DIRECTION" then
			if val == -1 then val = L["MOON"] end
			if val == 1 then val = L["SUN"] end
		end
		if type == "HAPPINESS" then
			val = _G["PET_HAPPINESS" .. val]
		end
		if type == "ICON" then
			val = ""
		end
		for k,v in pairs(TellMeWhen_CondtMenu_ConditionTypes) do
			if (v.value == type) and (v.percent) then
				val = val .. "%"
			end
		end
		if _G[self:GetParent():GetName() .. "ValText"] then
			_G[self:GetParent():GetName() .. "ValText"]:SetText(val)
		else
			TellMeWhen_ConditionEditor_CreateGroups()
		end
	end
end

function TellMeWhen_ConditionPanel_SetSliderMinMax(self)
	local type = UIDropDownMenu_GetSelectedValue(_G[self:GetParent():GetName() .. "Type"])
	for k,v in pairs(TellMeWhen_CondtMenu_ConditionTypes) do
		if (v.value == type) then
			self:SetMinMaxValues(v.min,v.max)
		end
	end
end

function TellMeWhen_Conditions_Typecheck(num,unit,isicon,nooperator,noslide)
	_G["TellMeWhen_ConditionEditorGroup" .. num .. "Icon"]:Hide() --it bugs soemtimes so just do it by default
	local showval = true
	TellMeWhen_SetText(num)
	_G["TellMeWhen_ConditionEditorGroup" .. num .. "Unit"]:Show()
	if unit then
		_G["TellMeWhen_ConditionEditorGroup" .. num .. "Unit"]:Hide()
		_G["TellMeWhen_ConditionEditorGroup" .. num .. "TextUnitDef"]:SetText(unit)
	end
	if nooperator then
		_G["TellMeWhen_ConditionEditorGroup" .. num .. "TextOperator"]:SetText("")
		_G["TellMeWhen_ConditionEditorGroup" .. num .. "Operator"]:Hide()
	else
		_G["TellMeWhen_ConditionEditorGroup" .. num .. "Operator"]:Show()
	end
	if noslide then
		showval = false
		_G["TellMeWhen_ConditionEditorGroup" .. num .. "Slider"]:Hide()
		_G["TellMeWhen_ConditionEditorGroup" .. num .. "TextValue"]:SetText("")
		_G["TellMeWhen_ConditionEditorGroup" .. num .. "ValText"]:Hide()
	else
		_G["TellMeWhen_ConditionEditorGroup" .. num .. "ValText"]:Show()
		_G["TellMeWhen_ConditionEditorGroup" .. num .. "Slider"]:Show()
	end
	if isicon then
		showval = false
		_G["TellMeWhen_ConditionEditorGroup" .. num .. "TextUnitOrIcon"]:SetText(L["ICONTOCHECK"])
		_G["TellMeWhen_ConditionEditorGroup" .. num .. "Icon"]:Show()
		_G["TellMeWhen_ConditionEditorGroup" .. num .. "Unit"]:Hide()
	else
		_G["TellMeWhen_ConditionEditorGroup" .. num .. "Icon"]:Hide()
	end
	return showval
end

function TellMeWhen_ConditionPanel_NumCheck(val)
	local number = 0
	for groupID = 1, TELLMEWHEN_MAXGROUPS do
		for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
			if #TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Conditions"] > number then
				number = #TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Conditions"]
			end
		end
	end
	if val < number then
		local dialog = StaticPopup_Show("TELLMEWHEN_CONDT_WARN")
		if dialog then dialog.data = val end
	else
		TellMeWhen_Settings["NumCondits"] = val
		TellMeWhen_ConditionEditor_CreateGroups()
	end
end



-- ----------
-- COPY PANEL
-- ----------

local TMW_TEMPENABLED = {}
for qqq=1,TELLMEWHEN_MAXGROUPS do
	TMW_TEMPENABLED[qqq] = {
	["C"] = false,
	["E"] = false,
	["P"] = false,
	["S"] = false,
	}
end

function TellMeWhen_CopyPanel_Update(one)
	if TELLMEWHEN_INITIALIZED then
		local groupn = TellMeWhen_CopyFrameGroupSlider:GetValue()
		local iconn = TellMeWhen_CopyFrameIconSlider:GetValue()
		local curgroupID = TellMeWhen_CurrentCopyIcon["groupID"];
		local curiconID = TellMeWhen_CurrentCopyIcon["iconID"];
		TellMeWhen_CopyFrameTitleFS:SetText(L["COPYPANEL_TITLE"])
		TellMeWhen_CopyFrameCancelButton:SetText(L["CANCEL"]);
		TellMeWhen_CopyFrameOkayButton:SetText(L["COPY"]);
		TellMeWhen_CopyFrameEnableGroupButton:SetText(string.format(L["GENABLEBUTTON"],groupn))
		TellMeWhen_CopyFrameGroupFS:SetText(L["COPYPANEL_GROUP"] .. groupn)
		TellMeWhen_CopyFrameIconFS:SetText(L["COPYPANEL_ICON"] .. iconn)
		TellMeWhen_CopyFrameFromFS:SetText(L["FROM"])
		TellMeWhen_CopyFrameToFS:SetText(L["TO"])
		TellMeWhen_CopyFrameFromNumbersFS:SetText(format(L["GROUPICON"],groupn,iconn))
		TellMeWhen_CopyFrameToNumbersFS:SetText(format(L["GROUPICON"],curgroupID,curiconID))
		local group = _G["TellMeWhen_Group".. groupn] or CreateFrame("Frame","TellMeWhen_Group"..groupID, UIParent, "TellMeWhen_GroupTemplate");
		if one == 1 then
			TMW_TEMPENABLED[groupn]["C"] = true
			TMW_TEMPENABLED[groupn]["E"] = TellMeWhen_Settings["Groups"][groupn]["Enabled"]
			TMW_TEMPENABLED[groupn]["P"] = group.activePriSpec
			TMW_TEMPENABLED[groupn]["S"] = group.activeSecSpec
			TellMeWhen_Settings["Groups"][groupn]["Enabled"] = true
			TellMeWhen_Settings["Groups"][groupn]["PrimarySpec"] = true
			TellMeWhen_Settings["Groups"][groupn]["SecondarySpec"] = true
			TellMeWhen_Update()
			TellMeWhen_CopyPanel_Update()
		end
		TellMeWhen_CopyFrameIconSlider:SetMinMaxValues(1,(group.rows*group.columns))
		if not group.genabled then
			TellMeWhen_CopyFrameEnableGroupButton:Show()
			TellMeWhen_CopyFrameIconSlider:Hide()
		else
			TellMeWhen_CopyFrameEnableGroupButton:Hide()
			TellMeWhen_CopyFrameIconSlider:Show()
		end
		local fromicon = _G["TellMeWhen_Group".. groupn .. "_Icon" .. iconn]
		local toicon = _G["TellMeWhen_Group".. curgroupID .. "_Icon" .. curiconID]
		if fromicon then
			local fromtex = fromicon.texture:GetTexture()
			TellMeWhen_CopyFrameTextureFrom:SetTexture(fromtex)
			TellMeWhen_CopyFrameFromNameFS:SetText(gsub(fromicon.Name,";",";\r\n"))
		else
			TellMeWhen_CopyFrameTextureFrom:SetTexture(nil)
			TellMeWhen_CopyFrameFromNameFS:SetText("")
		end
		if toicon then
			local totex = toicon.texture:GetTexture()
			TellMeWhen_CopyFrameTextureTo:SetTexture(totex)
			TellMeWhen_CopyFrameToNameFS:SetText(gsub(toicon.Name,";",";\r\n"))
		else
			TellMeWhen_CopyFrameTextureTo:SetTexture(nil)
			TellMeWhen_CopyFrameToNameFS:SetText("")
		end
		TellMeWhen_CopyFrame:SetFrameLevel(TellMeWhen_ConditionEditorFrame:GetFrameLevel() + 5)
	end
end

function TellMeWhen_CopyPanel_Copy()
	if TELLMEWHEN_INITIALIZED then
		local groupn = TellMeWhen_CopyFrameGroupSlider:GetValue()
		local iconn = TellMeWhen_CopyFrameIconSlider:GetValue()
		local curgroupID = TellMeWhen_CurrentCopyIcon["groupID"];
		local curiconID = TellMeWhen_CurrentCopyIcon["iconID"];
		local fromicon = _G["TellMeWhen_Group".. groupn .. "_Icon" .. iconn]
		local toicon = _G["TellMeWhen_Group".. curgroupID .. "_Icon" .. curiconID]
		local fromiconsettings = TellMeWhen_Settings["Groups"][groupn]["Icons"][iconn]
		local toiconsettings = TellMeWhen_Settings["Groups"][curgroupID]["Icons"][curiconID]
		for k,v in pairs(toiconsettings) do
			toiconsettings[k] = fromiconsettings[k]
		end
		for a,b in pairs(TMW_TEMPENABLED) do
			if b["C"] == true then
				TellMeWhen_Settings["Groups"][a]["Enabled"] = b["E"]
				TellMeWhen_Settings["Groups"][a]["PrimarySpec"] = b["P"]
				TellMeWhen_Settings["Groups"][a]["SecondarySpec"] = b["S"]
			end
		end
		for qqq=1,TELLMEWHEN_MAXGROUPS do
			TMW_TEMPENABLED[qqq] = {
			["C"] = false,
			["E"] = false,
			["P"] = false,
			["S"] = false,
			}
		end
		TellMeWhen_Update()
	end
end

function TellMeWhen_CopyPanel_Cancel()
	if TELLMEWHEN_INITIALIZED then
		for a,b in pairs(TMW_TEMPENABLED) do
			if b["C"] == true then
				TellMeWhen_Settings["Groups"][a]["Enabled"] = b["E"]
				TellMeWhen_Settings["Groups"][a]["PrimarySpec"] = b["P"]
				TellMeWhen_Settings["Groups"][a]["SecondarySpec"] = b["S"]
			end
		end
		for qqq=1,TELLMEWHEN_MAXGROUPS do
			TMW_TEMPENABLED[qqq] = {
			["C"] = false,
			["E"] = false,
			["P"] = false,
			["S"] = false,
			}
		end
		TellMeWhen_Update()
	end
end


-- ------------
-- LDB plugin
-- ------------

local popupFrame = CreateFrame("Frame", "TellMeWhenLaunchermenu", UIParent, "UIDropDownmenuTemplate")
local TMWmenu = {}
local TMWmenuNeedsUpdate = true

local function updateTMWmenu()
    TMWmenuNeedsUpdate = nil
    TMWmenu = wipe(TMWmenu)
    for i = 1,TELLMEWHEN_MAXGROUPS do
        local tmp = {
            text = L["COPYPANEL_GROUP"] .. i,
            tooltipTitle = L["COPYPANEL_GROUP"] .. i,
			tooltipText = L["COPYPANEL_GROUP"] .. i,
			disabled  = false,
			notCheckable = true,
			tooltipOnButton = true,
			hasArrow = true,
            menuList = {
				{
					text = L["UIPANEL_ENABLEGROUP"],
					checked = TellMeWhen_Settings.Groups[i].Enabled,
					tooltipTitle = L["UIPANEL_ENABLEGROUP"],
					tooltipText = L["UIPANEL_TOOLTIP_ENABLEGROUP"],
					tooltipOnButton = true,
					keepShownOnClick = true,
					func = function()
						TellMeWhen_Settings.Groups[i].Enabled = not TellMeWhen_Settings.Groups[i].Enabled
						TellMeWhen_Group_Update(i)
						TMWmenuNeedsUpdate = true
					end,
				},
				{
					text = L["UIPANEL_PRIMARYSPEC"],
					checked = TellMeWhen_Settings.Groups[i].PrimarySpec,
					tooltipTitle = L["UIPANEL_PRIMARYSPEC"],
					tooltipText = L["UIPANEL_TOOLTIP_PRIMARYSPEC"],
					tooltipOnButton = true,
					keepShownOnClick = true,
					func = function()
						TellMeWhen_Settings.Groups[i].PrimarySpec = not TellMeWhen_Settings.Groups[i].PrimarySpec
						TellMeWhen_Group_Update(i)
						TMWmenuNeedsUpdate = true
					end,
				},
				{
					text = L["UIPANEL_SECONDARYSPEC"],
					checked = TellMeWhen_Settings.Groups[i].SecondarySpec,
					tooltipTitle = L["UIPANEL_SECONDARYSPEC"],
					tooltipText = L["UIPANEL_TOOLTIP_SECONDARYSPEC"],
					tooltipOnButton = true,
					keepShownOnClick = true,
					func = function()
						TellMeWhen_Settings.Groups[i].SecondarySpec = not TellMeWhen_Settings.Groups[i].SecondarySpec
						TellMeWhen_Group_Update(i)
						TMWmenuNeedsUpdate = true
					end,
				},
				{
					text = L["UIPANEL_ONLYINCOMBAT"],
					checked = TellMeWhen_Settings.Groups[i].OnlyInCombat,
					tooltipTitle = L["UIPANEL_ONLYINCOMBAT"],
					tooltipText = L["UIPANEL_TOOLTIP_ONLYINCOMBAT"],
					tooltipOnButton = true,
					keepShownOnClick = true,
					func = function()
						TellMeWhen_Settings.Groups[i].OnlyInCombat = not TellMeWhen_Settings.Groups[i].OnlyInCombat
						TellMeWhen_Group_Update(i)
						TMWmenuNeedsUpdate = true
					end,
				},
			},
			
        }
        table.insert(TMWmenu, tmp)
    end
end

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:GetDataObjectByName("TellMeWhen") or     
ldb:NewDataObject("TellMeWhen", {
	type = "launcher", 
	icon = "Interface\\Icons\\INV_Misc_PocketWatch_01", 
})

dataobj.OnClick = function(self, button)         
   if button == "RightButton" then
        if TMWmenuNeedsUpdate then
            updateTMWmenu()
        end
        if #TMWmenu > 0 then
            EasyMenu(TMWmenu, popupFrame, self, 20, 4, "TMWmenu")
        end
    else
        TellMeWhen_LockToggle()        
    end
end

dataobj.OnTooltipShow = function(tt)
    tt:AddLine(L["ICON_TOOLTIP1"])
    tt:AddLine(L["LDB_TOOLTIP1"])
    tt:AddLine(L["LDB_TOOLTIP2"])
end

