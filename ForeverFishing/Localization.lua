-- Forever Fishing
-- Copyright © 2026 Hamish336. All Rights Reserved.
-- Applies to original Forever Fishing code and assets only.
-- Blizzard-owned assets and trademarks remain property of Blizzard Entertainment.
-- Unauthorized redistribution or modification is prohibited.
local FF = _G.ForeverFishing

-- Public language availability is separate from independent linguistic/native
-- review. Supported packs detect the client language; manual choices take priority.
FF.supportedLocales = { enUS = true }
FF.auditedLocales = { enUS = true }
FF.englishStrings = {
    ["settings.title"] = "Fishing settings",
["welcome.title"] = "Forever Fishing",
["welcome.version"] = "Version %s",
["welcome.subtitle"] = "Your fishing companion for World of Warcraft: Forever.",
["welcome.open"] = "Open Settings",
["welcome.open-help"] = "Customise your fishing experience in Forever Fishing’s built-in settings.",
["welcome.developer"] = "Made in Australia, enjoyed across Azeroth",
["welcome.developer-intro"] = "Created and maintained by Hamish336, an independent Aussie developer focused on thoughtful tools and a familiar Warcraft feel.",
["welcome.developer-thanks"] = "Thanks for using the addon, sharing feedback and helping Forever Fishing improve.",
["welcome.supporters"] = "Supporters",
["welcome.supporters-intro"] = "Special thanks to the people who have supported Forever Fishing.",
    ["bug-report.title"] = "Report a Bug",
    ["bug-report.instructions"] = "Open the GitHub form in your browser, then copy the report and paste it into %s.",
    ["bug-report.github-account"] = "A free GitHub account is required. Fill out the remaining fields and submit the issue on GitHub.",
    ["bug-report.curseforge-pm"] = "You can also send your issue and diagnostics report in a private message to Hamish336 on CurseForge.",
    ["bug-report.copy"] = "Copy Report",
    ["bug-report.open"] = "Get GitHub Form Link",
    ["bug-report.manual-copy"] = "Report selected. Press %s to copy it.",
    ["bug-report.manual-link"] = "Link selected. Press %s to copy it, then paste it into your browser.",
    ["settings.general"] = "General",
    ["settings.interface"] = "Interface",
    ["settings.controls"] = "Controls",
    ["settings.sounds"] = "Sounds",
    ["language.automatic"] = "Automatic",
    ["language.english"] = "English",
    ["language.help"] = "Uses your client language unless you choose another.",
    ["binding.unassigned"] = "Unassigned",
    ["binding.choose"] = "Choose binding",
    ["binding.clear"] = "Clear",
}
FF.englishStrings["information.title"] = "Fishing information"
FF.englishStrings["information.enabled"] = "Show information panel"
FF.englishStrings["information.show-gold-per-hour"] = "Show gold per hour"
FF.englishStrings["information.gold-per-hour"] = "Gold per hour"
FF.englishStrings["information.gold-source"] = "Source: %s"
FF.englishStrings["information.status"] = "Status messages"
FF.englishStrings["information.skill"] = "Fishing skill"
FF.englishStrings["information.progress"] = "Cast progress"
FF.englishStrings["information.seconds"] = "Remaining seconds"
FF.englishStrings["information.skill-format"] = "%s %d / %s"
FF.englishStrings["information.seconds-format"] = "%.1fs"
FF.englishStrings["information.skill-tooltip"] = "Fishing %d/%s trained; %d effective"
FF.englishStrings["information.rank-format"] = "%s %d%s/%d%s"
FF.englishStrings["information.rank.apprentice"] = "Apprentice"
FF.englishStrings["information.rank.journeyman"] = "Journeyman"
FF.englishStrings["information.rank.expert"] = "Expert"
FF.englishStrings["information.rank.artisan"] = "Artisan"
FF.englishStrings["information.expert-angler"] = "Expert Angler"
FF.englishStrings["information.train-available"] = "%s now available, see Journal for info"
FF.englishStrings["information.train-capped"] = "Skill capped — %s now available, see Journal for info"
FF.englishStrings["information.bonus-tooltip"] = "Bonuses: %+d"
FF.englishStrings["utility.title"] = "Toys & Consumables"
FF.englishStrings["utility.open"] = "Open Toys & Consumables"
FF.englishStrings["utility.visibility"] = "Show Toys & Consumables button"
FF.englishStrings["utility.owner-tooltip"] = "Arrow: Choose a toy or consumable. Add usable bag items in the flyout."
FF.englishStrings["utility.excluded"] = "Use Gear, Lures or Master Chef for that item."
FF.englishStrings["utility.unready"] = "Item use information is not ready. Check its native tooltip and try again."
FF.englishStrings["utility.add"] = "Add a toy or consumable"
FF.englishStrings["utility.add-tooltip"] = "Drag a usable bag item here. Only bag/equipped items are listed; collection-only toys are not supported."
FF.englishStrings["utility.empty"] = "No verified utilities currently owned."
FF.englishStrings["utility.unavailable"] = "No longer available. Reopen to refresh the list."
FF.englishStrings["utility.action-tooltip"] = "Click: Select for the main button  |  Right click: Remove from this flyout"
FF.englishStrings["utility.choose"] = "Choose a toy or consumable"
FF.englishStrings["utility.use-selected"] = "Click: Use selected item"
FF.englishStrings["utility.no-selection"] = "No item selected. Use the arrow to choose one."
FF.englishStrings["utility.selected-unavailable"] = "Selected item is not currently in your bags or equipped."
FF.englishStrings["utility.requirements"] = "Native equip, location and cooldown requirements apply. Equipment may need to be worn first."
FF.englishStrings["language.availability"] = "Automatic currently uses English. German and French are not yet available."
FF.englishStrings["settings.copy.d-px-1c85"] = "%d px"
FF.englishStrings["settings.copy.d-s-515d"] = "%d s"
FF.englishStrings["settings.copy.d-71fa"] = "%d%%"
FF.englishStrings["settings.copy.g-s-9e5a"] = "%g s"
FF.englishStrings["settings.copy.above-8079"] = "Above"
FF.englishStrings["settings.copy.addon-sounds-50bc"] = "Addon sounds"
FF.englishStrings["settings.copy.all-flyouts-3e6a"] = "All Flyouts"
FF.englishStrings["settings.copy.ambient-sounds-b19b"] = "Ambient sounds"
FF.englishStrings["settings.auto-equip-and-restore-gear"] = "Auto Equip and Restore Gear"
FF.englishStrings["settings.auto-equip-and-restore-gear.help"] = "Equip fishing gear when the Forever Fishing bar opens or when you use the Fishing Key. Restore your previous gear when the bar closes."
FF.englishStrings["settings.copy.auto-equip-lures-3084"] = "Auto Equip Lures"
FF.englishStrings["settings.copy.auto-open-6e70"] = "Auto Open"
FF.englishStrings["settings.behavior"] = "Behavior"
FF.englishStrings["settings.copy.automatic-d461"] = "Automatic"
FF.englishStrings["settings.copy.available-outside-combat-including-when-the-86ff"] = "Available outside combat, including when the fishing bar is closed."
FF.englishStrings["settings.copy.below-a53d"] = "Below"
FF.englishStrings["settings.copy.briefly-show-items-from-successful-fishing-ea45"] = "Briefly show items from successful fishing catches."
FF.englishStrings["settings.copy.button-bar-8396"] = "Button bar"
FF.englishStrings["settings.copy.catch-recap-4e81"] = "Catch Recap"
FF.englishStrings["settings.copy.catch-confirmed-sound-3f30"] = "Catch confirmed sound"
FF.englishStrings["settings.copy.changes-are-saved-automatically-a99d"] = "Changes are saved automatically"
FF.englishStrings["settings.copy.choose-a-binding-review-its-current-b6f7"] = "Press a shortcut to assign it while fishing. The global toggle requires confirmation; Jump protection appears when needed."
FF.englishStrings["settings.copy.compact-9945"] = "Compact"
FF.englishStrings["settings.copy.cursor-reminder-cd57"] = "Cursor reminder"
FF.englishStrings["settings.copy.custom-details-8ba9"] = "Custom details"
FF.englishStrings["settings.copy.custom-494c"] = "Custom"
FF.englishStrings["settings.copy.double-right-click-9938"] = "Double right click"
FF.englishStrings["settings.copy.edit-layout-for-b013"] = "Edit layout for"
FF.englishStrings["settings.copy.emphasise-the-fishing-splash-while-still-85d1"] = "Use a separate fishing mix while the fishing bar is open.\nAdjust Master, Music and Ambient sounds below while Focus is active.\nWhen Focus is off or Fishing is closed, these sliders only show current levels.\nChange your normal audio in the game Audio settings."
FF.englishStrings["settings.copy.enable-alert-sounds-ed2b"] = "Enable alert sounds"
FF.englishStrings["settings.copy.event-sounds-5e65"] = "Event sounds"
FF.englishStrings["settings.fast-native-auto-loot"] = "Fast Auto Loot"
FF.englishStrings["settings.fast-native-auto-loot.help"] = "Faster automatic looting.\nOther addons' fast auto-loot\nfeatures take priority when enabled."
FF.englishStrings["settings.faster-recast"] = "Fast Recast"
FF.englishStrings["settings.faster-recast.help"] = "*Experimental*\nCast again faster after\nlooting or a failed catch.\nDuring network or server lag,\nrecasting early may leave\nsome multi-catch loot behind.\nPlease report any issues"
FF.englishStrings["settings.copy.fish-escaped-sound-edef"] = "Fish escaped sound"
FF.englishStrings["settings.copy.fishing-bar-c149"] = "Fishing Bar"
FF.englishStrings["settings.copy.fishing-actions-f97a"] = "Fishing actions"
FF.englishStrings["settings.copy.fishing-view-6816"] = "Fishing view"
FF.englishStrings["settings.copy.fit-fishing-bar-bb68"] = "Fit fishing bar"
FF.englishStrings["settings.copy.flyout-layout-0e5e"] = "Flyout Layout"
FF.englishStrings["settings.copy.focus-splash-sound-b3d6"] = "Focus splash sound"
FF.englishStrings["settings.copy.forever-fishing-fish-0044"] = "Forever Fishing  /fish"
FF.englishStrings["settings.copy.full-bar-81c2"] = "Full Bar"
FF.englishStrings["settings.copy.game-sounds-7f6b"] = "Game sounds"
FF.englishStrings["settings.sounds.dialogue-volume"] = "Dialogue Volume"
FF.englishStrings["settings.sounds.mute-pets"] = "Mute Pets"
FF.englishStrings["settings.sounds.mute-pets-help"] = "Turn off WoW's pet sound setting whilst Forever Fishing is open"
FF.englishStrings["settings.sounds.full-bags"] = "Full Bags Sound"
FF.englishStrings["settings.copy.gear-d6ea"] = "Gear"
FF.englishStrings["settings.copy.has-individual-overrides-342c"] = "Has individual overrides."
FF.englishStrings["settings.copy.hide-blizzard-ui-while-fishing-7f85"] = "Hide Blizzard UI While Fishing"
FF.englishStrings["settings.copy.hide-lure-glow-when-out-of-5779"] = "Hide Lure Glow When Out Of Lures"
FF.englishStrings["settings.copy.hide-the-blizzard-ui-while-fishing-ab55"] = "Hide the Blizzard UI while fishing and restore its previous state when the bar closes."
FF.englishStrings["settings.copy.hide-the-lure-button-glow-when-7b03"] = "Hide the lure button glow when no lures are in your bags."
FF.englishStrings["settings.copy.icon-spacing-bcfb"] = "Icon Spacing"
FF.englishStrings["settings.copy.icon-size-a86c"] = "Icon size"
FF.englishStrings["settings.copy.icon-spacing-4d61"] = "Icon spacing"
FF.englishStrings["settings.copy.idle-reminder-delay-2e48"] = "Idle reminder delay"
FF.englishStrings["settings.copy.include-selected-lure-use-in-the-ad5f"] = "Apply a usable lure before casting when your fishing pole needs one."
FF.englishStrings["settings.copy.inherits-shared-defaults-1bfc"] = "Inherits shared defaults."
FF.englishStrings["settings.copy.journal-launcher-4138"] = "Journal & minimap"
FF.englishStrings["settings.copy.journal-faction-59a0"] = "Journal Faction"
FF.englishStrings["settings.copy.journal-text-size-eddf"] = "Journal Text Size"
FF.englishStrings["settings.copy.language-a4fe"] = "Language"
FF.englishStrings["settings.copy.lures-4959"] = "Lures"
FF.englishStrings["settings.copy.manual-columns-custom-ebd4"] = "Manual columns (Custom)"
FF.englishStrings["settings.copy.manual-columns-74dc"] = "Manual columns"
FF.englishStrings["settings.copy.master-chef-78f9"] = "Master Chef"
FF.englishStrings["settings.copy.master-volume-b041"] = "Master volume"
FF.englishStrings["settings.copy.match-bar-follows-icon-size-spacing-5126"] = "Match Bar follows icon size, spacing and scale. Compact uses smaller icons at bar scale. Hover reveals; pin keeps a tray open."
FF.englishStrings["settings.copy.match-bar-3b0e"] = "Match Bar"
FF.englishStrings["settings.copy.match-bar-icon-size-0b63"] = "Match bar icon size"
FF.englishStrings["settings.copy.match-bar-scale-0626"] = "Match bar scale"
FF.englishStrings["settings.copy.match-bar-spacing-05f1"] = "Match bar spacing"
FF.englishStrings["settings.copy.meals-above-camps-below-3987"] = "Meals above / camps below"
FF.englishStrings["settings.copy.music-6eb0"] = "Music"
FF.englishStrings["settings.copy.off-ca79"] = "Off"
FF.englishStrings["settings.copy.on-1300"] = "On"
FF.englishStrings["settings.copy.one-tray-1b25"] = "One tray"
FF.englishStrings["settings.copy.open-journal-f7b5"] = "Open Journal"
FF.englishStrings["settings.copy.open-the-fishing-bar-when-a-c0e5"] = "Open the fishing bar when a fishing rod is equipped."
FF.englishStrings["settings.copy.placement-4df9"] = "Placement"
FF.englishStrings["settings.copy.play-436e"] = "Play"
FF.englishStrings["settings.copy.preset-7252"] = "Preset"
FF.englishStrings["settings.copy.recommended-baa5"] = "RECOMMENDED"
FF.englishStrings["settings.copy.recast-reminder-sound-075a"] = "Recast reminder sound"
FF.englishStrings["settings.copy.repeat-interval-c48d"] = "Repeat interval"
FF.englishStrings["settings.copy.repeat-b6b7"] = "Repeat"
FF.englishStrings["settings.copy.report-a-scan-issue-63df"] = "Report a Scan Issue"
FF.englishStrings["settings.copy.reset-all-settings-ef4d"] = "Reset all settings"
FF.englishStrings["settings.copy.reset-shared-defaults-b1d7"] = "Reset shared defaults"
FF.englishStrings["settings.copy.restore-inheritance-removes-only-this-flyout-04ca"] = "Restore inheritance removes only this flyout's overrides. Placement uses a viable side at screen edges."
FF.englishStrings["settings.copy.restore-inheritance-e97b"] = "Restore inheritance"
FF.englishStrings["settings.copy.scale-f102"] = "Scale"
FF.englishStrings["settings.copy.shared-defaults-individual-overrides-stay-unchanged-245c"] = "Shared defaults. Individual overrides stay unchanged."
FF.englishStrings["settings.copy.show-fishing-s-minimap-icon-or-f972"] = "Show Fishing's minimap icon or its contribution to the shared Forever icon. Fishing stays in the shared list and /fish remains available."
FF.englishStrings["settings.copy.show-minimap-icon-fa0c"] = "Show Minimap Icon"
FF.englishStrings["settings.copy.single-icon-click-6bc0"] = "Single Icon: Click"
FF.englishStrings["settings.copy.single-icon-hover-1bf7"] = "Single Icon: Hover"
FF.englishStrings["settings.copy.sound-in-background-39ab"] = "Sound in Background"
FF.englishStrings["settings.copy.voice-alert-volume-2d90"] = "Voice alert volume"
FF.englishStrings["settings.copy.while-the-fishing-bar-is-open-bb36"] = "While the fishing bar is open; suspended during typing and key capture."
FF.englishStrings["settings.copy.width-3019"] = "Width"
FF.englishStrings["settings.copy.journal-only"] = "Journal"
FF.englishStrings["bar.layout"] = "Layout"
FF.englishStrings["bar.horizontal"] = "Horizontal"
FF.englishStrings["bar.vertical"] = "Vertical"
FF.englishStrings["bar.auto-collapse"] = "Auto-collapse"
FF.englishStrings["bar.auto-collapse-tooltip"] = "Collapse to the Fishing button when unused. Hover to reveal tools; the bar stays open while using its buttons or flyouts."
FF.englishStrings["bar.sizing-hint"] = "Ctrl + drag the bar to resize. Shift + drag moves both bars; Alt + drag moves the tools."
FF.englishStrings["flyout.adjust"] = "Adjust flyout"
FF.englishStrings["flyout.all"] = "All"
FF.englishStrings["flyout.gear"] = "Gear"
FF.englishStrings["flyout.lures"] = "Lures"
FF.englishStrings["flyout.chef"] = "Master Chef"
FF.englishStrings["flyout.mixed"] = "Mixed"
FF.englishStrings["flyout.adjust-help"] = "Choose which flyout to edit. Switching only loads its values. All applies each adjustment to every category; Mixed means that value differs."
FF.englishStrings["flyout.icons-per-row"] = "Icons per row"

-- Runtime messages are display-only; never compare translated wording as state.
FF.englishStrings["startup.bar"] = "Fishing could not finish starting. Reload the UI. If it happens again, report the first Lua error."
FF.englishStrings["startup.gamepad"] = "Fishing controller controls could not start. Reload the UI or turn off Gamepad Mode to use your fishing keyboard shortcuts."
FF.englishStrings["startup.rod-auto-open"] = "The Fishing Bar could not open automatically. Type /fish to open it manually."
FF.englishStrings["runtime.minimap-unavailable"] = "The minimap button is unavailable. Reload the UI and try again."
FF.englishStrings["runtime.macro-slots-full"] = "No free character macro slot for the Cast button. The fishing key remains available."
FF.englishStrings["runtime.gear-combat"] = "Change automatic gear handling outside combat."
FF.englishStrings["runtime.lure-combat"] = "Change automatic lure handling outside combat."
FF.englishStrings["binding.choose-outside-combat"] = "Choose a key outside combat."
FF.englishStrings["reset.all-combat"] = "Reset Forever Fishing after combat."
FF.englishStrings["reset.reload-needed"] = "Saved data has been cleared. Type /reload to finish the reset."
FF.englishStrings["reset.settings-combat"] = "Reset settings after combat."
FF.englishStrings["reset.settings-done"] = "Fishing settings restored to defaults."
FF.englishStrings["reset.settings-title"] = "Reset Forever Fishing"
FF.englishStrings["reset.settings-button"] = "Reset Settings"
FF.englishStrings["reset.clear-all-button"] = "Clear All Data"
FF.englishStrings["reset.all-title"] = "Clear all Forever Fishing data?"
FF.englishStrings["reset.all-confirm"] = "This permanently erases your catch history and all other saved Forever Fishing data for every character."
FF.englishStrings["runtime.flyout-help-legacy"] = "Flyouts close by clicking their button again or moving away. Auto-collapse is in Interface settings."
FF.englishStrings["minimap.open"] = "Left click: Open"
FF.englishStrings["minimap.settings"] = "Right click: Settings"
FF.englishStrings["minimap.equipped"] = "Equipped"
FF.englishStrings["minimap.lure-none"] = "Lure: None active"
FF.englishStrings["minimap.lure-unavailable"] = "Lure: Unavailable"
FF.englishStrings["minimap.pole-none"] = "Pole: Not equipped"
FF.englishStrings["runtime.macro-conflict"] = "A macro named '%s' already exists with different contents. The fishing key remains available."
FF.englishStrings["binding.unchanged-conflict"] = "Binding unchanged: shortcut is used by %s."
FF.englishStrings["minimap.session"] = "Session: %s catches  •  %s casts"
FF.englishStrings["minimap.rod-time"] = "Rod time: %dh %02dm"
FF.englishStrings["minimap.lifetime"] = "Lifetime catches: %s"
FF.englishStrings["minimap.location"] = "Location: %s"
FF.englishStrings["minimap.pole"] = "Pole: %s"
FF.englishStrings["minimap.lure-time"] = "Lure: %dm %02ds remaining"
FF.englishStrings["minimap.selected-lure"] = "Selected lure: %s"
FF.englishStrings["window.resize-dimensions"] = "Drag to resize width and height"
FF.englishStrings["window.resize-scale"] = "Drag to resize  •  Ctrl-drag to scale"
FF.englishStrings["window.scale"] = "Drag to scale window"
FF.englishStrings["bar.key"] = "Key"
FF.englishStrings["bar.cast-input-help"] = "Cast and hook with your chosen input."
FF.englishStrings["bar.close"] = "Close fishing"
FF.englishStrings["bar.title-command"] = "Forever Fishing /fish"
FF.englishStrings["bar.move-both"] = "Shift + drag: Move both bars"
FF.englishStrings["bar.move-main"] = "Alt + drag: Move fishing bar"
FF.englishStrings["bar.resize-main"] = "Ctrl + drag: Resize fishing bar"
FF.englishStrings["bar.move-tools"] = "Alt + drag: Move icon bar"
FF.englishStrings["bar.resize-tools"] = "Ctrl + drag: Resize icon bar"
FF.englishStrings["gear.none-found"] = "No fishing gear found"
FF.englishStrings["gear.name"] = "Fishing gear"
FF.englishStrings["gear.equip-restore"] = "Click: Equip or restore"
FF.englishStrings["gear.arrow-help"] = "Arrow: Gear Management"
FF.englishStrings["gear.remove-help"] = "Right click an item to remove it"
FF.englishStrings["gear.management"] = "Fishing gear management"
FF.englishStrings["lure.name"] = "Fishing lure"
FF.englishStrings["lure.apply-help"] = "Click: Apply to rod"
FF.englishStrings["lure.vendor-help"] = "Visit a fishing vendor to purchase more lures."
FF.englishStrings["lure.selected-missing"] = "No selected lure in bags"
FF.englishStrings["lure.choose-arrow"] = "Arrow: Choose lure"
FF.englishStrings["lure.add-arrow"] = "Arrow: Add lure"
FF.englishStrings["chef.quick-help"] = "Click: Quick cooking and campfire actions"
FF.englishStrings["chef.close-help-legacy"] = "Click again or move away: Close"
FF.englishStrings["journal.button-title"] = "Fishing journal"
FF.englishStrings["journal.toggle-help"] = "Click: Open or close journal"
FF.englishStrings["journal.button-help"] = "Catch records, stats, and field guide"
FF.englishStrings["settings.toggle-help"] = "Click: Open or close settings"
FF.englishStrings["settings.quick"] = "Quick settings"
FF.englishStrings["gamepad.flyout-on"] = "On: click to return to your keyboard and mouse bindings."
FF.englishStrings["gamepad.flyout-off"] = "Off: click to enable Gamepad Mode. New setups confirm the default controller bindings."
FF.englishStrings["gamepad.defaults-title"] = "Default Gamepad Bindings"
FF.englishStrings["gamepad.defaults-bindings"] = "%s · Fishing Key\n%s · Jump\n%s · Close fishing bar"
FF.englishStrings["gamepad.defaults-note"] = "Rebind in |cffffffffSettings → General|r. See |cffffffffAdvanced Bindings|r for more controls.\nSet |cffffffffToggle Forever Fishing|r at the bottom for a global shortcut to open or close."
FF.englishStrings["gamepad.defaults-question"] = "Enter Gamepad Mode?"
FF.englishStrings["gamepad.defaults-enter"] = "%s · Enter"
FF.englishStrings["gamepad.defaults-cancel"] = "%s · Cancel"
FF.englishStrings["runtime.close-combat"] = "Use the fishing bar's Close button during combat."
FF.englishStrings["runtime.open-combat"] = "Open Fishing after combat."
FF.englishStrings["status.bobber-not-visible"] = "Bobber not visible"
FF.englishStrings["status.bags-full"] = "Bags are Full"
FF.englishStrings["status.bags-full-help"] = "Free a slot in your regular bags for new catches. Click to dismiss."
FF.englishStrings["status.clear-npc-target"] = "Clear NPC Target"
FF.englishStrings["status.bobber-not-found-adjust"] = "Bobber not found, Adjust cursor box height for this fishing location"
FF.englishStrings["flyout.scroll-help"] = "Scroll for more items"
FF.englishStrings["chef.open-after-combat"] = "Open Master Chef quick actions after combat."
FF.englishStrings["gear.status-fallback"] = "Best fishing gear missing • Using best available"
FF.englishStrings["gear.status-no-rod"] = "No fishing rod found • Add manually if not detected"
FF.englishStrings["gear.status-manual"] = "Auto Equip Gear is OFF • Equip your fishing gear manually"
FF.englishStrings["gear.status-failed"] = "Fishing gear unavailable • Check bags and item locks"
FF.englishStrings["status.adjusting-marker"] = "Adjusting cursor marker"
FF.englishStrings["status.bobber-found-key"] = "Bobber found • press at the splash"
FF.englishStrings["status.bobber-found-marker"] = "Bobber found • return cursor to marker"
FF.englishStrings["status.centering"] = "Centering fishing view"
FF.englishStrings["status.camera-unavailable"] = "Camera unavailable • catch manually"
FF.englishStrings["status.scan-manual-cancel"] = "Manual input • Scan cancelled"
FF.englishStrings["status.scan-environment-cancel"] = "Camera changed • Scan cancelled"
FF.englishStrings["status.bobber-not-found"] = "Bobber not found • catch manually"
FF.englishStrings["status.paused-marker"] = "Paused • return cursor to marker"
FF.englishStrings["status.preparing-view"] = "Preparing fishing view"
FF.englishStrings["status.scanning"] = "Scanning for bobber"
FF.englishStrings["status.long-cast"] = "Long cast • place cursor on marker"
FF.englishStrings["status.good-key"] = "Good cast • press at the splash"
FF.englishStrings["status.good-mouse"] = "Good cast • right click at the splash"
FF.englishStrings["status.check-interact"] = "Check the bobber's Interact icon"
FF.englishStrings["status.dungeon-interact"] = "Press at the splash"
FF.englishStrings["status.checking"] = "Checking cast"
FF.englishStrings["status.click-key"] = "Click or press your fishing key"
FF.englishStrings["status.click-set-key"] = "Click to cast  •  set a fishing key"
FF.englishStrings["status.press-key"] = "Press your fishing key to cast"
FF.englishStrings["status.free-macro-slot"] = "Free a character macro slot to enable click cast"
FF.englishStrings["status.equip-gear"] = "Click or press key to equip fishing gear"
FF.englishStrings["status.apply-lure"] = "Click or press key to apply lure"
FF.englishStrings["status.preparing"] = "Finishing preparation"
FF.englishStrings["status.choose-key"] = "Choose a fishing key in settings"
FF.englishStrings["bar.preparation-help"] = "Use your Fishing Key to equip gear and apply lures,\nthen cast and hook."
FF.englishStrings["gear.vendor-help"] = "Visit a fishing vendor to buy a rod or\nadd any gear we've missed in the drop down"
FF.englishStrings["lure.rod-seconds"] = "%ss left on rod"
FF.englishStrings["preparation.cast"] = "Fishing: cast, then hook with native bobber interaction."
FF.englishStrings["preparation.gear"] = "Fishing: equip fishing gear; cast, then hook with native bobber interaction."
FF.englishStrings["preparation.lure"] = "Fishing: apply the selected lure; cast, then hook with native bobber interaction."
FF.englishStrings["preparation.gear-lure"] = "Fishing: equip fishing gear; apply the selected lure; cast, then hook with native bobber interaction."
FF.englishStrings["preparation.camera"] = " Experimental camera backup is enabled (/fish dev)."


-- Gear/lure display never supplies equipment or macro identities.
FF.englishStrings["gear.slot.head"] = "Head"
FF.englishStrings["gear.slot.neck"] = "Neck"
FF.englishStrings["gear.slot.shoulders"] = "Shoulders"
FF.englishStrings["gear.slot.shirt"] = "Shirt"
FF.englishStrings["gear.slot.chest"] = "Chest"
FF.englishStrings["gear.slot.waist"] = "Waist"
FF.englishStrings["gear.slot.legs"] = "Legs"
FF.englishStrings["gear.slot.feet"] = "Feet"
FF.englishStrings["gear.slot.wrists"] = "Wrists"
FF.englishStrings["gear.slot.hands"] = "Hands"
FF.englishStrings["gear.slot.finger-one"] = "Finger 1"
FF.englishStrings["gear.slot.finger-two"] = "Finger 2"
FF.englishStrings["gear.slot.trinket-one"] = "Trinket 1"
FF.englishStrings["gear.slot.trinket-two"] = "Trinket 2"
FF.englishStrings["gear.slot.back"] = "Back"
FF.englishStrings["gear.slot.main-hand"] = "Main hand"
FF.englishStrings["gear.slot.off-hand"] = "Off hand"
FF.englishStrings["gear.slot.ranged"] = "Ranged"
FF.englishStrings["gear.slot.tabard"] = "Tabard"
FF.englishStrings["gear.slot-fallback"] = "slot %s"
FF.englishStrings["gear.slot-fallback-title"] = "Slot %s"
FF.englishStrings["lure.choose-combat"] = "Choose a lure outside combat."
FF.englishStrings["lure.choose-help"] = "Choose a lure from the icon list or drag one onto the plus slot."
FF.englishStrings["lure.macro-temporary"] = "Lure temporarily unavailable"
FF.englishStrings["lure.macro-slots"] = "Lure unavailable: macro slots full"
FF.englishStrings["lure.macro-names"] = "Lure unavailable: macro names in use"
FF.englishStrings["lure.best"] = "Best available lure"
FF.englishStrings["lure.auto-equip-on"] = "On: applies a usable lure before casting when your pole needs one. Click to turn off."
FF.englishStrings["lure.auto-equip-off"] = "Off: selected lures are skipped by the one-button fishing rotation. Click to turn on."
FF.englishStrings["lure.next-found"] = "No usable lure available."
FF.englishStrings["lure.add"] = "Add a lure"
FF.englishStrings["lure.drop"] = "Drop a lure here"
FF.englishStrings["lure.best-selected"] = "Lure selection: best available."
FF.englishStrings["gear.normal-unidentified"] = "Normal weapons could not be identified. Equip your weapons or gear set, then try again."
FF.englishStrings["gear.normal-unidentified-popup"] = "Normal weapons could not be identified.\n\nEquip your weapons or gear set, then try again"
FF.englishStrings["gear.change-combat"] = "Change fishing gear outside combat."
FF.englishStrings["gear.invalid-slot"] = "That item cannot be added to a character equipment slot."
FF.englishStrings["gear.combat-unprepared"] = "No normal weapons are prepared for this combat restore. Gear is still remembered."
FF.englishStrings["gear.combat-attempt"] = "Attempting normal weapon restore. Other gear stays unchanged during combat."
FF.englishStrings["gear.combat-foreign-owner"] = "The combat restore snapshot belongs to another character."
FF.englishStrings["gear.restore-combat-help"] = "Use the Gear or Close button to restore normal weapons during combat."
FF.englishStrings["gear.restore-foreign-owner"] = "The restore snapshot belongs to another character."
FF.englishStrings["gear.restore-missing"] = "No previous gear snapshot is available to restore."
FF.englishStrings["gear.equip-combat"] = "Equip fishing gear outside combat."
FF.englishStrings["gear.choose-arrow"] = "Use the gear arrow to choose fishing gear."
FF.englishStrings["gear.manage-combat"] = "Manage fishing gear outside combat."
FF.englishStrings["gear.confirmation-unavailable"] = "Gear confirmation is unavailable. Reload the UI and try again."
FF.englishStrings["gear.remove-confirm"] = "Remove %s from your fishing gear?"
FF.englishStrings["gear.add"] = "Add fishing gear"
FF.englishStrings["gear.drop"] = "Drop equipment here"
FF.englishStrings["lure.no-bags"] = "No lures in bags"
FF.englishStrings["gear.remove"] = "Remove"
FF.englishStrings["lure.selected-message"] = "Selected lure: %s."
FF.englishStrings["lure.uses"] = "Uses %s"
FF.englishStrings["lure.bonus-bags"] = "+%s Fishing  |  %s in bags"
FF.englishStrings["gear.added-message"] = "%s added to Fishing Gear (%s)."
FF.englishStrings["gear.picker-remove"] = "%s  |  Right click to remove"
FF.englishStrings["gear.picker-select"] = "%s  |  Click to select"
FF.englishStrings["gear.failure.manual-choice"] = "Gear changed. Your manual choice has been kept."
FF.englishStrings["gear.failure.bags-full"] = "Gear Swap Failed • Bags are full"
FF.englishStrings["gear.failure.bag-space"] = "Gear swap blocked. Check your normal bag space."
FF.englishStrings["gear.failure.requirements"] = "This gear cannot be equipped. Check its requirements."
FF.englishStrings["gear.failure.unconfirmed"] = "Gear swap could not be confirmed. Click Gear to retry."
FF.englishStrings["gear.failure.unknown-space"] = "A safe bag slot could not be identified. Click Gear to retry."
FF.englishStrings["gear.failure.loading"] = "Finish loading, then click Gear."
FF.englishStrings["gear.failure.context"] = "Gear context changed. Click Gear to use your current setup."
FF.englishStrings["gear.failure.combat"] = "Gear is still remembered. Click Gear after combat."
FF.englishStrings["gear.failure.casting"] = "Finish your current cast, then click Gear."
FF.englishStrings["gear.failure.cursor"] = "Finish moving the item on your cursor, then click Gear."
FF.englishStrings["gear.failure.invalid-entry"] = "A saved gear entry could not be identified."
FF.englishStrings["gear.failure.incompatible"] = "These gear items cannot be worn together."
FF.englishStrings["gear.failure.item-missing"] = "A saved gear item is not available in your bags."
FF.englishStrings["gear.recovery-help"] = "Close Fishing, equip your normal weapons, then use /fishgear to replace remembered normal weapons. Use /fishgear empty only for intentionally empty hands."
FF.englishStrings["gear.recovery-unavailable"] = "Normal weapons could not be updated in this context. Your remembered gear is unchanged."
FF.englishStrings["gear.recovery-combat"] = "Use /fishgear after combat. Your remembered gear is unchanged."
FF.englishStrings["gear.recovery-close"] = "Close Fishing and equip your normal weapons, then use /fishgear."
FF.englishStrings["gear.recovery-busy"] = "Finish casting, moving items or swapping gear, then use /fishgear."
FF.englishStrings["gear.recovery-empty-only"] = "Use /fishgear empty only when both hands are intentionally empty."
FF.englishStrings["gear.recovery-empty-help"] = "Equip your normal weapon first. If both hands should stay empty, use /fishgear empty."
FF.englishStrings["gear.recovery-loading"] = "Normal weapon information is still loading. Wait briefly, then try again."
FF.englishStrings["gear.recovery-normal"] = "Equip your normal weapons instead of a fishing pole, then use /fishgear."
FF.englishStrings["gear.recovery-complete"] = "Finish equipping your normal weapons. To deliberately replace an old weapon pair, close Fishing and use /fishgear."
FF.englishStrings["gear.recovery-saved"] = "Your currently equipped normal weapons are now remembered. Fishing gear choices and other saved data are unchanged."
FF.englishStrings["settings.gear-clear.label"] = "Clear Gear Set"
FF.englishStrings["settings.gear-clear.help"] = "Temporary workaround for auto gear restore issues. Clears your saved normal gear set so it can be detected again."
FF.englishStrings["gear.clear-saved"] = "Normal gear set cleared. Please close Forever Fishing and equip your normal items again for detection."
FF.englishStrings["gear.clear-unavailable"] = "Finish casting or swapping gear, then try again outside combat."
FF.englishStrings["gear.failure.locked"] = "A gear item is locked. Click Gear when it is available."
FF.englishStrings["gear.failure.incomplete"] = "Gear swap could not be completed. Click Gear to retry."
FF.englishStrings["format.sentence-end"] = "."
FF.englishStrings["gear.failure.variant-missing"] = "The saved item variant is not available in your bags."
FF.englishStrings["gear.failure.item-loading"] = "Item information is still loading. Click Gear to retry."
FF.englishStrings["gear.failure.hand-pending"] = "The main-hand weapon must be restored first."
FF.englishStrings["gear.failure.item-context"] = "%s (%s): %s"
FF.englishStrings["gear.failure.partial-context"] = "Some gear was restored. %s"
FF.englishStrings["sound.recovery.retry"] = "Retry audio"
FF.englishStrings["sound.recovery.help"] = "Retry pending fishing audio changes or restore your normal levels after fishing. Your saved fishing preferences stay the same."
FF.englishStrings["sound.recovery.pending"] = "Some audio changes are still pending. Open Settings > Sounds and click Retry audio."
FF.englishStrings["gear.failure-chat-recalled"] = "%s%s Your original gear is still remembered."
FF.englishStrings["gear.failure-chat-retry"] = "%s%s Your original gear is still remembered; click Gear to retry. If you replaced your normal weapons, close Fishing, equip them and use /fishgear."
FF.englishStrings["gear.no-melee"] = "No melee weapons detected"
FF.englishStrings["chef.notice.preparing-cook"] = "Preparing %s • Click again to cook"
FF.englishStrings["chef.notice.preparing-craft"] = "Preparing %s • Click again to craft"
FF.englishStrings["chef.notice.prepared-cook"] = "%s prepared • Click again to cook"
FF.englishStrings["chef.notice.prepared-craft"] = "%s prepared • Click again to craft"
FF.englishStrings["chef.open-mini"] = "Open Mini Master Chef"
FF.englishStrings["chef.need-materials"] = "Need Materials"
FF.englishStrings["chef.tool"] = "Tool"
FF.englishStrings["chef.recipe-unlearned"] = "Recipe not learned"
FF.englishStrings["chef.place"] = "Click: Place"
FF.englishStrings["chef.craft-one"] = "Click: Craft one"
FF.englishStrings["chef.again-ready"] = "Click again when ready"
FF.englishStrings["chef.cook-all"] = "Click: Cook all available"
FF.englishStrings["chef.smart-camp-name"] = "Smart Campfire: %s"
FF.englishStrings["chef.available-count"] = "%s available"


FF.englishStrings["common.okay"] = "Okay"
FF.englishStrings["chef.quick-crafting"] = "Crafting %s"
FF.englishStrings["chef.quick-prepared"] = "%s prepared • click again to craft"
FF.englishStrings["chef.quick-preparing"] = "Preparing %s"
FF.englishStrings["chef.preparing-cooking"] = "Preparing Cooking"


-- Journal display labels stay separate from canonical page/data identities.
FF.englishStrings["journal.back"] = "Back"
FF.englishStrings["journal.records"] = "My records"
FF.englishStrings["journal.catch-tab"] = "Catch journal"
FF.englishStrings["journal.achievements"] = "Achievements"
FF.englishStrings["journal.session-title"] = "Session stats"
FF.englishStrings["journal.lifetime-title"] = "Lifetime stats"
FF.englishStrings["journal.field-guide"] = "Field guide"
FF.englishStrings["journal.events-tab"] = "Events"
FF.englishStrings["journal.show-all"] = "Show all"
FF.englishStrings["journal.known-finds"] = "Known fishing finds"
FF.englishStrings["journal.show-all-help"] = "Show fish and notable direct catches not yet recorded."
FF.englishStrings["journal.show-all-references"] = "Weighted trophy and quest references are also shown. The discovered count uses the unchanged 64-catch collection; references do not add achievement or goal requirements."
FF.englishStrings["journal.chef-campfire"] = "Campfire"
FF.englishStrings["journal.chef-grilling"] = "Grilling"
FF.englishStrings["journal.chef-guide"] = "Guide"
FF.englishStrings["journal.catch-title"] = "Your catch journal"
FF.englishStrings["journal.first-catch"] = "Your first catch is still out there!"
FF.englishStrings["journal.session-subtitle"] = "This login's fishing  •  reset whenever you wish"
FF.englishStrings["journal.history-button"] = "Session History"
FF.englishStrings["journal.session-footer"] = "End saves; Reset discards."
FF.englishStrings["journal.reset-session"] = "Reset Session"
FF.englishStrings["journal.end-session"] = "End Session"
FF.englishStrings["journal.quick"] = "Journal shortcuts"
FF.englishStrings["journal.quick-goals"] = "Open your goals for this fishing session."
FF.englishStrings["journal.quick-tracker"] = "Open the live session stats and catches."
FF.englishStrings["journal.goals-button"] = "Session Goals"
FF.englishStrings["journal.tracker-button"] = "Session Tracker"
FF.englishStrings["journal.tracker-move"] = "Drag here to move Session Tracker."
FF.englishStrings["journal.tracker-close"] = "Close Session Tracker"
FF.englishStrings["journal.tracker-stats-tab"] = "Stats"
FF.englishStrings["journal.tracker-catches-tab"] = "Catches"
FF.englishStrings["journal.tracker-settings"] = "Tracker Options"
FF.englishStrings["journal.tracker-gold-hour"] = "Gold/hr"
FF.englishStrings["journal.tracker-valuation"] = "Estimated value per hour of session time. Source: %s."
FF.englishStrings["journal.tracker-vendor"] = "Vendor value"
FF.englishStrings["journal.tracker-vendor-fallback"] = "vendor fallback"
FF.englishStrings["journal.tracker-unpriced"] = "Some catches are waiting for item prices and are omitted from the estimate."
FF.englishStrings["journal.tracker-no-catches"] = "No catches this session yet."
FF.englishStrings["journal.tracker-no-stats"] = "Choose stats in Tracker Options."
FF.englishStrings["journal.tracker-end-confirm"] = "End this session and save it to Session History if it has catches?"
FF.englishStrings["journal.tracker-reset-confirm"] = "Discard this session’s statistics without saving them to Session History?"
FF.englishStrings["journal.lifetime-subtitle"] = "Across recorded sessions  •  unaffected by Reset session"
FF.englishStrings["journal.lifetime-note"] = "Fishing time excludes idle time.\nValues estimate recorded catches at current prices."
FF.englishStrings["journal.history-title"] = "Session history"
FF.englishStrings["journal.history-subtitle"] = "Saved fishing sessions for this character"
FF.englishStrings["journal.current-session"] = "Current session"
FF.englishStrings["journal.saved-session"] = "Saved session"
FF.englishStrings["journal.history-empty-title"] = "No saved sessions yet"
FF.englishStrings["journal.history-empty-help"] = "End session or log out after a confirmed catch to save a session here. Reset session discards the current session."
FF.englishStrings["journal.breakdown-empty"] = "No item or location breakdown was recorded for this session."
FF.englishStrings["journal.ended-manually"] = "Ended with End Session"
FF.englishStrings["journal.saved-logout"] = "Saved on logout/reload"
FF.englishStrings["journal.locations-heading"] = "Locations"
FF.englishStrings["journal.zone-unavailable"] = "Current zone unavailable"
FF.englishStrings["journal.events-title"] = "Upcoming Events"
FF.englishStrings["journal.events-subtitle"] = "Fishing events in realm and local time"
FF.englishStrings["journal.empty-quote"] = "\"Give a man a fish, feed him for a day.\nTeach him to fish… and maybe this journal won’t be empty.\""
FF.englishStrings["journal.metric.time-fishing"] = "Time fishing"
FF.englishStrings["journal.metric.session-time"] = "Session time"
FF.englishStrings["journal.metric.casts"] = "Casts"
FF.englishStrings["journal.metric.catch-count"] = "Catch count"
FF.englishStrings["journal.metric.catches"] = "Catches"
FF.englishStrings["journal.metric.success"] = "Success rate"
FF.englishStrings["journal.metric.catches-hour"] = "Catches / hour"
FF.englishStrings["journal.metric.cast-loot"] = "Avg. cast to loot"
FF.englishStrings["journal.metric.sessions"] = "Sessions"
FF.englishStrings["journal.metric.unique"] = "Unique catches"
FF.englishStrings["journal.metric.vendor"] = "Vendor"
FF.englishStrings["journal.metric.auction"] = "Auction"
FF.englishStrings["journal.metric-help.time-fishing"] = "Time spent in fishing channels. Idle time is excluded."
FF.englishStrings["journal.metric-help.session-time"] = "Time since the first cast while a fishing rod is equipped. Time without a rod is excluded."
FF.englishStrings["journal.metric-help.casts"] = "Fishing channels started. Cancelled and expired casts count; rapid presses without a cast do not."
FF.englishStrings["journal.metric-help.catches"] = "Recorded fishing loot quantities. A catch with several items adds each item."
FF.englishStrings["journal.metric-help.success"] = "Casts with a recorded catch / casts started. Each successful cast counts once."
FF.englishStrings["journal.metric-help.lifetime-hour"] = "Catch quantities per hour of active fishing."
FF.englishStrings["journal.metric-help.session-hour"] = "Catch quantities per hour of session time with a fishing rod equipped."
FF.englishStrings["journal.metric-help.cast-loot"] = "Average time from cast start to its first recorded catch. Cancelled casts are excluded."
FF.englishStrings["journal.metric-help.sessions"] = "Sessions with a fishing cast. Login, Reset session, or End session starts a new session at the next cast."
FF.englishStrings["journal.metric-help.unique"] = "Different items recorded in your catch journal."
FF.englishStrings["journal.metric-help.vendor"] = "Vendor value of recorded catches at current sell prices."
FF.englishStrings["journal.metric-help.vendor-loading"] = " Some item prices are still loading."
FF.englishStrings["journal.metric-help.auction"] = "Estimated from Auctionator or TSM market prices. Prices may change."
FF.englishStrings["journal.metric-help.auction-install"] = "Install Auctionator or TSM to see auction estimates."
FF.englishStrings["journal.metric-help.vendor-loading-line"] = "\nSome vendor prices are still loading."
FF.englishStrings["journal.auction-fallback"] = "\n* No AH data for some catches.\nVendor value used: %s"
FF.englishStrings["journal.auction-install"] = "Install Auctionator or TSM"
FF.englishStrings["journal.metric-short.catches-hour"] = "Catches/hr"
FF.englishStrings["journal.metric-short.cast-loot"] = "Cast to loot"
FF.englishStrings["journal.metric-short.unique"] = "Unique"
FF.englishStrings["journal.hourly-missing"] = "— / hour"
FF.englishStrings["journal.hourly"] = "%s / hour"
FF.englishStrings["journal.history-average"] = "Avg. cast to loot %.1fs"
FF.englishStrings["journal.history-started"] = "Started %s"
FF.englishStrings["journal.history-rod-time"] = "%s rod time"
FF.englishStrings["journal.history-success"] = "%s success"
FF.englishStrings["journal.saved-count.one"] = "%d saved session"
FF.englishStrings["journal.saved-count.other"] = "%d saved sessions"
FF.englishStrings["journal.guide.leveling.label"] = "Leveling route"
FF.englishStrings["journal.guide.leveling.title"] = "Fishing 1–300"
FF.englishStrings["journal.guide.leveling.subtitle"] = "Where to fish and when to train"
FF.englishStrings["journal.guide.gear.label"] = "Gear & skill"
FF.englishStrings["journal.guide.gear.title"] = "Fishing skill kit"
FF.englishStrings["journal.guide.gear.subtitle"] = "Choose gear and lures that raise your Fishing skill"
FF.englishStrings["journal.guide.rares.label"] = "Rare catches"
FF.englishStrings["journal.guide.rares.title"] = "Rare & valuable waters"
FF.englishStrings["journal.guide.rares.subtitle"] = "Where to fish for rare and seasonal catches"
FF.englishStrings["journal.guide.nearby.label"] = "Nearby"
FF.englishStrings["journal.guide.nearby.title"] = "Nearby"
FF.englishStrings["journal.guide.nearby.subtitle"] = "Fishing discoveries and recipe sellers in your current zone"
FF.englishStrings["journal.search-map"] = "Show verified seller on map"
FF.englishStrings["journal.header"] = "Forever Fishing Journal"
FF.englishStrings["journal.search-placeholder"] = "Search journal…"
FF.englishStrings["journal.search-current"] = "Current page"
FF.englishStrings["journal.search-empty"] = "No matching Journal content."
FF.englishStrings["journal.search-current.one"] = "%d result • Current page"
FF.englishStrings["journal.search-current.other"] = "%d results • Current page"
FF.englishStrings["journal.search-whole.one"] = "%d result • Whole Journal"
FF.englishStrings["journal.search-whole.other"] = "%d results • Whole Journal"


FF.englishStrings["journal.nav-session"] = "Session stats"
FF.englishStrings["journal.nav-lifetime"] = "Lifetime stats"
FF.englishStrings["journal.header-short"] = "Fishing Journal"

-- Shared full/Mini Chef presentation; canonical operation messages remain separate.
FF.englishStrings["chef.ui.craft"] = "Craft"
FF.englishStrings["chef.ui.cook"] = "Cook"
FF.englishStrings["chef.ui.place"] = "Place"
FF.englishStrings["chef.ui.place-campfire"] = "Place Campfire"
FF.englishStrings["chef.ui.need-materials"] = "Need Materials"
FF.englishStrings["chef.ui.need-ingredients"] = "Need Ingredients"
FF.englishStrings["chef.ui.start"] = "Start"
FF.englishStrings["chef.ui.preparing"] = "Preparing"
FF.englishStrings["chef.ui.prepare"] = "Prepare"
FF.englishStrings["chef.ui.cooking"] = "Cooking"
FF.englishStrings["chef.ui.crafting"] = "Crafting"
FF.englishStrings["chef.ui.reserved"] = "Materials committed to queue"
FF.englishStrings["chef.ui.craft-one"] = "Craft one Basic Campfire"
FF.englishStrings["chef.ui.left-cook"] = "Left click: Cook"
FF.englishStrings["chef.ui.left-craft"] = "Left click: Craft"
FF.englishStrings["chef.ui.right-queue"] = "Right click: Add to queue"
FF.englishStrings["chef.ui.remove-next"] = "Remove next queued stack"
FF.englishStrings["chef.ui.crafting-queue"] = "Crafting Queue"
FF.englishStrings["chef.ui.cooking-queue"] = "Cooking Queue"
FF.englishStrings["chef.ui.camp-tools"] = "Camp tools"
FF.englishStrings["chef.ui.cooking-recipes"] = "Cooking recipes"
FF.englishStrings["chef.ui.cooking-guide"] = "Cooking guide"
FF.englishStrings["chef.ui.prepared"] = "%s prepared"
FF.englishStrings["chef.ui.ready"] = "%s ready"
FF.englishStrings["chef.ui.camp-prepared"] = "Camp tools • %s prepared"
FF.englishStrings["chef.ui.camp-short-prepared"] = "Camp • %s prepared"
FF.englishStrings["chef.ui.recipes-prepared"] = "Cooking recipes • %s prepared"
FF.englishStrings["chef.ui.recipes-short-prepared"] = "Recipes • %s prepared"
FF.englishStrings["chef.ui.stop-moving"] = "Stop moving"
FF.englishStrings["chef.ui.recipe-unknown"] = "Recipe unknown"
FF.englishStrings["chef.ui.materials-status"] = "Need materials"
FF.englishStrings["chef.ui.in-combat"] = "In combat"
FF.englishStrings["chef.ui.craft-paused"] = "Craft paused"
FF.englishStrings["chef.ui.cant-craft"] = "Can't craft"
FF.englishStrings["chef.ui.craft-complete"] = "Craft complete"
FF.englishStrings["chef.ui.ready-craft"] = "Ready to craft"
FF.englishStrings["chef.ui.craft-busy"] = "Craft busy"
FF.englishStrings["chef.ui.need-fire"] = "Need cooking fire"
FF.englishStrings["chef.ui.ingredients-status"] = "Need ingredients"
FF.englishStrings["chef.ui.cook-paused"] = "Cook paused"
FF.englishStrings["chef.ui.cant-cook"] = "Can't cook"
FF.englishStrings["chef.ui.ready-cook"] = "Ready to cook"
FF.englishStrings["chef.ui.cook-complete"] = "Cook complete"
FF.englishStrings["chef.ui.outdoor"] = "Outdoor only"
FF.englishStrings["chef.ui.no-room"] = "Not enough room"
FF.englishStrings["chef.ui.cant-place"] = "Can't place"
FF.englishStrings["chef.ui.ready-place"] = "Ready to place"
FF.englishStrings["chef.ui.place-complete"] = "Place complete"
FF.englishStrings["chef.ui.place-cancelled"] = "Place cancelled"
FF.englishStrings["chef.ui.preparing-cooking"] = "Preparing Cooking"
FF.englishStrings["chef.ui.to-cook"] = "%d to cook"
FF.englishStrings["chef.ui.to-craft"] = "%d to craft"
FF.englishStrings["chef.ui.next-cooking"] = "Cooking: %s  ×%d"
FF.englishStrings["chef.ui.next-crafting"] = "Crafting: %s  ×%d"
FF.englishStrings["chef.ui.next-preparing"] = "Preparing: %s  ×%d"
FF.englishStrings["chef.ui.next-ready"] = "Ready: %s  ×%d"
FF.englishStrings["chef.ui.next"] = "Next: %s  ×%d"
FF.englishStrings["chef.ui.queue-sound"] = "Queue completion sound: %s"

-- Chef operation display records; canonical English state readers remain separate.
FF.englishStrings["chef.message.cooking-changed-click"] = "Cooking session changed  •  click Cook to prepare"
FF.englishStrings["chef.message.cooking-changed-prepare"] = "Cooking session changed  •  press Prepare"
FF.englishStrings["chef.message.cooking-stopped-click"] = "Cooking stopped  •  click Cook to retry"
FF.englishStrings["chef.message.cooking-stopped-start"] = "Cooking stopped  •  press Start to retry"
FF.englishStrings["chef.message.cooking-stopped-prepare"] = "Cooking stopped  •  press Prepare to retry"
FF.englishStrings["chef.message.unconfirmed-click"] = "No craft confirmed  •  click Cook to retry"
FF.englishStrings["chef.message.unconfirmed-start"] = "No craft confirmed  •  press Start to retry"
FF.englishStrings["chef.message.cook-after-combat"] = "Cook after combat"
FF.englishStrings["chef.message.retry-after-combat"] = "Try again after combat"
FF.englishStrings["chef.message.prepare-cooking-retry"] = "Could not prepare Cooking  •  click Cook to retry"
FF.englishStrings["chef.message.conceal-cooking-retry"] = "Could not conceal Cooking  •  press Start to retry"
FF.englishStrings["chef.message.cooking-ready-click"] = "Cooking ready  •  click Cook again"
FF.englishStrings["chef.message.cooking-ready-start"] = "Cooking ready  •  press Start"
FF.englishStrings["chef.message.close-window-cook"] = "Close the other window before cooking"
FF.englishStrings["chef.message.finish-camp"] = "Finish the camp craft first"
FF.englishStrings["chef.message.recipe-unavailable"] = "Recipe data unavailable"
FF.englishStrings["chef.message.cooking-unavailable"] = "Cooking session unavailable"
FF.englishStrings["chef.message.start-cooking-failed"] = "Could not start Cooking"
FF.englishStrings["chef.message.cooking-unloaded-start"] = "Cooking did not load  •  press Start to retry"
FF.englishStrings["chef.message.finish-current"] = "Finish the current preparation or craft first"
FF.englishStrings["chef.message.need-unreserved"] = "Need ingredients not committed to the queue"
FF.englishStrings["chef.message.cooking-unloaded-click"] = "Cooking did not load  •  click Cook to retry"
FF.englishStrings["chef.message.close-profession"] = "Close the other profession first"
FF.englishStrings["chef.message.prepare-cooking-failed"] = "Could not prepare Cooking"
FF.englishStrings["chef.message.next-meal"] = "Press Start for the next meal"
FF.englishStrings["chef.message.continue-stack"] = "Press Start to continue this stack"
FF.englishStrings["chef.message.craft-stopped-click"] = "Craft stopped  •  click Cook to retry"
FF.englishStrings["chef.message.craft-stopped-retry"] = "Craft stopped  •  press Start to retry"
FF.englishStrings["chef.message.craft-stopped"] = "Craft stopped  •  try again"
FF.englishStrings["chef.message.cooking-paused"] = "Cooking paused  •  click Cook to prepare"
FF.englishStrings["chef.message.craft-after-combat"] = "Craft after combat"
FF.englishStrings["chef.message.profession-paused"] = "Profession paused  •  press Craft to prepare"
FF.englishStrings["chef.message.craft-stopped-continue"] = "Craft stopped  •  press Craft or Start to continue"
FF.englishStrings["chef.message.craft-stopped-start"] = "Craft stopped  •  press Start to continue"
FF.englishStrings["chef.message.profession-changed"] = "Profession changed  •  press Craft or Start"
FF.englishStrings["chef.message.prepare-after-combat"] = "Prepare after combat"
FF.englishStrings["chef.message.close-window-craft"] = "Close the other window before crafting"
FF.englishStrings["chef.message.recipe-unlearned"] = "Recipe not learned"
FF.englishStrings["chef.message.need-materials"] = "Need materials"
FF.englishStrings["chef.message.materials-reserved"] = "Materials committed to Crafting Queue"
FF.englishStrings["chef.message.craft-progress"] = "Craft in progress"
FF.englishStrings["chef.message.preparing-profession"] = "Preparing profession"
FF.englishStrings["chef.message.finish-cooking-queue"] = "Finish the Cooking Queue first"
FF.englishStrings["chef.message.profession-unavailable"] = "Profession crafting is unavailable"
FF.englishStrings["chef.message.check-materials"] = "Check materials, then press Start"
FF.englishStrings["chef.message.next-camp"] = "Press Start for the next camp craft"
FF.englishStrings["chef.message.ingredients-missing"] = "Ingredients missing for %s"
FF.englishStrings["chef.message.profession-unloaded"] = "%s did not load  •  press Craft or Start"
FF.englishStrings["chef.message.prepare-profession-failed"] = "Could not prepare %s"
FF.englishStrings["chef.message.open-profession"] = "Open %s, then press Craft"
FF.englishStrings["chef.message.camp-ready"] = "%s ready  •  press Craft or Start"
FF.englishStrings["chef.message.cooking-meal"] = "Cooking %s"
FF.englishStrings["chef.message.select-recipe-failed"] = "Could not select %s recipe"
FF.englishStrings["chef.message.meal-cooked"] = "%s cooked"
FF.englishStrings["chef.message.open-profession-failed"] = "Could not open %s"
FF.englishStrings["chef.message.preparing-profession-name"] = "Preparing %s"
FF.englishStrings["chef.message.crafting-camp"] = "Crafting %s"
FF.englishStrings["chef.message.camp-crafted"] = "%s crafted"
FF.englishStrings["chef.message.moving-click"] = "Stop moving  •  click Cook to retry"
FF.englishStrings["chef.message.fire-click"] = "Need cooking fire  •  click Cook to retry"
FF.englishStrings["chef.message.moving-start"] = "Stop moving  •  press Start to retry"
FF.englishStrings["chef.message.fire-start"] = "Need cooking fire  •  press Start to retry"
FF.englishStrings["chef.message.moving-camp"] = "Stop moving  •  press Craft or Start to retry"
FF.englishStrings["chef.message.fire-camp"] = "Need cooking fire  •  press Craft or Start to retry"
FF.englishStrings["chef.message.need-tool"] = "Need %s"
FF.englishStrings["chef.message.cooking-prepared"] = "Cooking prepared"
FF.englishStrings["chef.message.prepared-click-cook"] = "Cooking prepared • click again to cook"
FF.englishStrings["chef.message.prepared-click-craft"] = "%s prepared • click again to craft"
FF.englishStrings["chef.detail.materials"] = "Materials"
FF.englishStrings["chef.detail.effect"] = "Effect"
FF.englishStrings["chef.detail.recipe"] = "Recipe"
FF.englishStrings["chef.detail.ingredients"] = "Ingredients"
FF.englishStrings["chef.detail.find-ingredients"] = "Find ingredients"
FF.englishStrings["chef.detail.cooking"] = "Cooking"
FF.englishStrings["chef.detail.skill-unconfirmed"] = "Skill unknown"
FF.englishStrings["chef.detail.vendor-map"] = "Click: show this vendor on map"
FF.englishStrings["chef.detail.map-unavailable"] = "Map for this location is unavailable"

-- Authored Chef references; native reference arguments stay canonical.
FF.englishStrings["chef.reference.camp.279981.benefit"] = "Cook at the fire and add up to 3 camp features, one per player. Sit or craft nearby for 1 min to gain camp benefits."
FF.englishStrings["chef.reference.camp.279981.source"] = "Learn Cooking and craft with %s and %s."
FF.englishStrings["chef.reference.camp.279967.benefit"] = "Place beside a Campfire. Nearby seated players gain 8%% more stats; this does not stack with %s."
FF.englishStrings["chef.reference.camp.279967.source"] = "%s leads to a Fishing trainer at skill 20."
FF.englishStrings["chef.reference.camp.279965.benefit"] = "At a campfire, grants 1 hr of access to uncommon catches and offers lures to everyone. Improves your chance of catching bloated fish. Can replace a %s, keeping its benefits."
FF.englishStrings["chef.reference.camp.blueprint-drop"] = "%s drops from %s in %s."
FF.englishStrings["chef.reference.camp.279966.benefit"] = "At a campfire, grants 1 hr of access to rare catches and offers Fishing lures. Can replace a %s, keeping its benefits."
FF.englishStrings["chef.reference.camp.279956.benefit"] = "Restores mana to nearby campers."
FF.englishStrings["chef.reference.camp.279956.source"] = "Learn through the profession's introductory camp training."
FF.englishStrings["chef.reference.camp.279970.benefit"] = "Makes alchemy reagents at camp and improves mana recovery."
FF.englishStrings["chef.reference.camp.279970.source"] = "Learn the corresponding camp blueprint."
FF.englishStrings["chef.reference.camp.279990.benefit"] = "Provides an alchemy workspace at camp."
FF.englishStrings["chef.reference.camp.279944.benefit"] = "Provides a Strength benefit at camp."
FF.englishStrings["chef.reference.camp.279988.benefit"] = "Provides an anvil and the %s benefit."
FF.englishStrings["chef.reference.camp.279955.benefit"] = "Provides a forge and the %s benefit."
FF.englishStrings["chef.reference.camp.279976.benefit"] = "Provides a camp music benefit to nearby players."
FF.englishStrings["chef.reference.camp.279985.benefit"] = "Improves disenchanting at camp and keeps the lute benefit."
FF.englishStrings["chef.reference.camp.279987.benefit"] = "Provides an enchanting workspace at camp."
FF.englishStrings["chef.reference.camp.279950.benefit"] = "Provides a reagent vendor at camp."
FF.englishStrings["chef.reference.camp.279949.benefit"] = "Provides repair and reagent services at camp."
FF.englishStrings["chef.reference.camp.279989.benefit"] = "Provides an engineering workspace at camp."
FF.englishStrings["chef.reference.camp.279962.benefit"] = "Provides an Intellect benefit at camp."
FF.englishStrings["chef.reference.camp.279964.benefit"] = "Grows herbs from seeds and keeps the incense benefit."
FF.englishStrings["chef.reference.camp.279947.benefit"] = "Creates hybrid seeds and keeps the incense benefit."
FF.englishStrings["chef.reference.camp.279978.benefit"] = "Restores rested experience at camp."
FF.englishStrings["chef.reference.camp.279941.benefit"] = "Makes leatherworking reagents and keeps the tent benefit."
FF.englishStrings["chef.reference.camp.279945.benefit"] = "Provides a leatherworking workspace at camp."
FF.englishStrings["chef.reference.camp.279960.benefit"] = "Provides a melee attack power benefit at camp."
FF.englishStrings["chef.reference.camp.279948.benefit"] = "Produces a mining node over time and keeps the lodestone benefit."
FF.englishStrings["chef.reference.camp.279952.benefit"] = "Provides a mining workspace at camp."
FF.englishStrings["chef.reference.camp.279979.benefit"] = "Provides a critical strike benefit at camp."
FF.englishStrings["chef.reference.camp.279969.benefit"] = "Allows Track Beasts at camp and keeps the chair benefit."
FF.englishStrings["chef.reference.camp.279938.benefit"] = "Provides a trap at camp and keeps the chair benefit."
FF.englishStrings["chef.reference.camp.279972.benefit"] = "Provides a Spirit benefit to nearby Horde players."
FF.englishStrings["chef.reference.camp.279973.benefit"] = "Provides a Spirit benefit to nearby Alliance players."
FF.englishStrings["chef.reference.camp.279943.benefit"] = "Makes tailoring reagents and keeps the banner benefit."
FF.englishStrings["chef.reference.camp.279959.benefit"] = "Provides a tailoring workspace at camp."
FF.englishStrings["chef.reference.camp.279961.benefit"] = "Cooking 90 to craft and place. Supports up to 5 additional camp features."
FF.englishStrings["chef.reference.camp.279957.benefit"] = "Place by a cooking fire to serve Stamina food."
FF.englishStrings["chef.reference.camp.279974.benefit"] = "Cooking 200 to learn. Cooking 220 to place. Supports up to 10 additional camp features."
FF.englishStrings["chef.reference.camp.279982.benefit"] = "Place by a cooking fire for advanced Cooking recipes."
FF.englishStrings["chef.reference.camp.279968.benefit"] = "Provides a Stamina benefit at camp."
FF.englishStrings["chef.reference.camp.279940.benefit"] = "Provides healing and anti-venom supplies at camp."
FF.englishStrings["chef.reference.camp.279951.benefit"] = "Provides potions and poultices at camp."
FF.englishStrings["chef.reference.meal.5476.extra"] = "Its fish ingredient comes from Frenzy creatures, rather than a fishing cast."
FF.englishStrings["chef.reference.meal.286152.extra"] = "Check the current native buff for server restrictions."
FF.englishStrings["chef.reference.meal.13928.extra"] = "Needs an %s."
FF.englishStrings["chef.reference.meal.13931.extra"] = "Uses a cooking fire."
FF.englishStrings["chef.reference.route.1.heading"] = "1–50  •  First catches"
FF.englishStrings["chef.reference.route.1.fish"] = "%s from %s. Coastal option: %s."
FF.englishStrings["chef.reference.route.1.recipe"] = "Buy the recipe from a nearby fishing or cooking supplier."
FF.englishStrings["chef.reference.route.1.alliance"] = "Fish in %s or %s. For mackerel, use the %s coast."
FF.englishStrings["chef.reference.route.1.horde"] = "Fish in %s or %s. For mackerel, use the %s coast."
FF.englishStrings["chef.reference.route.2.heading"] = "50–100  •  Mud Snapper"
FF.englishStrings["chef.reference.route.2.fish"] = "%s from %s. Coastal option: %s."
FF.englishStrings["chef.reference.route.2.recipe"] = "Buy the Mud Snapper recipe from a fishing supplier. Train Journeyman Cooking at skill 50, before the 75 cap."
FF.englishStrings["chef.reference.route.2.alliance"] = "Fish %s canals or %s."
FF.englishStrings["chef.reference.route.2.horde"] = "Fish %s or %s waters."
FF.englishStrings["chef.reference.route.3.heading"] = "100–175  •  Catfish"
FF.englishStrings["chef.reference.route.3.fish"] = "%s from %s."
FF.englishStrings["chef.reference.route.3.recipe"] = "Buy the recipe from a fishing supplier. At skill 125, buy the %s before you reach the 150 cap."
FF.englishStrings["chef.reference.route.3.alliance"] = "Fish %s, %s or %s."
FF.englishStrings["chef.reference.route.3.horde"] = "Fish %s or %s."
FF.englishStrings["chef.reference.route.4.heading"] = "175–225  •  Trout"
FF.englishStrings["chef.reference.route.4.fish"] = "%s from %s. Cook %s from coastal catches too."
FF.englishStrings["chef.reference.route.4.recipe"] = "%s in %s sells both recipes."
FF.englishStrings["chef.reference.route.4.alliance"] = "Fish inland in %s near %s; fish its coast for cod."
FF.englishStrings["chef.reference.route.4.horde"] = "Fish %s inland waters; its coast also yields cod."
FF.englishStrings["chef.reference.route.5.heading"] = "225–250  •  Yellowtail"
FF.englishStrings["chef.reference.route.5.fish"] = "%s from %s. %s also works if you have the fish."
FF.englishStrings["chef.reference.route.5.recipe"] = "%s at %s sells Yellowtail; %s in %s sells Redgill. For Artisan Cooking, complete %s's %s in %s at level 35 and skill 225."
FF.englishStrings["chef.reference.route.5.alliance"] = "Fish the %s coast for yellowtail, or %s lakes for redgill."
FF.englishStrings["chef.reference.route.5.horde"] = "Fish the %s coast for yellowtail, or %s lakes for redgill."
FF.englishStrings["chef.reference.route.6.heading"] = "250–275  •  Nightfin"
FF.englishStrings["chef.reference.route.6.fish"] = "%s from %s and %s. By day, cook %s if you have an %s."
FF.englishStrings["chef.reference.route.6.recipe"] = "%s at %s sells both recipes."
FF.englishStrings["chef.reference.route.6.alliance"] = "Fish %s or %s lakes. Nightfin is best at night; Sunscale is a daytime catch."
FF.englishStrings["chef.reference.route.6.horde"] = "Fish %s or %s lakes. Nightfin is best at night; Sunscale is a daytime catch."
FF.englishStrings["chef.reference.route.7.heading"] = "275–300  •  Finish"
FF.englishStrings["chef.reference.route.7.fish"] = "Keep cooking %s. With an %s, make %s with spices, %s with %s, or %s with %s."
FF.englishStrings["chef.reference.route.7.Alliance.recipe"] = "%s at %s sells the three 275 recipes."
FF.englishStrings["chef.reference.route.7.Horde.recipe"] = "%s at %s sells the three 275 recipes."
FF.englishStrings["chef.reference.route.7.alliance"] = "Fish %s inland water for salmon, or high level coasts for mightfish and lobster."
FF.englishStrings["chef.reference.route.7.horde"] = "Fish %s inland water for salmon, or high level coasts for mightfish and lobster."
FF.englishStrings["chef.route.trainer"] = "Cooking trainer"
FF.englishStrings["chef.route.recipe-seller"] = "Recipe seller"
FF.englishStrings["chef.route.recipe"] = "%s recipe."
FF.englishStrings["chef.route.recipes"] = "%s recipes."
FF.englishStrings["chef.route.apprentice"] = "Learn Apprentice Cooking."
FF.englishStrings["chef.route.journeyman"] = "Train Journeyman Cooking at skill %s, before the 75 cap."
FF.englishStrings["chef.route.expert"] = "At skill %s, buy the %s before the 150 cap."
FF.englishStrings["chef.route.artisan"] = "At level 35 and Cooking %s, complete %s for Artisan Cooking."
FF.englishStrings["chef.route.recipe-compact"] = "%s recipe"
FF.englishStrings["chef.route.recipes-compact"] = "%s recipes"
FF.englishStrings["chef.route.compact.apprentice"] = "Apprentice Cooking"
FF.englishStrings["chef.route.compact.journeyman"] = "Journeyman Cooking (skill %s)"
FF.englishStrings["chef.route.compact.expert"] = "Cooking %s — %s"
FF.englishStrings["chef.route.compact.artisan"] = "Cooking %s, level 35 — %s"
FF.englishStrings["chef.route.instruction.catches"] = "Catches: %s"
FF.englishStrings["chef.route.instruction.recipe"] = "Recipe: %s"
FF.englishStrings["chef.route.instruction.training"] = "Training: %s"
FF.englishStrings["chef.route.instruction.waters"] = "Waters: %s"

-- Grilling source and waters prose; native names and map facts remain canonical.
FF.englishStrings["chef.reference.meal.6290.recipe"] = "Fishing or cooking suppliers in starting areas"
FF.englishStrings["chef.reference.meal.6290.waters"] = "Starting zone rivers and lakes"
FF.englishStrings["chef.reference.meal.787.Alliance.recipe"] = "Coastal fishing suppliers; %s in %s"
FF.englishStrings["chef.reference.meal.787.Horde.recipe"] = "Coastal fishing suppliers; %s near %s"
FF.englishStrings["chef.reference.meal.787.waters"] = "Starting zone coasts"
FF.englishStrings["chef.reference.meal.5476.Alliance.recipe"] = "%s in %s, %s"
FF.englishStrings["chef.reference.meal.5476.Horde.recipe"] = "Check the neutral Auction House"
FF.englishStrings["chef.reference.meal.5476.waters"] = "%s drops from %s in coastal water"
FF.englishStrings["chef.reference.meal.6316.Alliance.recipe"] = "%s in %s"
FF.englishStrings["chef.reference.meal.6316.waters"] = "%s lakes"
FF.englishStrings["chef.reference.meal.4592.Alliance.recipe"] = "Fishing suppliers; %s in %s"
FF.englishStrings["chef.reference.meal.4592.Horde.recipe"] = "Fishing suppliers in %s"
FF.englishStrings["chef.reference.meal.4592.Alliance.waters"] = "%s canals or %s lakes"
FF.englishStrings["chef.reference.meal.4592.Horde.waters"] = "%s or %s waters"
FF.englishStrings["chef.reference.meal.5095.recipe"] = "Coastal fishing suppliers"
FF.englishStrings["chef.reference.meal.5095.waters"] = "%s or %s coast"
FF.englishStrings["chef.reference.meal.21072.recipe"] = "Fishing suppliers; %s in %s also stocks it"
FF.englishStrings["chef.reference.meal.21072.waters"] = "%s schools in %s or %s"
FF.englishStrings["chef.reference.meal.6657.recipe"] = "Recipe drops from creatures in %s"
FF.englishStrings["chef.reference.meal.6657.waters"] = "%s oasis pools or %s"
FF.englishStrings["chef.reference.meal.251525.recipe"] = "Recipe drops from %s in %s"
FF.englishStrings["chef.reference.meal.251525.waters"] = "%s schools in %s"
FF.englishStrings["chef.reference.meal.5526.Alliance.recipe"] = "%s in %s or %s in %s"
FF.englishStrings["chef.reference.meal.5526.Horde.recipe"] = "No Horde recipe source is confirmed in this guide"
FF.englishStrings["chef.reference.meal.5526.waters"] = "Open clams caught in low level coastal water"
FF.englishStrings["chef.reference.meal.4593.Alliance.recipe"] = "Fishing suppliers in %s and other cities"
FF.englishStrings["chef.reference.meal.4593.Horde.recipe"] = "Fishing suppliers in %s and other cities"
FF.englishStrings["chef.reference.meal.4593.Alliance.waters"] = "%s or %s rivers and lakes"
FF.englishStrings["chef.reference.meal.4593.Horde.waters"] = "%s or %s inland water"
FF.englishStrings["chef.reference.meal.5527.recipe"] = "Cooking trainer"
FF.englishStrings["chef.reference.meal.5527.waters"] = "Open clams from coastal fishing or sea creatures"
FF.englishStrings["chef.reference.meal.6038.recipe"] = "Fishing supplier in %s, %s"
FF.englishStrings["chef.reference.meal.6038.waters"] = "Open %s from higher level coastal catches"
FF.englishStrings["chef.reference.meal.8364.recipe"] = "%s in %s; also sold by regional fishing suppliers"
FF.englishStrings["chef.reference.meal.8364.waters"] = "%s or %s inland water"
FF.englishStrings["chef.reference.meal.4594.waters"] = "%s or %s coast"
FF.englishStrings["chef.reference.meal.21217.Alliance.recipe"] = "%s in %s or %s in %s"
FF.englishStrings["chef.reference.meal.21217.Horde.recipe"] = "%s in %s or %s in %s"
FF.englishStrings["chef.reference.meal.21217.waters"] = "%s schools in %s or %s"
FF.englishStrings["chef.reference.meal.13927.recipe"] = "%s in %s"
FF.englishStrings["chef.reference.meal.13927.waters"] = "%s or %s coast"
FF.englishStrings["chef.reference.meal.13930.waters"] = "%s or %s lakes"
FF.englishStrings["chef.reference.meal.recipe-unconfirmed"] = "Recipe source not yet confirmed in Forever"
FF.englishStrings["chef.reference.meal.recipe-item-unconfirmed"] = "%s (source unconfirmed)"
FF.englishStrings["chef.reference.meal.274971.recipe"] = "%s from %s. Speak to %s in %s."
FF.englishStrings["chef.reference.meal.274971.waters"] = "Loot %s and %s. Buy %s from cooking suppliers."
FF.englishStrings["chef.reference.meal.8957.waters"] = "Buy %s from fish vendors."
FF.englishStrings["chef.reference.meal.286152.waters"] = "%s or %s inland water"
FF.englishStrings["chef.reference.meal.6887.recipe"] = "%s at %s, %s"
FF.englishStrings["chef.reference.meal.16766.recipe"] = "%s at %s, %s"
FF.englishStrings["chef.reference.meal.16766.waters"] = "Open %s from higher level coastal catches"
FF.englishStrings["chef.reference.meal.13928.waters"] = "%s coast in winter"
FF.englishStrings["chef.reference.meal.13929.waters"] = "%s coast in summer"
FF.englishStrings["chef.reference.meal.13931.waters"] = "%s or %s lakes at night"
FF.englishStrings["chef.reference.meal.13932.waters"] = "%s or %s lakes by day"
FF.englishStrings["chef.reference.meal.13935.Alliance.recipe"] = "%s at %s"
FF.englishStrings["chef.reference.meal.13935.Horde.recipe"] = "%s at %s"
FF.englishStrings["chef.reference.meal.13935.waters"] = "%s or %s inland water"
FF.englishStrings["chef.reference.meal.13933.waters"] = "High level coastal water"
FF.englishStrings["chef.reference.meal.238642.waters"] = "Fish high level coasts for %s"
FF.englishStrings["chef.reference.meal.238641.waters"] = "Fish the %s or %s coast for yellowtail and cod"

-- Fishing route and camp milestone display prose; stable names remain arguments.
FF.englishStrings["fishing.route.1.heading"] = "1–75  •  Starting waters"
FF.englishStrings["fishing.route.1.summary"] = "Starting waters, your first pole and %s training."
FF.englishStrings["fishing.route.1.row.1"] = "Train %s Fishing; {trainer}."
FF.englishStrings["fishing.route.1.row.2"] = "Buy a pole from a fishing supplier; {supplier}."
FF.englishStrings["fishing.route.1.row.3"] = "Fish inland near your starting area for %s, or try the coast for %s."
FF.englishStrings["fishing.route.1.row.4"] = "Use a %s if fish keep escaping."
FF.englishStrings["fishing.route.2.heading"] = "%s Fishing  •  Skill 50, Level 10 required"
FF.englishStrings["fishing.route.2.support"] = "Train before the 75 skill cap; raises your cap to 150."
FF.englishStrings["fishing.route.3.heading"] = "75–150  •  City waters"
FF.englishStrings["fishing.route.3.summary"] = "City waters for early Cooking fish; prepare for %s Fishing."
FF.englishStrings["fishing.route.3.row.1"] = "Learn %s Fishing (Skill 50, Level 10; cap 150); {trainer}."
FF.englishStrings["fishing.route.3.row.2.Alliance"] = "Fish in %s or %s for early Cooking fish. Some %s water may not be fishable on modern Classic clients."
FF.englishStrings["fishing.route.3.row.2.Horde"] = "Fish in %s or %s for early Cooking fish."
FF.englishStrings["fishing.route.4.heading"] = "%s Fishing  •  Skill 125, Level 20 required"
FF.englishStrings["fishing.route.4.support"] = "Buy %s, then read it to raise your cap to 225."
FF.englishStrings["fishing.route.5.heading"] = "150–225  •  Intermediate waters"
FF.englishStrings["fishing.route.5.summary"] = "Intermediate waters and the %s Fishing quest."
FF.englishStrings["fishing.route.5.row.1"] = "Read %s (Skill 125, Level 20; cap 225); {trainer}."
FF.englishStrings["fishing.route.5.row.2"] = "Try %s or the %s coast. If fish escape too often, fish in %s, %s, or %s until your skill catches up."
FF.englishStrings["fishing.route.6.heading"] = "%s Fishing  •  Skill 225, Level 35 required"
FF.englishStrings["fishing.route.6.support"] = "For %s, catch:\n• %s — %s %s.\n• %s — southeast %s coast %s.\n• %s — %s %s.\n• %s — %s %s."
FF.englishStrings["fishing.route.7.heading"] = "225–300  •  Final stretch"
FF.englishStrings["fishing.route.7.summary"] = "Higher-skill waters, valuable pools and the %s."
FF.englishStrings["fishing.route.7.row.1"] = "Complete %s (Skill 225, Level 35; cap 300); {trainer}."
FF.englishStrings["fishing.route.7.row.2"] = "Fish in %s, %s, %s, %s, %s, or %s. Level Cooking with your catches, or look for valuable pools."
FF.englishStrings["fishing.route.7.row.3"] = "Use a lure if your skill is low for the water."
FF.englishStrings["fishing.milestone.1.heading"] = "Camp milestone  •  Fishing 20: %s"
FF.englishStrings["fishing.milestone.1.body"] = "%s sends you to a trainer for the %s. Use 1 %s and 1 %s. %s before placing it; the seated buff is 8%% stats and does not stack with %s."
FF.englishStrings["fishing.milestone.4.heading"] = "Camp milestone  •  Fishing 140: %s"
FF.englishStrings["fishing.milestone.4.body"] = "%s drops from %s in %s. Use 2 %s, 1 %s and 2 %s. Place by a campfire for 1 hr of uncommon-catch access. Lures are available to everyone. Improves your chance of catching bloated fish. Can replace a %s."
FF.englishStrings["fishing.milestone.7.heading"] = "Camp milestone  •  Fishing 300: %s"
FF.englishStrings["fishing.row.start"] = "Start"
FF.englishStrings["fishing.row.supplies"] = "Supplies"
FF.englishStrings["fishing.row.waters"] = "Waters"
FF.englishStrings["fishing.row.bait"] = "Bait"
FF.englishStrings["fishing.training-heading"] = "Next training • %s • Skill %d, Level %d; {trainer}"
FF.englishStrings["fishing.milestones-on"] = "Camp milestones: On"
FF.englishStrings["fishing.milestones-off"] = "Camp milestones: Off"

-- Structured route display slots: numeric requirements and translated ranks.
FF.englishStrings["skill.display.value"] = "%d"
FF.englishStrings["skill.display.range"] = "%d–%d"
FF.englishStrings["skill.fishing.route.1.heading"] = "%s  •  Starting waters"
FF.englishStrings["skill.fishing.route.2.heading"] = "%s Fishing  •  Skill %s, Level 10 required"
FF.englishStrings["skill.fishing.route.3.heading"] = "%s  •  City waters"
FF.englishStrings["skill.fishing.route.3.row.1"] = "Learn %s Fishing (Skill %s, Level 10; cap 150); {trainer}."
FF.englishStrings["skill.fishing.route.4.heading"] = "%s Fishing  •  Skill %s, Level 20 required"
FF.englishStrings["skill.fishing.route.5.heading"] = "%s  •  Intermediate waters"
FF.englishStrings["skill.fishing.route.5.row.1"] = "Read %s (Skill %s, Level 20; cap 225); {trainer}."
FF.englishStrings["skill.fishing.route.6.heading"] = "%s Fishing  •  Skill %s, Level 35 required"
FF.englishStrings["skill.fishing.route.7.heading"] = "%s  •  Final stretch"
FF.englishStrings["skill.fishing.route.7.row.1"] = "Complete %s (Skill %s, Level 35; cap 300); {trainer}."
FF.englishStrings["skill.fishing.milestone.1.heading"] = "Camp milestone  •  Fishing %s: %s"
FF.englishStrings["skill.fishing.milestone.4.heading"] = "Camp milestone  •  Fishing %s: %s"
FF.englishStrings["skill.fishing.milestone.7.heading"] = "Camp milestone  •  Fishing %s: %s"
FF.englishStrings["skill.fishing.milestone.7.guide"] = "%s drops from %s in %s. Use 5 %s, 2 %s and 1 %s. At level 35 and Fishing %s, use a %s on %s or %s to prepare the steaks. Place by a campfire for 1 hr of rare-catch access. Provides Fishing lures. Can replace a %s. Camp features share a 1 hr placement cooldown."
FF.englishStrings["skill.chef.reference.route.1.heading"] = "%s  •  First catches"
FF.englishStrings["skill.chef.reference.route.2.heading"] = "%s  •  Mud Snapper"
FF.englishStrings["skill.chef.reference.route.2.recipe"] = "Buy the Mud Snapper recipe from a fishing supplier. Train Journeyman Cooking at skill %s, before the 75 cap."
FF.englishStrings["skill.chef.reference.route.3.heading"] = "%s  •  Catfish"
FF.englishStrings["skill.chef.reference.route.3.recipe"] = "Buy the recipe from a fishing supplier. At skill %s, buy the %s before you reach the 150 cap."
FF.englishStrings["skill.chef.reference.route.4.heading"] = "%s  •  Trout"
FF.englishStrings["skill.chef.reference.route.5.heading"] = "%s  •  Yellowtail"
FF.englishStrings["skill.chef.reference.route.5.recipe"] = "%s at %s sells Yellowtail; %s in %s sells Redgill. For Artisan Cooking, complete %s's %s in %s at level 35 and skill %s."
FF.englishStrings["skill.chef.reference.route.6.heading"] = "%s  •  Nightfin"
FF.englishStrings["skill.chef.reference.route.7.heading"] = "%s  •  Finish"
FF.englishStrings["skill.chef.reference.route.7.Alliance.recipe"] = "%s at %s sells the three %s recipes."
FF.englishStrings["skill.chef.reference.route.7.Horde.recipe"] = "%s at %s sells the three %s recipes."
FF.englishStrings["skill.fishing.training-heading"] = "Next training • %s • Skill %s, Level %d; {trainer}"

-- Training source tooltip display; native ranks and actions remain unchanged.
FF.englishStrings["fishing.source.apprentice"] = "%s Fishing: no skill or level requirement; cap 75."
FF.englishStrings["fishing.source.journeyman"] = "%s Fishing: Skill 50, Level 10; cap 150."
FF.englishStrings["fishing.source.expert"] = "Book seller: %s. Skill 125, Level 20; cap 225."
FF.englishStrings["fishing.source.artisan"] = "Quest giver: %s. Skill 225, Level 35; cap 300."
FF.englishStrings["fishing.source.supplier"] = "Supplies: sells %s."

-- Nearby display only; zone/filter/source identities stay canonical.
FF.englishStrings["nearby.current"] = "Current"
FF.englishStrings["nearby.zone-unavailable"] = "Zone unavailable"
FF.englishStrings["nearby.browse-tip"] = "Browsing this zone. Current restores following your location."
FF.englishStrings["nearby.follow-tip"] = "Following your current zone. Click to browse."
FF.englishStrings["nearby.heading.conditions"] = "Fishing conditions"
FF.englishStrings["nearby.heading.gallery"] = "Catches here"
FF.englishStrings["nearby.heading.supplies"] = "Local supplies & services"
FF.englishStrings["nearby.heading.method"] = "Fishing method"
FF.englishStrings["nearby.heading.skill"] = "Effective fishing skill"
FF.englishStrings["nearby.heading.waters"] = "Best waters"
FF.englishStrings["nearby.leads-tip"] = "These are verified leads, not a complete zone loot table."
FF.englishStrings["nearby.skill-tip"] = "Effective Fishing is your learned Fishing skill plus pole, gear, lure and other active bonuses. Minimum lets you fish here; reliable reduces fish escaping. Named waters can have higher requirements, as listed. Colours compare each requirement with your current effective skill."
FF.englishStrings["nearby.waters-tip"] = "Verified named pools and schools in this area. Click a name to show its known catches. Land your bobber inside a pool. Spawn positions and complete pool loot tables are not tracked."
FF.englishStrings["nearby.conditions-empty"] = "No verified fishing conditions are listed for this zone yet."
FF.englishStrings["nearby.pools"] = "Pools & schools"
FF.englishStrings["nearby.skill-thresholds"] = "%s minimum  •  %s reliable"
FF.englishStrings["nearby.water.inland"] = "Inland water"
FF.englishStrings["nearby.water.coastal"] = "Coastal water"
FF.englishStrings["nearby.water.open"] = "Open water"
FF.englishStrings["nearby.filter.all"] = "All"
FF.englishStrings["nearby.filter.rare"] = "Rare"
FF.englishStrings["nearby.filter.trophy"] = "Trophy"
FF.englishStrings["nearby.filter.common"] = "Common"
FF.englishStrings["nearby.empty.all"] = "No verified catches are listed here. Saved catches remain below."
FF.englishStrings["nearby.empty.rare"] = "No verified rare or bloated catches are listed here. Saved catches remain below."
FF.englishStrings["nearby.empty.trophy"] = "No verified trophy fish are listed here. Saved catches remain below."
FF.englishStrings["nearby.empty.common"] = "No verified common fish are listed here. Saved catches remain below."
FF.englishStrings["nearby.sources-empty"] = "No verified local sources are listed."
FF.englishStrings["nearby.map-unavailable"] = "Zone map unavailable; local sources need verified map data."
FF.englishStrings["nearby.tools"] = "Fishing kit & camp tools"

-- Nearby service wording is display-only; canonical roles and targets stay intact.
FF.englishStrings["nearby.role.trainer"] = "Fishing trainer"
FF.englishStrings["nearby.role.book"] = "Fishing book"
FF.englishStrings["nearby.role.artisan"] = "Artisan quest"
FF.englishStrings["nearby.role.pole"] = "Fishing pole quest"
FF.englishStrings["nearby.role.recipes"] = "Recipes"
FF.englishStrings["nearby.role.supplies"] = "Fishing supplies"
FF.englishStrings["nearby.service.training"] = "Training"
FF.englishStrings["nearby.service.sells"] = "Sells"
FF.englishStrings["nearby.service.recipes"] = "Recipes"
FF.englishStrings["nearby.service.other"] = "Services"
FF.englishStrings["nearby.service.fishing-ranks"] = "Apprentice and Journeyman Fishing"
FF.englishStrings["nearby.service.fishing-ranks-tip"] = "Apprentice: cap 75. Journeyman: Skill 50, Level 10; cap 150."
FF.englishStrings["nearby.service.limited"] = "Limited"
FF.englishStrings["nearby.service.limited-tip"] = "Limited stock — this item may be unavailable when you visit. Current vendor stock is not tracked."
FF.englishStrings["nearby.service.recipe"] = "Recipe: %s"
FF.englishStrings["nearby.service.ingredients"] = "Cooking %d • %s"
FF.englishStrings["nearby.service.open-recipe"] = "Click: open this Master Chef recipe"
FF.englishStrings["nearby.service.open-guide"] = "Click: open the related Journal instructions"
FF.englishStrings["nearby.person.services"] = "%s • services"
FF.englishStrings["nearby.person.distance"] = "≈ %d yd"
FF.englishStrings["nearby.person.distance-tip"] = "≈ %d yd (straight-line)"
FF.englishStrings["nearby.person.distance-unavailable"] = "? — Distance unavailable for your current position or map."
FF.englishStrings["nearby.person.toggle"] = "Click header: show or hide this NPC's services"
FF.englishStrings["nearby.person.map"] = "%.1f, %.1f • Click: show on map"
FF.englishStrings["nearby.person.map-distance-unavailable"] = "Distance unavailable"
FF.englishStrings["nearby.person.sells-pole"] = "Also verified to sell Fishing Pole."
FF.englishStrings["nearby.service.toggle"] = "Show or hide this person's verified services."

-- Nearby authored notes and whole count phrases: display projections only.
FF.englishStrings["nearby.method.blackmouth"] = "Blackmouth schools or coastal water"
FF.englishStrings["nearby.method.coastal"] = "Coastal open water"
FF.englishStrings["nearby.method.coastal-debris"] = "Coastal open water or debris"
FF.englishStrings["nearby.method.coastal-wreckage"] = "Coastal open water or wreckage"
FF.englishStrings["nearby.method.pools-wreckage"] = "Coastal pools or wreckage"
FF.englishStrings["nearby.method.deviate"] = "Deviate Fish schools or inland water"
FF.englishStrings["nearby.method.firefin"] = "Firefin schools"
FF.englishStrings["nearby.method.firefin-coastal"] = "Firefin schools or coastal water"
FF.englishStrings["nearby.method.schools-debris"] = "Fish schools or floating debris"
FF.englishStrings["nearby.method.schools-wreckage"] = "Fish schools or wreckage"
FF.englishStrings["nearby.method.debris"] = "Floating Debris pools"
FF.englishStrings["nearby.method.greater-sagefish"] = "Greater Sagefish schools"
FF.englishStrings["nearby.method.inland"] = "Inland open water"
FF.englishStrings["nearby.method.muddy"] = "Muddy Churning Waters only"
FF.englishStrings["nearby.method.unknown"] = "No verified fishing-water leads are listed for this zone yet."
FF.englishStrings["nearby.method.oil"] = "Oil Spill pools only"
FF.englishStrings["nearby.method.open"] = "Open water"
FF.englishStrings["nearby.method.sagefish"] = "Sagefish schools"
FF.englishStrings["nearby.method.tastyfish"] = "Schools of Tastyfish only"
FF.englishStrings["nearby.method.stonescale"] = "Stonescale Eel schools or coastal water"
FF.englishStrings["nearby.method.whimsyfin"] = "Whimsyfin schools only"
FF.englishStrings["nearby.method.wreckage"] = "Wreckage pools"
FF.englishStrings["nearby.condition.quest"] = "For the %s quest."
FF.englishStrings["nearby.note.day"] = "Daytime catch."
FF.englishStrings["nearby.note.raid"] = "Inside the %s raid."
FF.englishStrings["nearby.note.more-night"] = "More common at night."
FF.englishStrings["nearby.note.most-night"] = "Most common at night."
FF.englishStrings["nearby.note.quest-coast"] = "%s must be active; fish the %s."
FF.englishStrings["nearby.note.quest-east"] = "%s must be active; fish the eastern coast."
FF.englishStrings["nearby.note.quest-west"] = "%s must be active; fish the western coast."
FF.englishStrings["nearby.note.needed"] = "Needed for %s."
FF.englishStrings["nearby.note.tournament"] = "%s, Sunday 2–4 p.m. server time."
FF.englishStrings["nearby.note.summer"] = "Summer season; limited overlap in spring and autumn."
FF.englishStrings["nearby.note.winter"] = "Winter season; limited overlap in spring and autumn."
FF.englishStrings["nearby.caveat.multiple"] = "%s need %s minimum / %s reliable effective skill."
FF.englishStrings["nearby.caveat.single"] = "%s needs %s minimum / %s reliable effective skill."
FF.englishStrings["nearby.caveat.modern"] = "Some %s water may not be fishable on modern Classic clients."
FF.englishStrings["nearby.pool.note"] = "Cast so your bobber lands inside the pool. Listed catches are verified leads; pool spawn positions are not tracked."
FF.englishStrings["nearby.pool.debris-note"] = "Fish inside the visible debris or wreckage ring. These are curated catch leads, not an exhaustive loot table or inventory contents."
FF.englishStrings["nearby.pool.catches"] = "Known catches: %s"
FF.englishStrings["nearby.pool.toggle"] = "Click: show or hide pool catches"
FF.englishStrings["nearby.family.heading"] = "Weighted trophy catches"
FF.englishStrings["nearby.family.toggle"] = "Show or hide individual catch icons below this row. Each retains its own record and mastery."
FF.englishStrings["nearby.family.individual"] = "%s • individual weights"
FF.englishStrings["nearby.family.tip"] = "%s family • %d verified local weights. Use the chevron for individual catches."
FF.englishStrings["nearby.catch.recorded"] = "Recorded in your Journal • Click: open Catch Journal"
FF.englishStrings["nearby.catch.uncaught"] = "Not yet caught • Click: open Catch Journal"
FF.englishStrings["nearby.records.summary"] = "Your catches • %s • %s"
FF.englishStrings["nearby.records.types.one"] = "%s type"
FF.englishStrings["nearby.records.types.other"] = "%s types"
FF.englishStrings["nearby.records.items.one"] = "%s item"
FF.englishStrings["nearby.records.items.other"] = "%s items"
FF.englishStrings["nearby.records.title"] = "Your recorded catches"
FF.englishStrings["nearby.records.tip"] = "Saved across your characters in this zone and its subzones. Similar zone-name prefixes are excluded. Types count distinct item IDs; items count caught quantity, including records outside the guide catalogue. These are not inventory quantities or known-availability totals."
FF.englishStrings["nearby.records.empty"] = "No catches have been recorded in this zone yet."

-- Event and shared achievement presentation; canonical definitions stay intact.
FF.englishStrings["events.now"] = "Now"
FF.englishStrings["events.realm"] = "Realm:"
FF.englishStrings["events.local"] = "Local:"
FF.englishStrings["events.unavailable"] = "Event times are unavailable. Check the in game calendar."
FF.englishStrings["events.schedule-note"] = "Beta schedules can change. Check the in game calendar."
FF.englishStrings["events.stranglethorn.title"] = "Stranglethorn Fishing Extravaganza"
FF.englishStrings["events.guide.requirements.heading"] = "Requirements"
FF.englishStrings["events.guide.waters.heading"] = "Where to fish"
FF.englishStrings["events.guide.task.heading"] = "What to do"
FF.englishStrings["events.guide.tips.heading"] = "Tips"
FF.englishStrings["events.guide.requirements.body"] = "Bring a fishing pole and learn Fishing; no registration is needed. Aim for Fishing %s or higher. Fishing %s plus a lure reduces escapes."
FF.englishStrings["events.guide.waters.body"] = "When the event starts, fish %s along the %s coast, outside %s. Land your bobber inside a pool."
FF.englishStrings["events.guide.task.body"] = "Turn in 40 %s to %s on %s's central dock. The first 250 turn-ins per ruleset win. Exchange the prize coin with %s."
FF.englishStrings["events.guide.tips.body"] = "Clear bag space and set your Hearthstone to %s. Keep fishing for rare catches after the main prize announcement while the event remains active."
FF.englishStrings["events.full-guide"] = "See Rare Catches for the full guide."
FF.englishStrings["events.open-next-tip"] = "Open the next Stranglethorn Fishing Extravaganza with realm and local times."
FF.englishStrings["events.search.upcoming"] = "Upcoming event"
FF.englishStrings["events.search.calendar"] = "Fishing event calendar"
FF.englishStrings["events.search.help"] = "Upcoming events; realm and local fishing event times; check the in game calendar when times are unavailable."
FF.englishStrings["achievement.completed-count"] = "%s / %s completed"
FF.englishStrings["achievement.notice.earned"] = "ACHIEVEMENT EARNED"
FF.englishStrings["achievement.detail.completed"] = "Completed"
FF.englishStrings["achievement.detail.completed-date"] = "Completed  •  %s"
FF.englishStrings["achievement.detail.lures"] = "Apply lures to a fishing pole; carrying them does not count."
FF.englishStrings["achievement.detail.recipes-fallback"] = "Learn recipes on this character to fill your collection."
FF.englishStrings["achievement.detail.zones"] = "Subzones within the same zone count once."
FF.englishStrings["achievement.detail.missing"] = "Still to catch: %s"
FF.englishStrings["achievement.detail.missing-more"] = "Still to catch: %s  •  +%d more"

-- Achievement wording projects from stable IDs; definition/ledger owners stay canonical.
FF.englishStrings["achievement.definition.first-bite.title"] = "First Bite"
FF.englishStrings["achievement.definition.first-bite.description"] = "Catch your first fish."
FF.englishStrings["achievement.definition.first-bite.flavour"] = "A quiet ripple can be the start of a grand adventure."
FF.englishStrings["achievement.definition.eyes-on-the-water.title"] = "Eyes on the Water"
FF.englishStrings["achievement.definition.eyes-on-the-water.description"] = "Land 10 successful catches within five minutes."
FF.englishStrings["achievement.definition.eyes-on-the-water.flavour"] = "Patience and a watchful eye are an angler's finest tackle."
FF.englishStrings["achievement.definition.eyes-on-the-water.detail"] = "Progress shows your best five-minute window. Each successful fishing cast counts once, regardless of item quantity. Failed or cancelled casts do not reset the window."
FF.englishStrings["achievement.definition.hook-to-hearth.title"] = "From Hook to Hearth"
FF.englishStrings["achievement.definition.hook-to-hearth.description"] = "Cook your first fishing meal with Master Chef."
FF.englishStrings["achievement.definition.hook-to-hearth.flavour"] = "Every great fishing tale deserves a freshly cooked meal."
FF.englishStrings["achievement.definition.something-fishy.title"] = "Something Fishy"
FF.englishStrings["achievement.definition.something-fishy.description"] = "Discover 10 different fish."
FF.englishStrings["achievement.definition.something-fishy.flavour"] = "There is always another surprise beneath the surface."
FF.englishStrings["achievement.definition.one-of-a-kind.title"] = "One of a Kind"
FF.englishStrings["achievement.definition.one-of-a-kind.description"] = "Reel in your first rare catch."
FF.englishStrings["achievement.definition.one-of-a-kind.flavour"] = "Some ripples are worth remembering."
FF.englishStrings["achievement.definition.treasure-from-the-deep.title"] = "Treasure from the Deep"
FF.englishStrings["achievement.definition.treasure-from-the-deep.description"] = "Fish up something that isn’t a fish."
FF.englishStrings["achievement.definition.treasure-from-the-deep.flavour"] = "The waters have a curious idea of buried treasure."
FF.englishStrings["achievement.definition.hooked.title"] = "Hooked"
FF.englishStrings["achievement.definition.hooked.description"] = "Record 100 catches."
FF.englishStrings["achievement.definition.hooked.flavour"] = "Just one more cast is a perfectly reasonable plan."
FF.englishStrings["achievement.definition.new-waters.title"] = "New Waters"
FF.englishStrings["achievement.definition.new-waters.description"] = "Catch fish in 5 different zones."
FF.englishStrings["achievement.definition.new-waters.flavour"] = "Pack a pole and let the next shoreline choose the view."
FF.englishStrings["achievement.definition.plenty-of-fish.title"] = "Plenty of Fish"
FF.englishStrings["achievement.definition.plenty-of-fish.description"] = "Discover 25 different fish."
FF.englishStrings["achievement.definition.plenty-of-fish.flavour"] = "A well-worn journal makes room for colourful company."
FF.englishStrings["achievement.definition.camp-cook.title"] = "Camp Cook"
FF.englishStrings["achievement.definition.camp-cook.description"] = "Cook 50 fishing meals with Master Chef."
FF.englishStrings["achievement.definition.camp-cook.flavour"] = "The campfire always draws a hungry crowd."
FF.englishStrings["achievement.definition.tackle-box.title"] = "Tackle Box"
FF.englishStrings["achievement.definition.tackle-box.description"] = "Put 5 different fishing lures to use."
FF.englishStrings["achievement.definition.tackle-box.flavour"] = "A little preparation can make a quiet afternoon interesting."
FF.englishStrings["achievement.definition.rare-company.title"] = "Rare Company"
FF.englishStrings["achievement.definition.rare-company.description"] = "Discover 5 different rare catches."
FF.englishStrings["achievement.definition.rare-company.flavour"] = "Unusual company makes for excellent dockside stories."
FF.englishStrings["achievement.definition.seasoned-angler.title"] = "Seasoned Angler"
FF.englishStrings["achievement.definition.seasoned-angler.description"] = "Record 500 catches."
FF.englishStrings["achievement.definition.seasoned-angler.flavour"] = "Patience wears as comfortably as a favourite fishing hat."
FF.englishStrings["achievement.definition.master-of-the-line.title"] = "Master of the Line"
FF.englishStrings["achievement.definition.master-of-the-line.description"] = "Reach 300 Fishing skill."
FF.englishStrings["achievement.definition.master-of-the-line.flavour"] = "Even the longest cast begins with a steady hand."
FF.englishStrings["achievement.definition.master-of-the-line.detail"] = "Base Fishing skill; equipment and lure bonuses do not count."
FF.englishStrings["achievement.definition.well-travelled.title"] = "Well Travelled"
FF.englishStrings["achievement.definition.well-travelled.description"] = "Catch fish in 15 different zones."
FF.englishStrings["achievement.definition.well-travelled.flavour"] = "The road is easier to follow when it runs beside the water."
FF.englishStrings["achievement.definition.fully-equipped.title"] = "Fully Equipped"
FF.englishStrings["achievement.definition.fully-equipped.description"] = "Fish up every piece of equippable fishing gear in the collection."
FF.englishStrings["achievement.definition.fully-equipped.flavour"] = "The finest tackle sometimes comes from the other end of the line."
FF.englishStrings["achievement.definition.fully-equipped.detail"] = "Catch %s, %s and %s yourself; buying or trading for them does not count."
FF.englishStrings["achievement.definition.master-angler.title"] = "Master Angler"
FF.englishStrings["achievement.definition.master-angler.description"] = "Catch every standard fish in the Catch Collection."
FF.englishStrings["achievement.definition.master-angler.flavour"] = "Every page is an invitation to try another stretch of water."
FF.englishStrings["achievement.definition.master-chef.title"] = "Master Chef"
FF.englishStrings["achievement.definition.master-chef.description"] = "Learn every fishing recipe in the Master Chef collection."
FF.englishStrings["achievement.definition.master-chef.flavour"] = "A good recipe is a treasure worth keeping beside the tackle box."
FF.englishStrings["achievement.definition.forever-fishing.title"] = "Forever Fishing"
FF.englishStrings["achievement.definition.forever-fishing.description"] = "Record 1,000 catches."
FF.englishStrings["achievement.definition.forever-fishing.flavour"] = "There is no hurry when the water still has stories to tell."
FF.englishStrings["achievement.definition.the-deep-end.title"] = "The Deep End"
FF.englishStrings["achievement.definition.the-deep-end.description"] = "Discover every rare and special catch."
FF.englishStrings["achievement.definition.the-deep-end.flavour"] = "Beyond the familiar shallows, stranger tales are waiting."
FF.englishStrings["achievement.definition.master-of-the-waters.title"] = "Master of the Waters"
FF.englishStrings["achievement.definition.master-of-the-waters.description"] = "Catch every standard fish at least 10 times."
FF.englishStrings["achievement.definition.master-of-the-waters.flavour"] = "The best fishing spots reward those who linger."
FF.englishStrings["achievement.definition.master-of-the-waters.detail"] = "Reach Catch Mastery Tier I for each standard fish (10 catches). Later tiers begin at 50, 100, 250, 500 and 1,000 catches."
FF.englishStrings["achievement.definition.hook-em-all.title"] = "Hook ’Em All"
FF.englishStrings["achievement.definition.hook-em-all.description"] = "Complete the entire Catch Collection."
FF.englishStrings["achievement.definition.hook-em-all.flavour"] = "A journal full of possibilities begins with an empty page."
FF.englishStrings["achievement.definition.hook-em-all.detail"] = "Includes standard fish, rare and special catches, equippable catches and other finds. Items inside opened containers do not count."
FF.englishStrings["achievement.search-context"] = "Achievement"

FF.localePacks = {}
FF.installedLocalePacks = {} -- Generated, validated pack references; missing units fall back individually.
FF.previewLocales = {} -- Filled only by the TOC-loaded development preview resource.

FF.englishStrings["settings.keybindings"] = "Keybindings"
FF.englishStrings["settings.gamepad-heading"] = "Gamepad"
FF.englishStrings["settings.addon-language"] = "Addon language"
FF.englishStrings["settings.buttons-shortcuts"] = "Buttons & Shortcuts"
FF.englishStrings["progress.off"] = "Off"
FF.englishStrings["progress.always"] = "Always"
FF.englishStrings["progress.hidden"] = "Blizzard bar hidden"
FF.englishStrings["progress.summary"] = "Fishing and cooking progress with remaining time. Minimal cast view is for fishing only."
FF.englishStrings["progress.help"] = "Off hides progress and remaining time. Always shows them during fishing and cooking while the information panel is visible. Blizzard bar hidden shows them when Forever Fishing owns hiding Blizzard UI or that activity's cast bar. Does not reveal a hidden information panel."
FF.englishStrings["cast-bars.label"] = "Hide Blizzard cast bars"
FF.englishStrings["cast-bars.off"] = "Off"
FF.englishStrings["cast-bars.fishing"] = "Fishing only"
FF.englishStrings["cast-bars.cooking"] = "Cooking only"
FF.englishStrings["cast-bars.both"] = "Fishing and cooking"
FF.englishStrings["cast-bars.help"] = "Replace the selected activity's Blizzard cast bar when the information panel can visibly show reliable progress and remaining time. After cooking finishes or is interrupted, keep its bar hidden until Forever Fishing closes. Unrelated casts use Blizzard's normal bar. Unknown timing, a hidden panel, Cast progress Off, Minimal cast view or combat restores native control."
FF.englishStrings["information.cooking"] = "Cooking: %s"

FF.englishStrings["settings.fishing-view"] = "Fishing View"
FF.englishStrings["settings.fishing-key"] = "Fishing key"
FF.englishStrings["settings.advanced-bindings"] = "Advanced Bindings"
FF.englishStrings["settings.binding-guidance"] = "Fishing shortcuts are active only while fishing is open. The global toggle opens or closes fishing."
FF.englishStrings["settings.fishing-feedback"] = "Fishing feedback"
FF.englishStrings["settings.blizzard-ui"] = "Blizzard UI"
FF.englishStrings["settings.show-minimap"] = "Show minimap"
FF.englishStrings["minimap.help"] = "Keep the game minimap visible while Blizzard UI is hidden. Uses your existing tracking; does not grant Find Fish. The Forever Fishing minimap icon has its own setting."
FF.englishStrings["settings.show-chat"] = "Show chat"
FF.englishStrings["settings.minimal-cast"] = "Minimal cast view"
FF.englishStrings["chat.hidden"] = "Hidden"
FF.englishStrings["chat.always"] = "Always"
FF.englishStrings["chat.whispers"] = "Whispers"
FF.englishStrings["chat.guild"] = "Whispers & Guild"
FF.englishStrings["chat.help"] = "Applies while Forever Fishing hides Blizzard UI. Keep your normal chat, tabs and history. Whispers reveals it for incoming and outgoing character/Battle.net whispers; Whispers & Guild adds guild messages. Chat fades after about 12 seconds, paused while you use it. This controls visibility, not which messages appear. Temporary chat stays visible during combat."
FF.englishStrings["minimal.help"] = "During a fishing channel, temporarily replace the fishing buttons and information panel with a thin countdown bar. The configured display fades back after a short recasting delay. Works independently of Hide Blizzard UI. Your fishing key, chat choice, Settings and Journal remain available. Uses the normal display during combat."

FF.englishStrings["food.restores"] = "Restores"
FF.englishStrings["food.bonuses"] = "Bonuses"
FF.englishStrings["food.effects-unavailable"] = "Food effects not yet available."
FF.englishStrings["food.item-effects-unavailable"] = "Effects not yet available."
FF.englishStrings["food.camp-bowl-stats"] = "+%s stats while seated (does not stack with Blessing of Kings)"
FF.englishStrings["food.camp-uncommon-fish"] = "Catch uncommon fish (%s)"
FF.englishStrings["food.camp-lures"] = "Fishing skill lures"
FF.englishStrings["food.camp-bowl-benefits"] = "Fish Bowl benefits"
FF.englishStrings["food.restores-summary"] = "Restores %s"
FF.englishStrings["food.attack-power-short"] = "AP"
FF.englishStrings["food.kill-xp-short"] = "kill XP"
FF.englishStrings["food.mana-regen-short"] = "MP5"
FF.englishStrings["food.fishing-short"] = "Fishing"
FF.englishStrings["food.effect-separator"] = " · "

FF.englishStrings["settings.hide-blizzard-ui"] = "Hide Blizzard UI"
FF.englishStrings["ui-hide.never"] = "Off"
FF.englishStrings["ui-hide.fishing"] = "While fishing"
FF.englishStrings["ui-hide.casts"] = "While casting"
FF.englishStrings["ui-hide.help"] = "While casting keeps Blizzard UI hidden for 1.5 seconds after a fishing cast ends so you can recast. While fishing keeps it hidden between casts. Manual loot can temporarily show Blizzard UI. Minimal cast view is independent."


FF.englishStrings["action.fishing"]="Fishing"
FF.englishStrings["action.recast"]="Quick recast"
FF.englishStrings["action.gear"]="Equip / restore fishing gear"
FF.englishStrings["action.lure"]="Apply selected lure"
FF.englishStrings["action.chef"]="Open Master Chef"
FF.englishStrings["action.jump"]="Jump"
FF.englishStrings["action.toggle"]="Toggle Forever Fishing"
FF.englishStrings["binding.unknown-action"]="Unknown fishing action"
FF.englishStrings["binding.world-mouse"]="World mouse controls"
FF.englishStrings["binding.journal-back"]="Journal Back"
FF.englishStrings["binding.jump-required"]="Jump needs an available alternative"
FF.englishStrings["binding.conflict"]="Already used by %s. Choose another shortcut."
FF.englishStrings["binding.press"]="Press a key or combination…"
FF.englishStrings["binding.session-scope"]="Active only while fishing is open. Normal game bindings return when fishing closes."
FF.englishStrings["binding.global-warning"]="Global binding — active even when fishing is closed."
FF.englishStrings["binding.global-candidate"]="%s — opens or closes Forever Fishing."
FF.englishStrings["binding.global-candidate-action"]="%s — opens or closes Forever Fishing.\nOverrides: %s."
FF.englishStrings["binding.game-shortcut"]="Existing game shortcut"
FF.englishStrings["binding.addon-shortcut"]="Another addon shortcut"
FF.englishStrings["binding.assign"]="Assign binding"
FF.englishStrings["binding.cancel"]="Cancel"
FF.englishStrings["binding.double-right"]="Use double right click"
FF.englishStrings["binding.jump-help"]="Jump alternative: %s. Change it under Advanced bindings."
FF.englishStrings["binding.toggle-help"]="Opens or closes fishing. Global shortcut; opening is unavailable during combat."

FF.englishStrings["binding.capture-prompt"]="Press a key or mouse button…"
FF.englishStrings["binding.capture-fishing-prompt"]="Press a key, mouse button, or double right-click…"
FF.englishStrings["binding.session-only"]="Only active while fishing is open."
FF.englishStrings["binding.escape"]="Esc to cancel"
FF.englishStrings["binding.replace"]="Replace binding"
FF.englishStrings["binding.replace-conflict"]="%s is assigned to %s."
FF.englishStrings["binding.override-game"]="Overrides: %s."

-- Session Goals: semantic whole messages; native item names and saved IDs stay native.
FF.englishStrings["goals.move-help"] = "Session Goals • /Goals — drag the heading to move."
FF.englishStrings["goals.add-help"] = "Add Goal — choose a custom goal or catch target."
FF.englishStrings["goals.minimize-help"] = "Minimise Session Goals — tracking continues."
FF.englishStrings["goals.custom.catches"] = "Total catches"
FF.englishStrings["goals.custom.catches-help"] = "Confirmed fishing-loot quantity in this session. Stacked catches count each item."
FF.englishStrings["goals.custom.vendor"] = "Vendor value"
FF.englishStrings["goals.custom.vendor-help"] = "Current vendor-value estimate of items caught this session, not money received from selling. Unloaded prices are excluded until available."
FF.englishStrings["goals.custom.time"] = "Fishing time"
FF.englishStrings["goals.custom.time-help"] = "Session time since the first cast while a fishing rod is equipped. Time without a rod is excluded. Enter a target in whole minutes."
FF.englishStrings["goals.custom.casts"] = "Casts"
FF.englishStrings["goals.custom.casts-help"] = "Fishing channels started this session, including cancelled or expired casts. Rapid presses without a cast do not count."
FF.englishStrings["goals.custom.auction"] = "Estimated auction value"
FF.englishStrings["goals.custom.auction-help"] = "Current Auctionator/TSM estimate for session catches. This is not sale income; prices can change. Missing auction prices use the existing vendor-value fallback."
FF.englishStrings["common.unavailable"] = "Unavailable"
FF.englishStrings["format.currency"] = "%dg %02ds %02dc"
FF.englishStrings["format.hours-minutes-seconds"] = "%dh %02dm %02ds"
FF.englishStrings["format.minutes-seconds"] = "%dm %02ds"
FF.englishStrings["goals.choose-custom"] = "Choose a custom goal."
FF.englishStrings["goals.enter-currency"] = "Enter gold, silver and copper."
FF.englishStrings["goals.currency-range"] = "Use whole numbers: gold 0–999999, silver/copper 0–99."
FF.englishStrings["goals.positive-value"] = "Enter a value greater than zero."
FF.englishStrings["goals.choose-catch"] = "Choose a recorded or curated direct catch."
FF.englishStrings["goals.auction-unavailable"] = "Usable session auction prices are unavailable."
FF.englishStrings["goals.owner-unavailable"] = "Character identity is unavailable; try again when ready."
FF.englishStrings["goals.currency-target"] = "Target value: gold / silver / copper"
FF.englishStrings["goals.minutes-target"] = "Target in minutes"
FF.englishStrings["goals.target"] = "Session target"
FF.englishStrings["goals.update"] = "Update goal"
FF.englishStrings["goals.add"] = "Add goal"
FF.englishStrings["goals.add-heading"] = "Add Goal"
FF.englishStrings["goals.title-command"] = "Session Goals • /Goals"
FF.englishStrings["goals.add-short"] = "Add"
FF.englishStrings["goals.title"] = "Session Goals"
FF.englishStrings["goals.title-short"] = "Goals"
FF.englishStrings["goals.no-matches"] = "No matching catches."
FF.englishStrings["goals.vendor-loading"] = "Some vendor prices are still loading."
FF.englishStrings["goals.auction-fallback"] = "Some auction prices are unavailable; the existing vendor fallback is included."
FF.englishStrings["goals.expand"] = "Expand Session Goals"
FF.englishStrings["goals.close"] = "Close Session Goals"
FF.englishStrings["goals.search"] = "Search catches…"
FF.englishStrings["goals.custom-heading"] = "Custom goals"
FF.englishStrings["goals.catches-heading"] = "Catches"
FF.englishStrings["goals.done"] = "Done"
FF.englishStrings["common.item-id"] = "Item %s"
FF.englishStrings["goals.target-range"] = "Enter a whole number from 1 to %d."
FF.englishStrings["goals.session-progress"] = "This session: %s"
FF.englishStrings["goals.catch-progress"] = "Caught this session: %s"
FF.englishStrings["goals.empty"] = "Select %s to choose a goal."
FF.englishStrings["goals.saved-target"] = "Goal: %s"
FF.englishStrings["goals.unit-minutes"] = "minutes"
FF.englishStrings["goals.unit-count"] = "count"
FF.englishStrings["currency.gold-short"] = "g"
FF.englishStrings["currency.silver-short"] = "s"
FF.englishStrings["currency.copper-short"] = "c"
FF.englishStrings["count.catch.one"] = "%d catch"
FF.englishStrings["count.catch.other"] = "%d catches"
FF.englishStrings["count.cast.one"] = "%d cast"
FF.englishStrings["count.cast.other"] = "%d casts"
FF.englishStrings["count.location.one"] = "%d location"
FF.englishStrings["count.location.other"] = "%d locations"
FF.englishStrings["count.fishing-location.one"] = "%d fishing location"
FF.englishStrings["count.fishing-location.other"] = "%d fishing locations"
FF.englishStrings["journal.catch-summary"] = "%s  •  %d / %d discovered  •  %s"
FF.englishStrings["journal.catch-summary-short"] = "%s  •  %d discovered  •  %s"

-- Names are autonyms, not saved identities or translated game names. Draft JSON
-- alone cannot activate a pack; installed previews are explicitly allowlisted.
FF.localeOrder = {"enUS","deDE","frFR","esES","esMX","itIT","ptBR","ruRU","koKR","zhCN","zhTW"}
FF.localeNames = {enUS="English",deDE="Deutsch",frFR="Français",esES="Español (España)",
    esMX="Español (Latinoamérica)",itIT="Italiano",ptBR="Português (Brasil)",
    ruRU="Русский",koKR="한국어",zhCN="简体中文",zhTW="繁體中文"}
FF.englishStrings["language.reload"] = "Reload UI"
FF.englishStrings["language.reload-help"] = "Language change saved. Reload UI to apply."
FF.englishStrings["sound.off"] = "Off"
FF.englishStrings["sound.soft"] = "Battle.net notification"
FF.englishStrings["sound.ping"] = "Soft ping"
FF.englishStrings["sound.chime"] = "Chime"
FF.englishStrings["sound.raid"] = "Raid warning"
FF.englishStrings["sound.male"] = "Male Voice"
FF.englishStrings["sound.female"] = "Female Voice"
FF.englishStrings["sound.cursor-reminder"] = "Cursor reminder sound"
FF.englishStrings["sound.out-of-range"] = "Out of range sound"
FF.englishStrings["faction.auto"] = "Auto"
FF.englishStrings["faction.alliance"] = "Alliance"
FF.englishStrings["faction.horde"] = "Horde"

function FF:IsLocaleAvailable(locale)
    if (issecretvalue and issecretvalue(locale)) or type(locale)~="string" then return false end
    if locale == "enUS" then return true end
    if not (self.supportedLocales[locale] or self.auditedLocales[locale] or self.previewLocales[locale])
        or not self.localeNames[locale] then return false end
    local pack = self.localePacks[locale]
    if type(pack) ~= "table" then return false end
    -- Generated packs may intentionally omit new/stale messages. Keep their
    -- saved language selectable while each omitted unit uses current English.
    if self.installedLocalePacks[locale] == pack then return true end
    for key in pairs(self.englishStrings) do
        if type(pack[key]) ~= "string" or pack[key] == "" then return false end
        local plural = key:match("^(.-)%.one$")
        if plural and locale == "ruRU" then
            for _, form in ipairs({"few","many","other"}) do
                if type(pack[plural.."."..form]) ~= "string" or pack[plural.."."..form] == "" then return false end
            end
        end
    end
    return true
end

function FF:GetLanguage()
    local choice = self.db and self.db.language
    -- An unavailable saved manual override falls back to English; it must not
    -- silently become detection of a different supported client language.
    return not (issecretvalue and issecretvalue(choice)) and type(choice) == "string" and choice ~= "auto" and choice or "auto"
end

-- Client identities are read independently of the selected display pack.
local function PublicNative(value) return not (issecretvalue and issecretvalue(value)) end
local function NativeID(value)
    return PublicNative(value) and type(value)=="number" and value>0 and value<math.huge and value==math.floor(value)
end
local function NativeRead(fn,...)
    if not PublicNative(fn) or type(fn)~="function" then return end
    local ok,value=pcall(fn,...)
    if ok and PublicNative(value) then return value end
end
local function NativeField(api,key)
    return PublicNative(api) and type(api)=="table" and rawget(api,key) or nil
end
local function NativeName(value)
    return PublicNative(value) and type(value)=="string" and value~="" and value or nil
end
local function NativeItemName(value,id)
    local name=NativeName(value)
    if name=="Item "..id or name=="Item #"..id then return end
    if PublicNative(RETRIEVING_ITEM_INFO) and name==RETRIEVING_ITEM_INFO then return end
    return name
end
function FF:GetClientLocale()
    return NativeName(NativeRead(GetLocale))
end
function FF:UsesNativeJournalNames()
    local locale=self:GetClientLocale()
    return locale and locale~="enUS" and locale~="enGB" or false
end
function FF:InvalidateNativeJournalNames()
    self.nativeJournalNameRevision=(self.nativeJournalNameRevision or 0)+1
    self.guideNativeNamesDirty=true
    self.guideLinkTextCache=nil
    self.journalSearchIndex=nil
    self.sessionGoalCatalogue=nil
end
function FF:ObserveNativeJournalName(kind,id,name)
    local values=self.nativeJournalNameValues
    if not values then values={item={},spell={},quest={}};self.nativeJournalNameValues=values end
    local previous=values[kind][id]
    local value=name or false
    values[kind][id]=value
    if previous~=nil and previous~=value then self:InvalidateNativeJournalNames() end
    return name
end
function FF:RefreshPendingNativeJournalNames()
    if not self:UsesNativeJournalNames() or not self.nativeJournalNameValues then return end
    local now=NativeRead(GetTime)
    if type(now)~="number" or now~=now or now>=math.huge or now<(self.nativeJournalNameRetryAt or 0) then return end
    self.nativeJournalNameRetryAt=now+1
    -- Retry only previously queried missing names during a deliberate render
    -- or search. No timer, idle scan, world lookup or data-load request.
    local readers={item=self.GetNativeItemName,spell=self.GetNativeSpellName,quest=self.GetNativeQuestName}
    for kind,values in pairs(self.nativeJournalNameValues) do
        for id,name in pairs(values) do if name==false then readers[kind](self,id) end end
    end
end
local nativeNameEvents={GET_ITEM_INFO_RECEIVED="item",ITEM_DATA_LOAD_RESULT="item",
    SPELL_DATA_LOAD_RESULT="spell",QUEST_DATA_LOAD_RESULT="quest"}
function FF:WatchNativeJournalName(kind,id)
    local known=self.nativeJournalNameIDs
    if not known then known={item={},spell={},quest={}};self.nativeJournalNameIDs=known end
    if not known[kind] then return end
    known[kind][id]=true
    if self.nativeJournalNameWatcher then return end
    local watch=CreateFrame("Frame")
    -- Optional events differ between supported clients; never retry creating
    -- frames on a client that lacks an event. There is no data request/timer.
    for event in pairs(nativeNameEvents) do pcall(watch.RegisterEvent,watch,event) end
    watch:SetScript("OnEvent",function(_,event,changed,success)
        if not NativeID(changed) or not PublicNative(success) or success==false then return end
        local ids=known[nativeNameEvents[event]]
        if not ids or not ids[changed] then return end
        self:InvalidateNativeJournalNames()
    end)
    self.nativeJournalNameWatcher=watch
end
function FF:GetNativeItemName(id,fallback)
    if not self:UsesNativeJournalNames() or not NativeID(id) then return fallback end
    self:WatchNativeJournalName("item",id)
    local name=NativeItemName(NativeRead(NativeField(C_Item,"GetItemInfo"),id),id)
        or NativeItemName(NativeRead(GetItemInfo,id),id)
    return self:ObserveNativeJournalName("item",id,name) or fallback
end
function FF:GetNativeSpellName(id,fallback)
    if not self:UsesNativeJournalNames() or not NativeID(id) then return fallback end
    self:WatchNativeJournalName("spell",id)
    local name=NativeName(NativeRead(NativeField(C_Spell,"GetSpellName"),id))
        or NativeName(NativeRead(GetSpellInfo,id))
    return self:ObserveNativeJournalName("spell",id,name) or fallback
end
function FF:GetNativeQuestName(id,fallback)
    if not self:UsesNativeJournalNames() or not NativeID(id) then return fallback end
    self:WatchNativeJournalName("quest",id)
    local name=NativeName(NativeRead(NativeField(C_QuestLog,"GetQuestInfo"),id))
    if name then return self:ObserveNativeJournalName("quest",id,name) end
    local count=NativeRead(NativeField(C_QuestLog,"GetNumQuestLogEntries"))
    if type(count)=="number" and count>=0 and count<=10000 then
        for index=1,count do
            local info=NativeRead(NativeField(C_QuestLog,"GetInfo"),index)
            if type(info)=="table" and NativeID(rawget(info,"questID")) and rawget(info,"questID")==id then
                return self:ObserveNativeJournalName("quest",id,NativeName(rawget(info,"title"))) or fallback
            end
        end
    end
    return self:ObserveNativeJournalName("quest",id,nil) or fallback
end
function FF:GetNativeMapName(id,fallback)
    if not self:UsesNativeJournalNames() or not NativeID(id) then return fallback end
    local info=NativeRead(NativeField(C_Map,"GetMapInfo"),id)
    return type(info)=="table" and NativeName(rawget(info,"name")) or fallback
end

-- Zone labels come from the Forever client exports and follow the addon
-- locale, even when native map names and saved location keys use another one.
local zoneAliases = {
    Alterac="Alterac Mountains", Dustwallow="Dustwallow Marsh", Redridge="Redridge Mountains",
    Stonetalon="Stonetalon Mountains", Stormwind="Stormwind City", Stranglethorn="Stranglethorn Vale",
    Theramore="Theramore Isle", ["Un'Goro"]="Un'Goro Crater",
}
local zoneLocaleIndices, reverseZoneNames
function FF:GetCanonicalZoneName(name)
    if not NativeName(name) or not self.zoneNames then return name end
    if self.zoneNames[name] then return name end
    if zoneAliases[name] and self.zoneNames[zoneAliases[name]] then return zoneAliases[name] end
    if not reverseZoneNames then
        reverseZoneNames = {}
        for english, translations in pairs(self.zoneNames) do
            for _, display in pairs(translations) do
                local previous = reverseZoneNames[display]
                if previous == nil then reverseZoneNames[display] = english
                elseif previous ~= english then reverseZoneNames[display] = false end
            end
        end
    end
    return reverseZoneNames[name] or self.zoneNameAliases and self.zoneNameAliases[name] or name
end

function FF:GetZoneDisplayName(name)
    if not NativeName(name) or not self.zoneNames then return name end
    local canonical = self:GetCanonicalZoneName(name)
    if not zoneLocaleIndices then
        zoneLocaleIndices = {}
        for index, locale in ipairs(self.zoneNameLocales) do zoneLocaleIndices[locale] = index end
    end
    local translations = self.zoneNames[canonical]
    local localized = translations and translations[zoneLocaleIndices[self:GetResolvedLocale()]]
    return localized or (zoneAliases[name] and name) or canonical
end

local function LocationParts(self, place)
    if not NativeName(place) or not self.zoneNames then return place end
    if self.zoneNames[self:GetCanonicalZoneName(place)] then return place end
    local boundary
    for separator in place:gmatch("(): ") do
        if self.zoneNames[self:GetCanonicalZoneName(place:sub(1, separator - 1))] then boundary = separator end
    end
    if boundary then return place:sub(1, boundary - 1), place:sub(boundary + 2) end
    return place
end

function FF:GetFishingLocationDisplay(place, english)
    local zone, sub = LocationParts(self, place)
    local display = english and self.GetCanonicalZoneName or self.GetZoneDisplayName
    return sub and (display(self, zone) .. ": " .. display(self, sub)) or display(self, zone)
end

function FF:GetFishingLocationZone(place)
    if not NativeName(place) then return nil end
    local zone, sub = LocationParts(self, place)
    if sub or (self.zoneNames and self.zoneNames[self:GetCanonicalZoneName(zone)]) then return zone end
    return place:match("^(.-): ") or place
end

function FF:FishingLocationMatchesZone(place, zone)
    if not NativeName(place) or not NativeName(zone) then return false end
    if place == zone then return true end
    local savedZone = LocationParts(self, place)
    if savedZone ~= place then
        return self:GetCanonicalZoneName(savedZone) == self:GetCanonicalZoneName(zone)
    end
    return self:GetCanonicalZoneName(place) == self:GetCanonicalZoneName(zone)
        or place:sub(1, #zone + 2) == zone .. ": "
end

function FF:GetFishingLocationSearchText(locations)
    local terms = {}
    for place in pairs(locations or {}) do
        if type(place) == "string" then
            terms[#terms+1] = place
            local english = self:GetFishingLocationDisplay(place, true)
            local display = self:GetFishingLocationDisplay(place)
            if english ~= place then terms[#terms+1] = english end
            if display ~= place and display ~= english then terms[#terms+1] = display end
        end
    end
    return table.concat(terms, " ")
end

-- Only geography names used in authored reference text. The full client
-- catalogue also contains common words and must not be used to rewrite prose.
local referenceZones = {
    "Alterac", "Alterac Mountains", "Alterac Valley", "Arathi Highlands", "Ashenvale", "Auberdine", "Azshara",
    "Badlands", "Bay of Storms", "Blackfathom Deeps", "Bloodhoof Village", "Booty Bay", "Brightwater Lake",
    "Camp Mojache", "Crystal Lake", "Darkshore", "Darnassus", "Deadwind Pass", "Desolace", "Dun Morogh",
    "Durotar", "Duskwood", "Dustwallow", "Dustwallow Marsh", "Eastern Kingdoms", "Eastern Plaguelands",
    "Elwynn Forest", "Feathermoon Stronghold", "Felwood", "Feralas", "Gadgetzan", "Hetaera's Clutch",
    "Hillsbrad", "Hillsbrad Fields", "Hillsbrad Foothills", "Iceflow Lake", "Ironforge", "Jademir Lake", "Jaguero Isle",
    "Kalimdor", "Lake Everstill", "Lakeshire", "Loch Modan", "Menethil Harbor", "Moonglade", "Mount Hyjal",
    "Mulgore", "New Avalon", "Orgrimmar", "Powderfuse Port", "Redridge", "Redridge Mountains", "Revantusk Village",
    "Riverglades", "Rut'theran Village", "Scalebeard's Cave", "Sen'jin Village", "Shadowprey Village",
    "Shen'dar Village", "Shen'dralas", "Silithus", "Silverpine Forest", "Southshore", "Steamwheedle Port",
    "Stonetalon", "Stonetalon Mountains", "Stonetalon Peak", "Stormwind", "Stormwind City", "Stormwind Harbor",
    "Stranglethorn", "Stranglethorn Vale",
    "Swamp of Sorrows", "Tanaris", "Tarren Mill", "Teldrassil", "The Barrens", "The Hinterlands", "Theramore",
    "Theramore Isle", "Thousand Needles", "Thunder Bluff", "Tirisfal Glades", "Undercity", "Un'Goro",
    "Un'Goro Crater", "Valanaar", "Verdantis River", "Wailing Caverns", "Western Plaguelands", "Westfall",
    "Wetlands", "Windshear Crag", "Winterspring", "Zephras Isle", "Zul'Gurub",
}
local referenceZonesByWord = {}
local referenceZoneExtrasReady
for _, name in ipairs(referenceZones) do
    local word = name:match("^[%w']+")
    local names = referenceZonesByWord[word] or {}
    names[#names+1] = name
    referenceZonesByWord[word] = names
end
for _, names in pairs(referenceZonesByWord) do
    table.sort(names, function(a, b) return #a > #b end)
end

function FF:LocalizeReferenceZones(text)
    if not referenceZoneExtrasReady and self.journalReferencePlaces then
        referenceZoneExtrasReady=true
        for name in pairs(self.journalReferencePlaces) do
            local word=name:match("^[%w']+")
            if word then
                local names=referenceZonesByWord[word] or {};referenceZonesByWord[word]=names
                names[#names+1]=name
                table.sort(names,function(a,b) return #a>#b end)
            end
        end
    end
    if type(text) ~= "string" or not self.zoneNames or self:GetResolvedLocale() == "enUS" then return text end
    local parts, cursor = {}, 1
    for start, word in text:gmatch("()(%u[%w']*)") do
        local names = referenceZonesByWord[word]
        if start >= cursor and names and not text:sub(start - 1, start - 1):match("[%w']") then
            for _, name in ipairs(names) do
                local after = start + #name
                if text:sub(start, after - 1) == name and not text:sub(after, after):match("[%w']") then
                    -- Shorthand such as Stranglethorn may also begin an event
                    -- title. Full place names above take priority.
                    local inTitle = zoneAliases[name] and text:find("^%s+%u", after)
                    local localized = not inTitle and self:GetZoneDisplayName(name) or name
                    if localized ~= name then
                        parts[#parts+1] = text:sub(cursor, start - 1)
                        parts[#parts+1] = localized
                        cursor = after
                    end
                    break
                end
            end
        end
    end
    if cursor == 1 then return text end
    parts[#parts+1] = text:sub(cursor)
    return table.concat(parts)
end

function FF:GetGuideMapLabel(point)
    local name = self:GetZoneDisplayName(point.label)
    return name ~= point.label and name or self:LocalizeJournalReferenceText(name)
end

function FF:GetClientGuideTargetName(target,fallback)
    local kind=target.kind
    if kind=="fish" or kind=="meal" or kind=="camp" or kind=="item" then
        return self:GetNativeItemName(target.id,fallback)
    elseif kind=="spell" then return self:GetNativeSpellName(target.id,fallback)
    elseif kind=="quest" then return self:GetNativeQuestName(target.id,fallback)
    elseif kind=="info" then
        local quest=self:GetJournalQuestReference(target.label or fallback)
        if quest and quest.questID==target.id then return self:GetNativeQuestName(quest.questID,fallback) end
    end
    return fallback
end

function FF:GetNativeGuideTargetName(target,fallback)
    if not self:UsesJournalDisplayNames() then return fallback end
    local kind=target.kind
    if kind=="fish" or kind=="meal" or kind=="camp" or kind=="item" then
        return self:GetJournalItemDisplayName(target.id,fallback)
    elseif kind=="spell" then return self:GetJournalSpellDisplayName(target.id,fallback)
    elseif kind=="quest" then return self:GetJournalQuestDisplayName(target.id,fallback)
    elseif kind=="info" then
        local quest=self:GetJournalQuestReference(target.label or fallback)
        if quest and quest.questID==target.id then return self:GetJournalQuestDisplayName(quest.questID,fallback) end
    elseif kind=="campinfo" then
        if target.label=="Build a Campfire" then return self:LocalizedText("gear.details.build-camp") end
        return self:GetJournalItemDisplayName(target.id,fallback)
    elseif kind=="nearbypool" then return self:GetJournalPoolDisplayName(fallback)
    elseif kind=="map" then return self:LocalizeJournalReferenceText(fallback)
    end
    return fallback
end


function FF:ResolveLanguage(choice)
    if not PublicNative(choice) then return "enUS" end
    local locale = choice
    local automatic = not locale or locale == "auto"
    if automatic then locale = self:GetClientLocale() or "enUS" end
    -- Both English clients use the existing English base. No unverified
    -- regional/script aliases or saved-choice rewrites are introduced.
    if locale=="enGB" then locale="enUS" end
    if automatic and not (self.supportedLocales[locale] or self.auditedLocales[locale]) then return "enUS" end
    return self:IsLocaleAvailable(locale) and locale or "enUS"
end

function FF:GetResolvedLocale()
    -- Once UI construction starts the display language is immutable for this
    -- login. Saved choices take effect only at the next explicit reload/login.
    return self.activeLocale or self:ResolveLanguage(self:GetLanguage())
end

function FF:InitializeLocalization()
    self.activeLocale = self:ResolveLanguage(self:GetLanguage())
    if self.RefreshSessionGoalLanguage then self:RefreshSessionGoalLanguage() end
    self:RefreshSoundChoiceLanguage()
    if self.RefreshFishingActionLanguage then self:RefreshFishingActionLanguage() end
end

function FF:RefreshSoundChoiceLanguage()
    -- Only presentation changes: preserve IDs, kit fallbacks, voice files,
    -- preview constraints and every saved event/loop/volume preference.
    for _, choice in ipairs(self.rangeSoundChoices or {}) do
        if choice.labelKey then choice.label = self:LocalizedText(choice.labelKey) end
    end
end

function FF:GetLanguageChoices()
    local choices = {}
    for _, locale in ipairs(self.localeOrder) do
        if self:IsLocaleAvailable(locale) then
            choices[#choices+1] = {id=locale,label=self.localeNames[locale]}
        end
    end
    return choices
end

function FF:HasPendingLanguageChange()
    return self:ResolveLanguage(self:GetLanguage()) ~= self:GetResolvedLocale()
end

function FF:ReloadLocalization()
    if not self:HasPendingLanguageChange() or not ReloadUI
        or (InCombatLockdown and InCombatLockdown()) then return false end
    ReloadUI() -- Only the explicit Settings button may call this method.
    return true
end

function FF:LocalizedText(key, ...)
    local pack = self.localePacks[self:GetResolvedLocale()]
    local english = self.englishStrings[key]
    local text = (pack and pack[key]) or english or key
    if (pack and english and not pack[key]) or (not english and type(key)=="string" and key:match("^[a-z][%w_-]*%.[%w_.-]+$")) then
        -- Development evidence only; never print or expose keys to players.
        self.missingLocaleKeys = self.missingLocaleKeys or {}
        self.missingLocaleKeys[key] = true
    end
    if select("#", ...) > 0 then return string.format(text, ...) end
    return text
end

function FF:SetLanguage(language)
    if not PublicNative(language) or (language ~= "auto" and not self:IsLocaleAvailable(language)) then return false end
    if not self.db or (InCombatLockdown and InCombatLockdown()) then return false end
    -- Freeze before writing, including callers used before UI construction.
    if not self.activeLocale then self:InitializeLocalization() end
    self.db.language = language ~= "auto" and language or nil
    local panel = self.settingsPanel
    if panel and panel.RefreshLanguageControls then panel:RefreshLanguageControls() end
    return true
end

-- UTF-8 search folding is presentation-only. Never use this for saved keys,
-- hyperlink payloads, native action names or offsets into the original text.
local searchFold = {
    ["A"]="a",["B"]="b",["C"]="c",["D"]="d",["E"]="e",["F"]="f",["G"]="g",["H"]="h",
    ["I"]="i",["J"]="j",["K"]="k",["L"]="l",["M"]="m",["N"]="n",["O"]="o",["P"]="p",
    ["Q"]="q",["R"]="r",["S"]="s",["T"]="t",["U"]="u",["V"]="v",["W"]="w",["X"]="x",
    ["Y"]="y",["Z"]="z",["À"]="à",["Á"]="á",["Â"]="â",["Ã"]="ã",["Ä"]="ä",["Å"]="å",
    ["Æ"]="æ",["Ç"]="ç",["È"]="è",["É"]="é",["Ê"]="ê",["Ë"]="ë",["Ì"]="ì",["Í"]="í",
    ["Î"]="î",["Ï"]="ï",["Ð"]="ð",["Ñ"]="ñ",["Ò"]="ò",["Ó"]="ó",["Ô"]="ô",["Õ"]="õ",
    ["Ö"]="ö",["Ø"]="ø",["Ù"]="ù",["Ú"]="ú",["Û"]="û",["Ü"]="ü",["Ý"]="ý",["Þ"]="þ",
    ["ß"]="ss",["Ā"]="ā",["Ă"]="ă",["Ą"]="ą",["Ć"]="ć",["Ĉ"]="ĉ",["Ċ"]="ċ",["Č"]="č",
    ["Ď"]="ď",["Đ"]="đ",["Ē"]="ē",["Ĕ"]="ĕ",["Ė"]="ė",["Ę"]="ę",["Ě"]="ě",["Ĝ"]="ĝ",
    ["Ğ"]="ğ",["Ġ"]="ġ",["Ģ"]="ģ",["Ĥ"]="ĥ",["Ħ"]="ħ",["Ĩ"]="ĩ",["Ī"]="ī",["Ĭ"]="ĭ",
    ["Į"]="į",["İ"]="i̇",["Ĳ"]="ĳ",["Ĵ"]="ĵ",["Ķ"]="ķ",["Ĺ"]="ĺ",["Ļ"]="ļ",["Ľ"]="ľ",
    ["Ŀ"]="ŀ",["Ł"]="ł",["Ń"]="ń",["Ņ"]="ņ",["Ň"]="ň",["ŉ"]="ʼn",["Ŋ"]="ŋ",["Ō"]="ō",
    ["Ŏ"]="ŏ",["Ő"]="ő",["Œ"]="œ",["Ŕ"]="ŕ",["Ŗ"]="ŗ",["Ř"]="ř",["Ś"]="ś",["Ŝ"]="ŝ",
    ["Ş"]="ş",["Š"]="š",["Ţ"]="ţ",["Ť"]="ť",["Ŧ"]="ŧ",["Ũ"]="ũ",["Ū"]="ū",["Ŭ"]="ŭ",
    ["Ů"]="ů",["Ű"]="ű",["Ų"]="ų",["Ŵ"]="ŵ",["Ŷ"]="ŷ",["Ÿ"]="ÿ",["Ź"]="ź",["Ż"]="ż",
    ["Ž"]="ž",["ſ"]="s",["Ɓ"]="ɓ",["Ƃ"]="ƃ",["Ƅ"]="ƅ",["Ɔ"]="ɔ",["Ƈ"]="ƈ",["Ɖ"]="ɖ",
    ["Ɗ"]="ɗ",["Ƌ"]="ƌ",["Ǝ"]="ǝ",["Ə"]="ə",["Ɛ"]="ɛ",["Ƒ"]="ƒ",["Ɠ"]="ɠ",["Ɣ"]="ɣ",
    ["Ɩ"]="ɩ",["Ɨ"]="ɨ",["Ƙ"]="ƙ",["Ɯ"]="ɯ",["Ɲ"]="ɲ",["Ɵ"]="ɵ",["Ơ"]="ơ",["Ƣ"]="ƣ",
    ["Ƥ"]="ƥ",["Ʀ"]="ʀ",["Ƨ"]="ƨ",["Ʃ"]="ʃ",["Ƭ"]="ƭ",["Ʈ"]="ʈ",["Ư"]="ư",["Ʊ"]="ʊ",
    ["Ʋ"]="ʋ",["Ƴ"]="ƴ",["Ƶ"]="ƶ",["Ʒ"]="ʒ",["Ƹ"]="ƹ",["Ƽ"]="ƽ",["Ǆ"]="ǆ",["ǅ"]="ǆ",
    ["Ǉ"]="ǉ",["ǈ"]="ǉ",["Ǌ"]="ǌ",["ǋ"]="ǌ",["Ǎ"]="ǎ",["Ǐ"]="ǐ",["Ǒ"]="ǒ",["Ǔ"]="ǔ",
    ["Ǖ"]="ǖ",["Ǘ"]="ǘ",["Ǚ"]="ǚ",["Ǜ"]="ǜ",["Ǟ"]="ǟ",["Ǡ"]="ǡ",["Ǣ"]="ǣ",["Ǥ"]="ǥ",
    ["Ǧ"]="ǧ",["Ǩ"]="ǩ",["Ǫ"]="ǫ",["Ǭ"]="ǭ",["Ǯ"]="ǯ",["ǰ"]="ǰ",["Ǳ"]="ǳ",["ǲ"]="ǳ",
    ["Ǵ"]="ǵ",["Ƕ"]="ƕ",["Ƿ"]="ƿ",["Ǹ"]="ǹ",["Ǻ"]="ǻ",["Ǽ"]="ǽ",["Ǿ"]="ǿ",["Ȁ"]="ȁ",
    ["Ȃ"]="ȃ",["Ȅ"]="ȅ",["Ȇ"]="ȇ",["Ȉ"]="ȉ",["Ȋ"]="ȋ",["Ȍ"]="ȍ",["Ȏ"]="ȏ",["Ȑ"]="ȑ",
    ["Ȓ"]="ȓ",["Ȕ"]="ȕ",["Ȗ"]="ȗ",["Ș"]="ș",["Ț"]="ț",["Ȝ"]="ȝ",["Ȟ"]="ȟ",["Ƞ"]="ƞ",
    ["Ȣ"]="ȣ",["Ȥ"]="ȥ",["Ȧ"]="ȧ",["Ȩ"]="ȩ",["Ȫ"]="ȫ",["Ȭ"]="ȭ",["Ȯ"]="ȯ",["Ȱ"]="ȱ",
    ["Ȳ"]="ȳ",["Ⱥ"]="ⱥ",["Ȼ"]="ȼ",["Ƚ"]="ƚ",["Ⱦ"]="ⱦ",["Ɂ"]="ɂ",["Ƀ"]="ƀ",["Ʉ"]="ʉ",
    ["Ʌ"]="ʌ",["Ɇ"]="ɇ",["Ɉ"]="ɉ",["Ɋ"]="ɋ",["Ɍ"]="ɍ",["Ɏ"]="ɏ",["Ѐ"]="ѐ",["Ё"]="ё",
    ["Ђ"]="ђ",["Ѓ"]="ѓ",["Є"]="є",["Ѕ"]="ѕ",["І"]="і",["Ї"]="ї",["Ј"]="ј",["Љ"]="љ",
    ["Њ"]="њ",["Ћ"]="ћ",["Ќ"]="ќ",["Ѝ"]="ѝ",["Ў"]="ў",["Џ"]="џ",["А"]="а",["Б"]="б",
    ["В"]="в",["Г"]="г",["Д"]="д",["Е"]="е",["Ж"]="ж",["З"]="з",["И"]="и",["Й"]="й",
    ["К"]="к",["Л"]="л",["М"]="м",["Н"]="н",["О"]="о",["П"]="п",["Р"]="р",["С"]="с",
    ["Т"]="т",["У"]="у",["Ф"]="ф",["Х"]="х",["Ц"]="ц",["Ч"]="ч",["Ш"]="ш",["Щ"]="щ",
    ["Ъ"]="ъ",["Ы"]="ы",["Ь"]="ь",["Э"]="э",["Ю"]="ю",["Я"]="я",["Ѡ"]="ѡ",["Ѣ"]="ѣ",
    ["Ѥ"]="ѥ",["Ѧ"]="ѧ",["Ѩ"]="ѩ",["Ѫ"]="ѫ",["Ѭ"]="ѭ",["Ѯ"]="ѯ",["Ѱ"]="ѱ",["Ѳ"]="ѳ",
    ["Ѵ"]="ѵ",["Ѷ"]="ѷ",["Ѹ"]="ѹ",["Ѻ"]="ѻ",["Ѽ"]="ѽ",["Ѿ"]="ѿ",["Ҁ"]="ҁ",["Ҋ"]="ҋ",
    ["Ҍ"]="ҍ",["Ҏ"]="ҏ",["Ґ"]="ґ",["Ғ"]="ғ",["Ҕ"]="ҕ",["Җ"]="җ",["Ҙ"]="ҙ",["Қ"]="қ",
    ["Ҝ"]="ҝ",["Ҟ"]="ҟ",["Ҡ"]="ҡ",["Ң"]="ң",["Ҥ"]="ҥ",["Ҧ"]="ҧ",["Ҩ"]="ҩ",["Ҫ"]="ҫ",
    ["Ҭ"]="ҭ",["Ү"]="ү",["Ұ"]="ұ",["Ҳ"]="ҳ",["Ҵ"]="ҵ",["Ҷ"]="ҷ",["Ҹ"]="ҹ",["Һ"]="һ",
    ["Ҽ"]="ҽ",["Ҿ"]="ҿ",["Ӏ"]="ӏ",["Ӂ"]="ӂ",["Ӄ"]="ӄ",["Ӆ"]="ӆ",["Ӈ"]="ӈ",["Ӊ"]="ӊ",
    ["Ӌ"]="ӌ",["Ӎ"]="ӎ",["Ӑ"]="ӑ",["Ӓ"]="ӓ",["Ӕ"]="ӕ",["Ӗ"]="ӗ",["Ә"]="ә",["Ӛ"]="ӛ",
    ["Ӝ"]="ӝ",["Ӟ"]="ӟ",["Ӡ"]="ӡ",["Ӣ"]="ӣ",["Ӥ"]="ӥ",["Ӧ"]="ӧ",["Ө"]="ө",["Ӫ"]="ӫ",
    ["Ӭ"]="ӭ",["Ӯ"]="ӯ",["Ӱ"]="ӱ",["Ӳ"]="ӳ",["Ӵ"]="ӵ",["Ӷ"]="ӷ",["Ӹ"]="ӹ",["Ӻ"]="ӻ",
    ["Ӽ"]="ӽ",["Ӿ"]="ӿ",["Ԁ"]="ԁ",["Ԃ"]="ԃ",["Ԅ"]="ԅ",["Ԇ"]="ԇ",["Ԉ"]="ԉ",["Ԋ"]="ԋ",
    ["Ԍ"]="ԍ",["Ԏ"]="ԏ",["Ԑ"]="ԑ",["Ԓ"]="ԓ",["Ԕ"]="ԕ",["Ԗ"]="ԗ",["Ԙ"]="ԙ",["Ԛ"]="ԛ",
    ["Ԝ"]="ԝ",["Ԟ"]="ԟ",["Ԡ"]="ԡ",["Ԣ"]="ԣ",["Ԥ"]="ԥ",["Ԧ"]="ԧ",["Ԩ"]="ԩ",["Ԫ"]="ԫ",
    ["Ԭ"]="ԭ",["Ԯ"]="ԯ",["Ḁ"]="ḁ",["Ḃ"]="ḃ",["Ḅ"]="ḅ",["Ḇ"]="ḇ",["Ḉ"]="ḉ",["Ḋ"]="ḋ",
    ["Ḍ"]="ḍ",["Ḏ"]="ḏ",["Ḑ"]="ḑ",["Ḓ"]="ḓ",["Ḕ"]="ḕ",["Ḗ"]="ḗ",["Ḙ"]="ḙ",["Ḛ"]="ḛ",
    ["Ḝ"]="ḝ",["Ḟ"]="ḟ",["Ḡ"]="ḡ",["Ḣ"]="ḣ",["Ḥ"]="ḥ",["Ḧ"]="ḧ",["Ḩ"]="ḩ",["Ḫ"]="ḫ",
    ["Ḭ"]="ḭ",["Ḯ"]="ḯ",["Ḱ"]="ḱ",["Ḳ"]="ḳ",["Ḵ"]="ḵ",["Ḷ"]="ḷ",["Ḹ"]="ḹ",["Ḻ"]="ḻ",
    ["Ḽ"]="ḽ",["Ḿ"]="ḿ",["Ṁ"]="ṁ",["Ṃ"]="ṃ",["Ṅ"]="ṅ",["Ṇ"]="ṇ",["Ṉ"]="ṉ",["Ṋ"]="ṋ",
    ["Ṍ"]="ṍ",["Ṏ"]="ṏ",["Ṑ"]="ṑ",["Ṓ"]="ṓ",["Ṕ"]="ṕ",["Ṗ"]="ṗ",["Ṙ"]="ṙ",["Ṛ"]="ṛ",
    ["Ṝ"]="ṝ",["Ṟ"]="ṟ",["Ṡ"]="ṡ",["Ṣ"]="ṣ",["Ṥ"]="ṥ",["Ṧ"]="ṧ",["Ṩ"]="ṩ",["Ṫ"]="ṫ",
    ["Ṭ"]="ṭ",["Ṯ"]="ṯ",["Ṱ"]="ṱ",["Ṳ"]="ṳ",["Ṵ"]="ṵ",["Ṷ"]="ṷ",["Ṹ"]="ṹ",["Ṻ"]="ṻ",
    ["Ṽ"]="ṽ",["Ṿ"]="ṿ",["Ẁ"]="ẁ",["Ẃ"]="ẃ",["Ẅ"]="ẅ",["Ẇ"]="ẇ",["Ẉ"]="ẉ",["Ẋ"]="ẋ",
    ["Ẍ"]="ẍ",["Ẏ"]="ẏ",["Ẑ"]="ẑ",["Ẓ"]="ẓ",["Ẕ"]="ẕ",["ẖ"]="ẖ",["ẗ"]="ẗ",["ẘ"]="ẘ",
    ["ẙ"]="ẙ",["ẚ"]="aʾ",["ẛ"]="ṡ",["ẞ"]="ss",["Ạ"]="ạ",["Ả"]="ả",["Ấ"]="ấ",["Ầ"]="ầ",
    ["Ẩ"]="ẩ",["Ẫ"]="ẫ",["Ậ"]="ậ",["Ắ"]="ắ",["Ằ"]="ằ",["Ẳ"]="ẳ",["Ẵ"]="ẵ",["Ặ"]="ặ",
    ["Ẹ"]="ẹ",["Ẻ"]="ẻ",["Ẽ"]="ẽ",["Ế"]="ế",["Ề"]="ề",["Ể"]="ể",["Ễ"]="ễ",["Ệ"]="ệ",
    ["Ỉ"]="ỉ",["Ị"]="ị",["Ọ"]="ọ",["Ỏ"]="ỏ",["Ố"]="ố",["Ồ"]="ồ",["Ổ"]="ổ",["Ỗ"]="ỗ",
    ["Ộ"]="ộ",["Ớ"]="ớ",["Ờ"]="ờ",["Ở"]="ở",["Ỡ"]="ỡ",["Ợ"]="ợ",["Ụ"]="ụ",["Ủ"]="ủ",
    ["Ứ"]="ứ",["Ừ"]="ừ",["Ử"]="ử",["Ữ"]="ữ",["Ự"]="ự",["Ỳ"]="ỳ",["Ỵ"]="ỵ",["Ỷ"]="ỷ",
    ["Ỹ"]="ỹ",["Ỻ"]="ỻ",["Ỽ"]="ỽ",["Ỿ"]="ỿ",
}
function FF:FoldSearchText(text)
    text = tostring(text or "")
    text = text:gsub(" "," "):gsub(" "," "):gsub("　"," ")
    return (text:gsub("[%z\1-\127\194-\244][\128-\191]*",function(char)
        return searchFold[char] or char
    end))
end

function FF:GetPluralCategory(count, locale)
    local n = math.abs(tonumber(count) or 0)
    locale = locale or self:GetResolvedLocale()
    if locale == "koKR" or locale == "zhCN" or locale == "zhTW" then return "other" end
    if locale == "frFR" or locale == "ptBR" then return n < 2 and "one" or "other" end
    if locale == "ruRU" then
        if n ~= math.floor(n) then return "other" end
        local last, pair = n % 10, n % 100
        if last == 1 and pair ~= 11 then return "one" end
        if last >= 2 and last <= 4 and (pair < 12 or pair > 14) then return "few" end
        return "many"
    end
    return n == 1 and "one" or "other"
end

function FF:LocalizedPlural(key, count, ...)
    local locale = self:GetResolvedLocale()
    local form = self:GetPluralCategory(count, locale)
    local pack = self.localePacks[locale]
    local message = pack and pack[key.."."..form]
    if not message then
        -- A missing translated plural falls back as a whole English message;
        -- English has no few/many forms and must use its own grammar.
        local englishForm = self:GetPluralCategory(count,"enUS")
        message = self.englishStrings[key.."."..englishForm]
        self.missingLocaleKeys = self.missingLocaleKeys or {}
        if locale ~= "enUS" then self.missingLocaleKeys[key.."."..form] = true end
    end
    return string.format(message or key, count, ...)
end

local numberMarks = {
    deDE={",","."},frFR={","," "},esES={",","."},esMX={".",","},
    itIT={",","."},ptBR={",","."},ruRU={","," "},
}
function FF:LocalizedNumber(value, decimals, grouped)
    value = tonumber(value) or 0
    decimals = math.max(0,math.min(6,math.floor(tonumber(decimals) or 0)))
    local marks = numberMarks[self:GetResolvedLocale()] or {".",","}
    local text = string.format("%."..decimals.."f",value)
    local sign, integer, fraction = text:match("^([+-]?)(%d+)%.?(%d*)$")
    if not integer then return text end
    if grouped then
        integer = integer:reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,",""):gsub(",",marks[2])
    end
    return sign..integer..(fraction ~= "" and marks[1]..fraction or "")
end

-- A reference argument may name a display key and an explicit skill requirement.
-- Numbers never gain gameplay meaning from translated prose. Plain projections
-- (search and data consumers) omit the rendering snapshot and contain no colours.
function FF:FormatLocalizedReference(spec, skills)
    local args = {}
    for index = 2, #spec do
        local value = spec[index]
        if type(value) == "table" and value.textKey then
            local text = self:LocalizedText(value.textKey, unpack(value.values or {}))
            if skills and self:GetResolvedLocale() ~= "enUS" and value.profession then
                text = self:ColorJournalRequirement(skills, text, value.profession,
                    value.required, value.goodAt, value.fixedUpperBound, value.fieldGuide)
            end
            value = text
        end
        args[#args+1] = value
    end
    return string.format(self:LocalizedText(spec[1]), unpack(args))
end

-- Sort canonical roles before translating; wording cannot reorder NPC ownership.
local nearbyRoleKeys={
    ["Fishing trainer"]="trainer",["Fishing book"]="book",["Artisan quest"]="artisan",
    ["Fishing pole quest"]="pole",["Recipes"]="recipes",["Fishing supplies"]="supplies",
}
function FF:GetNearbyRoleDisplayText(roles)
    local names={};for name in pairs(roles or {}) do names[#names+1]=name end;table.sort(names)
    for index,name in ipairs(names) do
        local key=nearbyRoleKeys[name];names[index]=key and self:LocalizedText("nearby.role."..key) or name
    end
    return table.concat(names," • ")
end

function FF:GetNearbyPointRoleDisplayText(point)
    for _,person in ipairs(self.journalPanel and self.journalPanel.nearbyPeople or {}) do
        if person.point==point then return self:GetNearbyRoleDisplayText(person.roles) end
    end
    return point.roleText
end

-- Only this authored non-native training description has a display projection.
-- Unknown or edited fields remain literal; item/quest/spell labels stay native.
function FF:GetNearbyServiceDisplayText(service,field)
    local raw=service[field]
    if field=="label" then
        if service.kind=="meal" or service.kind=="item" or service.kind=="fish" or service.kind=="camp" then
            return self:GetJournalItemDisplayName(service.id,raw)
        elseif service.kind=="quest" then return self:GetJournalQuestDisplayName(service.id,raw) end
    end
    if service.kind=="info" and service.label==self.englishStrings["nearby.service.fishing-ranks"] then
        local key=field=="label" and "nearby.service.fishing-ranks" or field=="tooltip" and "nearby.service.fishing-ranks-tip"
        if key and raw==self.englishStrings[key] then return self:LocalizedText(key) end
    end
    return raw
end

-- Exact authored fragments are projected only after canonical discovery/sorting.
local nearbyProse={
    ["For the Gaffer Jacks quest."]={"nearby.condition.quest","Gaffer Jacks"},
    ["For the Electropellers quest."]={"nearby.condition.quest","Electropellers"},
    ["Blackmouth schools or coastal water"]={"nearby.method.blackmouth"},
    ["Coastal open water"]={"nearby.method.coastal"},
    ["Coastal open water or debris"]={"nearby.method.coastal-debris"},
    ["Coastal open water or wreckage"]={"nearby.method.coastal-wreckage"},
    ["Coastal pools or wreckage"]={"nearby.method.pools-wreckage"},
    ["Deviate Fish schools or inland water"]={"nearby.method.deviate"},
    ["Firefin schools"]={"nearby.method.firefin"},
    ["Firefin schools or coastal water"]={"nearby.method.firefin-coastal"},
    ["Fish schools or floating debris"]={"nearby.method.schools-debris"},
    ["Fish schools or wreckage"]={"nearby.method.schools-wreckage"},
    ["Floating Debris pools"]={"nearby.method.debris"},
    ["Greater Sagefish schools"]={"nearby.method.greater-sagefish"},
    ["Inland open water"]={"nearby.method.inland"},
    ["Muddy Churning Waters only"]={"nearby.method.muddy"},
    ["No verified fishing-water leads are listed for this zone yet."]={"nearby.method.unknown"},
    ["Oil Spill pools only"]={"nearby.method.oil"},
    ["Open water"]={"nearby.method.open"},
    ["Sagefish schools"]={"nearby.method.sagefish"},
    ["Schools of Tastyfish only"]={"nearby.method.tastyfish"},
    ["Stonescale Eel schools or coastal water"]={"nearby.method.stonescale"},
    ["Whimsyfin schools only"]={"nearby.method.whimsyfin"},
    ["Wreckage pools"]={"nearby.method.wreckage"},
    ["Daytime catch."]={"nearby.note.day"},
    ["More common at night."]={"nearby.note.more-night"},
    ["Most common at night."]={"nearby.note.most-night"},
    ["Summer season; limited overlap in spring and autumn."]={"nearby.note.summer"},
    ["Winter season; limited overlap in spring and autumn."]={"nearby.note.winter"},
    ["Cast so your bobber lands inside the pool. Listed catches are verified leads; pool spawn positions are not tracked."]={"nearby.pool.note"},
    ["Fish inside the visible debris or wreckage ring. These are curated catch leads, not an exhaustive loot table or inventory contents."]={"nearby.pool.debris-note"},
    ["Inside the Zul'Gurub raid."]={"nearby.note.raid","Zul'Gurub"},
    ["Nat Pagle, Angler Extreme must be active; fish the Savage Coast."]={"nearby.note.quest-coast","Nat Pagle, Angler Extreme","Savage Coast"},
    ["Nat Pagle, Angler Extreme must be active; fish the Verdantis River."]={"nearby.note.quest-coast","Nat Pagle, Angler Extreme","Verdantis River"},
    ["Nat Pagle, Angler Extreme must be active; fish the eastern coast."]={"nearby.note.quest-east","Nat Pagle, Angler Extreme"},
    ["Nat Pagle, Angler Extreme must be active; fish the western coast."]={"nearby.note.quest-west","Nat Pagle, Angler Extreme"},
    ["Needed for The Family and the Fishing Pole."]={"nearby.note.needed","The Family and the Fishing Pole"},
    ["Stranglethorn Fishing Extravaganza, Sunday 2–4 p.m. server time."]={"nearby.note.tournament","Stranglethorn Fishing Extravaganza"},
}
function FF:GetNearbyProseDisplayText(text,separator,rawFormatter)
    if not text then return text end
    local function Render(raw)
        local spec=nearbyProse[raw]
        if spec then return self:LocalizedText(spec[1],unpack(spec,2)) end
        return rawFormatter and rawFormatter(raw) or raw
    end
    if not separator then return Render(text) end
    local result,position={},1
    while true do
        local first,last=text:find(separator,position,true)
        result[#result+1]=Render(first and text:sub(position,first-1) or text:sub(position))
        if not first then break end
        position=last+1
    end
    return table.concat(result,separator)
end

-- Numeric requirements are supplied explicitly; translated words are never
-- parsed for skill, minimum/reliable semantics or native location identity.
local nearbyCaveats={
    ["Bay of Storms, Hetaera's Clutch and Scalebeard's Cave need 330 minimum / 425 reliable effective skill."]=
        {"nearby.caveat.multiple","Bay of Storms, Hetaera's Clutch and Scalebeard's Cave",330,425},
    ["Jademir Lake needs 330 minimum / 425 reliable effective skill."]={"nearby.caveat.single","Jademir Lake",330,425},
    ["Jaguero Isle needs 205 minimum / 300 reliable effective skill."]={"nearby.caveat.single","Jaguero Isle",205,300},
    ["Some Ironforge water may not be fishable on modern Classic clients."]={"nearby.caveat.modern","Ironforge"},
}
function FF:GetNearbyCaveatDisplayText(raw,threshold)
    local spec=nearbyCaveats[raw]
    if not spec then return end
    if spec[3] then return self:LocalizedText(spec[1],spec[2],threshold(spec[3]),threshold(spec[4])) end
    return self:LocalizedText(spec[1],spec[2])
end

-- Keep cached link targets canonical. Resolve transient pool help at hover,
-- so the direct-link registry never retains a translated tooltip.
function FF:GetNearbyPoolTooltipDisplayText(raw)
    if type(raw)~="string" then return raw end
    local note,names=raw:match("^(.-)\nKnown catches: (.*)$")
    if not note then return self:GetNearbyProseDisplayText(raw) end
    return self:GetNearbyProseDisplayText(note).."\n"..self:LocalizedText("nearby.pool.catches",names)
end

local fishingEventBlocks={
    ["Requirements"]={raw="Bring a fishing pole and learn Fishing; no registration is needed. Aim for Fishing 150 or higher. Fishing 225 plus a lure reduces escapes.",
        heading="events.guide.requirements.heading",body={"events.guide.requirements.body",
            {textKey="skill.display.value",values={150},profession="Fishing",required=150,fieldGuide=false},
            {textKey="skill.display.value",values={225},profession="Fishing",required=225,fieldGuide=false}}},
    ["Where to fish"]={raw="When the event starts, fish Schools of Tastyfish along the Stranglethorn coast, outside Booty Bay. Land your bobber inside a pool.",
        heading="events.guide.waters.heading",body={"events.guide.waters.body","Schools of Tastyfish","Stranglethorn","Booty Bay"}},
    ["What to do"]={raw="Turn in 40 Speckled Tastyfish to Riggle Bassbait on Booty Bay's central dock. The first 250 turn-ins per ruleset win. Exchange the prize coin with Jang.",
        heading="events.guide.task.heading",body={"events.guide.task.body","Speckled Tastyfish","Riggle Bassbait","Booty Bay","Jang"}},
    ["Tips"]={raw="Clear bag space and set your Hearthstone to Booty Bay. Keep fishing for rare catches after the main prize announcement while the event remains active.",
        heading="events.guide.tips.heading",body={"events.guide.tips.body","Booty Bay"}},
}

-- Read-only projections are guarded by the exact known event/block text.
-- Future/edited events stay literal, with their original IDs and date strings.
function FF:GetFishingEventDisplayText(event,field,block,skills)
    local raw=block and block[field] or field=="footer" and event.guideTarget and event.guideTarget.label or event[field]
    if event.title~="Stranglethorn Fishing Extravaganza" then return raw end
    if field=="title" then return self:LocalizedText("events.stranglethorn.title") end
    if field=="footer" then
        if raw==self.englishStrings["events.full-guide"] then return self:LocalizedText("events.full-guide") end
        return raw
    end
    local spec=block and fishingEventBlocks[block.heading]
    if not spec or block.body~=spec.raw then return raw end
    if field=="heading" then return self:LocalizedText(spec.heading) end
    if field=="body" then
        return self:FormatLocalizedReference(spec.body,skills),self:GetResolvedLocale()~="enUS"
    end
    return raw
end

function FF:GetFishingEventSearchText(event)
    local result={self:GetFishingEventDisplayText(event,"title")}
    for _,block in ipairs(event.blocks or {}) do
        result[#result+1]=self:GetFishingEventDisplayText(event,"heading",block)
        result[#result+1]=self:GetFishingEventDisplayText(event,"body",block)
    end
    return table.concat(result," ")
end

local achievementDisplaySpecs={
    ["first-bite"]={
        title={"achievement.definition.first-bite.title"},
        description={"achievement.definition.first-bite.description"},
        flavour={"achievement.definition.first-bite.flavour"},
    },
    ["eyes-on-the-water"]={
        title={"achievement.definition.eyes-on-the-water.title"},
        description={"achievement.definition.eyes-on-the-water.description"},
        flavour={"achievement.definition.eyes-on-the-water.flavour"},
        detail={"achievement.definition.eyes-on-the-water.detail"},
    },
    ["hook-to-hearth"]={
        title={"achievement.definition.hook-to-hearth.title"},
        description={"achievement.definition.hook-to-hearth.description"},
        flavour={"achievement.definition.hook-to-hearth.flavour"},
    },
    ["something-fishy"]={
        title={"achievement.definition.something-fishy.title"},
        description={"achievement.definition.something-fishy.description"},
        flavour={"achievement.definition.something-fishy.flavour"},
    },
    ["one-of-a-kind"]={
        title={"achievement.definition.one-of-a-kind.title"},
        description={"achievement.definition.one-of-a-kind.description"},
        flavour={"achievement.definition.one-of-a-kind.flavour"},
    },
    ["treasure-from-the-deep"]={
        title={"achievement.definition.treasure-from-the-deep.title"},
        description={"achievement.definition.treasure-from-the-deep.description"},
        flavour={"achievement.definition.treasure-from-the-deep.flavour"},
    },
    ["hooked"]={
        title={"achievement.definition.hooked.title"},
        description={"achievement.definition.hooked.description"},
        flavour={"achievement.definition.hooked.flavour"},
    },
    ["new-waters"]={
        title={"achievement.definition.new-waters.title"},
        description={"achievement.definition.new-waters.description"},
        flavour={"achievement.definition.new-waters.flavour"},
    },
    ["plenty-of-fish"]={
        title={"achievement.definition.plenty-of-fish.title"},
        description={"achievement.definition.plenty-of-fish.description"},
        flavour={"achievement.definition.plenty-of-fish.flavour"},
    },
    ["camp-cook"]={
        title={"achievement.definition.camp-cook.title"},
        description={"achievement.definition.camp-cook.description"},
        flavour={"achievement.definition.camp-cook.flavour"},
    },
    ["tackle-box"]={
        title={"achievement.definition.tackle-box.title"},
        description={"achievement.definition.tackle-box.description"},
        flavour={"achievement.definition.tackle-box.flavour"},
    },
    ["rare-company"]={
        title={"achievement.definition.rare-company.title"},
        description={"achievement.definition.rare-company.description"},
        flavour={"achievement.definition.rare-company.flavour"},
    },
    ["seasoned-angler"]={
        title={"achievement.definition.seasoned-angler.title"},
        description={"achievement.definition.seasoned-angler.description"},
        flavour={"achievement.definition.seasoned-angler.flavour"},
    },
    ["master-of-the-line"]={
        title={"achievement.definition.master-of-the-line.title"},
        description={"achievement.definition.master-of-the-line.description"},
        flavour={"achievement.definition.master-of-the-line.flavour"},
        detail={"achievement.definition.master-of-the-line.detail"},
    },
    ["well-travelled"]={
        title={"achievement.definition.well-travelled.title"},
        description={"achievement.definition.well-travelled.description"},
        flavour={"achievement.definition.well-travelled.flavour"},
    },
    ["fully-equipped"]={
        title={"achievement.definition.fully-equipped.title"},
        description={"achievement.definition.fully-equipped.description"},
        flavour={"achievement.definition.fully-equipped.flavour"},
        detail={"achievement.definition.fully-equipped.detail","Rockhide Strongfish","Steelscale Crushfish","The 1 Ring"},
    },
    ["master-angler"]={
        title={"achievement.definition.master-angler.title"},
        description={"achievement.definition.master-angler.description"},
        flavour={"achievement.definition.master-angler.flavour"},
    },
    ["master-chef"]={
        title={"achievement.definition.master-chef.title"},
        description={"achievement.definition.master-chef.description"},
        flavour={"achievement.definition.master-chef.flavour"},
    },
    ["forever-fishing"]={
        title={"achievement.definition.forever-fishing.title"},
        description={"achievement.definition.forever-fishing.description"},
        flavour={"achievement.definition.forever-fishing.flavour"},
    },
    ["the-deep-end"]={
        title={"achievement.definition.the-deep-end.title"},
        description={"achievement.definition.the-deep-end.description"},
        flavour={"achievement.definition.the-deep-end.flavour"},
    },
    ["master-of-the-waters"]={
        title={"achievement.definition.master-of-the-waters.title"},
        description={"achievement.definition.master-of-the-waters.description"},
        flavour={"achievement.definition.master-of-the-waters.flavour"},
        detail={"achievement.definition.master-of-the-waters.detail"},
    },
    ["hook-em-all"]={
        title={"achievement.definition.hook-em-all.title"},
        description={"achievement.definition.hook-em-all.description"},
        flavour={"achievement.definition.hook-em-all.flavour"},
        detail={"achievement.definition.hook-em-all.detail"},
    },
}

-- Definitions remain canonical and may be read by tracking and other addons.
-- Match the exact authored field before projecting, so edited/future text never
-- inherits stale translations just because it reuses a known achievement ID.
function FF:GetAchievementDisplayText(definition,field)
    local raw=definition[field]
    local fields=achievementDisplaySpecs[definition.id]
    local spec=fields and fields[field]
    if not spec then return raw end
    local english=self.englishStrings[spec[1]]
    if raw~=string.format(english,unpack(spec,2)) then return raw end
    return self:LocalizedText(spec[1],unpack(spec,2))
end

function FF:GetAchievementSearchText(definition)
    local result={}
    for _,field in ipairs({"title","description","flavour","detail"}) do
        local text=self:GetAchievementDisplayText(definition,field)
        if text then result[#result+1]=text end
    end
    return table.concat(result," ")
end

FF.englishStrings["achievement.recipe.rules"] = "Recipes for your faction count. Recipes from the other faction or with an unknown source also count if you have learned them."
FF.englishStrings["achievement.recipe.missing"] = "Still to learn: %s"
FF.englishStrings["achievement.recipe.missing-more"] = "Still to learn: %s  •  +%d more"
FF.englishStrings["catch.guidance.waters"] = "Best waters"
FF.englishStrings["catch.guidance.your-waters"] = "Your waters"
FF.englishStrings["catch.guidance.skill"] = "Recommended skill"
FF.englishStrings["catch.guidance.method"] = "Fishing method"
FF.englishStrings["catch.guidance.condition"] = "Special conditions"
FF.englishStrings["catch.guidance.uses"] = "Recipes & Uses"
FF.englishStrings["catch.guidance.not-verified"] = "Not verified"
FF.englishStrings["catch.guidance.no-waters"] = "No recorded waters yet"
FF.englishStrings["catch.guidance.skill-bonuses"] = "%s (includes gear and lure bonuses)"
FF.englishStrings["catch.use.source-unknown"] = "Source not verified"
FF.englishStrings["catch.use.instructions"] = "Open the verified Journal instructions."
FF.englishStrings["catch.use.related-instructions"] = "Open the related Journal instructions."
FF.englishStrings["catch.use.tournament"] = "Fishing tournament"
FF.englishStrings["catch.use.seasonal"] = "At level %d and Fishing %d, use a %s on %s or %s to prepare %s for the %s."


-- Recipe eligibility stays with Master Chef. This per-login record contains
-- only the already-decided missing names and its canonical message ownership.
function FF:GetAchievementRecipeDetail()
    local raw, record = self.achievementRecipeDetail, self.achievementRecipeDisplay
    if not record or record.canonical ~= raw then
        return raw or self:LocalizedText("achievement.detail.recipes-fallback")
    end
    local detail = self:LocalizedText("achievement.recipe.rules")
    local missing = record.missing
    if #missing > 0 then
        local names = {}
        for index = 1, math.min(5, #missing) do names[#names+1] = missing[index] end
        local key = #missing > 5 and "achievement.recipe.missing-more" or "achievement.recipe.missing"
        detail = detail .. "\n\n" .. self:LocalizedText(key,table.concat(names,", "),#missing-5)
    end
    return detail
end

local seasonalUse = {"catch.use.seasonal",35,275,"Chef's Knife","Raw Winter Squid","Raw Summer Bass","Seasonal Fish Steaks","Fishing Hut"}
-- Only presentation reads this projection. Use discovery, ingredient matching,
-- canonical ordering and direct-link cache identities stay with their owners.
function FF:GetJournalCatchUseDisplayText(use, field)
    local target = use.target
    local raw = field == "label" and target.label or use.detail
    if field == "label" then
        if target.kind == "guideuse" and target.id == 19807 and raw == "Fishing tournament" then
            return self:LocalizedText("catch.use.tournament")
        end
        return raw
    end
    if target.kind == "meal" then
        for _,meal in ipairs(self.masterChefMeals or {}) do if meal.id == target.id then
            local faction = self:GetJournalFaction()
            local source = meal.recipe
            if type(source)=="table" then source=source[faction] end
            local heading = meal.skill and "Cooking "..meal.skill or "Ingredients"
            local expected = heading.." • "..meal.ingredients.."\n"..(source or "Source not verified")
            if raw ~= expected then return raw end
            local ingredients = meal.skill and self:LocalizedText("nearby.service.ingredients",meal.skill,meal.ingredients)
                or self:LocalizedText("chef.detail.ingredients").." • "..meal.ingredients
            return ingredients.."\n"
                ..(source and self:GetMasterChefReferenceText("meal",meal,"recipe",faction) or self:LocalizedText("catch.use.source-unknown"))
        end end
    elseif target.kind == "campinfo" then
        if target.id == 279966 and raw == string.format(self.englishStrings[seasonalUse[1]],unpack(seasonalUse,2)) then
            return self:LocalizedText(unpack(seasonalUse))
        end
        for _,camp in ipairs(self.masterChefCamps or {}) do
            if camp.id == target.id and raw == camp.source then return self:GetMasterChefReferenceText("camp",camp,"source") end
        end
    elseif target.kind == "guideuse" and raw == self.englishStrings["catch.use.instructions"] then
        return self:LocalizedText("catch.use.instructions")
    end
    return raw
end

function FF:GetJournalCatchUseSearchText(id)
    local result = {}
    for _,use in ipairs(self:GetJournalCatchUses(id)) do
        result[#result+1] = self:GetJournalCatchUseDisplayText(use,"label")
        result[#result+1] = self:GetJournalCatchUseDisplayText(use,"detail")
    end
    return table.concat(result," ")
end

FF.englishStrings["catch.column.scope"] = "Scope"
FF.englishStrings["catch.column.caught"] = "Caught"
FF.englishStrings["catch.column.share"] = "Catch %s"
FF.englishStrings["catch.column.best"] = "Best session"
FF.englishStrings["catch.column.last"] = "Last"
FF.englishStrings["catch.column.short-caught"] = "Ct"
FF.englishStrings["catch.column.short-best"] = "Best"
FF.englishStrings["catch.scope.lifetime"] = "Lifetime"
FF.englishStrings["catch.scope.current"] = "Your current fishing location"
FF.englishStrings["catch.scope.recorded"] = "Recorded catch statistics"
FF.englishStrings["catch.scope.count-share"] = "Caught: %d • Catch share: %s"
FF.englishStrings["catch.scope.best-last"] = "Best session: %s • Last: %s"
FF.englishStrings["catch.unknown-water"] = "Unknown water"
FF.englishStrings["catch.not-caught"] = "Not yet caught"
FF.englishStrings["catch.mastery.title"] = "Catch Mastery"
FF.englishStrings["catch.mastery.unearned"] = "Unearned"
FF.englishStrings["catch.mastery.tier"] = "Tier %s"
FF.englishStrings["catch.mastery.heading"] = "Catch Mastery • %s"
FF.englishStrings["catch.mastery.earned"] = "Earned tier: %s"
FF.englishStrings["catch.mastery.lifetime.one"] = "Lifetime total: %d catches"
FF.englishStrings["catch.mastery.lifetime.other"] = "Lifetime total: %d catches"
FF.englishStrings["catch.mastery.next"] = "Tier %s requires %d total catches"
FF.englishStrings["catch.mastery.complete"] = "Mastered • all six tiers earned"
FF.englishStrings["catch.mastery.milestones"] = "Milestones: I 10 • II 50 • III 100 • IV 250 • V 500 • VI 1,000"
FF.englishStrings["catch.mastery.toward"] = "%d/%d toward Tier %s"
FF.englishStrings["catch.mastery.mastered"] = "Mastered"
FF.englishStrings["catch.mastery.remaining.one"] = "%d catches to go"
FF.englishStrings["catch.mastery.remaining.other"] = "%d catches to go"
FF.englishStrings["catch.mastery.total.one"] = "%d total catches"
FF.englishStrings["catch.mastery.total.other"] = "%d total catches"
FF.englishStrings["catch.help.hide-locations"] = "Click: Hide locations"
FF.englishStrings["catch.help.show-locations"] = "Click: Where to fish"
FF.englishStrings["catch.help.hide-details"] = "Click: Hide catch details"
FF.englishStrings["catch.help.show-details"] = "Click: Show catch details"
FF.englishStrings["catch.class.ultra"] = "Extra Rare catch"
FF.englishStrings["catch.class.rare"] = "Rare catch"
FF.englishStrings["catch.class.trophy"] = "Trophy fish"
FF.englishStrings["catch.class.bloated"] = "Bloated fish"
FF.englishStrings["catch.class.quest"] = "Quest catch"
FF.englishStrings["catch.class.event"] = "Event catch"
FF.englishStrings["catch.tooltip.effective-skill"] = "Recommended effective skill: %d"
FF.englishStrings["catch.badge.unearned"] = "Unearned â€¢ first milestone: 10"
FF.englishStrings["catch.badge.reached"] = "Tier %s â€¢ %d milestone reached"
FF.englishStrings["catch.badge.recorded"] = "%d recorded"
FF.englishStrings["catch.badge.next"] = "Next: %d â€¢ %d to go"
FF.englishStrings["catch.badge.complete"] = "All six milestones reached"

FF.englishStrings["catch.reference.waters.two-coast"] = "%s or %s coast"
FF.englishStrings["catch.reference.waters.rivers"] = "%s rivers"
FF.englishStrings["catch.reference.condition.alongside"] = "Rare catch alongside %s."
FF.englishStrings["catch.reference.waters.coast"] = "%s coast"
FF.englishStrings["catch.reference.waters.canals-lakes"] = "%s canals or %s lakes"
FF.englishStrings["catch.reference.waters.two-lakes"] = "%s or %s lakes"
FF.englishStrings["catch.reference.waters.two-rivers"] = "%s or %s rivers"
FF.englishStrings["catch.reference.waters.lakes"] = "%s lakes"
FF.englishStrings["catch.reference.waters.coast-outside"] = "%s coast, outside %s"
FF.englishStrings["catch.reference.condition.tournament-turnin"] = "Rare tournament catch. Turn in to %s."
FF.englishStrings["catch.reference.waters.coast-near"] = "%s coast near %s"
FF.englishStrings["catch.reference.waters.oasis-instance"] = "%s oasis pools or %s"
FF.englishStrings["catch.reference.waters.three-coast"] = "%s, %s, or %s coast"
FF.englishStrings["catch.reference.waters.inland"] = "%s inland water"
FF.englishStrings["catch.reference.condition.rare"] = "Rare catch."
FF.englishStrings["catch.reference.waters.two-inland"] = "%s or %s inland water"
FF.englishStrings["catch.reference.waters.two-rivers-lakes"] = "%s or %s rivers and lakes"
FF.englishStrings["catch.reference.waters.lake-shore-rivers"] = "%s' %s shore or %s rivers"
FF.englishStrings["catch.reference.waters.main-lake"] = "%s, especially %s's main lake"
FF.englishStrings["catch.reference.waters.two-waters"] = "%s or %s waters"
FF.englishStrings["catch.reference.condition.tournament"] = "Rare tournament catch."
FF.englishStrings["catch.reference.waters.canals-instance"] = "%s canals or %s"
FF.englishStrings["catch.reference.waters.water"] = "%s water"
FF.englishStrings["catch.reference.waters.waters"] = "%s waters"
FF.englishStrings["catch.reference.waters.canals"] = "%s canals"
FF.englishStrings["catch.reference.condition.very-rare"] = "Very rare catch."
FF.englishStrings["catch.reference.waters.east"] = "%s, east of %s"
FF.englishStrings["catch.reference.waters.unknown"] = "Exact waters not verified"
FF.englishStrings["catch.reference.method.unknown"] = "Exact fishing method not verified"
FF.englishStrings["catch.reference.condition.waters-undocumented"] = "Exact Forever waters are not fully documented."
FF.englishStrings["catch.reference.condition.availability-unknown"] = "Availability in Forever is not fully documented."

local catchReferenceProse={["Tanaris or Azshara coast"]={"catch.reference.waters.two-coast","Tanaris","Azshara"},["Ashenvale rivers"]={"catch.reference.waters.rivers","Ashenvale"},["Redridge rivers"]={"catch.reference.waters.rivers","Redridge"},["Rare catch alongside Raw Bristle Whisker Catfish."]={"catch.reference.condition.alongside","Raw Bristle Whisker Catfish"},["Hillsbrad coast"]={"catch.reference.waters.coast","Hillsbrad"},["Wetlands coast"]={"catch.reference.waters.coast","Wetlands"},["Rare catch alongside Firefin Snapper."]={"catch.reference.condition.alongside","Firefin Snapper"},["Stormwind canals or Loch Modan lakes"]={"catch.reference.waters.canals-lakes","Stormwind","Loch Modan"},["Rare catch alongside Raw Longjaw Mud Snapper."]={"catch.reference.condition.alongside","Raw Longjaw Mud Snapper"},["Felwood or Feralas lakes"]={"catch.reference.waters.two-lakes","Felwood","Feralas"},["Rare catch alongside Raw Redgill."]={"catch.reference.condition.alongside","Raw Redgill"},["Desolace or Stranglethorn coast"]={"catch.reference.waters.two-coast","Desolace","Stranglethorn"},["Rare catch alongside Raw Rockscale Cod."]={"catch.reference.condition.alongside","Raw Rockscale Cod"},["Durotar rivers"]={"catch.reference.waters.rivers","Durotar"},["Elwynn Forest rivers"]={"catch.reference.waters.rivers","Elwynn Forest"},["Rare catch alongside Raw Brilliant Smallfish."]={"catch.reference.condition.alongside","Raw Brilliant Smallfish"},["Dustwallow Marsh or Stranglethorn rivers"]={"catch.reference.waters.two-rivers","Dustwallow Marsh","Stranglethorn"},["Rare catch alongside Raw Mithril Head Trout."]={"catch.reference.condition.alongside","Raw Mithril Head Trout"},["Winterspring lakes"]={"catch.reference.waters.lakes","Winterspring"},["Rare catch alongside Raw Whitescale Salmon."]={"catch.reference.condition.alongside","Raw Whitescale Salmon"},["Stranglethorn coast, outside Booty Bay"]={"catch.reference.waters.coast-outside","Stranglethorn","Booty Bay"},["Rare tournament catch. Turn in to Fishbot 5000."]={"catch.reference.condition.tournament-turnin","Fishbot 5000"},["Darkshore coast near Auberdine"]={"catch.reference.waters.coast-near","Darkshore","Auberdine"},["Darkshore or Westfall coast"]={"catch.reference.waters.two-coast","Darkshore","Westfall"},["The Barrens oasis pools or Wailing Caverns"]={"catch.reference.waters.oasis-instance","The Barrens","Wailing Caverns"},["Desolace, Dustwallow Marsh, or Stranglethorn coast"]={"catch.reference.waters.three-coast","Desolace","Dustwallow Marsh","Stranglethorn"},["Feralas inland water"]={"catch.reference.waters.inland","Feralas"},["Rare catch."]={"catch.reference.condition.rare"},["Feralas, Tanaris, or Azshara coast"]={"catch.reference.waters.three-coast","Feralas","Tanaris","Azshara"},["The Barrens coast"]={"catch.reference.waters.coast","The Barrens"},["Darkshore coast"]={"catch.reference.waters.coast","Darkshore"},["Tirisfal Glades rivers"]={"catch.reference.waters.rivers","Tirisfal Glades"},["The Barrens or Hillsbrad inland water"]={"catch.reference.waters.two-inland","The Barrens","Hillsbrad"},["Redridge or Wetlands rivers and lakes"]={"catch.reference.waters.two-rivers-lakes","Redridge","Wetlands"},["Tanaris or Feralas coast"]={"catch.reference.waters.two-coast","Tanaris","Feralas"},["Alterac Mountains' Lake Lordamere shore or Stranglethorn rivers"]={"catch.reference.waters.lake-shore-rivers","Alterac Mountains","Lake Lordamere","Stranglethorn"},["Loch Modan, especially Loch Modan's main lake"]={"catch.reference.waters.main-lake","Loch Modan","Loch Modan"},["Orgrimmar or Thunder Bluff waters"]={"catch.reference.waters.two-waters","Orgrimmar","Thunder Bluff"},["Moonglade or Felwood lakes"]={"catch.reference.waters.two-lakes","Moonglade","Felwood"},["Eastern Plaguelands inland water"]={"catch.reference.waters.inland","Eastern Plaguelands"},["Westfall or Darkshore coast"]={"catch.reference.waters.two-coast","Westfall","Darkshore"},["Stranglethorn or Dustwallow Marsh coast"]={"catch.reference.waters.two-coast","Stranglethorn","Dustwallow Marsh"},["Ashenvale or Wetlands rivers"]={"catch.reference.waters.two-rivers","Ashenvale","Wetlands"},["Durotar coast"]={"catch.reference.waters.coast","Durotar"},["Teldrassil coast"]={"catch.reference.waters.coast","Teldrassil"},["Rare tournament catch."]={"catch.reference.condition.tournament"},["Stranglethorn coast"]={"catch.reference.waters.coast","Stranglethorn"},["Desolace or Dustwallow Marsh coast"]={"catch.reference.waters.two-coast","Desolace","Dustwallow Marsh"},["Undercity canals or Blackfathom Deeps"]={"catch.reference.waters.canals-instance","Undercity","Blackfathom Deeps"},["Westfall coast"]={"catch.reference.waters.coast","Westfall"},["Hillsbrad water"]={"catch.reference.waters.water","Hillsbrad"},["Wetlands water"]={"catch.reference.waters.water","Wetlands"},["Orgrimmar waters"]={"catch.reference.waters.waters","Orgrimmar"},["Stormwind canals"]={"catch.reference.waters.canals","Stormwind"},["Very rare catch."]={"catch.reference.condition.very-rare"},["Ashenvale coast"]={"catch.reference.waters.coast","Ashenvale"},["Redridge, east of Lake Everstill"]={"catch.reference.waters.east","Redridge","Lake Everstill"},["Zul'Gurub rivers"]={"catch.reference.waters.rivers","Zul'Gurub"},["Exact waters not verified"]={"catch.reference.waters.unknown"},["Exact fishing method not verified"]={"catch.reference.method.unknown"},["Exact Forever waters are not fully documented."]={"catch.reference.condition.waters-undocumented"},["Availability in Forever is not fully documented."]={"catch.reference.condition.availability-unknown"}}
local catchReferenceFields={
    [7973]={["waters"]="Tanaris or Azshara coast",["method"]="Coastal open water"},
    [6647]={["waters"]={["Horde"]="Ashenvale rivers",["Alliance"]="Redridge rivers"},["method"]="Inland open water",["condition"]="Rare catch alongside Raw Bristle Whisker Catfish."},
    [21163]={["waters"]={["Horde"]="Hillsbrad coast",["Alliance"]="Wetlands coast"},["method"]="Firefin schools",["condition"]="Rare catch alongside Firefin Snapper."},
    [6645]={["waters"]="Stormwind canals or Loch Modan lakes",["method"]="Inland open water",["condition"]="Rare catch alongside Raw Longjaw Mud Snapper."},
    [13881]={["waters"]="Felwood or Feralas lakes",["method"]="Inland open water",["condition"]="Rare catch alongside Raw Redgill."},
    [21164]={["waters"]="Desolace or Stranglethorn coast",["method"]="Coastal open water",["condition"]="Rare catch alongside Raw Rockscale Cod."},
    [6643]={["waters"]={["Horde"]="Durotar rivers",["Alliance"]="Elwynn Forest rivers"},["method"]="Inland open water",["condition"]="Rare catch alongside Raw Brilliant Smallfish."},
    [8366]={["waters"]="Dustwallow Marsh or Stranglethorn rivers",["method"]="Inland open water",["condition"]="Rare catch alongside Raw Mithril Head Trout."},
    [13891]={["waters"]="Winterspring lakes",["method"]="Inland open water",["condition"]="Rare catch alongside Raw Whitescale Salmon."},
    [19803]={["waters"]="Stranglethorn coast, outside Booty Bay",["method"]="Schools of Tastyfish only",["condition"]="Rare tournament catch. Turn in to Fishbot 5000."},
    [13888]={["waters"]="Azshara, Bay of Storms",["method"]="Coastal open water"},
    [12238]={["waters"]="Darkshore coast near Auberdine",["method"]="Coastal open water",["condition"]={["Alliance"]="Needed for The Family and the Fishing Pole."}},
    [6351]={["waters"]="Darkshore or Westfall coast",["method"]="Coastal open water or debris"},
    [6522]={["waters"]="The Barrens oasis pools or Wailing Caverns",["method"]="Deviate Fish schools or inland water"},
    [19806]={["waters"]="Stranglethorn coast, outside Booty Bay",["method"]="Schools of Tastyfish only",["condition"]="Rare tournament catch. Turn in to Fishbot 5000."},
    [6359]={["waters"]={["Horde"]="Hillsbrad coast",["Alliance"]="Wetlands coast"},["method"]="Firefin schools or coastal water"},
    [13874]={["waters"]="Tanaris or Azshara coast",["method"]="Coastal open water or wreckage"},
    [21150]={["waters"]="Desolace, Dustwallow Marsh, or Stranglethorn coast",["method"]="Wreckage pools"},
    [19805]={["waters"]="Stranglethorn coast, outside Booty Bay",["method"]="Schools of Tastyfish only",["condition"]="Rare tournament catch. Turn in to Fishbot 5000."},
    [13893]={["waters"]="Azshara, Bay of Storms",["method"]="Coastal open water"},
    [13757]={["waters"]="Feralas inland water",["method"]="Inland open water"},
    [6307]={["waters"]="Darkshore or Westfall coast",["method"]="Coastal open water",["condition"]="Rare catch."},
    [21228]={["waters"]="Feralas, Tanaris, or Azshara coast",["method"]="Wreckage pools"},
    [6458]={["waters"]="Windshear Crag, Stonetalon Mountains",["method"]="Oil Spill pools only"},
    [6358]={["waters"]={["Horde"]="The Barrens coast",["Alliance"]="Darkshore coast"},["method"]="Blackmouth schools or coastal water"},
    [6301]={["waters"]="Tirisfal Glades rivers",["method"]="Inland open water",["condition"]="Rare catch."},
    [6291]={["waters"]={["Horde"]="Durotar rivers",["Alliance"]="Elwynn Forest rivers"},["method"]="Inland open water"},
    [6308]={["waters"]={["Horde"]="The Barrens or Hillsbrad inland water",["Alliance"]="Redridge or Wetlands rivers and lakes"},["method"]="Inland open water"},
    [13754]={["waters"]="Tanaris or Feralas coast",["method"]="Coastal open water"},
    [21153]={["waters"]="Alterac Mountains' Lake Lordamere shore or Stranglethorn rivers",["method"]="Greater Sagefish schools"},
    [6317]={["waters"]="Loch Modan, especially Loch Modan's main lake",["method"]="Inland open water"},
    [6289]={["waters"]={["Horde"]="Orgrimmar or Thunder Bluff waters",["Alliance"]="Stormwind canals or Loch Modan lakes"},["method"]="Inland open water"},
    [8365]={["waters"]="Dustwallow Marsh or Stranglethorn rivers",["method"]="Inland open water"},
    [13759]={["waters"]="Moonglade or Felwood lakes",["method"]="Inland open water",["condition"]="Most common at night."},
    [13890]={["waters"]="Eastern Plaguelands inland water",["method"]="Inland open water"},
    [6361]={["waters"]="Westfall or Darkshore coast",["method"]="Coastal open water"},
    [13758]={["waters"]="Felwood or Feralas lakes",["method"]="Inland open water"},
    [6362]={["waters"]="Stranglethorn or Dustwallow Marsh coast",["method"]="Coastal open water"},
    [21071]={["waters"]="Ashenvale or Wetlands rivers",["method"]="Sagefish schools"},
    [6303]={["waters"]={["Horde"]="Durotar coast",["Alliance"]="Teldrassil coast"},["method"]="Coastal open water"},
    [4603]={["waters"]="Tanaris or Feralas coast",["method"]="Coastal open water"},
    [13756]={["waters"]="Tanaris or Feralas coast",["method"]="Coastal open water",["condition"]="Summer season; limited overlap in spring and autumn."},
    [13760]={["waters"]="Moonglade or Felwood lakes",["method"]="Inland open water",["condition"]="Daytime catch."},
    [13889]={["waters"]="Winterspring lakes",["method"]="Inland open water"},
    [13755]={["waters"]="Tanaris or Feralas coast",["method"]="Coastal open water",["condition"]="Winter season; limited overlap in spring and autumn."},
    [19808]={["waters"]="Stranglethorn coast, outside Booty Bay",["method"]="Schools of Tastyfish only",["condition"]="Rare tournament catch."},
    [21151]={["waters"]="Stranglethorn coast",["method"]="Fish schools or wreckage"},
    [21114]={["waters"]={["Horde"]="Hillsbrad coast",["Alliance"]="Wetlands coast"},["method"]="Fish schools or wreckage"},
    [20709]={["waters"]={["Horde"]="The Barrens coast",["Alliance"]="Darkshore coast"},["method"]="Fish schools or floating debris"},
    [6357]={["waters"]="Desolace or Dustwallow Marsh coast",["method"]="Coastal open water or wreckage"},
    [6299]={["waters"]={["Horde"]="Undercity canals or Blackfathom Deeps",["Alliance"]="Blackfathom Deeps"},["method"]="Inland open water"},
    [5523]={["waters"]={["Horde"]="Durotar coast",["Alliance"]="Westfall coast"},["method"]="Coastal open water"},
    [6353]={["waters"]="Westfall or Darkshore coast",["method"]="Coastal open water or debris"},
    [19807]={["waters"]="Stranglethorn coast, outside Booty Bay",["method"]="Schools of Tastyfish only",["condition"]="Stranglethorn Fishing Extravaganza, Sunday 2–4 p.m. server time."},
    [6360]={["waters"]={["Horde"]="Hillsbrad water",["Alliance"]="Wetlands water"},["method"]="Open water",["condition"]="Rare catch."},
    [13422]={["waters"]="Tanaris or Feralas coast",["method"]="Stonescale Eel schools or coastal water",["condition"]="More common at night."},
    [3820]={["waters"]="Wetlands coast",["method"]="Coastal pools or wreckage"},
    [8350]={["waters"]={["Horde"]="Orgrimmar waters",["Alliance"]="Stormwind canals"},["method"]="Inland open water",["condition"]="Very rare catch."},
    [5524]={["waters"]={["Horde"]="Hillsbrad coast",["Alliance"]="Ashenvale coast"},["method"]="Coastal open water"},
    [20708]={["waters"]={["Horde"]="The Barrens coast",["Alliance"]="Darkshore or Westfall coast"},["method"]="Floating Debris pools"},
    [6352]={["waters"]={["Horde"]="Hillsbrad coast",["Alliance"]="Wetlands coast"},["method"]="Coastal open water or wreckage"},
    [21113]={["waters"]={["Horde"]="Hillsbrad coast",["Alliance"]="Wetlands coast"},["method"]="Wreckage pools"},
    [251524]={["waters"]="Redridge, east of Lake Everstill",["method"]="Whimsyfin schools only"},
    [19975]={["waters"]="Zul'Gurub rivers",["method"]="Muddy Churning Waters only",["condition"]="Inside the Zul'Gurub raid."},
    [6292]={["waters"]="Dun Morogh, Durotar, Elwynn Forest, Mulgore, Teldrassil, Tirisfal Glades, Zephras Isle",["method"]="Exact fishing method not verified"},
    [6295]={["waters"]="Elwynn Forest, Mulgore, Teldrassil, Dun Morogh, Durotar, Tirisfal Glades, The Barrens, Zephras Isle",["method"]="Exact fishing method not verified"},
    [6294]={["waters"]="Elwynn Forest, Mulgore, Tirisfal Glades, Teldrassil, Durotar, Dun Morogh, Zephras Isle",["method"]="Exact fishing method not verified"},
    [6309]={["waters"]="Stormwind City, Darnassus, Orgrimmar, Ashenvale, Dustwallow Marsh, Darkshore, Redridge Mountains, Stranglethorn Vale, Undercity, Hillsbrad Foothills, Alterac Mountains, The Barrens, Thunder Bluff, Stonetalon Mountains, Arathi Highlands, Desolace, Loch Modan",["method"]="Exact fishing method not verified"},
    [6310]={["waters"]="Stormwind City, Ashenvale, Dustwallow Marsh, Redridge Mountains, Darkshore, Alterac Mountains, Hillsbrad Foothills, Orgrimmar, Stranglethorn Vale, Darnassus, The Barrens, Thunder Bluff, Loch Modan, Desolace, Arathi Highlands, Undercity, Stonetalon Mountains",["method"]="Exact fishing method not verified"},
    [6311]={["waters"]="Dustwallow Marsh, Ashenvale, Hillsbrad Foothills, Redridge Mountains, Desolace, Stormwind City, Arathi Highlands, Orgrimmar, Stonetalon Mountains, The Barrens, Darnassus, Stranglethorn Vale, Thunder Bluff, Alterac Mountains, Swamp of Sorrows, Darkshore, Thousand Needles, Loch Modan, Undercity, Westfall",["method"]="Exact fishing method not verified"},
    [6363]={["waters"]="Desolace, Dustwallow Marsh, Redridge Mountains, Ashenvale, Stranglethorn Vale, Alterac Mountains, Stonetalon Mountains, Arathi Highlands, Hillsbrad Foothills, Duskwood, Wetlands, Swamp of Sorrows",["method"]="Exact fishing method not verified"},
    [6364]={["waters"]="Dustwallow Marsh, Arathi Highlands, Desolace, Redridge Mountains, Ashenvale",["method"]="Exact fishing method not verified"},
    [13882]={["waters"]="Moonglade, Western Plaguelands, Feralas, The Hinterlands, Azshara, Felwood",["method"]="Exact fishing method not verified"},
    [13883]={["waters"]="Western Plaguelands, Moonglade, Feralas, The Hinterlands, Azshara, Felwood, Un'Goro Crater, Eastern Plaguelands",["method"]="Exact fishing method not verified"},
    [13884]={["waters"]="Feralas, Western Plaguelands, Moonglade, The Hinterlands, Un'Goro Crater, Azshara, Felwood",["method"]="Exact fishing method not verified"},
    [13885]={["waters"]="Un'Goro Crater, Felwood, Feralas, Moonglade, The Hinterlands, Western Plaguelands, Azshara",["method"]="Exact fishing method not verified"},
    [13886]={["waters"]="Western Plaguelands, Moonglade, Feralas, The Hinterlands, Azshara, Felwood, Un'Goro Crater",["method"]="Exact fishing method not verified"},
    [13887]={["waters"]="Western Plaguelands, Feralas, Azshara, Moonglade, The Hinterlands, Un'Goro Crater",["method"]="Exact fishing method not verified"},
    [13902]={["waters"]="Eastern Plaguelands, Winterspring, Alterac Valley",["method"]="Exact fishing method not verified"},
    [13904]={["waters"]="Winterspring, Deadwind Pass, Eastern Plaguelands, Mount Hyjal",["method"]="Exact fishing method not verified"},
    [13905]={["waters"]="Eastern Plaguelands, Winterspring, Alterac Valley",["method"]="Exact fishing method not verified"},
    [13915]={["waters"]="Azshara",["method"]="Exact fishing method not verified"},
    [13914]={["waters"]="Exact waters not verified",["method"]="Exact fishing method not verified",["condition"]="Exact Forever waters are not fully documented."},
    [13916]={["waters"]="Azshara",["method"]="Exact fishing method not verified"},
    [13917]={["waters"]="Exact waters not verified",["method"]="Exact fishing method not verified",["condition"]="Availability in Forever is not fully documented."},
    [13876]={["waters"]="The Hinterlands, Feralas, Azshara, Tanaris, Stranglethorn Vale",["method"]="Exact fishing method not verified"},
    [13877]={["waters"]="Tanaris, Azshara, Feralas, The Hinterlands",["method"]="Exact fishing method not verified"},
    [13878]={["waters"]="Azshara, Tanaris, Feralas, The Hinterlands",["method"]="Exact fishing method not verified"},
    [13879]={["waters"]="Azshara, Tanaris, Feralas, The Hinterlands, Stranglethorn Vale",["method"]="Exact fishing method not verified"},
    [13880]={["waters"]="Azshara, Tanaris, Feralas, The Hinterlands",["method"]="Exact fishing method not verified"},
    [16967]={["waters"]="Feralas",["method"]="Exact fishing method not verified",["condition"]="Nat Pagle, Angler Extreme must be active; fish the Verdantis River."},
    [16968]={["waters"]="Desolace",["method"]="Exact fishing method not verified",["condition"]="Nat Pagle, Angler Extreme must be active; fish the western coast."},
    [16969]={["waters"]="Stranglethorn Vale",["method"]="Exact fishing method not verified",["condition"]="Nat Pagle, Angler Extreme must be active; fish the Savage Coast."},
    [16970]={["waters"]="Swamp of Sorrows",["method"]="Exact fishing method not verified",["condition"]="Nat Pagle, Angler Extreme must be active; fish the eastern coast."},
    [6717]={["waters"]="Darkshore",["method"]="Exact fishing method not verified",["condition"]="For the Gaffer Jacks quest."},
    [6718]={["waters"]="Darkshore",["method"]="Exact fishing method not verified",["condition"]="For the Electropellers quest."},
    [21243]={["waters"]="Tanaris, Riverglades",["method"]="Exact fishing method not verified"},
    [118]={["waters"]="Elwynn Forest, Mulgore, Tirisfal Glades, Teldrassil, Durotar, Zephras Isle, Dun Morogh",["method"]="Exact fishing method not verified"},
    [288206]={["waters"]="Mount Hyjal",["method"]="Exact fishing method not verified"},
}

local function CatchReferenceField(value,faction)
    if type(value)=="table" then return value[faction] end
    return value
end

-- Display-only: never rewrite curated catch data or feed translated locations
-- back into discovery, sorting, recorded places, skill parsing or navigation.
function FF:GetJournalCatchReferenceText(entry,field,faction)
    local guide=entry and entry[3]
    local raw=guide and CatchReferenceField(guide[field],faction)
    local fields=entry and catchReferenceFields[entry[1]]
    local expected=fields and CatchReferenceField(fields[field],faction)
    if raw~=expected then return raw end
    local spec=catchReferenceProse[raw] or nearbyProse[raw]
    return spec and self:LocalizedText(spec[1],unpack(spec,2)) or raw
end

function FF:GetJournalCatchReferenceSearchText(entry,faction)
    local result={}
    for _,field in ipairs({"waters","method","condition"}) do
        local text=self:GetJournalCatchReferenceText(entry,field,faction)
        if text then result[#result+1]=text end
    end
    return table.concat(result," ")
end

-- Quest prose is display-only; native titles, IDs and reference facts stay canonical.
FF.englishStrings["quest.reference.angler.summary"] = "Catch %s in the %s, %s off southeast %s, %s off %s and %s off %s. Return to %s in %s."
FF.englishStrings["quest.reference.fishing-level"] = "Fishing %d • Level %d"
FF.englishStrings["quest.reference.skill-cap"] = "%s Fishing • skill cap %d"
FF.englishStrings["quest.reference.family.summary"] = "Fish six %s near %s and return to %s."
FF.englishStrings["quest.reference.faction-level"] = "%s • Level %d"
FF.englishStrings["quest.reference.fishing-bonus"] = "%s • +%d Fishing"
FF.englishStrings["quest.reference.snapjaws.summary"] = "Kill %d %s on the coast north of %s, then return to %s."
FF.englishStrings["quest.reference.required-bonus"] = "%s • +%d Fishing; requires Fishing %d"
FF.englishStrings["quest.reference.bottles.summary"] = "Collect 6 %s from the murloc camps on %s's south shore and return to %s."
FF.englishStrings["quest.reference.timed-bonus"] = "%s • +%d Fishing for %d minutes"
FF.englishStrings["quest.reference.camping.summary"] = "Your starting-zone camping guide sends you to a Fishing trainer for %s training."
FF.englishStrings["quest.reference.camping.requirements"] = "Level %d • Fishing %d • introductory camping chain: %s, then %s"
FF.englishStrings["quest.reference.training"] = "%s training"
FF.englishStrings["quest.reference.bowl-campfire"] = "A campfire is required before placing the bowl."
FF.englishStrings["quest.reference.adventurer.summary"] = "Starts the introductory camping chain, before %s and %s."
FF.englishStrings["quest.reference.outdoors.summary"] = "Continues the introductory camping chain after %s and before %s."
FF.englishStrings["quest.reference.details-unknown"] = "Further objectives, requirements and rewards are not yet verified."
FF.englishStrings["quest.reference.gaffer-jacks.summary"] = "Fish %d %s near %s and return to %s."
FF.englishStrings["quest.reference.electropellers.summary"] = "Finish %s. Fish %d %s in %s and return to %s."
FF.englishStrings["quest.reference.item-quantity"] = "%d × %s"

local questReferenceText = {["Nat Pagle, Angler Extreme"]={["mapLabel"]="Nat Pagle",["fields"]={["summary"]={["raw"]="Catch Feralas Ahi in the Verdantis River, Misty Reed Mahi Mahi off southeast Swamp of Sorrows, Sar'theris Striker off Desolace and Savage Coast Blue Sailfin off Stranglethorn. Return to Nat Pagle in Dustwallow Marsh.",["spec"]={"quest.reference.angler.summary","Feralas Ahi","Verdantis River","Misty Reed Mahi Mahi","Swamp of Sorrows","Sar'theris Striker","Desolace","Savage Coast Blue Sailfin","Stranglethorn","Nat Pagle","Dustwallow Marsh"}},["requirements"]={["raw"]="Fishing 225 • Level 35",["spec"]={"quest.reference.fishing-level",225,35}},["rewards"]={["raw"]="Artisan Fishing • skill cap 300",["spec"]={"quest.reference.skill-cap",{["textKey"]="information.rank.artisan"},300}}}},["The Family and the Fishing Pole"]={["fields"]={["summary"]={["raw"]="Fish six Darkshore Grouper near Auberdine and return to Gubber Blump.",["spec"]={"quest.reference.family.summary","Darkshore Grouper","Auberdine","Gubber Blump"}},["requirements"]={["raw"]="Alliance • Level 10",["spec"]={"quest.reference.faction-level",{["textKey"]="faction.alliance"},10}},["rewards"]={["raw"]="Blump Family Fishing Pole • +3 Fishing",["spec"]={"quest.reference.fishing-bonus","Blump Family Fishing Pole",3}}}},["Snapjaws, Mon!"]={["fields"]={["summary"]={["raw"]="Kill 15 Saltwater Snapjaws on the coast north of Revantusk Village, then return to Katoom the Angler.",["spec"]={"quest.reference.snapjaws.summary",15,"Saltwater Snapjaws","Revantusk Village","Katoom the Angler"}},["requirements"]={["raw"]="Horde • Level 44",["spec"]={"quest.reference.faction-level",{["textKey"]="faction.horde"},44}},["rewards"]={["raw"]="Nat Pagle's Extreme Angler FC-5000 • +25 Fishing; requires Fishing 100",["spec"]={"quest.reference.required-bonus","Nat Pagle's Extreme Angler FC-5000",25,100}}}},["Camping 101: Fishing"]={["questID"]=97920,["fields"]={["summary"]={["raw"]="Your starting-zone camping guide sends you to a Fishing trainer for Fish Bowl training.",["spec"]={"quest.reference.camping.summary","Fish Bowl"}},["requirements"]={["raw"]="Level 4 • Fishing 20 • introductory camping chain: The Adventurer, then The Great Outdoors",["spec"]={"quest.reference.camping.requirements",4,20,"The Adventurer","The Great Outdoors"}},["rewards"]={["raw"]="Fish Bowl training",["spec"]={"quest.reference.training","Fish Bowl"}},["note"]={["raw"]="A campfire is required before placing the bowl.",["spec"]={"quest.reference.bowl-campfire"}}}},["The Adventurer"]={["fields"]={["summary"]={["raw"]="Starts the introductory camping chain, before The Great Outdoors and Camping 101: Fishing.",["spec"]={"quest.reference.adventurer.summary","The Great Outdoors","Camping 101: Fishing"}},["note"]={["raw"]="Further objectives, requirements and rewards are not yet verified.",["spec"]={"quest.reference.details-unknown"}}}},["The Great Outdoors"]={["fields"]={["summary"]={["raw"]="Continues the introductory camping chain after The Adventurer and before Camping 101: Fishing.",["spec"]={"quest.reference.outdoors.summary","The Adventurer","Camping 101: Fishing"}},["note"]={["raw"]="Further objectives, requirements and rewards are not yet verified.",["spec"]={"quest.reference.details-unknown"}}}}}

questReferenceText["Bottles and Baubles"]={questID=99143,mapLabel="Lee Brown",fields={
    summary={raw="Collect 6 Shiny Junk from the murloc camps on Crystal Lake's south shore and return to Lee Brown.",
        spec={"quest.reference.bottles.summary","Shiny Junk","Crystal Lake","Lee Brown"}},
    requirements={raw="Alliance",spec={"faction.alliance"}},
    rewards={raw="Shiny Silver Coin • +30 Fishing for 30 minutes",
        spec={"quest.reference.timed-bonus","Shiny Silver Coin",30,30}},
}}

questReferenceText["Gaffer Jacks"]={questID=1579,mapLabel="Wizbang Cranktoggle",fields={
    summary={raw="Fish 8 Gaffer Jacks near Auberdine and return to Wizbang Cranktoggle.",
        spec={"quest.reference.gaffer-jacks.summary",8,"Gaffer Jacks","Auberdine","Wizbang Cranktoggle"}},
    requirements={raw="Alliance",spec={"faction.alliance"}},
}}
questReferenceText["Electropellers"]={questID=1580,mapLabel="Wizbang Cranktoggle",fields={
    summary={raw="Finish Gaffer Jacks. Fish 12 Electropellers in Darkshore and return to Wizbang Cranktoggle.",
        spec={"quest.reference.electropellers.summary","Gaffer Jacks",12,"Electropellers","Darkshore","Wizbang Cranktoggle"}},
    requirements={raw="Alliance",spec={"faction.alliance"}},
    rewards={raw="20 × Aquadynamic Fish Lens",spec={"quest.reference.item-quantity",20,"Aquadynamic Fish Lens"}},
}}

function FF:GetJournalQuestDisplayText(quest,field)
    local raw=quest and quest[field]
    local record=quest and questReferenceText[quest.title]
    local spec=record and record.fields[field]
    if not spec or raw~=spec.raw or quest.questID~=record.questID or quest.mapLabel~=record.mapLabel then return raw end
    return self:FormatLocalizedReference(spec.spec)
end

-- Gear details are transient canonical lines. Project only the still-owned
-- quest summary for the exact curated item/quest pair, never arbitrary prose.
local gearQuestReferences = {[12225]="The Family and the Fishing Pole",[19022]="Snapjaws, Mon!",[286732]="Bottles and Baubles"}
function FF:GetJournalGearQuestDetailsText(entry)
    local raw=entry and entry.details
    if not entry or gearQuestReferences[entry.id]~=entry.quest or type(raw)~="string" then return raw end
    local quest=self:GetJournalQuestReference(entry.quest)
    local summary=quest and quest.summary
    if not summary then return raw end
    return (raw:gsub("[^\n]+",function(line)
        return line==summary and self:GetJournalQuestDisplayText(quest,"summary") or line
    end))
end

function FF:GetJournalQuestSearchText(quest)
    local parts={}
    for _,field in ipairs({"summary","requirements","rewards","note"}) do
        local value=self:GetJournalQuestDisplayText(quest,field)
        if value then parts[#parts+1]=value end
    end
    return table.concat(parts," ")
end

function FF:GetJournalGearQuestEntrySearchText(entry)
    if not entry or gearQuestReferences[entry.id]~=entry.quest then return "" end
    return self:GetJournalQuestSearchText(self:GetJournalQuestReference(entry.quest))
end

function FF:GetJournalGearQuestSearchText(block,faction)
    local parts={}
    for _,entry in ipairs(self:GetJournalGearReferences(block,faction)) do
        parts[#parts+1]=self:GetJournalGearQuestEntrySearchText(entry)
    end
    return table.concat(parts," ")
end

-- Rare guide display follows canonical grouping; native facts and destinations stay unchanged.
FF.englishStrings["rare.guide.sunday"] = "Every Sunday"
FF.englishStrings["rare.guide.event.time"] = "%s, 2–4 p.m. server time. You do not need to register."
FF.englishStrings["rare.guide.event.pools"] = "• Fish %s along the %s coast, outside %s. Your bobber must land inside a pool."
FF.englishStrings["rare.guide.event.turn-in"] = "• Catch 40 %s and turn them in to %s on %s's central dock. The first 250 turn-ins per ruleset win."
FF.englishStrings["rare.guide.event.winners"] = "• Winners receive an %s and an %s. Exchange the coin with %s in %s for %s, %s, %s, %s or %s."
FF.englishStrings["rare.guide.event.preparation"] = "Reach at least %s Fishing; %s and a lure mean fewer fish get away. Clear bag space and set your Hearthstone to %s. Keep it ready for the trip back to %s. A mount helps you reach the next pool."
FF.englishStrings["rare.guide.event.rares"] = "Tastyfish pools can also yield rare fish. Turn each one in to %s beside %s in %s:"
FF.englishStrings["rare.guide.event.after"] = "The pools stay up until the event ends, so keep fishing for rare fish. %s's apprentice pays for %s in groups of five. Turn them in while the tournament NPCs are still in %s."
FF.englishStrings["rare.guide.whimsyfin"] = "Look for %s schools east of %s. Learn %s at Cooking %s; each craft uses one %s and one %s to make two portions. Its recipe can drop from %s enemies, including %s. The food transforms you into an orc pirate or ninja."
FF.englishStrings["rare.guide.schools.deviate"] = "• %s — %s oases and %s."
FF.englishStrings["rare.guide.schools.blackmouth"] = "• %s — coastal zones at many levels."
FF.englishStrings["rare.guide.schools.firefin"] = "• %s — coasts in mid and high level zones."
FF.englishStrings["rare.guide.schools.wreckage"] = "• %s and %s may hold trunks, trade goods, bags, or uncommon items."
FF.englishStrings["rare.guide.season"] = "%s bites most at night; %s is a daytime catch. %s is more common around dawn, dusk, and night. %s and %s are seasonal, with some overlap in spring and autumn."
FF.englishStrings["rare.guide.camp"] = "%s improves your chance of catching bloated fish and offers Fishing lures. %s enables rare camp catches and offers Fishing lures. Use your Catch journal to compare what you find in each zone."
FF.englishStrings["rare.guide.heading.preparation"] = "Before the tournament"
FF.englishStrings["rare.guide.heading.prizes"] = "Rare fish prizes"
FF.englishStrings["rare.guide.heading.after"] = "After a winner is announced"
FF.englishStrings["rare.guide.heading.whimsyfin"] = "%s in %s"
FF.englishStrings["rare.guide.heading.schools"] = "Useful schools"
FF.englishStrings["rare.guide.heading.season"] = "Fish by time and season"
FF.englishStrings["rare.guide.heading.camp"] = "Forever camp catches"
FF.englishStrings["rare.guide.event.summary"] = "%s: these catches are available only during the event."
FF.englishStrings["rare.guide.section.event"] = "Event"
FF.englishStrings["rare.guide.section.preparation"] = "Requirements & preparation"
FF.englishStrings["rare.guide.section.turn-in"] = "Catches & turn-in"
FF.englishStrings["rare.guide.section.winners"] = "Winner rewards"
FF.englishStrings["rare.guide.section.rare-rewards"] = "Rare catches & rewards"

local rareGuideText = {
    ["Stranglethorn Fishing Extravaganza"] = {
        ["raw"] = "Every Sunday, 2–4 p.m. server time. You do not need to register.\n• Fish Schools of Tastyfish along the Stranglethorn coast, outside Booty Bay. Your bobber must land inside a pool.\n• Catch 40 Speckled Tastyfish and turn them in to Riggle Bassbait on Booty Bay's central dock. The first 250 turn-ins per ruleset win.\n• Winners receive an Arcanite Fishing Pole and an Extravagant Extravaganza Coin. Exchange the coin with Jang in Booty Bay for Hook of the Master Angler, Surfer Shoes, Master Angler's Fishing Hat, Empty Fish Bucket or Bitter Baitling.",
        ["lines"] = {{"rare.guide.event.time", {
            ["textKey"] = "rare.guide.sunday"
        }}, {"rare.guide.event.pools", "Schools of Tastyfish", "Stranglethorn", "Booty Bay"}, {"rare.guide.event.turn-in", "Speckled Tastyfish", "Riggle Bassbait", "Booty Bay"}, {"rare.guide.event.winners", "Arcanite Fishing Pole", "Extravagant Extravaganza Coin", "Jang", "Booty Bay", "Hook of the Master Angler", "Surfer Shoes", "Master Angler's Fishing Hat", "Empty Fish Bucket", "Bitter Baitling"}},
        ["heading"] = {"events.stranglethorn.title"}
    },
    ["Before the tournament"] = {
        ["raw"] = "Reach at least 150 Fishing; 225 and a lure mean fewer fish get away. Clear bag space and set your Hearthstone to Booty Bay. Keep it ready for the trip back to Riggle. A mount helps you reach the next pool.",
        ["lines"] = {{"rare.guide.event.preparation", {
            ["textKey"] = "skill.display.value",
            ["values"] = {150},
            ["profession"] = "Fishing",
            ["required"] = 150,
            ["fieldGuide"] = true
        }, {
            ["textKey"] = "skill.display.value",
            ["values"] = {225},
            ["profession"] = "Fishing",
            ["required"] = 225,
            ["fieldGuide"] = true
        }, "Booty Bay", "Riggle"}},
        ["heading"] = {"rare.guide.heading.preparation"}
    },
    ["Rare fish prizes"] = {
        ["raw"] = "Tastyfish pools can also yield rare fish. Turn each one in to Fishbot 5000 beside Riggle Bassbait in Booty Bay:\n• Keefer's Angelfish — Lucky Fishing Hat.\n• Brownell's Blue Striped Racer — Nat Pagle's Extreme Anglin' Boots.\n• Dezian Queenfish — High Test Eternium Fishing Line.",
        ["lines"] = {{"rare.guide.event.rares", "Fishbot 5000", "Riggle Bassbait", "Booty Bay"}, "• Keefer's Angelfish — Lucky Fishing Hat.", "• Brownell's Blue Striped Racer — Nat Pagle's Extreme Anglin' Boots.", "• Dezian Queenfish — High Test Eternium Fishing Line."},
        ["heading"] = {"rare.guide.heading.prizes"}
    },
    ["After a winner is announced"] = {
        ["raw"] = "The pools stay up until the event ends, so keep fishing for rare fish. Riggle's apprentice pays for Speckled Tastyfish in groups of five. Turn them in while the tournament NPCs are still in Booty Bay.",
        ["lines"] = {{"rare.guide.event.after", "Riggle", "Speckled Tastyfish", "Booty Bay"}},
        ["heading"] = {"rare.guide.heading.after"}
    },
    ["Whimsyfin in Redridge"] = {
        ["raw"] = "Look for Whimsyfin schools east of Lake Everstill. Learn Savory Whimsyfin Delight at Cooking 85; each craft uses one Whimsyfin and one Mild Spices to make two portions. Its recipe can drop from Redridge enemies, including Great Goretusks. The food transforms you into an orc pirate or ninja.",
        ["lines"] = {{"rare.guide.whimsyfin", "Whimsyfin", "Lake Everstill", "Savory Whimsyfin Delight", {
            ["textKey"] = "skill.display.value",
            ["values"] = {85},
            ["profession"] = "Cooking",
            ["required"] = 85,
            ["fieldGuide"] = true
        }, "Whimsyfin", "Mild Spices", "Redridge", "Great Goretusks"}},
        ["heading"] = {"rare.guide.heading.whimsyfin", "Whimsyfin", "Redridge"}
    },
    ["Useful schools"] = {
        ["raw"] = "• School of Deviate Fish — Barrens oases and Wailing Caverns.\n• Oily Blackmouth — coastal zones at many levels.\n• Firefin Snapper — coasts in mid and high level zones.\n• Stonescale Eel Swarm — Azshara, Feralas, and Tanaris.\n• Floating Wreckage and Debris may hold trunks, trade goods, bags, or uncommon items.",
        ["lines"] = {{"rare.guide.schools.deviate", "School of Deviate Fish", "Barrens", "Wailing Caverns"}, {"rare.guide.schools.blackmouth", "Oily Blackmouth"}, {"rare.guide.schools.firefin", "Firefin Snapper"}, "• Stonescale Eel Swarm — Azshara, Feralas, and Tanaris.", {"rare.guide.schools.wreckage", "Floating Wreckage", "Debris"}},
        ["heading"] = {"rare.guide.heading.schools"}
    },
    ["Fish by time and season"] = {
        ["raw"] = "Raw Nightfin Snapper bites most at night; Raw Sunscale Salmon is a daytime catch. Stonescale Eel is more common around dawn, dusk, and night. Winter Squid and Raw Summer Bass are seasonal, with some overlap in spring and autumn.",
        ["lines"] = {{"rare.guide.season", "Raw Nightfin Snapper", "Raw Sunscale Salmon", "Stonescale Eel", "Winter Squid", "Raw Summer Bass"}},
        ["heading"] = {"rare.guide.heading.season"}
    },
    ["Forever camp catches"] = {
        ["raw"] = "Fishing Rack improves your chance of catching bloated fish and offers Fishing lures. Fishing Hut enables rare camp catches and offers Fishing lures. Use your Catch journal to compare what you find in each zone.",
        ["lines"] = {{"rare.guide.camp", "Fishing Rack", "Fishing Hut"}},
        ["heading"] = {"rare.guide.heading.camp"}
    }
}
local rareGuideLabels = {
    ["Event"] = "rare.guide.section.event",
    ["Requirements & preparation"] = "rare.guide.section.preparation",
    ["Catches & turn-in"] = "rare.guide.section.turn-in",
    ["Winner rewards"] = "rare.guide.section.winners",
    ["Rare catches & rewards"] = "rare.guide.section.rare-rewards",
    ["Where to fish"] = "events.guide.waters.heading",
    ["After a winner is announced"] = "rare.guide.heading.after"
}

local function RareSunday(self,linked)
    local text=self:LocalizedText("rare.guide.sunday")
    if linked and self:GetResolvedLocale()~="enUS" then
        return self:GuideTargetLink({kind="fishingevent",id="stranglethorn",label="Stranglethorn Fishing Extravaganza"},text)
    end
    return text
end

function FF:GetRareGuideDisplayText(block,field,line,skills,linkedSchedule)
    local record=block and rareGuideText[block.heading]
    local raw=block and block[field]
    if field=="line" then
        local n=0
        local body=block and block.body
        for text in (type(body)=="string" and body or ""):gmatch("[^\n]+") do n=n+1;if n==line then raw=text;break end end
    end
    if not record or block.body~=record.raw then return raw,false end
    local translated=self:GetResolvedLocale()~="enUS"
    if field=="heading" then return self:FormatLocalizedReference(record.heading,skills),translated end
    local function Display(index)
        local spec=record.lines[index]
        if type(spec)=="string" then return spec end
        if not spec then return end
        if spec[1]=="rare.guide.event.time" then
            return self:LocalizedText(spec[1],RareSunday(self,linkedSchedule))
        end
        return self:FormatLocalizedReference(spec,skills)
    end
    if field=="line" then return Display(line),translated end
    if field=="body" then
        local lines={};for index=1,#record.lines do lines[index]=Display(index) end
        return table.concat(lines,"\n"),translated
    end
    return raw,false
end

function FF:GetRareGuideSummaryText(block,linkedSchedule)
    local record=block and rareGuideText[block.heading]
    if not record or block.heading~="Stranglethorn Fishing Extravaganza" or block.body~=record.raw then return end
    return self:LocalizedText("rare.guide.event.summary",RareSunday(self,linkedSchedule))
end

function FF:GetRareGuideSectionLabel(raw)
    return rareGuideLabels[raw] and self:LocalizedText(rareGuideLabels[raw]) or raw
end

function FF:GetRareGuideSearchText(block)
    local heading=self:GetRareGuideDisplayText(block,"heading")
    local body=self:GetRareGuideDisplayText(block,"body")
    return (type(heading)=="string" and heading or "").." "..(type(body)=="string" and body or "")
end

-- Gear overview, bonus and requirement projections never select or equip items.
FF.englishStrings["gear.reference.bonus.equipped-pole"] = "+%d Fishing · equipped pole"
FF.englishStrings["gear.reference.requires.quest"] = "Fishing %s; quest requires Level %d."
FF.englishStrings["gear.reference.requires.level-fishing"] = "Level %d · Fishing %s."
FF.englishStrings["gear.reference.requires.fishing"] = "Fishing %s."
FF.englishStrings["gear.reference.bonus.temporary-lure"] = "+%d Fishing · temporary lure"
FF.englishStrings["gear.reference.bonus.timed"] = "+%d Fishing · %d min"
FF.englishStrings["gear.reference.requires.food"] = "Level %d to eat · Cooking %s to prepare."
FF.englishStrings["gear.reference.requires.level"] = "Level %d."
FF.englishStrings["gear.reference.bonus.equipped-hat"] = "+%d Fishing · equipped hat"
FF.englishStrings["gear.reference.bonus.equipped-boots"] = "+%d Fishing · equipped boots"
FF.englishStrings["gear.reference.bonus.permanent-pole-enchant"] = "+%d Fishing · permanent pole enchant"
FF.englishStrings["gear.reference.bonus.permanent-glove-enchant"] = "+%d Fishing · permanent glove enchant"
FF.englishStrings["gear.reference.bonus.timed-lure"] = "+%d Fishing · %d min temporary lure"
FF.englishStrings["gear.reference.bonus.campfire"] = "Campfire · cooking and camp contributions"
FF.englishStrings["gear.reference.requires.cooking"] = "Cooking %s."
FF.englishStrings["gear.reference.bonus.bowl"] = "Camp buff · seated stats"
FF.englishStrings["gear.reference.bonus.rack"] = "Uncommon camp catches and Fishing lures · 1 hour"
FF.englishStrings["gear.reference.bonus.hut"] = "Rare camp catches and Fishing lures · 1 hour"
FF.englishStrings["gear.reference.bonus.knife"] = "Prepares %s · camp ingredient"
FF.englishStrings["gear.reference.bonus.form"] = "Fish form · utility"
FF.englishStrings["gear.reference.bonus.movement"] = "Water movement · utility"
FF.englishStrings["gear.reference.heading.poles"] = "Fishing poles"
FF.englishStrings["gear.reference.overview.poles"] = "Equipment bonuses apply while the pole is equipped."
FF.englishStrings["gear.reference.overview.lures"] = "Temporary pole enchants: applying another lure replaces the current lure. Check each native tooltip for its duration."
FF.englishStrings["gear.reference.heading.food"] = "Fishing food"
FF.englishStrings["gear.reference.overview.food"] = "Tooltip Fishing bonuses last 15 minutes after eating for 10 seconds. Confirm the effective skill change on your client; some beta reports disagree with the tooltip."
FF.englishStrings["gear.reference.heading.upgrades"] = "Fishing gear and upgrades"
FF.englishStrings["gear.reference.overview.upgrades"] = "Tournament rare catches come from %s's %s pools during the event. Equipment and permanent enchants are distinct from temporary lures."
FF.englishStrings["gear.reference.heading.legacy"] = "Legacy perks"
FF.englishStrings["gear.reference.overview.legacy"] = "%s gives a 25%% chance to catch an extra fish while a lure is active, rising to 50%% at rank 2. %s increases the chance to gain a tradeskill point by 4%% at its first rank, including Fishing. %s can raise Fishing by one point if it is your lowest tradeskill; 25-second cast, 23-hour cooldown. %s reduces the cooldown for placing fishing camp features. Learn these through the Legacy system; consult its current rank tooltips for higher-rank values."
FF.englishStrings["gear.reference.heading.tools"] = "Forever buffs and useful tools"
FF.englishStrings["gear.reference.overview.tools"] = "Buffs, camp contributions and utility effects are separate from permanent equipment bonuses."
FF.englishStrings["gear.reference.heading.additional"] = "Additional pole and bait references"
FF.englishStrings["gear.reference.overview.additional"] = "These entries are not confirmed shopping or catch routes. Current acquisition or availability remains unverified."
FF.englishStrings["gear.reference.heading.setup"] = "Set up your %s button"
FF.englishStrings["gear.reference.overview.setup"] = "Forever Fishing picks the strongest fishing pole and clothing that raises Fishing skill from your bags or equipped slots. Use the %s arrow to change items, or drag a missed item onto the icon. Click %s to equip your picks; click again to restore your previous items. The gold glow means some selected gear is not equipped."

local gearOverviewText = {
    ["Fishing poles"] = {
        ["raw"] = "Equipment bonuses apply while the pole is equipped.",
        ["heading"] = {"gear.reference.heading.poles"},
        ["body"] = {"gear.reference.overview.poles"}
    },
    ["Lures"] = {
        ["raw"] = "Temporary pole enchants: applying another lure replaces the current lure. Check each native tooltip for its duration.",
        ["heading"] = {"flyout.lures"},
        ["body"] = {"gear.reference.overview.lures"}
    },
    ["Fishing food"] = {
        ["raw"] = "Tooltip Fishing bonuses last 15 minutes after eating for 10 seconds. Confirm the effective skill change on your client; some beta reports disagree with the tooltip.",
        ["heading"] = {"gear.reference.heading.food"},
        ["body"] = {"gear.reference.overview.food"}
    },
    ["Fishing gear and upgrades"] = {
        ["raw"] = "Tournament rare catches come from Stranglethorn's Tastyfish pools during the event. Equipment and permanent enchants are distinct from temporary lures.",
        ["heading"] = {"gear.reference.heading.upgrades"},
        ["body"] = {"gear.reference.overview.upgrades", "Stranglethorn", "Tastyfish"}
    },
    ["Legacy perks"] = {
        ["raw"] = "Luremaster gives a 25% chance to catch an extra fish while a lure is active, rising to 50% at rank 2. Working Overtime increases the chance to gain a tradeskill point by 4% at its first rank, including Fishing. Dedicated Study can raise Fishing by one point if it is your lowest tradeskill; 25-second cast, 23-hour cooldown. Field Guide reduces the cooldown for placing fishing camp features. Learn these through the Legacy system; consult its current rank tooltips for higher-rank values.",
        ["heading"] = {"gear.reference.heading.legacy"},
        ["body"] = {"gear.reference.overview.legacy", "Luremaster", "Working Overtime", "Dedicated Study", "Field Guide"}
    },
    ["Forever buffs and useful tools"] = {
        ["raw"] = "Buffs, camp contributions and utility effects are separate from permanent equipment bonuses.",
        ["heading"] = {"gear.reference.heading.tools"},
        ["body"] = {"gear.reference.overview.tools"}
    },
    ["Additional pole and bait references"] = {
        ["raw"] = "These entries are not confirmed shopping or catch routes. Current acquisition or availability remains unverified.",
        ["heading"] = {"gear.reference.heading.additional"},
        ["body"] = {"gear.reference.overview.additional"}
    },
    ["Set up your Gear button"] = {
        ["raw"] = "Forever Fishing picks the strongest fishing pole and clothing that raises Fishing skill from your bags or equipped slots. Use the Gear arrow to change items, or drag a missed item onto the icon. Click Gear to equip your picks; click again to restore your previous items. The gold glow means some selected gear is not equipped.",
        ["heading"] = {"gear.reference.heading.setup", {
            ["textKey"] = "flyout.gear"
        }},
        ["body"] = {"gear.reference.overview.setup", {
            ["textKey"] = "flyout.gear"
        }, {
            ["textKey"] = "flyout.gear"
        }}
    }
}
local gearCoreText = {
    ["12225"] = {
        ["id"] = 12225,
        ["name"] = "Blump Family Fishing Pole",
        ["benefit"] = {
            ["raw"] = "+3 Fishing · equipped pole",
            ["spec"] = {"gear.reference.bonus.equipped-pole", 3}
        },
        ["requirements"] = {
            ["raw"] = "Fishing 1; quest requires Level 10.",
            ["spec"] = {"gear.reference.requires.quest", {
                ["textKey"] = "skill.display.value",
                ["values"] = {1},
                ["profession"] = "Fishing",
                ["required"] = 1,
                ["fieldGuide"] = true
            }, 10}
        }
    },
    ["6365"] = {
        ["id"] = 6365,
        ["name"] = "Strong Fishing Pole",
        ["benefit"] = {
            ["raw"] = "+5 Fishing · equipped pole",
            ["spec"] = {"gear.reference.bonus.equipped-pole", 5}
        },
        ["requirements"] = {
            ["raw"] = "Level 5 · Fishing 10.",
            ["spec"] = {"gear.reference.requires.level-fishing", 5, {
                ["textKey"] = "skill.display.value",
                ["values"] = {10},
                ["profession"] = "Fishing",
                ["required"] = 10,
                ["fieldGuide"] = true
            }}
        }
    },
    ["6367"] = {
        ["id"] = 6367,
        ["name"] = "Big Iron Fishing Pole",
        ["benefit"] = {
            ["raw"] = "+20 Fishing · equipped pole",
            ["spec"] = {"gear.reference.bonus.equipped-pole", 20}
        },
        ["requirements"] = {
            ["raw"] = "Level 25 · Fishing 100.",
            ["spec"] = {"gear.reference.requires.level-fishing", 25, {
                ["textKey"] = "skill.display.value",
                ["values"] = {100},
                ["profession"] = "Fishing",
                ["required"] = 100,
                ["fieldGuide"] = true
            }}
        }
    },
    ["19970"] = {
        ["id"] = 19970,
        ["name"] = "Arcanite Fishing Pole",
        ["benefit"] = {
            ["raw"] = "+35 Fishing · equipped pole",
            ["spec"] = {"gear.reference.bonus.equipped-pole", 35}
        },
        ["requirements"] = {
            ["raw"] = "Fishing 300.",
            ["spec"] = {"gear.reference.requires.fishing", {
                ["textKey"] = "skill.display.value",
                ["values"] = {300},
                ["profession"] = "Fishing",
                ["required"] = 300,
                ["fieldGuide"] = true
            }}
        }
    },
    ["19022"] = {
        ["id"] = 19022,
        ["name"] = "Nat Pagle's Extreme Angler FC-5000",
        ["benefit"] = {
            ["raw"] = "+25 Fishing · equipped pole",
            ["spec"] = {"gear.reference.bonus.equipped-pole", 25}
        },
        ["requirements"] = {
            ["raw"] = "Fishing 100; quest requires Level 44.",
            ["spec"] = {"gear.reference.requires.quest", {
                ["textKey"] = "skill.display.value",
                ["values"] = {100},
                ["profession"] = "Fishing",
                ["required"] = 100,
                ["fieldGuide"] = true
            }, 44}
        }
    },
    ["6529"] = {
        ["id"] = 6529,
        ["name"] = "Shiny Bauble",
        ["benefit"] = {
            ["raw"] = "+25 Fishing · temporary lure",
            ["spec"] = {"gear.reference.bonus.temporary-lure", 25}
        },
        ["requirements"] = {
            ["raw"] = "Fishing 1.",
            ["spec"] = {"gear.reference.requires.fishing", {
                ["textKey"] = "skill.display.value",
                ["values"] = {1},
                ["profession"] = "Fishing",
                ["required"] = 1,
                ["fieldGuide"] = true
            }}
        }
    },
    ["6530"] = {
        ["id"] = 6530,
        ["name"] = "Nightcrawlers",
        ["benefit"] = {
            ["raw"] = "+50 Fishing · temporary lure",
            ["spec"] = {"gear.reference.bonus.temporary-lure", 50}
        },
        ["requirements"] = {
            ["raw"] = "Fishing 50.",
            ["spec"] = {"gear.reference.requires.fishing", {
                ["textKey"] = "skill.display.value",
                ["values"] = {50},
                ["profession"] = "Fishing",
                ["required"] = 50,
                ["fieldGuide"] = true
            }}
        }
    },
    ["6811"] = {
        ["id"] = 6811,
        ["name"] = "Aquadynamic Fish Lens",
        ["benefit"] = {
            ["raw"] = "+50 Fishing · temporary lure",
            ["spec"] = {"gear.reference.bonus.temporary-lure", 50}
        },
        ["requirements"] = {
            ["raw"] = "Fishing 50.",
            ["spec"] = {"gear.reference.requires.fishing", {
                ["textKey"] = "skill.display.value",
                ["values"] = {50},
                ["profession"] = "Fishing",
                ["required"] = 50,
                ["fieldGuide"] = true
            }}
        }
    },
    ["6532"] = {
        ["id"] = 6532,
        ["name"] = "Bright Baubles",
        ["benefit"] = {
            ["raw"] = "+75 Fishing · temporary lure",
            ["spec"] = {"gear.reference.bonus.temporary-lure", 75}
        },
        ["requirements"] = {
            ["raw"] = "Fishing 100.",
            ["spec"] = {"gear.reference.requires.fishing", {
                ["textKey"] = "skill.display.value",
                ["values"] = {100},
                ["profession"] = "Fishing",
                ["required"] = 100,
                ["fieldGuide"] = true
            }}
        }
    },
    ["7307"] = {
        ["id"] = 7307,
        ["name"] = "Flesh Eating Worm",
        ["benefit"] = {
            ["raw"] = "+75 Fishing · temporary lure",
            ["spec"] = {"gear.reference.bonus.temporary-lure", 75}
        },
        ["requirements"] = {
            ["raw"] = "Fishing 100.",
            ["spec"] = {"gear.reference.requires.fishing", {
                ["textKey"] = "skill.display.value",
                ["values"] = {100},
                ["profession"] = "Fishing",
                ["required"] = 100,
                ["fieldGuide"] = true
            }}
        }
    },
    ["6533"] = {
        ["id"] = 6533,
        ["name"] = "Aquadynamic Fish Attractor",
        ["benefit"] = {
            ["raw"] = "+100 Fishing · temporary lure",
            ["spec"] = {"gear.reference.bonus.temporary-lure", 100}
        },
        ["requirements"] = {
            ["raw"] = "Fishing 100.",
            ["spec"] = {"gear.reference.requires.fishing", {
                ["textKey"] = "skill.display.value",
                ["values"] = {100},
                ["profession"] = "Fishing",
                ["required"] = 100,
                ["fieldGuide"] = true
            }}
        }
    },
    ["6316"] = {
        ["id"] = 6316,
        ["name"] = "Loch Frenzy Delight",
        ["benefit"] = {
            ["raw"] = "+3 Fishing · 15 min",
            ["spec"] = {"gear.reference.bonus.timed", 3, 15}
        },
        ["requirements"] = {
            ["raw"] = "Level 5 to eat · Cooking 50 to prepare.",
            ["spec"] = {"gear.reference.requires.food", 5, {
                ["textKey"] = "skill.display.value",
                ["values"] = {50},
                ["profession"] = "Cooking",
                ["required"] = 50,
                ["fieldGuide"] = true
            }}
        }
    },
    ["5476"] = {
        ["id"] = 5476,
        ["name"] = "Fillet of Frenzy",
        ["benefit"] = {
            ["raw"] = "+5 Fishing · 15 min",
            ["spec"] = {"gear.reference.bonus.timed", 5, 15}
        },
        ["requirements"] = {
            ["raw"] = "Level 5 to eat · Cooking 50 to prepare.",
            ["spec"] = {"gear.reference.requires.food", 5, {
                ["textKey"] = "skill.display.value",
                ["values"] = {50},
                ["profession"] = "Cooking",
                ["required"] = 50,
                ["fieldGuide"] = true
            }}
        }
    },
    ["4593"] = {
        ["id"] = 4593,
        ["name"] = "Bristle Whisker Catfish",
        ["benefit"] = {
            ["raw"] = "+8 Fishing · 15 min",
            ["spec"] = {"gear.reference.bonus.timed", 8, 15}
        },
        ["requirements"] = {
            ["raw"] = "Level 15 to eat · Cooking 100 to prepare.",
            ["spec"] = {"gear.reference.requires.food", 15, {
                ["textKey"] = "skill.display.value",
                ["values"] = {100},
                ["profession"] = "Cooking",
                ["required"] = 100,
                ["fieldGuide"] = true
            }}
        }
    },
    ["4594"] = {
        ["id"] = 4594,
        ["name"] = "Rockscale Cod",
        ["benefit"] = {
            ["raw"] = "+12 Fishing · 15 min",
            ["spec"] = {"gear.reference.bonus.timed", 12, 15}
        },
        ["requirements"] = {
            ["raw"] = "Level 25 to eat · Cooking 175 to prepare.",
            ["spec"] = {"gear.reference.requires.food", 25, {
                ["textKey"] = "skill.display.value",
                ["values"] = {175},
                ["profession"] = "Cooking",
                ["required"] = 175,
                ["fieldGuide"] = true
            }}
        }
    },
    ["13930"] = {
        ["id"] = 13930,
        ["name"] = "Filet of Redgill",
        ["benefit"] = {
            ["raw"] = "+18 Fishing · 15 min",
            ["spec"] = {"gear.reference.bonus.timed", 18, 15}
        },
        ["requirements"] = {
            ["raw"] = "Level 35 to eat · Cooking 225 to prepare.",
            ["spec"] = {"gear.reference.requires.food", 35, {
                ["textKey"] = "skill.display.value",
                ["values"] = {225},
                ["profession"] = "Cooking",
                ["required"] = 225,
                ["fieldGuide"] = true
            }}
        }
    },
    ["8957"] = {
        ["id"] = 8957,
        ["name"] = "Spinefin Halibut",
        ["benefit"] = {
            ["raw"] = "+18 Fishing · 15 min",
            ["spec"] = {"gear.reference.bonus.timed", 18, 15}
        },
        ["requirements"] = {
            ["raw"] = "Level 45.",
            ["spec"] = {"gear.reference.requires.level", 45}
        }
    },
    ["19972"] = {
        ["id"] = 19972,
        ["name"] = "Lucky Fishing Hat",
        ["benefit"] = {
            ["raw"] = "+5 Fishing · equipped hat",
            ["spec"] = {"gear.reference.bonus.equipped-hat", 5}
        }
    },
    ["19969"] = {
        ["id"] = 19969,
        ["name"] = "Nat Pagle's Extreme Anglin' Boots",
        ["benefit"] = {
            ["raw"] = "+5 Fishing · equipped boots",
            ["spec"] = {"gear.reference.bonus.equipped-boots", 5}
        }
    },
    ["19971"] = {
        ["id"] = 19971,
        ["name"] = "High Test Eternium Fishing Line",
        ["benefit"] = {
            ["raw"] = "+5 Fishing · permanent pole enchant",
            ["spec"] = {"gear.reference.bonus.permanent-pole-enchant", 5}
        }
    },
    ["glove-enchant"] = {
        ["name"] = "Enchant Gloves – Fishing",
        ["benefit"] = {
            ["raw"] = "+2 Fishing · permanent glove enchant",
            ["spec"] = {"gear.reference.bonus.permanent-glove-enchant", 2}
        }
    },
    ["286732"] = {
        ["id"] = 286732,
        ["name"] = "Shiny Silver Coin",
        ["benefit"] = {
            ["raw"] = "+30 Fishing · 30 min",
            ["spec"] = {"gear.reference.bonus.timed", 30, 30}
        }
    },
    ["259846"] = {
        ["id"] = 259846,
        ["name"] = "Wide-Brimmed Fishing Hat",
        ["benefit"] = {
            ["raw"] = "+25 Fishing · 10 min temporary lure",
            ["spec"] = {"gear.reference.bonus.timed-lure", 25, 10}
        }
    },
    ["279981"] = {
        ["id"] = 279981,
        ["name"] = "Basic Campfire",
        ["benefit"] = {
            ["raw"] = "Campfire · cooking and camp contributions",
            ["spec"] = {"gear.reference.bonus.campfire"}
        },
        ["requirements"] = {
            ["raw"] = "Cooking 1.",
            ["spec"] = {"gear.reference.requires.cooking", {
                ["textKey"] = "skill.display.value",
                ["values"] = {1},
                ["profession"] = "Cooking",
                ["required"] = 1,
                ["fieldGuide"] = true
            }}
        }
    },
    ["279967"] = {
        ["id"] = 279967,
        ["name"] = "Fish Bowl",
        ["benefit"] = {
            ["raw"] = "Camp buff · seated stats",
            ["spec"] = {"gear.reference.bonus.bowl"}
        },
        ["requirements"] = {
            ["raw"] = "Fishing 20.",
            ["spec"] = {"gear.reference.requires.fishing", {
                ["textKey"] = "skill.display.value",
                ["values"] = {20},
                ["profession"] = "Fishing",
                ["required"] = 20,
                ["fieldGuide"] = true
            }}
        }
    },
    ["279965"] = {
        ["id"] = 279965,
        ["name"] = "Fishing Rack",
        ["benefit"] = {
            ["raw"] = "Uncommon camp catches and Fishing lures · 1 hour",
            ["spec"] = {"gear.reference.bonus.rack"}
        },
        ["requirements"] = {
            ["raw"] = "Fishing 140.",
            ["spec"] = {"gear.reference.requires.fishing", {
                ["textKey"] = "skill.display.value",
                ["values"] = {140},
                ["profession"] = "Fishing",
                ["required"] = 140,
                ["fieldGuide"] = true
            }}
        }
    },
    ["279966"] = {
        ["id"] = 279966,
        ["name"] = "Fishing Hut",
        ["benefit"] = {
            ["raw"] = "Rare camp catches and Fishing lures · 1 hour",
            ["spec"] = {"gear.reference.bonus.hut"}
        },
        ["requirements"] = {
            ["raw"] = "Fishing 300.",
            ["spec"] = {"gear.reference.requires.fishing", {
                ["textKey"] = "skill.display.value",
                ["values"] = {300},
                ["profession"] = "Fishing",
                ["required"] = 300,
                ["fieldGuide"] = true
            }}
        }
    },
    ["273636"] = {
        ["id"] = 273636,
        ["name"] = "Chef's Knife",
        ["benefit"] = {
            ["raw"] = "Prepares Seasonal Fish Steaks · camp ingredient",
            ["spec"] = {"gear.reference.bonus.knife", "Seasonal Fish Steaks"}
        },
        ["requirements"] = {
            ["raw"] = "Level 35 · Fishing 275.",
            ["spec"] = {"gear.reference.requires.level-fishing", 35, {
                ["textKey"] = "skill.display.value",
                ["values"] = {275},
                ["profession"] = "Fishing",
                ["required"] = 275,
                ["fieldGuide"] = true
            }}
        }
    },
    ["19979"] = {
        ["id"] = 19979,
        ["name"] = "Hook of the Master Angler",
        ["benefit"] = {
            ["raw"] = "Fish form · utility",
            ["spec"] = {"gear.reference.bonus.form"}
        }
    },
    ["276274"] = {
        ["id"] = 276274,
        ["name"] = "Surfer Shoes",
        ["benefit"] = {
            ["raw"] = "Water movement · utility",
            ["spec"] = {"gear.reference.bonus.movement"}
        }
    },
    ["285094"] = {
        ["id"] = 285094,
        ["name"] = "Ravaged Fishing Pole",
        ["benefit"] = {
            ["raw"] = "+31 Fishing · equipped pole",
            ["spec"] = {"gear.reference.bonus.equipped-pole", 31}
        },
        ["requirements"] = {
            ["raw"] = "Level 20 · Fishing 50.",
            ["spec"] = {"gear.reference.requires.level-fishing", 20, {
                ["textKey"] = "skill.display.value",
                ["values"] = {50},
                ["profession"] = "Fishing",
                ["required"] = 50,
                ["fieldGuide"] = true
            }}
        }
    },
    ["6366"] = {
        ["id"] = 6366,
        ["name"] = "Darkwood Fishing Pole",
        ["benefit"] = {
            ["raw"] = "+15 Fishing · equipped pole",
            ["spec"] = {"gear.reference.bonus.equipped-pole", 15}
        },
        ["requirements"] = {
            ["raw"] = "Level 15 · Fishing 50.",
            ["spec"] = {"gear.reference.requires.level-fishing", 15, {
                ["textKey"] = "skill.display.value",
                ["values"] = {50},
                ["profession"] = "Fishing",
                ["required"] = 50,
                ["fieldGuide"] = true
            }}
        }
    },
    ["7996"] = {
        ["id"] = 7996,
        ["name"] = "Worn Fishing Hat",
        ["benefit"] = {
            ["raw"] = "+13 Fishing · equipped hat",
            ["spec"] = {"gear.reference.bonus.equipped-hat", 13}
        },
        ["requirements"] = {
            ["raw"] = "Level 15 · Fishing 1.",
            ["spec"] = {"gear.reference.requires.level-fishing", 15, {
                ["textKey"] = "skill.display.value",
                ["values"] = {1},
                ["profession"] = "Fishing",
                ["required"] = 1,
                ["fieldGuide"] = true
            }}
        }
    },
    ["268880"] = {
        ["id"] = 268880,
        ["name"] = "\"Secret\" Bait",
        ["benefit"] = {
            ["raw"] = "+25 Fishing · 10 min temporary lure",
            ["spec"] = {"gear.reference.bonus.timed-lure", 25, 10}
        }
    }
}

function FF:GetGearOverviewText(block,field)
    local raw=block and block[field]
    local record=block and gearOverviewText[block.heading]
    if not record or block.body~=record.raw or not record[field] then return raw,false end
    return self:FormatLocalizedReference(record[field]),self:GetResolvedLocale()~="enUS"
end

function FF:GetGearReferenceDisplayText(entry,field,skills)
    local raw=entry and entry[field]
    local record=entry and gearCoreText[entry.key]
    local spec=record and record[field]
    if not spec or entry.id~=record.id or entry.name~=record.name or raw~=spec.raw then return raw end
    return self:FormatLocalizedReference(spec.spec,skills)
end

function FF:GetGearReferenceSearchText(entry)
    local text={}
    for _,field in ipairs({"benefit","requirements"}) do
        local value=self:GetGearReferenceDisplayText(entry,field)
        if type(value)=="string" then text[#text+1]=value end
    end
    return table.concat(text," ")
end

function FF:GetGearOverviewSearchText(block,faction)
    local text={}
    for _,field in ipairs({"heading","body"}) do
        local value=self:GetGearOverviewText(block,field)
        if type(value)=="string" then text[#text+1]=value end
    end
    for _,entry in ipairs(self:GetJournalGearReferences(block,faction)) do text[#text+1]=self:GetGearReferenceSearchText(entry) end
    return table.concat(text," ")
end

-- Gear details are display-only copies of still-owned canonical field values.
FF.englishStrings["gear.details.supplier"] = "Buy from a fishing supplier."
FF.englishStrings["gear.details.supplier-limited"] = "Buy from a fishing supplier. Stock can be limited."
FF.englishStrings["gear.details.traps"] = "Open underwater %s off %s in %s, or check the Auction House. A pole is not guaranteed."
FF.englishStrings["gear.details.lenses"] = "Complete %s, then %s. Return to %s in %s for 20 × %s."
FF.englishStrings["gear.details.worms"] = "Loot %s in %s. A worm is not guaranteed."
FF.englishStrings["gear.details.engineering"] = "Engineers craft this lure; some fishing suppliers also stock it in limited quantities. Engineering recipe requirements and materials are not verified in this guide."
FF.englishStrings["gear.details.halibut"] = "Buy the prepared food from fish vendors or cook it with %s."
FF.englishStrings["gear.details.line"] = "Apply the line to a pole you plan to keep; this is a permanent upgrade, separate from a temporary lure."
FF.englishStrings["gear.details.gloves"] = "Ask an Enchanter to apply %s to your gloves. Enchanting recipe acquisition and materials are not verified in this guide."
FF.englishStrings["gear.details.coin"] = "For %s, collect 6 %s from the murloc camps on %s's south shore. Return to %s."
FF.englishStrings["gear.details.hat"] = "Use the hat to attach its lure to your equipped pole (10-minute use cooldown). This is not a permanent clothing Fishing bonus. Acquisition and equip requirements are not yet verified."
FF.englishStrings["gear.details.knife"] = "Buy the knife from a fishing supplier. Use it to prepare %s from %s or %s for the %s."
FF.englishStrings["gear.details.form"] = "Check the native item tooltip for form restrictions and cooldown; this is not a permanent Fishing-skill upgrade."
FF.englishStrings["gear.details.movement"] = "Check the native item tooltip for movement restrictions and cooldown; this is not a permanent Fishing-skill upgrade."
FF.englishStrings["gear.details.database"] = "Listed in the current Forever item database; its acquisition source is not yet verified."
FF.englishStrings["gear.details.source-unknown"] = "A current Forever drop or vendor source is not verified."
FF.englishStrings["gear.details.availability"] = "Current availability and acquisition are not verified."
FF.englishStrings["gear.details.bait-unknown"] = "The Forever client records this pole lure. Its acquisition and additional requirements are not verified."
FF.englishStrings["gear.details.bowl-quest"] = "A level 4+ starting-zone camping quest that teaches %s at Fishing %s. Follow the introductory camping chain (%s, then %s), then take %s from your starting-zone camping guide. Alliance guides: %s in %s, %s in %s, or %s in %s. Horde guides: %s in %s, %s in %s, or %s in %s. Skyborne: %s on %s. Finish the quest at its named Fishing trainer. A campfire is required before placing the bowl; learn %s from a Cooking trainer."
FF.englishStrings["gear.details.build-camp"] = "Build a Campfire"
FF.englishStrings["gear.details.camp-placement"] = "%s before placing this contribution."
FF.englishStrings["gear.details.open-chef"] = "View %s in Master Chef"
FF.englishStrings["gear.details.quest-start"] = "Take %s from %s in %s."
FF.englishStrings["gear.details.tournament"] = "During the %s, turn in 40 %s to %s in %s. The first 250 turn-ins per ruleset win an %s and an %s."
FF.englishStrings["gear.details.ingredients"] = "Ingredients: %s."
FF.englishStrings["gear.details.recipe"] = "Recipe: %s."
FF.englishStrings["gear.details.rare-reward"] = "During the %s, fish %s along the %s coast for %s. Take that rare catch to %s beside %s in %s for this reward. A rare catch is not guaranteed."
FF.englishStrings["gear.details.materials"] = "Materials: %s."
FF.englishStrings["gear.details.tool"] = "Tool: %s (not consumed)."
FF.englishStrings["gear.details.exchange"] = "Exchange the coin with %s in %s for %s."

local gearDetailText = {
    ["12225"] = {
        ["Alliance"] = {
            ["name"] = "Blump Family Fishing Pole",
            ["raw"] = "Take The Family and the Fishing Pole from Gubber Blump in Auberdine, Darkshore.\nFish six Darkshore Grouper near Auberdine and return to Gubber Blump.",
            ["lines"] = {{"gear.details.quest-start", "The Family and the Fishing Pole", "Gubber Blump", "Auberdine, Darkshore"}, {"quest.reference.family.summary", "Darkshore Grouper", "Auberdine", "Gubber Blump"}},
            ["id"] = 12225
        }
    },
    ["6365"] = {
        ["Alliance"] = {
            ["name"] = "Strong Fishing Pole",
            ["raw"] = "Buy from a fishing supplier. Stock can be limited.",
            ["lines"] = {{"gear.details.supplier-limited"}},
            ["id"] = 6365
        },
        ["Horde"] = {
            ["name"] = "Strong Fishing Pole",
            ["raw"] = "Buy from a fishing supplier. Stock can be limited.",
            ["lines"] = {{"gear.details.supplier-limited"}},
            ["id"] = 6365
        }
    },
    ["6367"] = {
        ["Alliance"] = {
            ["name"] = "Big Iron Fishing Pole",
            ["raw"] = "Open underwater Shellfish Traps off Shadowprey Village in Desolace, or check the Auction House. A pole is not guaranteed.",
            ["lines"] = {{"gear.details.traps", "Shellfish Traps", "Shadowprey Village", "Desolace"}},
            ["id"] = 6367
        },
        ["Horde"] = {
            ["name"] = "Big Iron Fishing Pole",
            ["raw"] = "Open underwater Shellfish Traps off Shadowprey Village in Desolace, or check the Auction House. A pole is not guaranteed.",
            ["lines"] = {{"gear.details.traps", "Shellfish Traps", "Shadowprey Village", "Desolace"}},
            ["id"] = 6367
        }
    },
    ["19970"] = {
        ["Alliance"] = {
            ["name"] = "Arcanite Fishing Pole",
            ["raw"] = "During the Stranglethorn Fishing Extravaganza, turn in 40 Speckled Tastyfish to Riggle Bassbait in Booty Bay. The first 250 turn-ins per ruleset win an Arcanite Fishing Pole and an Extravagant Extravaganza Coin.",
            ["lines"] = {{"gear.details.tournament", "Stranglethorn Fishing Extravaganza", "Speckled Tastyfish", "Riggle Bassbait", "Booty Bay", "Arcanite Fishing Pole", "Extravagant Extravaganza Coin"}},
            ["id"] = 19970
        },
        ["Horde"] = {
            ["name"] = "Arcanite Fishing Pole",
            ["raw"] = "During the Stranglethorn Fishing Extravaganza, turn in 40 Speckled Tastyfish to Riggle Bassbait in Booty Bay. The first 250 turn-ins per ruleset win an Arcanite Fishing Pole and an Extravagant Extravaganza Coin.",
            ["lines"] = {{"gear.details.tournament", "Stranglethorn Fishing Extravaganza", "Speckled Tastyfish", "Riggle Bassbait", "Booty Bay", "Arcanite Fishing Pole", "Extravagant Extravaganza Coin"}},
            ["id"] = 19970
        }
    },
    ["19022"] = {
        ["Horde"] = {
            ["name"] = "Nat Pagle's Extreme Angler FC-5000",
            ["raw"] = "Take Snapjaws, Mon! from Katoom the Angler in Revantusk Village, The Hinterlands (80.2, 81.4).\nKill 15 Saltwater Snapjaws on the coast north of Revantusk Village, then return to Katoom the Angler.",
            ["lines"] = {{"gear.details.quest-start", "Snapjaws, Mon!", "Katoom the Angler", "Revantusk Village, The Hinterlands (80.2, 81.4)"}, {"quest.reference.snapjaws.summary", 15, "Saltwater Snapjaws", "Revantusk Village", "Katoom the Angler"}},
            ["id"] = 19022
        }
    },
    ["6529"] = {
        ["Alliance"] = {
            ["name"] = "Shiny Bauble",
            ["raw"] = "Buy from a fishing supplier.",
            ["lines"] = {{"gear.details.supplier"}},
            ["id"] = 6529
        },
        ["Horde"] = {
            ["name"] = "Shiny Bauble",
            ["raw"] = "Buy from a fishing supplier.",
            ["lines"] = {{"gear.details.supplier"}},
            ["id"] = 6529
        }
    },
    ["6530"] = {
        ["Alliance"] = {
            ["name"] = "Nightcrawlers",
            ["raw"] = "Buy from a fishing supplier.",
            ["lines"] = {{"gear.details.supplier"}},
            ["id"] = 6530
        },
        ["Horde"] = {
            ["name"] = "Nightcrawlers",
            ["raw"] = "Buy from a fishing supplier.",
            ["lines"] = {{"gear.details.supplier"}},
            ["id"] = 6530
        }
    },
    ["6811"] = {
        ["Alliance"] = {
            ["name"] = "Aquadynamic Fish Lens",
            ["raw"] = "Complete Gaffer Jacks, then Electropellers. Return to Wizbang Cranktoggle in Auberdine for 20 × Aquadynamic Fish Lens.",
            ["lines"] = {{"gear.details.lenses", "Gaffer Jacks", "Electropellers", "Wizbang Cranktoggle", "Auberdine", "Aquadynamic Fish Lens"}},
            ["id"] = 6811
        }
    },
    ["6532"] = {
        ["Alliance"] = {
            ["name"] = "Bright Baubles",
            ["raw"] = "Buy from a fishing supplier.",
            ["lines"] = {{"gear.details.supplier"}},
            ["id"] = 6532
        },
        ["Horde"] = {
            ["name"] = "Bright Baubles",
            ["raw"] = "Buy from a fishing supplier.",
            ["lines"] = {{"gear.details.supplier"}},
            ["id"] = 6532
        }
    },
    ["7307"] = {
        ["Alliance"] = {
            ["name"] = "Flesh Eating Worm",
            ["raw"] = "Loot Rotted Ones in Duskwood. A worm is not guaranteed.",
            ["lines"] = {{"gear.details.worms", "Rotted Ones", "Duskwood"}},
            ["id"] = 7307
        },
        ["Horde"] = {
            ["name"] = "Flesh Eating Worm",
            ["raw"] = "Loot Rotted Ones in Duskwood. A worm is not guaranteed.",
            ["lines"] = {{"gear.details.worms", "Rotted Ones", "Duskwood"}},
            ["id"] = 7307
        }
    },
    ["6533"] = {
        ["Alliance"] = {
            ["name"] = "Aquadynamic Fish Attractor",
            ["raw"] = "Engineers craft this lure; some fishing suppliers also stock it in limited quantities. Engineering recipe requirements and materials are not verified in this guide.",
            ["lines"] = {{"gear.details.engineering"}},
            ["id"] = 6533
        },
        ["Horde"] = {
            ["name"] = "Aquadynamic Fish Attractor",
            ["raw"] = "Engineers craft this lure; some fishing suppliers also stock it in limited quantities. Engineering recipe requirements and materials are not verified in this guide.",
            ["lines"] = {{"gear.details.engineering"}},
            ["id"] = 6533
        }
    },
    ["6316"] = {
        ["Alliance"] = {
            ["name"] = "Loch Frenzy Delight",
            ["raw"] = "Ingredients: Raw Loch Frenzy, Mild Spices.\nRecipe: Khara Deepwater in Loch Modan.",
            ["lines"] = {{"gear.details.ingredients", "Raw Loch Frenzy, Mild Spices"}, {"gear.details.recipe", {
                ["nested"] = {"chef.reference.meal.6316.Alliance.recipe", "Khara Deepwater", "Loch Modan"}
            }}},
            ["id"] = 6316
        },
        ["Horde"] = {
            ["name"] = "Loch Frenzy Delight",
            ["raw"] = "Ingredients: Raw Loch Frenzy, Mild Spices.\nRecipe: Check the neutral Auction House.",
            ["lines"] = {{"gear.details.ingredients", "Raw Loch Frenzy, Mild Spices"}, {"gear.details.recipe", {
                ["nested"] = {"chef.reference.meal.5476.Horde.recipe"}
            }}},
            ["id"] = 6316
        }
    },
    ["5476"] = {
        ["Alliance"] = {
            ["name"] = "Fillet of Frenzy",
            ["raw"] = "Ingredients: Soft Frenzy Flesh, Mild Spices.\nRecipe: Laird in Auberdine, Darkshore.\nIts fish ingredient comes from Frenzy creatures, rather than a fishing cast.",
            ["lines"] = {{"gear.details.ingredients", "Soft Frenzy Flesh, Mild Spices"}, {"gear.details.recipe", {
                ["nested"] = {"chef.reference.meal.5476.Alliance.recipe", "Laird", "Auberdine", "Darkshore"}
            }}, {"chef.reference.meal.5476.extra"}},
            ["id"] = 5476
        },
        ["Horde"] = {
            ["name"] = "Fillet of Frenzy",
            ["raw"] = "Ingredients: Soft Frenzy Flesh, Mild Spices.\nRecipe: Check the neutral Auction House.\nIts fish ingredient comes from Frenzy creatures, rather than a fishing cast.",
            ["lines"] = {{"gear.details.ingredients", "Soft Frenzy Flesh, Mild Spices"}, {"gear.details.recipe", {
                ["nested"] = {"chef.reference.meal.5476.Horde.recipe"}
            }}, {"chef.reference.meal.5476.extra"}},
            ["id"] = 5476
        }
    },
    ["4593"] = {
        ["Alliance"] = {
            ["name"] = "Bristle Whisker Catfish",
            ["raw"] = "Ingredients: Raw Bristle Whisker Catfish.\nRecipe: Fishing suppliers in Stormwind and other cities.",
            ["lines"] = {{"gear.details.ingredients", "Raw Bristle Whisker Catfish"}, {"gear.details.recipe", {
                ["nested"] = {"chef.reference.meal.4593.Alliance.recipe", "Stormwind"}
            }}},
            ["id"] = 4593
        },
        ["Horde"] = {
            ["name"] = "Bristle Whisker Catfish",
            ["raw"] = "Ingredients: Raw Bristle Whisker Catfish.\nRecipe: Fishing suppliers in Thunder Bluff and other cities.",
            ["lines"] = {{"gear.details.ingredients", "Raw Bristle Whisker Catfish"}, {"gear.details.recipe", {
                ["nested"] = {"chef.reference.meal.4593.Horde.recipe", "Thunder Bluff"}
            }}},
            ["id"] = 4593
        }
    },
    ["4594"] = {
        ["Alliance"] = {
            ["name"] = "Rockscale Cod",
            ["raw"] = "Ingredients: Raw Rockscale Cod.\nRecipe: Kelsey Yance in Booty Bay; also sold by regional fishing suppliers.",
            ["lines"] = {{"gear.details.ingredients", "Raw Rockscale Cod"}, {"gear.details.recipe", {
                ["nested"] = {"chef.reference.meal.8364.recipe", "Kelsey Yance", "Booty Bay"}
            }}},
            ["id"] = 4594
        },
        ["Horde"] = {
            ["name"] = "Rockscale Cod",
            ["raw"] = "Ingredients: Raw Rockscale Cod.\nRecipe: Kelsey Yance in Booty Bay; also sold by regional fishing suppliers.",
            ["lines"] = {{"gear.details.ingredients", "Raw Rockscale Cod"}, {"gear.details.recipe", {
                ["nested"] = {"chef.reference.meal.8364.recipe", "Kelsey Yance", "Booty Bay"}
            }}},
            ["id"] = 4594
        }
    },
    ["13930"] = {
        ["Alliance"] = {
            ["name"] = "Filet of Redgill",
            ["raw"] = "Ingredients: Raw Redgill.\nRecipe: Kelsey Yance in Booty Bay.",
            ["lines"] = {{"gear.details.ingredients", "Raw Redgill"}, {"gear.details.recipe", {
                ["nested"] = {"chef.reference.meal.13927.recipe", "Kelsey Yance", "Booty Bay"}
            }}},
            ["id"] = 13930
        },
        ["Horde"] = {
            ["name"] = "Filet of Redgill",
            ["raw"] = "Ingredients: Raw Redgill.\nRecipe: Kelsey Yance in Booty Bay.",
            ["lines"] = {{"gear.details.ingredients", "Raw Redgill"}, {"gear.details.recipe", {
                ["nested"] = {"chef.reference.meal.13927.recipe", "Kelsey Yance", "Booty Bay"}
            }}},
            ["id"] = 13930
        }
    },
    ["8957"] = {
        ["Alliance"] = {
            ["name"] = "Spinefin Halibut",
            ["raw"] = "Buy the prepared food from fish vendors or cook it with Raw Spinefin Halibut.",
            ["lines"] = {{"gear.details.halibut", "Raw Spinefin Halibut"}},
            ["id"] = 8957
        },
        ["Horde"] = {
            ["name"] = "Spinefin Halibut",
            ["raw"] = "Buy the prepared food from fish vendors or cook it with Raw Spinefin Halibut.",
            ["lines"] = {{"gear.details.halibut", "Raw Spinefin Halibut"}},
            ["id"] = 8957
        }
    },
    ["19972"] = {
        ["Alliance"] = {
            ["name"] = "Lucky Fishing Hat",
            ["raw"] = "During the Stranglethorn Fishing Extravaganza, fish Schools of Tastyfish along the Stranglethorn coast for Keefer's Angelfish. Take that rare catch to Fishbot 5000 beside Riggle Bassbait in Booty Bay for this reward. A rare catch is not guaranteed.",
            ["lines"] = {{"gear.details.rare-reward", "Stranglethorn Fishing Extravaganza", "Schools of Tastyfish", "Stranglethorn", "Keefer's Angelfish", "Fishbot 5000", "Riggle Bassbait", "Booty Bay"}},
            ["id"] = 19972
        },
        ["Horde"] = {
            ["name"] = "Lucky Fishing Hat",
            ["raw"] = "During the Stranglethorn Fishing Extravaganza, fish Schools of Tastyfish along the Stranglethorn coast for Keefer's Angelfish. Take that rare catch to Fishbot 5000 beside Riggle Bassbait in Booty Bay for this reward. A rare catch is not guaranteed.",
            ["lines"] = {{"gear.details.rare-reward", "Stranglethorn Fishing Extravaganza", "Schools of Tastyfish", "Stranglethorn", "Keefer's Angelfish", "Fishbot 5000", "Riggle Bassbait", "Booty Bay"}},
            ["id"] = 19972
        }
    },
    ["19969"] = {
        ["Alliance"] = {
            ["name"] = "Nat Pagle's Extreme Anglin' Boots",
            ["raw"] = "During the Stranglethorn Fishing Extravaganza, fish Schools of Tastyfish along the Stranglethorn coast for Brownell's Blue Striped Racer. Take that rare catch to Fishbot 5000 beside Riggle Bassbait in Booty Bay for this reward. A rare catch is not guaranteed.",
            ["lines"] = {{"gear.details.rare-reward", "Stranglethorn Fishing Extravaganza", "Schools of Tastyfish", "Stranglethorn", "Brownell's Blue Striped Racer", "Fishbot 5000", "Riggle Bassbait", "Booty Bay"}},
            ["id"] = 19969
        },
        ["Horde"] = {
            ["name"] = "Nat Pagle's Extreme Anglin' Boots",
            ["raw"] = "During the Stranglethorn Fishing Extravaganza, fish Schools of Tastyfish along the Stranglethorn coast for Brownell's Blue Striped Racer. Take that rare catch to Fishbot 5000 beside Riggle Bassbait in Booty Bay for this reward. A rare catch is not guaranteed.",
            ["lines"] = {{"gear.details.rare-reward", "Stranglethorn Fishing Extravaganza", "Schools of Tastyfish", "Stranglethorn", "Brownell's Blue Striped Racer", "Fishbot 5000", "Riggle Bassbait", "Booty Bay"}},
            ["id"] = 19969
        }
    },
    ["19971"] = {
        ["Alliance"] = {
            ["name"] = "High Test Eternium Fishing Line",
            ["raw"] = "During the Stranglethorn Fishing Extravaganza, fish Schools of Tastyfish along the Stranglethorn coast for Dezian Queenfish. Take that rare catch to Fishbot 5000 beside Riggle Bassbait in Booty Bay for this reward. A rare catch is not guaranteed.\nApply the line to a pole you plan to keep; this is a permanent upgrade, separate from a temporary lure.",
            ["lines"] = {{"gear.details.rare-reward", "Stranglethorn Fishing Extravaganza", "Schools of Tastyfish", "Stranglethorn", "Dezian Queenfish", "Fishbot 5000", "Riggle Bassbait", "Booty Bay"}, {"gear.details.line"}},
            ["id"] = 19971
        },
        ["Horde"] = {
            ["name"] = "High Test Eternium Fishing Line",
            ["raw"] = "During the Stranglethorn Fishing Extravaganza, fish Schools of Tastyfish along the Stranglethorn coast for Dezian Queenfish. Take that rare catch to Fishbot 5000 beside Riggle Bassbait in Booty Bay for this reward. A rare catch is not guaranteed.\nApply the line to a pole you plan to keep; this is a permanent upgrade, separate from a temporary lure.",
            ["lines"] = {{"gear.details.rare-reward", "Stranglethorn Fishing Extravaganza", "Schools of Tastyfish", "Stranglethorn", "Dezian Queenfish", "Fishbot 5000", "Riggle Bassbait", "Booty Bay"}, {"gear.details.line"}},
            ["id"] = 19971
        }
    },
    ["glove-enchant"] = {
        ["Alliance"] = {
            ["name"] = "Enchant Gloves – Fishing",
            ["raw"] = "Ask an Enchanter to apply Enchant Gloves – Fishing to your gloves. Enchanting recipe acquisition and materials are not verified in this guide.",
            ["lines"] = {{"gear.details.gloves", "Enchant Gloves – Fishing"}}
        },
        ["Horde"] = {
            ["name"] = "Enchant Gloves – Fishing",
            ["raw"] = "Ask an Enchanter to apply Enchant Gloves – Fishing to your gloves. Enchanting recipe acquisition and materials are not verified in this guide.",
            ["lines"] = {{"gear.details.gloves", "Enchant Gloves – Fishing"}}
        }
    },
    ["286732"] = {
        ["Alliance"] = {
            ["name"] = "Shiny Silver Coin",
            ["raw"] = "For Bottles and Baubles, collect 6 Shiny Junk from the murloc camps on Crystal Lake's south shore. Return to Lee Brown.",
            ["lines"] = {{"gear.details.coin", "Bottles and Baubles", "Shiny Junk", "Crystal Lake", "Lee Brown"}},
            ["id"] = 286732
        },
        ["Horde"] = {
            ["name"] = "Shiny Silver Coin",
            ["raw"] = "For Bottles and Baubles, collect 6 Shiny Junk from the murloc camps on Crystal Lake's south shore. Return to Lee Brown.",
            ["lines"] = {{"gear.details.coin", "Bottles and Baubles", "Shiny Junk", "Crystal Lake", "Lee Brown"}},
            ["id"] = 286732
        }
    },
    ["259846"] = {
        ["Alliance"] = {
            ["name"] = "Wide-Brimmed Fishing Hat",
            ["raw"] = "Use the hat to attach its lure to your equipped pole (10-minute use cooldown). This is not a permanent clothing Fishing bonus. Acquisition and equip requirements are not yet verified.",
            ["lines"] = {{"gear.details.hat"}},
            ["id"] = 259846
        },
        ["Horde"] = {
            ["name"] = "Wide-Brimmed Fishing Hat",
            ["raw"] = "Use the hat to attach its lure to your equipped pole (10-minute use cooldown). This is not a permanent clothing Fishing bonus. Acquisition and equip requirements are not yet verified.",
            ["lines"] = {{"gear.details.hat"}},
            ["id"] = 259846
        }
    },
    ["279981"] = {
        ["Alliance"] = {
            ["name"] = "Basic Campfire",
            ["raw"] = "Learn Cooking and craft with Simple Wood and Flint and Tinder.\nMaterials: 1 Simple Wood.\nTool: Flint and Tinder (not consumed).\nCook at the fire and add up to 3 camp features, one per player. Sit or craft nearby for 1 min to gain camp benefits.",
            ["lines"] = {{"chef.reference.camp.279981.source", "Simple Wood", "Flint and Tinder"}, {"gear.details.materials", "1 Simple Wood"}, {"gear.details.tool", "Flint and Tinder"}, {"chef.reference.camp.279981.benefit"}},
            ["id"] = 279981
        },
        ["Horde"] = {
            ["name"] = "Basic Campfire",
            ["raw"] = "Learn Cooking and craft with Simple Wood and Flint and Tinder.\nMaterials: 1 Simple Wood.\nTool: Flint and Tinder (not consumed).\nCook at the fire and add up to 3 camp features, one per player. Sit or craft nearby for 1 min to gain camp benefits.",
            ["lines"] = {{"chef.reference.camp.279981.source", "Simple Wood", "Flint and Tinder"}, {"gear.details.materials", "1 Simple Wood"}, {"gear.details.tool", "Flint and Tinder"}, {"chef.reference.camp.279981.benefit"}},
            ["id"] = 279981
        }
    },
    ["279967"] = {
        ["Alliance"] = {
            ["name"] = "Fish Bowl",
            ["raw"] = "A level 4+ starting-zone camping quest that teaches Fish Bowl at Fishing 20. Follow the introductory camping chain (The Adventurer, then The Great Outdoors), then take Camping 101: Fishing from your starting-zone camping guide. Alliance guides: Sam Sarsaparilla in Elwynn Forest, Eric Brighthammer in Dun Morogh, or Lyreena Duskblade in Teldrassil. Horde guides: Brakk in Durotar, Eleanor Shackleton in Tirisfal Glades, or Kaga Wildhoof in Mulgore. Skyborne: Raan Wildwind on Zephras Isle. Finish the quest at its named Fishing trainer. A campfire is required before placing the bowl; learn Basic Campfire from a Cooking trainer.\nMaterials: 1 Raw Brilliant Smallfish, 1 Empty Vial.\nPlace beside a Campfire. Nearby seated players gain 8% more stats; this does not stack with Blessing of Kings.\nBuild a Campfire before placing this contribution.",
            ["lines"] = {{"gear.details.bowl-quest", "Fish Bowl", {
                ["textKey"] = "skill.display.value",
                ["values"] = {20},
                ["profession"] = "Fishing",
                ["required"] = 20,
                ["fieldGuide"] = true
            }, "The Adventurer", "The Great Outdoors", "Camping 101: Fishing", "Sam Sarsaparilla", "Elwynn Forest", "Eric Brighthammer", "Dun Morogh", "Lyreena Duskblade", "Teldrassil", "Brakk", "Durotar", "Eleanor Shackleton", "Tirisfal Glades", "Kaga Wildhoof", "Mulgore", "Raan Wildwind", "Zephras Isle", "Basic Campfire"}, {"gear.details.materials", "1 Raw Brilliant Smallfish, 1 Empty Vial"}, {"chef.reference.camp.279967.benefit", "Blessing of Kings"}, {"gear.details.camp-placement", {
                ["textKey"] = "gear.details.build-camp"
            }}},
            ["id"] = 279967
        },
        ["Horde"] = {
            ["name"] = "Fish Bowl",
            ["raw"] = "A level 4+ starting-zone camping quest that teaches Fish Bowl at Fishing 20. Follow the introductory camping chain (The Adventurer, then The Great Outdoors), then take Camping 101: Fishing from your starting-zone camping guide. Alliance guides: Sam Sarsaparilla in Elwynn Forest, Eric Brighthammer in Dun Morogh, or Lyreena Duskblade in Teldrassil. Horde guides: Brakk in Durotar, Eleanor Shackleton in Tirisfal Glades, or Kaga Wildhoof in Mulgore. Skyborne: Raan Wildwind on Zephras Isle. Finish the quest at its named Fishing trainer. A campfire is required before placing the bowl; learn Basic Campfire from a Cooking trainer.\nMaterials: 1 Raw Brilliant Smallfish, 1 Empty Vial.\nPlace beside a Campfire. Nearby seated players gain 8% more stats; this does not stack with Blessing of Kings.\nBuild a Campfire before placing this contribution.",
            ["lines"] = {{"gear.details.bowl-quest", "Fish Bowl", {
                ["textKey"] = "skill.display.value",
                ["values"] = {20},
                ["profession"] = "Fishing",
                ["required"] = 20,
                ["fieldGuide"] = true
            }, "The Adventurer", "The Great Outdoors", "Camping 101: Fishing", "Sam Sarsaparilla", "Elwynn Forest", "Eric Brighthammer", "Dun Morogh", "Lyreena Duskblade", "Teldrassil", "Brakk", "Durotar", "Eleanor Shackleton", "Tirisfal Glades", "Kaga Wildhoof", "Mulgore", "Raan Wildwind", "Zephras Isle", "Basic Campfire"}, {"gear.details.materials", "1 Raw Brilliant Smallfish, 1 Empty Vial"}, {"chef.reference.camp.279967.benefit", "Blessing of Kings"}, {"gear.details.camp-placement", {
                ["textKey"] = "gear.details.build-camp"
            }}},
            ["id"] = 279967
        }
    },
    ["279965"] = {
        ["Alliance"] = {
            ["name"] = "Fishing Rack",
            ["raw"] = "Blueprint: Fishing Rack drops from Gelihast in Blackfathom Deeps.\nMaterials: 2 Simple Wood, 1 Crystal Vial, 2 Raw Mithril Head Trout.\nAt a campfire, grants 1 hr of access to uncommon catches and offers lures to everyone. Improves your chance of catching bloated fish. Can replace a Fish Bowl, keeping its benefits.\nBuild a Campfire before placing this contribution.",
            ["lines"] = {{"chef.reference.camp.blueprint-drop", "Blueprint: Fishing Rack", "Gelihast", "Blackfathom Deeps"}, {"gear.details.materials", "2 Simple Wood, 1 Crystal Vial, 2 Raw Mithril Head Trout"}, {"chef.reference.camp.279965.benefit", "Fish Bowl"}, {"gear.details.camp-placement", {
                ["textKey"] = "gear.details.build-camp"
            }}},
            ["id"] = 279965
        },
        ["Horde"] = {
            ["name"] = "Fishing Rack",
            ["raw"] = "Blueprint: Fishing Rack drops from Gelihast in Blackfathom Deeps.\nMaterials: 2 Simple Wood, 1 Crystal Vial, 2 Raw Mithril Head Trout.\nAt a campfire, grants 1 hr of access to uncommon catches and offers lures to everyone. Improves your chance of catching bloated fish. Can replace a Fish Bowl, keeping its benefits.\nBuild a Campfire before placing this contribution.",
            ["lines"] = {{"chef.reference.camp.blueprint-drop", "Blueprint: Fishing Rack", "Gelihast", "Blackfathom Deeps"}, {"gear.details.materials", "2 Simple Wood, 1 Crystal Vial, 2 Raw Mithril Head Trout"}, {"chef.reference.camp.279965.benefit", "Fish Bowl"}, {"gear.details.camp-placement", {
                ["textKey"] = "gear.details.build-camp"
            }}},
            ["id"] = 279965
        }
    },
    ["279966"] = {
        ["Alliance"] = {
            ["name"] = "Fishing Hut",
            ["raw"] = "Blueprint: Fishing Hut drops from Jammal'an the Prophet in Sunken Temple.\nMaterials: 5 Simple Wood, 2 Bolt of Runecloth, 1 Seasonal Fish Steaks.\nAt a campfire, grants 1 hr of access to rare catches and offers Fishing lures. Can replace a Fish Bowl, keeping its benefits.\nBuild a Campfire before placing this contribution.",
            ["lines"] = {{"chef.reference.camp.blueprint-drop", "Blueprint: Fishing Hut", "Jammal'an the Prophet", "Sunken Temple"}, {"gear.details.materials", "5 Simple Wood, 2 Bolt of Runecloth, 1 Seasonal Fish Steaks"}, {"chef.reference.camp.279966.benefit", "Fish Bowl"}, {"gear.details.camp-placement", {
                ["textKey"] = "gear.details.build-camp"
            }}},
            ["id"] = 279966
        },
        ["Horde"] = {
            ["name"] = "Fishing Hut",
            ["raw"] = "Blueprint: Fishing Hut drops from Jammal'an the Prophet in Sunken Temple.\nMaterials: 5 Simple Wood, 2 Bolt of Runecloth, 1 Seasonal Fish Steaks.\nAt a campfire, grants 1 hr of access to rare catches and offers Fishing lures. Can replace a Fish Bowl, keeping its benefits.\nBuild a Campfire before placing this contribution.",
            ["lines"] = {{"chef.reference.camp.blueprint-drop", "Blueprint: Fishing Hut", "Jammal'an the Prophet", "Sunken Temple"}, {"gear.details.materials", "5 Simple Wood, 2 Bolt of Runecloth, 1 Seasonal Fish Steaks"}, {"chef.reference.camp.279966.benefit", "Fish Bowl"}, {"gear.details.camp-placement", {
                ["textKey"] = "gear.details.build-camp"
            }}},
            ["id"] = 279966
        }
    },
    ["273636"] = {
        ["Alliance"] = {
            ["name"] = "Chef's Knife",
            ["raw"] = "Buy the knife from a fishing supplier. Use it to prepare Seasonal Fish Steaks from Raw Summer Bass or Raw Winter Squid for the Fishing Hut.",
            ["lines"] = {{"gear.details.knife", "Seasonal Fish Steaks", "Raw Summer Bass", "Raw Winter Squid", "Fishing Hut"}},
            ["id"] = 273636
        },
        ["Horde"] = {
            ["name"] = "Chef's Knife",
            ["raw"] = "Buy the knife from a fishing supplier. Use it to prepare Seasonal Fish Steaks from Raw Summer Bass or Raw Winter Squid for the Fishing Hut.",
            ["lines"] = {{"gear.details.knife", "Seasonal Fish Steaks", "Raw Summer Bass", "Raw Winter Squid", "Fishing Hut"}},
            ["id"] = 273636
        }
    },
    ["19979"] = {
        ["Alliance"] = {
            ["name"] = "Hook of the Master Angler",
            ["raw"] = "During the Stranglethorn Fishing Extravaganza, turn in 40 Speckled Tastyfish to Riggle Bassbait in Booty Bay. The first 250 turn-ins per ruleset win an Arcanite Fishing Pole and an Extravagant Extravaganza Coin.\nExchange the coin with Jang in Booty Bay for Hook of the Master Angler.\nCheck the native item tooltip for form restrictions and cooldown; this is not a permanent Fishing-skill upgrade.",
            ["lines"] = {{"gear.details.tournament", "Stranglethorn Fishing Extravaganza", "Speckled Tastyfish", "Riggle Bassbait", "Booty Bay", "Arcanite Fishing Pole", "Extravagant Extravaganza Coin"}, {"gear.details.exchange", "Jang", "Booty Bay", "Hook of the Master Angler"}, {"gear.details.form"}},
            ["id"] = 19979
        },
        ["Horde"] = {
            ["name"] = "Hook of the Master Angler",
            ["raw"] = "During the Stranglethorn Fishing Extravaganza, turn in 40 Speckled Tastyfish to Riggle Bassbait in Booty Bay. The first 250 turn-ins per ruleset win an Arcanite Fishing Pole and an Extravagant Extravaganza Coin.\nExchange the coin with Jang in Booty Bay for Hook of the Master Angler.\nCheck the native item tooltip for form restrictions and cooldown; this is not a permanent Fishing-skill upgrade.",
            ["lines"] = {{"gear.details.tournament", "Stranglethorn Fishing Extravaganza", "Speckled Tastyfish", "Riggle Bassbait", "Booty Bay", "Arcanite Fishing Pole", "Extravagant Extravaganza Coin"}, {"gear.details.exchange", "Jang", "Booty Bay", "Hook of the Master Angler"}, {"gear.details.form"}},
            ["id"] = 19979
        }
    },
    ["276274"] = {
        ["Alliance"] = {
            ["name"] = "Surfer Shoes",
            ["raw"] = "During the Stranglethorn Fishing Extravaganza, turn in 40 Speckled Tastyfish to Riggle Bassbait in Booty Bay. The first 250 turn-ins per ruleset win an Arcanite Fishing Pole and an Extravagant Extravaganza Coin.\nExchange the coin with Jang in Booty Bay for Surfer Shoes.\nCheck the native item tooltip for movement restrictions and cooldown; this is not a permanent Fishing-skill upgrade.",
            ["lines"] = {{"gear.details.tournament", "Stranglethorn Fishing Extravaganza", "Speckled Tastyfish", "Riggle Bassbait", "Booty Bay", "Arcanite Fishing Pole", "Extravagant Extravaganza Coin"}, {"gear.details.exchange", "Jang", "Booty Bay", "Surfer Shoes"}, {"gear.details.movement"}},
            ["id"] = 276274
        },
        ["Horde"] = {
            ["name"] = "Surfer Shoes",
            ["raw"] = "During the Stranglethorn Fishing Extravaganza, turn in 40 Speckled Tastyfish to Riggle Bassbait in Booty Bay. The first 250 turn-ins per ruleset win an Arcanite Fishing Pole and an Extravagant Extravaganza Coin.\nExchange the coin with Jang in Booty Bay for Surfer Shoes.\nCheck the native item tooltip for movement restrictions and cooldown; this is not a permanent Fishing-skill upgrade.",
            ["lines"] = {{"gear.details.tournament", "Stranglethorn Fishing Extravaganza", "Speckled Tastyfish", "Riggle Bassbait", "Booty Bay", "Arcanite Fishing Pole", "Extravagant Extravaganza Coin"}, {"gear.details.exchange", "Jang", "Booty Bay", "Surfer Shoes"}, {"gear.details.movement"}},
            ["id"] = 276274
        }
    },
    ["285094"] = {
        ["Alliance"] = {
            ["name"] = "Ravaged Fishing Pole",
            ["raw"] = "Listed in the current Forever item database; its acquisition source is not yet verified.",
            ["lines"] = {{"gear.details.database"}},
            ["id"] = 285094
        },
        ["Horde"] = {
            ["name"] = "Ravaged Fishing Pole",
            ["raw"] = "Listed in the current Forever item database; its acquisition source is not yet verified.",
            ["lines"] = {{"gear.details.database"}},
            ["id"] = 285094
        }
    },
    ["6366"] = {
        ["Alliance"] = {
            ["name"] = "Darkwood Fishing Pole",
            ["raw"] = "A current Forever drop or vendor source is not verified.",
            ["lines"] = {{"gear.details.source-unknown"}},
            ["id"] = 6366
        },
        ["Horde"] = {
            ["name"] = "Darkwood Fishing Pole",
            ["raw"] = "A current Forever drop or vendor source is not verified.",
            ["lines"] = {{"gear.details.source-unknown"}},
            ["id"] = 6366
        }
    },
    ["7996"] = {
        ["Alliance"] = {
            ["name"] = "Worn Fishing Hat",
            ["raw"] = "Current availability and acquisition are not verified.",
            ["lines"] = {{"gear.details.availability"}},
            ["id"] = 7996
        },
        ["Horde"] = {
            ["name"] = "Worn Fishing Hat",
            ["raw"] = "Current availability and acquisition are not verified.",
            ["lines"] = {{"gear.details.availability"}},
            ["id"] = 7996
        }
    },
    ["268880"] = {
        ["Alliance"] = {
            ["name"] = "\"Secret\" Bait",
            ["raw"] = "The Forever client records this pole lure. Its acquisition and additional requirements are not verified.",
            ["lines"] = {{"gear.details.bait-unknown"}},
            ["id"] = 268880
        },
        ["Horde"] = {
            ["name"] = "\"Secret\" Bait",
            ["raw"] = "The Forever client records this pole lure. Its acquisition and additional requirements are not verified.",
            ["lines"] = {{"gear.details.bait-unknown"}},
            ["id"] = 268880
        }
    }
}

local function GearDetailMessage(self,spec,skills,linked)
    local args={spec[1]}
    for index=2,#spec do
        local value=spec[index]
        if type(value)=="table" and value.nested then value=GearDetailMessage(self,value.nested,skills,linked)
        elseif type(value)=="table" and value.textKey=="gear.details.build-camp" and linked and self:GetResolvedLocale()~="enUS" then
            value=self:GuideTargetLink({kind="campinfo",id=279981,label="Build a Campfire"},self:LocalizedText(value.textKey))
        end
        args[#args+1]=value
    end
    return self:FormatLocalizedReference(args,skills)
end

function FF:GetGearDetailDisplayText(entry,faction,skills,linked)
    local raw=entry and entry.details
    local owner=entry and gearDetailText[entry.key]
    local record=owner and owner[faction]
    if not record or entry.id~=record.id or entry.name~=record.name or raw~=record.raw then
        return entry and self:GetJournalGearQuestDetailsText(entry) or raw
    end
    local lines={}
    for index,spec in ipairs(record.lines) do lines[index]=GearDetailMessage(self,spec,skills,linked) end
    return table.concat(lines,"\n")
end

function FF:GetGearDetailSearchText(block,faction)
    local text={}
    for _,entry in ipairs(self:GetJournalGearReferences(block,faction)) do
        text[#text+1]=self:GetGearDetailDisplayText(entry,faction)
    end
    return table.concat(text," ")
end

-- Shared Journal presentation. Native targets and tooltip lifecycle remain canonical.
FF.englishStrings["journal.link.quest-unavailable"] = "Quest details are not yet available."
FF.englishStrings["journal.link.objectives"] = "Objectives"
FF.englishStrings["journal.link.requires"] = "Requires: %s"
FF.englishStrings["journal.link.rewards"] = "Rewards: %s"
FF.englishStrings["journal.link.quest-client-unavailable"] = "Client quest details are unavailable; showing Journal information."
FF.englishStrings["journal.link.item-unavailable"] = "Item information is unavailable."
FF.englishStrings["journal.link.open-catch"] = "Click: open Catch journal"
FF.englishStrings["journal.link.open-chef"] = "Click: open Master Chef"
FF.englishStrings["journal.link.instructions"] = "Click: open the related Journal instructions"
FF.englishStrings["journal.link.click-map"] = "Click: show on map"
FF.englishStrings["journal.link.distance"] = "≈ %d yd"
FF.englishStrings["journal.link.distance-straight"] = "≈ %d yd (straight-line)"
FF.englishStrings["journal.link.distance-unavailable"] = "Distance unavailable"
FF.englishStrings["journal.link.picker-distance"] = "%s (straight-line)"
FF.englishStrings["journal.link.picker-distance-unavailable"] = "? — Distance unavailable for your current position or map."
FF.englishStrings["journal.link.verified-map"] = "Verified map location"
FF.englishStrings["journal.link.other-local"] = "Other local sources"
FF.englishStrings["journal.link.other-sources"] = "Other sources"
FF.englishStrings["journal.link.other-suppliers"] = "Other suppliers"
FF.englishStrings["journal.link.other-trainers"] = "Other trainers"
FF.englishStrings["journal.link.alternatives"] = "Listed in distance order when available. Click to show or hide alternatives."
FF.englishStrings["journal.link.effect-unverified"] = "Verified item effect; acquisition and equip requirements are not yet verified."
FF.englishStrings["journal.link.enchant-unavailable"] = "Native enchant information is unavailable."
FF.englishStrings["journal.link.browse-zone"] = "Browse this zone. Current restores following your location."
FF.englishStrings["journal.link.weighted-catch"] = "Click: open this weighted catch in Catch Journal"
FF.englishStrings["journal.link.show-map"] = "Show on map"
FF.englishStrings["journal.link.book-seller"] = "Book seller"
FF.englishStrings["journal.link.quest-giver"] = "Quest giver"
FF.englishStrings["journal.link.sells"] = "Sells %s."
FF.englishStrings["journal.link.sells-limited"] = "Sells %s (limited stock; live availability unknown)."

function FF:GetJournalSourcePickerTitle(rank)
    local key = rank:sub(1,7)=="Nearby:" and "other-local"
        or (rank:sub(1,5)=="Gear:" or rank:sub(1,12)=="Chef:Recipe:") and "other-sources"
        or rank=="Supplier" and "other-suppliers" or "other-trainers"
    return self:LocalizedText("journal.link."..key)
end

function FF:GetGuideTargetTooltipText(target)
    local raw=target.tooltip
    local record=gearDetailText["279967"].Alliance
    local first=record.raw:match("^[^\n]+")
    if self:GetResolvedLocale()~="enUS" and target.kind=="info" and target.id==97920
        and target.label=="Camping 101: Fishing" and raw==first then
        return GearDetailMessage(self,record.lines[1])
    end
    return raw
end

function FF:GetJournalSourceKindText(point)
    local raw=point.sourceKind or point.rank
    if raw=="Cooking trainer" then return self:LocalizedText("chef.route.trainer") end
    if raw=="Recipe seller" then return self:LocalizedText("chef.route.recipe-seller") end
    if raw=="Book seller" then return self:LocalizedText("journal.link.book-seller") end
    if raw=="Quest giver" then return self:LocalizedText("journal.link.quest-giver") end
    local key=raw and ({Apprentice="apprentice",Journeyman="journeyman",Expert="expert",Artisan="artisan"})[raw]
    return key and self:LocalizedText("information.rank."..key) or raw
end

function FF:GetJournalSourceRoleText(point,rank)
    if point.cookingSource then return self:GetCookingRouteSourceLabel(point.cookingSource) end
    if self:GetResolvedLocale()=="enUS" then return point.roleText end
    local entry=self.journalPanel and self.journalPanel.gearSourceEntries and self.journalPanel.gearSourceEntries[rank]
    if entry and entry.suppliers and point.roleText then
        if point.roleText=="Sells "..entry.name.."." then return self:LocalizedText("journal.link.sells",entry.name) end
        if point.roleText=="Sells "..entry.name.." (limited stock; live availability unknown)." then
            return self:LocalizedText("journal.link.sells-limited",entry.name)
        end
    end
    return self:GetNearbyPointRoleDisplayText(point)
end

function FF:GetJournalSourceServicesText(point)
    if self:GetResolvedLocale()~="enUS" then
        for _,person in ipairs(self.journalPanel and self.journalPanel.nearbyPeople or {}) do
            if person.point==point then
                local text={};for _,service in ipairs(person.services) do text[#text+1]=self:GetNearbyServiceDisplayText(service,"label") end
                return table.concat(text," • ")
            end
        end
    end
    return point.serviceSummary
end

FF.englishStrings["journal.link.book-location"] = "%s, lower %s"
FF.englishStrings["journal.link.quest-location"] = "Island southwest of %s, %s"

function FF:GetJournalSourceLocationText(point)
    local raw=point.location
    if point.name=="Old Man Heming" and point.mapID==1434 and point.x==.274 and point.y==.77
        and raw=="Happy Bobber, lower Booty Bay" then
        return self:LocalizedText("journal.link.book-location","Happy Bobber",self:GetZoneDisplayName("Booty Bay"))
    elseif point.name=="Nat Pagle" and point.mapID==1445 and point.x==.59 and point.y==.60
        and raw=="Island southwest of Theramore, Dustwallow Marsh" then
        return self:LocalizedText("journal.link.quest-location",self:GetZoneDisplayName("Theramore"),self:GetZoneDisplayName("Dustwallow Marsh"))
    end
    return self:LocalizeJournalReferenceText(raw)
end

-- Food display consumes canonical summaries, never translated native-parser input.
FF.englishStrings["food.display.bonus"] = "+%s %s"
FF.englishStrings["food.display.duration"] = "%s (%s)"
FF.englishStrings["food.display.stat.spell-damage"] = "Spell Damage"
FF.englishStrings["food.display.stat.armor"] = "Armor"
FF.englishStrings["food.display.stat.stamina"] = "Stamina"
FF.englishStrings["food.display.stat.spirit"] = "Spirit"
FF.englishStrings["food.display.stat.strength"] = "Strength"
FF.englishStrings["food.display.stat.agility"] = "Agility"
FF.englishStrings["food.display.stat.intellect"] = "Intellect"
FF.englishStrings["food.display.stat.stamina-spirit"] = "Stamina and Spirit"
FF.englishStrings["food.display.stat.movement-speed"] = "movement speed"
FF.englishStrings["food.display.time.sec"] = "%s sec"
FF.englishStrings["food.display.time.secs"] = "%s secs"
FF.englishStrings["food.display.time.min"] = "%s min"
FF.englishStrings["food.display.time.mins"] = "%s mins"
FF.englishStrings["food.display.time.hr"] = "%s hr"
FF.englishStrings["food.display.time.hrs"] = "%s hrs"
FF.englishStrings["food.display.time.hour"] = "%s hour"
FF.englishStrings["food.display.time.hours"] = "%s hours"
FF.englishStrings["food.display.time.day"] = "%s day"
FF.englishStrings["food.display.time.days"] = "%s days"
FF.englishStrings["food.display.health-over"] = "%s health over %s"
FF.englishStrings["food.display.mana-over"] = "%s mana over %s"
FF.englishStrings["food.display.health-mana-over"] = "%s health and %s mana over %s"
FF.englishStrings["food.display.mana-health-over"] = "%s mana and %s health over %s"
FF.englishStrings["food.display.disguise"] = "Ninja or pirate disguise"
FF.englishStrings["food.display.orc-disguise"] = "Orc ninja or pirate disguise"
FF.englishStrings["food.display.bowl"] = "+%s stats while seated (does not stack with %s)"
FF.englishStrings["food.display.bowl-benefits"] = "%s benefits"

local foodStatDisplayKeys={
    ["ap"]="food.attack-power-short",["mp5"]="food.mana-regen-short",["kill xp"]="food.kill-xp-short",
    ["fishing"]="food.fishing-short",["spell damage"]="food.display.stat.spell-damage",["armor"]="food.display.stat.armor",
    ["stamina"]="food.display.stat.stamina",["spirit"]="food.display.stat.spirit",["strength"]="food.display.stat.strength",
    ["agility"]="food.display.stat.agility",["intellect"]="food.display.stat.intellect",
    ["stamina and spirit"]="food.display.stat.stamina-spirit",["movement speed"]="food.display.stat.movement-speed",
}
local foodDurationUnits={sec="sec",secs="secs",second="sec",seconds="secs",min="min",mins="mins",minute="min",minutes="mins",hr="hr",hrs="hrs",hour="hour",hours="hours",day="day",days="days"}
local function FoodDisplayDuration(self,raw)
    local amount,unit=raw:match("^(%d+%.?%d*)%s+(%a+)$")
    unit=unit and unit:lower()
    if amount and foodDurationUnits[unit] then return self:LocalizedText("food.display.time."..foodDurationUnits[unit],self:FormatCanonicalNumericDisplay(amount)) end
end
local function FoodDisplayRestore(self,raw)
    if not raw then return end
    local parts={}
    for text in (raw.."; "):gmatch("(.-); ") do
        local a,b,d=text:lower():match("^(%d+%.?%d*%%?) health and (%d+%.?%d*%%?) mana over (.+)$")
        local key="health-mana-over"
        if not a then a,b,d=text:lower():match("^(%d+%.?%d*%%?) mana and (%d+%.?%d*%%?) health over (.+)$");key="mana-health-over" end
        if not a then a,d=text:lower():match("^(%d+%.?%d*%%?) health over (.+)$");key="health-over" end
        if not a then a,d=text:lower():match("^(%d+%.?%d*%%?) mana over (.+)$");key="mana-over" end
        local duration=d and FoodDisplayDuration(self,d)
        if a and duration then
            text=b and self:LocalizedText("food.display."..key,self:FormatCanonicalNumericDisplay(a),self:FormatCanonicalNumericDisplay(b),duration) or self:LocalizedText("food.display."..key,self:FormatCanonicalNumericDisplay(a),duration)
        end
        parts[#parts+1]=text
    end
    return table.concat(parts,"; ")
end
local function FoodDisplayBonus(self,text,id)
    -- The parser already proved availability. Unknown compact clauses remain literal.
    if id==279967 then
        local amount=text:match("^%+(%d+%.?%d*%%) stats while seated %(does not stack with Blessing of Kings%)$")
        if amount then return self:LocalizedText("food.display.bowl",self:FormatCanonicalNumericDisplay(amount),"Blessing of Kings") end
    elseif id==279965 then
        local duration=text:match("^Catch uncommon fish %((.-)%)$")
        duration=duration and FoodDisplayDuration(self,duration)
        if duration then return self:LocalizedText("food.camp-uncommon-fish",duration) end
        if text=="Fishing skill lures" then return self:LocalizedText("food.camp-lures") end
        if text=="Fish Bowl benefits" then return self:LocalizedText("food.display.bowl-benefits","Fish Bowl") end
    end
    local effect,duration=text:match("^(.-) %((%d+%.?%d*%s+%a+)%)$")
    effect=effect or text
    local amount,stat=effect:match("^%+(%d+%.?%d*%%?) (.+)$")
    local key=stat and foodStatDisplayKeys[stat:lower()]
    local display=key and self:LocalizedText("food.display.bonus",self:FormatCanonicalNumericDisplay(amount),self:LocalizedText(key))
    if not display and id==6657 and effect=="Ninja or pirate disguise" then display=self:LocalizedText("food.display.disguise") end
    if not display and id==251525 and effect=="Orc ninja or pirate disguise" then display=self:LocalizedText("food.display.orc-disguise") end
    local time=duration and FoodDisplayDuration(self,duration)
    if display and (not duration or time) then return time and self:LocalizedText("food.display.duration",display,time) or display end
    return text
end

function FF:GetJournalFoodDisplayEffects(id)
    local raw=self:GetJournalFoodEffects(id)
    if not raw or raw.nativeEffects or self:GetResolvedLocale()=="enUS" then return raw end
    local display={};for key,value in pairs(raw) do display[key]=value end
    id=tonumber(id)
    if not raw.available then
        display.summary=self:LocalizedText((id==279967 or id==279965) and "food.item-effects-unavailable" or "food.effects-unavailable")
        return display
    end
    display.restores=FoodDisplayRestore(self,raw.restores)
    if raw.bonuses then
        local parts={}
        for text in (raw.bonuses.." · "):gmatch("(.-) · ") do parts[#parts+1]=FoodDisplayBonus(self,text,id) end
        display.bonuses=table.concat(parts,self:LocalizedText("food.effect-separator"))
    end
    display.summary=display.bonuses or self:LocalizedText("food.restores-summary",display.restores)
    display.search=raw.search.." "..(display.restores or "").." "..(display.bonuses or "")
    return display
end

-- Remaining Journal chrome is projected after native identities are selected.
FF.englishStrings["journal.chrome.search.catch"] = "Catch Journal"
FF.englishStrings["journal.chrome.search.gear"] = "Gear & Skill • %s"
FF.englishStrings["journal.chrome.search.field"] = "Field Guide"
FF.englishStrings["journal.chrome.search.fishing"] = "Fishing 1–300"
FF.englishStrings["journal.chrome.search.cooking"] = "Cooking guide"
FF.englishStrings["journal.chrome.search.meals"] = "Master Chef • Grilling"
FF.englishStrings["journal.chrome.search.seller"] = "Recipe seller • %s"
FF.englishStrings["journal.chrome.search.camp"] = "Master Chef • Campfire"
FF.englishStrings["journal.chrome.search.session-title"] = "Session stats"
FF.englishStrings["journal.chrome.search.session-context"] = "Current fishing session"
FF.englishStrings["journal.chrome.search.session-terms"] = "Rod time Casts Catches Success rate Catches per hour Average cast to first loot Vendor Auction estimates End Reset History Goals"
FF.englishStrings["journal.chrome.search.lifetime-title"] = "Lifetime stats"
FF.englishStrings["journal.chrome.search.lifetime-context"] = "All recorded fishing"
FF.englishStrings["journal.chrome.search.lifetime-terms"] = "Time fishing Casts Catch count Success rate Catches per hour Average cast to loot Sessions Unique catches Vendor Auction estimates"
FF.englishStrings["journal.chrome.search.nearby-terms"] = "Recipe sellers recorded catches locations"
FF.englishStrings["journal.chrome.search.history.one"] = "Session History • %d catches"
FF.englishStrings["journal.chrome.search.history.other"] = "Session History • %d catches"
FF.englishStrings["journal.chrome.recap"] = "CATCH RECAP"
FF.englishStrings["journal.chrome.source-unavailable"] = "Source unavailable"
FF.englishStrings["journal.chrome.map-click"] = "%.1f, %.1f • Click: show on map"
FF.englishStrings["journal.chrome.item-hash"] = "Item #%s"
FF.englishStrings["journal.chrome.meal-hash"] = "Meal #%s"
FF.englishStrings["journal.chrome.camp-hash"] = "Camp item #%s"
FF.englishStrings["journal.chrome.tool"] = "Tool"
FF.englishStrings["journal.chrome.cooking-fire"] = "Cooking fire"
FF.englishStrings["journal.chrome.not-ready"] = "Not ready"
FF.englishStrings["journal.chrome.skill"] = "%s skill"
FF.englishStrings["journal.chrome.profession-skill"] = "%s %s"
FF.englishStrings["journal.chrome.fish-short"] = "Fish"
FF.englishStrings["journal.chrome.cook-short"] = "Cook"
FF.englishStrings["journal.chrome.search.open-catch"] = "Click: open Catch Journal"

function FF:GetJournalChefSkillText(profession,skill,compact)
    if self:GetResolvedLocale()=="enUS" then
        return (compact and (profession=="Fishing" and "Fish" or profession=="Cooking" and "Cook" or self:UTF8DisplayPrefix(profession,4)) or profession).." "..skill
    end
    local key=profession=="Fishing" and (compact and "journal.chrome.fish-short" or "action.fishing")
        or profession=="Cooking" and (compact and "journal.chrome.cook-short" or "chef.detail.cooking")
    local label=key and self:LocalizedText(key) or (compact and self:UTF8DisplayPrefix(profession,4) or profession)
    return self:LocalizedText("journal.chrome.profession-skill",label,skill)
end

function FF:GetJournalSearchDisplay(key,label,context,destination)
    if self:GetResolvedLocale()=="enUS" then return label,context end
    local simple={
        ["Catch Journal"]="catch",["Field Guide"]="field",["Fishing 1–300"]="fishing",
        ["Cooking guide"]="cooking",["Master Chef • Grilling"]="meals",["Master Chef • Campfire"]="camp",
    }
    local displayContext=context;local terms
    if key:match("^catch:") and context=="Catch Journal" or key=="page:nearby" and context=="Field Guide"
        or key:match("^milestone:") and context=="Fishing 1–300" or key:match("^cooking:") and context=="Cooking guide"
        or key:match("^meal:") and context=="Master Chef • Grilling" or key:match("^camp:") and context=="Master Chef • Campfire" then
        displayContext=self:LocalizedText("journal.chrome.search."..simple[context])
    elseif key:match("^gear:") and destination and destination.heading and context=="Gear & Skill • "..destination.heading then
        local heading=destination.heading
        for _,tab in ipairs(self.guideTabs) do if tab.id=="gear" then for _,block in ipairs(tab.blocks) do
            if block.heading==heading then heading=self:GetGearOverviewText(block,"heading");break end
        end end end
        displayContext=self:LocalizedText("journal.chrome.search.gear",heading)
    elseif key:match("^seller:") and context and context:sub(1,#"Recipe seller • ")=="Recipe seller • " then
        displayContext=self:LocalizedText("journal.chrome.search.seller",context:sub(#"Recipe seller • "+1))
    elseif key:match("^history:") and destination and destination.entry and destination.entry.catches and context=="Session History • "..destination.entry.catches.." catches" then
        displayContext=self:LocalizedPlural("journal.chrome.search.history",destination.entry.catches,destination.entry.catches)
    elseif key:match("^guide:") then
        for _,tab in ipairs(self.guideTabs) do
            local textKey="journal.guide."..tab.id..".title"
            if destination and tab.id==destination.tab and context==tab.title and context==self.englishStrings[textKey] then displayContext=self:GetJournalGuideDisplayText(tab,"title");break end
        end
    end
    if key=="page:session" and label=="Session stats" and context=="Current fishing session" then
        label=self:LocalizedText("journal.chrome.search.session-title");displayContext=self:LocalizedText("journal.chrome.search.session-context")
        terms=self:LocalizedText("journal.chrome.search.session-terms")
    elseif key=="page:lifetime" and label=="Lifetime stats" and context=="All recorded fishing" then
        label=self:LocalizedText("journal.chrome.search.lifetime-title");displayContext=self:LocalizedText("journal.chrome.search.lifetime-context")
        terms=self:LocalizedText("journal.chrome.search.lifetime-terms")
    elseif key=="page:nearby" then terms=self:LocalizedText("journal.chrome.search.nearby-terms") end
    return label,displayContext,terms
end

-- Binding labels are a selected-language view; native keys never pass through it.
FF.englishStrings["binding.display.double-full"] = "Double right click"
FF.englishStrings["binding.display.double-short"] = "Double right"
FF.englishStrings["binding.display.double-tiny"] = "Double RC"
FF.englishStrings["binding.display.double-minimum"] = "2x right"
FF.englishStrings["binding.display.alt"] = "Alt"
FF.englishStrings["binding.display.alt-short"] = "A"
FF.englishStrings["binding.display.ctrl"] = "Ctrl"
FF.englishStrings["binding.display.ctrl-short"] = "C"
FF.englishStrings["binding.display.shift"] = "Shift"
FF.englishStrings["binding.display.shift-short"] = "S"
FF.englishStrings["binding.display.mouse-full"] = "Mouse button %s"
FF.englishStrings["binding.display.mouse-short"] = "Button %s"
FF.englishStrings["binding.display.mouse-tiny"] = "B%s"
FF.englishStrings["binding.display.wheel-up"] = "Wheel up"
FF.englishStrings["binding.display.wheel-up-short"] = "W up"
FF.englishStrings["binding.display.wheel-up-tiny"] = "WU"
FF.englishStrings["binding.display.wheel-down"] = "Wheel down"
FF.englishStrings["binding.display.wheel-down-short"] = "W down"
FF.englishStrings["binding.display.wheel-down-tiny"] = "WD"
FF.englishStrings["binding.display.numpad"] = "Numpad %s"
FF.englishStrings["binding.display.key.space"] = "Space"
FF.englishStrings["binding.display.key.enter"] = "Enter"
FF.englishStrings["binding.display.key.escape"] = "Escape"
FF.englishStrings["binding.display.key.tab"] = "Tab"
FF.englishStrings["binding.display.key.backspace"] = "Backspace"
FF.englishStrings["binding.display.key.delete"] = "Delete"
FF.englishStrings["binding.display.key.insert"] = "Insert"
FF.englishStrings["binding.display.key.home"] = "Home"
FF.englishStrings["binding.display.key.end"] = "End"
FF.englishStrings["binding.display.key.pageup"] = "Pageup"
FF.englishStrings["binding.display.key.pagedown"] = "Pagedown"
FF.englishStrings["binding.display.key.up"] = "Up"
FF.englishStrings["binding.display.key.down"] = "Down"
FF.englishStrings["binding.display.key.left"] = "Left"
FF.englishStrings["binding.display.key.right"] = "Right"
FF.englishStrings["binding.display.key.capslock"] = "Capslock"
FF.englishStrings["binding.display.key.numlock"] = "Numlock"
FF.englishStrings["binding.display.key.scrolllock"] = "Scrolllock"
FF.englishStrings["binding.display.key.pause"] = "Pause"
FF.englishStrings["binding.display.key.printscreen"] = "Printscreen"
FF.englishStrings["binding.display.backspace-short"] = "Bksp"
FF.englishStrings["binding.display.pageup-short"] = "Pg up"
FF.englishStrings["binding.display.pagedown-short"] = "Pg dn"
FF.englishStrings["binding.display.empty"] = "Fishing Key"
FF.englishStrings["binding.display.unbound"] = "Unbound"
FF.englishStrings["session.end.finish-cast"] = "Finish the current cast before ending the session."
FF.englishStrings["session.end.no-character"] = "Could not save this session without a character identity."
FF.englishStrings["session.end.saved"] = "Session saved to history."
FF.englishStrings["session.end.empty"] = "No confirmed catches to save."
FF.englishStrings["runtime.close-stop-cast"] = "Stop casting, then click Close again to restore your weapons."

function FF:GetLocalizedFishingBindingLabels(key)
    local function L(id,...) return self:LocalizedText("binding.display."..id,...) end
    if key==self.doubleRightClickKey then
        return {L("double-full"),L("double-short"),L("double-tiny"),L("double-minimum")},L("double-full"),""
    end
    local base=key:gsub("ALT%-",""):gsub("CTRL%-",""):gsub("SHIFT%-","")
    local fullMods,shortMods={},{}
    for _,modifier in ipairs({{"ALT-","alt"},{"CTRL-","ctrl"},{"SHIFT-","shift"}}) do
        if key:find(modifier[1],1,true) then
            fullMods[#fullMods+1]=L(modifier[2]);shortMods[#shortMods+1]=L(modifier[2].."-short")
        end
    end
    local fullPrefix=#fullMods>0 and table.concat(fullMods," + ").." + " or ""
    local shortPrefix=#shortMods>0 and table.concat(shortMods,"+").."+" or ""
    local fullBase,shortBase,tinyBase
    if base=="MOUSEWHEELUP" or base=="MOUSEWHEELDOWN" then
        local direction=base=="MOUSEWHEELUP" and "wheel-up" or "wheel-down"
        fullBase,shortBase,tinyBase=L(direction),L(direction.."-short"),L(direction.."-tiny")
    elseif base:match("^BUTTON%d+$") then
        local number=base:match("%d+$")
        fullBase,shortBase,tinyBase=L("mouse-full",number),L("mouse-short",number),L("mouse-tiny",number)
    else
        local numpad=base:match("^NUMPAD(.+)$")
        local nameKey="binding.display.key."..(base:gsub("[A-Z]",string.lower))
        if self.englishStrings[nameKey] then fullBase=self:LocalizedText(nameKey)
        elseif numpad then
            local symbols={ADD="+",SUBTRACT="−",MULTIPLY="×",DIVIDE="/",DECIMAL=".",EQUALS="="}
            local part=symbols[numpad] or (numpad=="ENTER" and L("key.enter")) or (numpad:gsub("[A-Z]",string.lower))
            fullBase=L("numpad",part)
        else fullBase=base:find("[\128-\255]") and base or (base:sub(1,1)..base:sub(2):lower()) end
        local compact={BACKSPACE="backspace-short",PAGEUP="pageup-short",PAGEDOWN="pagedown-short"}
        shortBase=compact[base] and L(compact[base]) or fullBase;tinyBase=shortBase
    end
    return {fullPrefix..fullBase,shortPrefix..fullBase,shortPrefix..shortBase,shortPrefix..tinyBase},fullPrefix..fullBase,shortPrefix
end

-- Passive camera guidance; developer controls and machine reasons remain English.
FF.englishStrings["camera.help.marker"] = "Place cursor here • drag to move"
FF.englishStrings["camera.help.title"] = "Getting Started • Camera Backup"
FF.englishStrings["camera.help.hook"] = "At the splash, press |cffb3ddff%s|r to hook."
FF.englishStrings["camera.help.warning"] = "Do not click or move while scanning."
FF.englishStrings["camera.help.cursor"] = "Keep your cursor |cffc9d9e5inside the box|r and keep your mouse still."
FF.englishStrings["camera.help.scan"] = "The experimental scan will try to find the bobber."
FF.englishStrings["camera.help.footer"] = "Tip disappears after your first catch."

-- Current normal runtime display.
FF.englishStrings["lure.choose-tooltip"] = "Choose fishing lure"

-- Display formatting only: never use these strings as input or saved numbers.
FF.englishStrings["format.elapsed.days-hours"] = "%sd %sh"
FF.englishStrings["format.elapsed.hours-minutes"] = "%sh %sm"
FF.englishStrings["format.elapsed.hours-minutes-seconds"] = "%sh %sm %ss"
FF.englishStrings["format.elapsed.minutes-seconds"] = "%sm %ss"
FF.englishStrings["format.display-percent"] = "%s%%"
FF.englishStrings["format.display-seconds"] = "%ss"
FF.englishStrings["format.currency-numbers"] = "%sg %ss %sc"

function FF:FormatDisplayCount(value, compact)
    if self:GetResolvedLocale() == "enUS" then return tostring(value) end
    return self:LocalizedNumber(value, 0, not compact)
end

function FF:FormatElapsedDisplay(seconds, withSeconds)
    seconds = math.max(0, tonumber(seconds) or 0)
    local function Pad(value) return string.format("%02d", value) end
    if not withSeconds and seconds >= 86400 then
        return self:LocalizedText("format.elapsed.days-hours", self:FormatDisplayCount(math.floor(seconds / 86400)), Pad(math.floor(seconds / 3600) % 24))
    end
    if seconds >= 3600 then
        local hours, minutes = self:FormatDisplayCount(math.floor(seconds / 3600)), Pad(math.floor(seconds / 60) % 60)
        if withSeconds then return self:LocalizedText("format.elapsed.hours-minutes-seconds", hours, minutes, Pad(math.floor(seconds) % 60)) end
        return self:LocalizedText("format.elapsed.hours-minutes", hours, minutes)
    end
    return self:LocalizedText("format.elapsed.minutes-seconds", self:FormatDisplayCount(math.floor(seconds / 60)), Pad(math.floor(seconds) % 60))
end

-- Calendar display slots are named so drafts can reorder them safely.
FF.englishStrings["date.month.1"] = "Jan"
FF.englishStrings["date.month.2"] = "Feb"
FF.englishStrings["date.month.3"] = "Mar"
FF.englishStrings["date.month.4"] = "Apr"
FF.englishStrings["date.month.5"] = "May"
FF.englishStrings["date.month.6"] = "Jun"
FF.englishStrings["date.month.7"] = "Jul"
FF.englishStrings["date.month.8"] = "Aug"
FF.englishStrings["date.month.9"] = "Sep"
FF.englishStrings["date.month.10"] = "Oct"
FF.englishStrings["date.month.11"] = "Nov"
FF.englishStrings["date.month.12"] = "Dec"
FF.englishStrings["date.weekday.1"] = "Sun"
FF.englishStrings["date.weekday.2"] = "Mon"
FF.englishStrings["date.weekday.3"] = "Tue"
FF.englishStrings["date.weekday.4"] = "Wed"
FF.englishStrings["date.weekday.5"] = "Thu"
FF.englishStrings["date.weekday.6"] = "Fri"
FF.englishStrings["date.weekday.7"] = "Sat"
FF.englishStrings["date.format.short"] = "{day} {month} {year}"
FF.englishStrings["date.format.long"] = "{day} {month} {year}"
FF.englishStrings["date.format.event"] = "%s %s"
FF.englishStrings["date.format.history"] = "%s • %s"
FF.englishStrings["date.format.range"] = "%s, %s–%s"
FF.englishStrings["date.format.range-cross-day"] = "%s, %s–%s, %s"
FF.englishStrings["date.format.realm-line"] = "%s, %s"
FF.englishStrings["format.display-spaced-seconds"] = "%s s"

local DATE_NATIVE_FORMATS = { short = "%d %b %y", long = "%d %b %Y", history = "%d %b %Y • %H:%M", event = "%a %d %b %Y" }
local function NativeDateText(stamp, style)
    local text = date(DATE_NATIVE_FORMATS[style], stamp)
    if style == "short" then text = text:gsub("^0", "")
    elseif style == "event" then text = text:gsub(" 0(%d )", " %1") end
    return text
end
local function TimestampDisplayParts(stamp)
    if not date then return nil end
    local ok, text = pcall(date, "%Y|%m|%d|%w|%H:%M", stamp)
    if not ok or type(text) ~= "string" then return nil end
    local year, month, day, weekday, clock = text:match("^(%d+)|(%d+)|(%d+)|(%d)|(%d%d:%d%d)$")
    if not year then return nil end
    return {year=tonumber(year),month=tonumber(month),day=tonumber(day),weekday=tonumber(weekday)+1,clock=clock}
end
function FF:FormatDatePartsDisplay(parts, style)
    local fields = { day = tostring(parts.day), month = self:LocalizedText("date.month." .. parts.month),
        year = style == "short" and string.format("%02d", parts.year % 100) or tostring(parts.year) }
    local text = self:LocalizedText(style == "short" and "date.format.short" or "date.format.long")
    text = text:gsub("{([a-z]+)}", function(key) return fields[key] or ("{" .. key .. "}") end)
    if style == "event" then return self:LocalizedText("date.format.event", self:LocalizedText("date.weekday." .. parts.weekday), text) end
    if style == "history" then return self:LocalizedText("date.format.history", text, parts.clock) end
    return text
end
function FF:FormatTimestampDisplay(stamp, style)
    if not stamp or not date then return "—" end
    if self:GetResolvedLocale() == "enUS" then return NativeDateText(stamp, style) end
    local parts = TimestampDisplayParts(stamp)
    if not parts then return NativeDateText(stamp, style) end
    return self:FormatDatePartsDisplay(parts, style)
end
function FF:GetFishingEventTimeDisplay(event)
    local realm = event.realmDate .. ", " .. event.realmTime
    local owned = event.calendarDisplay
    if self:GetResolvedLocale() == "enUS" or type(owned) ~= "table"
        or event.starts ~= owned.starts or event.ends ~= owned.ends
        or event.realmDate ~= owned.realmDate or event.localDateTime ~= owned.localDateTime then
        return realm, event.localDateTime
    end
    local first, last = TimestampDisplayParts(event.starts), TimestampDisplayParts(event.ends)
    if not first or not last then return realm, event.localDateTime end
    realm = self:LocalizedText("date.format.realm-line", self:FormatDatePartsDisplay(owned, "long"), event.realmTime)
    local firstDate = self:FormatDatePartsDisplay(first, "event")
    if first.year == last.year and first.month == last.month and first.day == last.day then
        return realm, self:LocalizedText("date.format.range", firstDate, first.clock, last.clock)
    end
    return realm, self:LocalizedText("date.format.range-cross-day", firstDate, first.clock, self:FormatDatePartsDisplay(last, "event"), last.clock)
end
function FF:FormatGeneralDisplay(value)
    local text = string.format("%g", value)
    local marks = numberMarks[self:GetResolvedLocale()]
    if marks then text = text:gsub("%.", marks[1]) end
    return text
end

-- Final current display consumers; native numbers and parser records stay untouched.
FF.englishStrings["format.coordinates"] = "%s, %s"
FF.englishStrings["format.coordinates-click"] = "%s, %s • Click: show on map"
FF.englishStrings["journal.history-average-number"] = "Avg. cast to loot %ss"

function FF:FormatCoordinateDisplay(x, y, clickHint)
    return self:LocalizedText(clickHint and "format.coordinates-click" or "format.coordinates",
        self:LocalizedNumber(x,1),self:LocalizedNumber(y,1))
end
function FF:FormatCanonicalNumericDisplay(raw)
    -- Only already-recognised display tokens enter here, never native parser input.
    -- Preserve precision/trailing zeros, percent suffix and the canonical record.
    if type(raw) ~= "string" or not raw:match("^%d+%.?%d*%%?$") then return raw end
    local marks = numberMarks[self:GetResolvedLocale()]
    if not marks then return raw end
    local text = raw:gsub("%.", marks[1])
    return text
end

-- Display matching only. Folded offsets are never native identities or byte
-- offsets into a caller's original text: use the explicit whole-character maps.
function FF:FoldGuideLinkText(text)
    if not text:find("[\128-\255]") then return text:lower() end
    local parts, starts, ends, offsets, size = {}, {}, {}, {}, 0
    for at, char in text:gmatch("()([%z\1-\127\194-\244][\128-\191]*)") do
        local folded = (char==" " or char==" " or char=="　") and " " or searchFold[char] or char
        starts[size+1], offsets[at] = at, size+1
        size=size+#folded;ends[size]=at+#char-1
        parts[#parts+1]=folded
    end
    offsets[#text+1]=size+1
    return table.concat(parts), starts, ends, offsets
end

function FF:UTF8DisplayPrefix(text, count)
    local finish, seen = 0, 0
    for at, char in text:gmatch("()([%z\1-\127\194-\244][\128-\191]*)") do
        if seen>=count then break end
        finish=at+#char-1;seen=seen+1
    end
    return text:sub(1,finish)
end

-- Development preview notice; review status never changes saved identities.
FF.englishStrings["language.preview-help"] = "Additional languages are preview translations. Please share any wording or display issues."

-- SetFont(GetFont()) flattens a multilingual family to its Roman member.
-- Resize the existing family instead; the file path is a legacy fallback only.
function FF:SetDisplayFont(font, path, size, flags)
    if font.SetFontHeight and font.SetFontObject then
        if path == "Fonts\\2002.TTF" then
            font:SetFontObject("ForeverFishingSettingsFont")
        elseif path == "Fonts\\ARIALN.TTF" then
            font:SetFontObject("ForeverFishingSansFont")
        elseif flags == "OUTLINE" then
            font:SetFontObject("GameFontNormalLargeOutline")
        elseif flags == "" then
            local _, _, currentFlags = font:GetFont()
            if currentFlags and currentFlags ~= "" then font:SetFontObject("GameFontHighlight") end
        end
        font:SetFontHeight(size)
        return true
    end
    return font:SetFont(path, size, flags)
end

function FF:CopyDisplayFont(target, source, size, flags)
    local path, height, sourceFlags = source:GetFont()
    if target.SetFontHeight and target.SetFontObject and source.GetFontObject then
        local object = source:GetFontObject()
        if object then target:SetFontObject(object) end
    end
    return self:SetDisplayFont(target, path, size or height, flags or sourceFlags)
end

-- Native controller input profile; English-first pending translation.
FF.englishStrings["gamepad.title"] = "Gamepad mode"
FF.englishStrings["gamepad.mode-off"] = "Gamepad mode: Off"
FF.englishStrings["gamepad.mode-on"] = "Gamepad mode: On"
FF.englishStrings["gamepad.help"] = "Use a separate controller profile with either WoW interface. New profiles start with A / Cross. Fishing bindings override WoW actions while the Fishing Bar is open. If Fishing takes over Jump, Advanced Bindings lets you assign a Jump shortcut. The default Close shortcut is LT + B / L2 + Circle when the left trigger is mapped. The optional global Toggle uses a separate button. Native trigger combinations pause during combat. WoW’s overhead marker may show its own Interact button; use the binding shown by Forever Fishing."
FF.englishStrings["gamepad.capture-fishing-prompt"] = "Press a face button, bumper, D-pad direction or stick click. Hold %s, %s or both with a face button, D-pad direction or stick click."
FF.englishStrings["gamepad.capture-prompt"] = "Press a face button, bumper, D-pad direction or stick click."
FF.englishStrings["gamepad.capture-cancel"] = "%s or Esc to cancel"
FF.englishStrings["gamepad.capture-review-cancel"] = "%s, %s or Esc to cancel"
FF.englishStrings["gamepad.capture-action"] = "%s · %s"
FF.englishStrings["gamepad.reserved"] = "Choose a face button, bumper, D-pad direction or stick click. WoW keeps the menu buttons."
FF.englishStrings["gamepad.a-fishing-only"] = "%s is reserved for Jump and the Fishing Key. Choose another button for this shortcut."
FF.englishStrings["gamepad.release-modifiers"] = "Release extra modifiers and try again."
FF.englishStrings["gamepad.fishing-trigger-needs-mapping"] = "Use a trigger assigned to a WoW action-bar modifier in its gamepad interface, or configured as a gamepad modifier in its standard interface."
FF.englishStrings["gamepad.shoulder-modifier"] = "WoW uses this bumper as a modifier. Choose another button or change its WoW modifier assignment."
FF.englishStrings["gamepad.choose-mode"] = "Enable Gamepad mode to assign controller buttons."
FF.englishStrings["gamepad.unavailable"] = "Controller button capture is unavailable in this client."
FF.englishStrings["gamepad.button.up"] = "D-pad Up"
FF.englishStrings["gamepad.button.a"] = "A / Cross"
FF.englishStrings["gamepad.button.down"] = "D-pad Down"
FF.englishStrings["gamepad.button.left"] = "D-pad Left"
FF.englishStrings["gamepad.button.right"] = "D-pad Right"
FF.englishStrings["gamepad.button.left-stick"] = "Left stick click"
FF.englishStrings["gamepad.button.right-stick"] = "Right stick click"

FF.englishStrings["action.close"] = "Close Forever Fishing"
FF.englishStrings["gamepad.capture-chord-prompt"] = "Press a face button, bumper, D-pad direction or stick click. Hold a WoW modifier for a combination."
FF.englishStrings["gamepad.button.b"] = "B / Circle"
FF.englishStrings["gamepad.button.x"] = "X / Square"
FF.englishStrings["gamepad.button.y"] = "Y / Triangle"
FF.englishStrings["gamepad.button.back"] = "Back / Create"
FF.englishStrings["gamepad.modifier.lt"] = "LT / L2"
FF.englishStrings["gamepad.modifier.rt"] = "RT / R2"
FF.englishStrings["gamepad.modifier.lb"] = "LB / L1"
FF.englishStrings["gamepad.modifier.rb"] = "RB / R1"
FF.englishStrings["gamepad.modifier.alt"] = "Alt"
FF.englishStrings["gamepad.modifier.ctrl"] = "Ctrl"
FF.englishStrings["gamepad.modifier.shift"] = "Shift"
FF.englishStrings["gamepad.aim-paused"] = "Mouse active • aim paused"
FF.englishStrings["action.journal"] = "Toggle Fishing Journal"

-- Authored gallery categories, separate from individual client item names.
FF.englishStrings["nearby.family.name.mud-snapper"] = "Mud Snapper"
FF.englishStrings["nearby.family.name.catfish"] = "Catfish"
FF.englishStrings["nearby.family.name.redgill"] = "Redgill"
FF.englishStrings["nearby.family.name.salmon"] = "Salmon"
FF.englishStrings["nearby.family.name.mightfish"] = "Mightfish"
FF.englishStrings["nearby.family.name.yellowtail"] = "Yellowtail"
FF.englishStrings["nearby.pool.wreckage-group"] = "Floating Debris & Wreckage"
FF.englishStrings["nearby.pool.floating-wreckage"] = "Floating Wreckage"
