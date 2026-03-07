
local L = LibStub("AceLocale-3.0"):NewLocale("TellMeWhen", "enUS", true)

L["CMD_RESET"] = "reset";
L["CMD_OPTIONS"] = "options";
L["CMD_ERROR"] = "Cannot toggle TellMeWhen config in combat";
L["GROUPRESETMSG"] = "TellMeWhen Group %d position reset.";
L["ICON_TOOLTIP1"] = "TellMeWhen";
L["ICON_TOOLTIP2"] = "Right click for icon options. More options are in the Blizzard interface options menu. Type /tmw to lock and enable addon.";
L["LDB_TOOLTIP1"] = "|cff7fffffLeft-click|r to toggle the group locks";
L["LDB_TOOLTIP2"] = "|cff7fffffRight-click|r to show/hide specifc groups";

L["RESIZE"] = "Resize";
L["RESIZE_TOOLTIP"] = "Click and drag to change size";

L["HPSSWARN"] = "Warning! Any icon conditions that you had set that checked for holy power or soul shards may be messed up! Check them to prevent later confusion!";
L["CONDTWARN"] = "Warning! You have reduced the number of conditions shown in the editor below the highest number of conditions that any one icon has. This can cause these conditions to stop functioning. Are you sure you want to do this?"
L["RLWARN"] = "Warning! A UI Reload is required to fully reset TMW because the number of groups changed. Reload now?"


-- -------------
-- ICONMENU
-- -------------

L["ICONMENU_CHOOSENAME"] = "Choose spell/item/buff/etc.";
L["ICONMENU_ENABLE"] = "Enable icon";
L["CHOOSENAME_EQUIVS_TOOLTIP"] = "You can select a predefined set of buffs/debuffs in this menu.";
L["CHOOSENAME_DIALOG_DDDEFAULT"] = "Predefined Spell Sets";
L["CHOOSENAME_DIALOG"] = "Enter the Name or Id of the Spell/Ability/Item/Buff/Debuff you want this icon to monitor. You can add multiple Buffs/Debuffs by seperating them with ';'\r\nPET ABILITIES should use SpellIDs.";


L["ICONMENU_ALPHA"] = "Alpha for Group %d, Icon %d";
L["ICONMENU_TYPE"] = "Icon type";
L["ICONMENU_COOLDOWN"] = "Cooldown";
L["ICONMENU_BUFFDEBUFF"] = "Buff/Debuff";
L["ICONMENU_REACTIVE"] = "Reactive spell or ability";
L["ICONMENU_WPNENCHANT"] = "Temporary weapon enchant";
L["ICONMENU_TOTEM"] = "Totem/non-MoG Ghoul";

L["ICONMENU_OPTIONS"] = "More options";

L["ICONMENU_COOLDOWNTYPE"] = "Cooldown type";
L["ICONMENU_SPELL"] = "Spell or ability";
L["ICONMENU_ITEM"] = "Item";

L["ICONMENU_SHOWWHEN"] = "Show icon when";
L["ICONMENU_USABLE"] = "Usable";
L["ICONMENU_UNUSABLE"] = "Unusable";

L["ICONMENU_BUFFTYPE"] = "Buff or debuff?";
L["ICONMENU_BUFF"] = "Buff";
L["ICONMENU_DEBUFF"] = "Debuff";

L["ICONMENU_UNIT"] = "Unit to watch";
L["ICONMENU_TARGETTARGET"] = "Target's target";
L["ICONMENU_FOCUSTARGET"] = "Focus' target";
L["ICONMENU_PETTARGET"] = "Pet's target";
L["ICONMENU_MOUSEOVER"] = "Mouseover";
L["ICONMENU_MOUSEOVERTARGET"] = "Mouseover's target";
L["ICONMENU_VEHICLE"] = "Vehicle";

L["ICONMENU_BUFFSHOWWHEN"] = "Show when buff/debuff";
L["ICONMENU_PRESENT"] = "Present";
L["ICONMENU_ABSENT"] = "Absent";
L["ICONMENU_ALWAYS"] = "Always";

L["ICONMENU_ONLYMINE"] = "Only show if cast by self";
L["ICONMENU_SHOWTIMER"] = "Show timer";
L["ICONMENU_SHOWTIMERTEXT"] = "Show timer number";
L["ICONMENU_SHOWTIMERTEXT_DESC"] = "This is only applicable if 'Show timer' is checked";

L["ICONMENU_BARS"] = "Bars";
L["ICONMENU_SHOWPBAR"] = "Show power bar";
L["ICONMENU_SHOWCBAR"] = "Show cooldown/timer bar";
L["ICONMENU_INVERTBARS"] = "Fill bars up";
L["ICONMENU_DURATIONANDCD"] = "Duration > CD";

L["ICONMENU_REACT"] = "Unit Reaction";
L["ICONMENU_FRIEND"] = "Friendly Units";
L["ICONMENU_HOSTILE"] = "Hostile Units";
L["ICONMENU_EITHER"] = "All Units";

L["ICONMENU_RANGECHECK"] = "Range Check?";
L["ICONMENU_MANACHECK"] = "Power Check?";
L["ICONMENU_COOLDOWNCHECK"] = "Cooldown Check?";

L["ICONMENU_STACKS"] = "Stacks";
L["ICONMENU_STACKSMOD"] = "Stacks |cFFFF5959(Modified)|r";
L["ICONMENU_STACKS_HEADER"] = "Stacks for Group %d, Icon %d";
L["ICONMENU_STACKS_MIN"] = "Minimum stacks to show";
L["ICONMENU_STACKS_MAX"] = "Maximum stacks to show";
L["ICONMENU_STACKS_MIN_DESC"] = "Minimum number of stacks of the aura needed to show the icon";
L["ICONMENU_STACKS_MAX_DESC"] = "Maximum number of stacks of the aura needed to show the icon";

L["ICONMENU_SETALPHA"] = "Set Alpha Level";
L["ICONMENU_SETALPHAMOD"] = "Set Alpha Level |cFFFF5959(Modified)|r";
L["ICONMENU_ALPHA"] = "Alpha";
L["ICONALPHAPANEL_ALPHA"] = "Usable/Present Alpha Level";
L["ICONALPHAPANEL_ALPHA_DESC"] = "Slide to set the alpha level for the icon when the ability is usable/present";
L["ICONALPHAPANEL_UNALPHA"] = "Unusable/Absent Alpha Level";
L["ICONALPHAPANEL_UNALPHA_DESC"] = "Slide to set the alpha level for the icon when ability is unusable/absent";
L["ICONALPHAPANEL_FAKEHIDDEN"] = "Fake Hidden"
L["ICONALPHAPANEL_FAKEHIDDEN_DESC"] = "Makes the icon be hidden all the time, but while still enabled in order to allow the conditions of other icons to check this icon."

L["ICONMENU_WPNENCHANTTYPE"] = "Weapon slot to monitor";
L["ICONMENU_MAINHAND"] = "Mainhand";
L["ICONMENU_OFFHAND"] = "Offhand";
L["ICONMENU_THROWN"] = "Thrown Weapon";

L["ICONMENU_CLEAR"] = "Clear settings";


-- -------------
-- UI PANEL
-- -------------

L["UIPANEL_SUBTEXT1"] = "These options allow you to change the number, arrangement, and behavior of reminder icons.";
L["UIPANEL_SUBTEXT2"] = "Icons work when locked. When unlocked, you can move/size icon groups and right click individual icons for more settings. You can also type /tellmewhen or /tmw to lock/unlock.";
L["UIPANEL_ICONGROUP"] = "Icon group ";
L["UIPANEL_MAINOPT"] = "Main Options";
L["UIPANEL_GROUPS"] = "Groups";
L["UIPANEL_COLORS"] = "Colors";
L["UIPANEL_ENABLEGROUP"] = "Enable Group";
L["UIPANEL_ROWS"] = "Rows";
L["UIPANEL_COLUMNS"] = "Columns";
L["UIPANEL_ONLYINCOMBAT"] = "Only show in combat";
L["UIPANEL_PRIMARYSPEC"] = "Primary Spec";
L["UIPANEL_SECONDARYSPEC"] = "Secondary Spec";
L["UIPANEL_GROUPRESETHEADER"] = "Reset Position";
L["UIPANEL_GROUPRESET"] = "Reset Position";
L["UIPANEL_TOOLTIP_GROUPRESET"] = "Reset this group's position";
L["UIPANEL_ALLRESET"] = "Reset all";
L["UIPANEL_TOOLTIP_ALLRESET"] = "Reset DATA and POSITION of all icons and groups";
L["UIPANEL_LOCK"] = "Lock AddOn";
L["UIPANEL_LOCKUNLOCK"] = "Lock/Unlock AddOn";
L["UIPANEL_UNLOCK"] = "Unlock AddOn";
L["UIPANEL_BARTEXTURE"] = "Bar Texture";
L["UIPANEL_NOCOUNT"] = "Toggle Timer Text";
L["UIPANEL_NOCOUNT_DESC"] = "Enables/disables the text that displays the cooldown on the icon. It will only be shown if the icon's timer is enabled, this option is enabled, and OMNICC IS INSTALLED";
L["UIPANEL_BARIGNOREGCD"] = "Bars Ignore GCD";
L["UIPANEL_BARIGNOREGCD_DESC"] = "If checked, cooldown bars will not change values if the cooldown triggered is a global cooldown";
L["UIPANEL_CLOCKIGNOREGCD"] = "Timers Ignore GCD";
L["UIPANEL_CLOCKIGNOREGCD_DESC"] = "If checked, timers and the cooldown clock will not trigger from a global cooldown";
L["UIPANEL_UPDATEINTERVAL"] = "Update Interval";
L["UIPANEL_TOOLTIP_UPDATEINTERVAL"] = "Sets how often (in seconds) icons are checked for show/hide, alpha, conditions, etc. Does not affect overly bars. Zero is as fast as possible. Lower values can have a significant impact on framerate for low-end computers";
L["UIPANEL_ICONSPACING"] = "Icon Spacing";
L["UIPANEL_ICONSPACING_DESC"] = "Distance that icons within a group are away from eachother";
L["UIPANEL_NUMGROUPS"] = "Number of Groups";
L["UIPANEL_NUMGROUPS_DESC"] = "Changes the number of groups available. Requires UI Reload to take effect.";
L["UIPANEL_RELOAD"] = "Reload UI";

L["UIPANEL_NUMCONDTS"] = "Number of conditions";
L["UIPANEL_NUMCONDTS_DESC"] = "Changes the number of conditions available in the condition editor.";
L["UIPANEL_TOOLTIP_ENABLEGROUP"] = "Show and enable this group of icons";
L["UIPANEL_TOOLTIP_ROWS"] = "Set the number of icon rows in this group";
L["UIPANEL_TOOLTIP_COLUMNS"] = "Set the number of icon columns in this group";
L["UIPANEL_TOOLTIP_ONLYINCOMBAT"] = "Check to only show this group of icons while in combat";
L["UIPANEL_TOOLTIP_PRIMARYSPEC"] = "Check to show this group of icons while your primary spec is active";
L["UIPANEL_TOOLTIP_SECONDARYSPEC"] = "Check to show this group of icons while your secondary spec is active";
L["UIPANEL_COLOR"] = "Cooldown/Duration Bar Color";
L["UIPANEL_COLOR_COMPLETE"] = "CD/Duration Complete";
L["UIPANEL_COLOR_STARTED"] = "CD/Duration Begin";
L["UIPANEL_COLOR_COMPLETE_DESC"] = "Color of the cooldown/duration overlay bar when the cooldown/duration is complete";
L["UIPANEL_COLOR_STARTED_DESC"] = "Color of the cooldown/duration overlay bar when the cooldown/duration has just begun";
L["UIPANEL_DRAWEDGE"] = "Highlight timer edge";
L["UIPANEL_DRAWEDGE_DESC"] = "Highlights the edge of the cooldown timer (clock animation) to increase visibility";
L["UIPANEL_COLOR_OOR"] = "Out of range color";
L["UIPANEL_COLOR_OOR_DESC"] = "Tint and alpha of the icon when you are not in range of the target to cast the spell";
L["UIPANEL_COLOR_OOM"] = "Out of power color";
L["UIPANEL_COLOR_OOM_DESC"] = "Tint and alpha of the icon when you lack the mana/rage/energy/focus/runicpower to cast the spell";
L["UIPANEL_COLOR_DESC"] = "The following options only affect the colors of icons when they are set to show all the time";
L["UIPANEL_COLOR_PRESENT"] = "Present color";
L["UIPANEL_COLOR_PRESENT_DESC"] = "The tint of the icon when the buff/debuff/enchant/totem is present and the icon is set to always show.";
L["UIPANEL_COLOR_ABSENT"] = "Absent color";
L["UIPANEL_COLOR_ABSENT_DESC"] = "The tint of the icon when the buff/debuff/enchant/totem is absent and the icon is set to always show.";
L["UIPANEL_STANCE"] = "Show while in:";
L["NONE"] = "None of the below";
L["CASTERFORM"] = "Caster Form";
-- -------------
-- CONDITION PANEL
-- -------------

L["CONDITIONPANEL_TITLE"] = "TellMeWhen Condition Editor";
L["ICONMENU_ADDCONDITION"] = "Add condition";
L["ICONMENU_EDITCONDITION"] = "|cFFFF5959Edit|r condition";
L["IS_CONDITION"] = "Is Condition";
L["CONDITIONPANEL_ICON"] = "Icon Shown";
L["ICONTOCHECK"] = "Icon to check";
L["MOON"] = "Moon";
L["SUN"] = "Sun";
L["CONDITIONPANEL_TYPE"] = "Type";
L["CONDITIONPANEL_UNIT"] = "Unit";
L["CONDITIONPANEL_OPERATOR"] = "Operator";
L["CONDITIONPANEL_VALUE"] = "Percent";
L["CONDITIONPANEL_VALUEN"] = "Value";
L["CONDITIONPANEL_ANDOR"] = "And / Or";
L["CONDITIONPANEL_AND"] = "And";
L["CONDITIONPANEL_OR"] = "Or";
L["CONDITIONPANEL_POWER"] = "Primary Resource";
L["CONDITIONPANEL_COMBO"] = "Combo Points";
L["CONDITIONPANEL_EXISTS"] = "Unit Exists";
L["CONDITIONPANEL_EXISTS_DESC"] = "The condition will pass if the unit specified exists."
L["CONDITIONPANEL_ALIVE"] = "Unit is Alive";
L["CONDITIONPANEL_ALIVE_DESC"] = "The condition will pass if the unit specified is alive."
L["CONDITIONPANEL_POWER_DESC"] = [=[Will check for energy if the unit is a druid in cat form, 
rage if the unit is a warrior, etc.]=]
L["ECLIPSE_DIRECTION"] = "Eclipse Direction";
L["ECLIPSE_DIRECTION_DESC"] = [=['-1' will be interpereted as going towards the left(moon side).
'1' will be interperted as going towards the right(sun side).]=]
L["CONDITIONPANEL_ECLIPSE_DESC"] = [=[Eclipse has a range of -100 (a lunar eclipse) to 100 (a solar eclipse). 
Input -80 if you want the icon to work with a value of 80 lunar power.]=]
L["CONDITIONPANEL_ICON_DESC"] = [=[The condition will pass if the icon specified is currently shown with an alpha above 0%. 
If you don't want to display the icons that are being checked, check 'Fake Hidden' in the icon's alpha settings.
The group of the icon being checked must also be shown in order to check the icon]=]
L["CONDITIONPANEL_EQUALS"] = "Equals";
L["CONDITIONPANEL_NOTEQUAL"] = "Not Equal to";
L["CONDITIONPANEL_LESS"] = "Less Than";
L["CONDITIONPANEL_LESSEQUAL"] = "Less Than or Equal to";
L["CONDITIONPANEL_GREATER"] = "Greater Than";
L["CONDITIONPANEL_GREATEREQUAL"] = "Greater Than or Equal to";
L["CONDITIONPANEL_RESET"] = "Clear";
L["OKAY"] = "Okay";
L["CANCEL"] = "Cancel";

-- ----------
-- COPYPANEL
-- ----------

L["COPYSETTINGS"] = "Copy from another icon";
L["COPYPANEL_TITLE"] = "TellMeWhen Icon Copier";
L["GROUPICON"] = "Group: %d, Icon: %d";
L["COPYPANEL_GROUP"] = "Group: ";
L["GROUP"] = "Group ";
L["COPYPANEL_ICON"] = "Icon: ";
L["FROM"] = "From:";
L["TO"] = "To:";
L["COPY"] = "Copy";
L["GENABLEBUTTON"] = "Group %d is disabled. Click to temporarily enable.";





-- --------
-- EQUIVS
-- --------

L["Bleeding"] = "Bleeding";
L["Incapacitated"] = "Incapacitated";
L["StunnedOrIncapacitated"] = "Stunned Or Incapacitated";
L["Stunned"] = "Stunned";
--L["DontMelee"] = "Dont Melee";
L["ImmuneToStun"] = "Immune To Stun";
L["ImmuneToMagicCC"] = "Immune To Magic CC";
--L["MovementSlowed"] = "Movement Slowed";
L["Disoriented"] = "Disoriented";
L["Silenced"] = "Silenced";
L["Disarmed"] = "Disarmed";
L["Rooted"] = "Rooted";
L["IncreasedStats"] = "Increased Stats";
L["IncreasedDamage"] = "Increased Damage Done";
L["IncreasedCrit"] = "Increased Crit Chance";
L["IncreasedAP"] = "Increased Attack Power";
L["IncreasedSPsix"] = "Increased Spellpower (6%)";
L["IncreasedSPten"] = "Increased Spellpower (10%)";
L["IncreasedSPboth"] = "Increased Spellpower (6% or 10%)";
L["IncreasedPhysHaste"] = "Increased Physical Haste";
L["IncreasedSpellHaste"] = "Increased Spell Haste";
L["BurstHaste"] = "Burst Haste";
L["BonusAgiStr"] = "Increased Agility/Strength";
L["BonusStamina"] = "Increased Stamina";
L["BonusArmor"] = "Increased Armor";
L["BonusMana"] = "Increased Mana Pool";
L["ManaRegen"] = "Increased Mana Regen";
L["BurstManaRegen"] = "Burst Mana Regen";
L["PushbackResistance"] = "Increased Pushback Resistance";
L["Resistances"] = "Increased Spell Resistance";
L["PhysicalDmgTaken"] = "Increased Physical Damage Taken";
L["SpellDamageTaken"] = "Increased Spell Damage Taken";
L["SpellCritTaken"] = "Increased Spell Crit Chance";
L["BleedDamageTaken"] = "Increased Bleed Damage Taken";
L["ReducedAttackSpeed"] = "Reduced Attack Speed";
L["ReducedCastingSpeed"] = "Reduced Casting Speed";
L["ReducedArmor"] = "Reduced Armor";
L["ReducedHealing"] = "Reduced Healing";
L["ReducedPhysicalDone"] = "Reduced Physical Damage Done";


