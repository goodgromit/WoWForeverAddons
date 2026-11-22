# Forever Fishing historical feature notes

The current installable version is specified by `ForeverFishing.toc`. The notes below record earlier development work.

## Male Voice 2

The former Wise Voice option is now named Male Voice 2. It keeps the seven short alert lines and British `bm_george` voice. The clips have been regenerated at a faster speaking pace so the short phrases sound closer to the original longer pack. Existing saved selections continue to work.

## Meal recipe map links and collapse controls

The Recipe line in expanded Meals now opens the world map with temporary marks for its verified sellers. The saved Journal Faction selects Alliance or Horde sources, and recipes with several listed sellers show all their marks together. Marks follow the world map into continent, zone and city views and clear when the map closes. Trainer, drop, Auction House and unconfirmed sources remain plain text where no vendor position is verified. Clicking an expanded meal or its minus control now collapses it.

## Field Guide links and skill steps

Guide link hover no longer rewrites its text, so fish, meal and map links keep their click target as the pointer enters them. Field Guide step headings now colour `Skill 50` and similar requirements using the player's current skill. Step ranges such as `75–150` stay red below the range, yellow from 75 through 149, and turn green at 150. The large `Fishing 1–300` title uses one consistent heading style.

## Journal Faction

General options → Automatic setup now has a Journal Faction dropdown beneath Auto Restore Gear. Auto follows the current character; Alliance and Horde are saved overrides. The choice applies across the journal to faction-specific Field Guide routes, Catch Journal suggested waters and quest notes, and Master Chef recipe sources and Cooking Guide routes. The Cooking Guide's inline faction buttons have been removed. Changing the setting refreshes an open journal and keeps its current tab and scroll position. Shared waters and recipes remain visible where the guide has no verified faction alternative.

## Upcoming Events journal cards

Upcoming Events uses compact framed parchment cards with a warm left accent, stronger event titles, aligned Realm and Local date columns, and right-side expansion controls. Expanded requirements, directions, steps and tips now sit within the same event card under ribbon headings and fine dividers. The existing event times, skill checks, links and scroll-preserving expansion remain in place.

## Field Guide parchment ink

Field Guide titles and ordinary heading text use the journal's brown ink. The skill requirements and ranges in step headings use the player's current skill, with softer olive, ochre and brick colours. Guide links use muted teal ink. Wording, spacing, navigation and map markers are unchanged.

## Journal Back mouse shortcut

Mouse Button 4 now returns through linked Journal pages on release while Back is visible, including when the pointer rests over another Journal control. The temporary override prevents the button's usual action until Back disappears; combat releases the override. The visible Back button remains clickable as before.

## Custom rare catch surrounds

The Catch Journal uses the custom gold surround for its marked rare catches and recorded rare-quality items. The 1 Ring and Steelscale Crushfish use the custom silver surround for ultra-rare catches. Both full-canvas rings sit over the catch icon without cropping or masking their decorative tips, including for undiscovered collection entries. The surrounding artwork comes from the Fishing rare icon folder; its PNG masters and rebuild files remain in the development project rather than the installable addon.

## Male Voice 2 wording

Male Voice 2 speaks the same seven short alert lines as Male Voice, using its British voice. Cursor reminder says only “Place cursor here”; Recast mode still has “Out of range” as its separate cue.

## Single-line Male and Female cursor previews

Previewing Male or Female Voice for Cursor reminder now says only “Place cursor here.” Their live Camera-mode reminder already used that single line. In Recast mode, the same selector is Out of range sound and still uses its separate “Out of range” cue.

## Voice pack cleanup

Pirate Voice has been removed from Notification Sounds and from the bundled audio. Male and Female Voice now say only “No fish hooked” for that fishing failure; their original recordings were trimmed after those words at every voice-volume level.

## Faster first Journal open

The Catch Journal now builds the first nine visible rows immediately and fills the rest in small batches over the following frames. Its full scroll range is available from the start. Cold item-data responses update only the matching fish row instead of redrawing the entire collection for every item. Show all, linked fish, item colours and tooltips, expanded details, and tab navigation keep their existing behaviour.

## Journal Back placement and mouse shortcut

The Journal Back button sits 27 UI units lower beside Close. While Back is visible, Mouse Button 4 temporarily activates it; the player's usual Button 4 action returns when Back disappears. If Button 4 is also the fishing key, Back takes priority only while shown. The temporary binding releases during combat and returns afterward if Back is still visible.

## Journal Back button

Following a fish or meal link to another journal page now reveals a large, gold-edged Back button beside Close. Back returns to the previous page and scroll position, including the Master Chef view you came from. Multiple linked pages can be retraced in order. Choosing a journal tab or Master Chef view manually, or closing the journal, clears the return history. Map links continue to leave the journal ready behind the map and do not create a Back destination.

## Smaller Show all checkbox

The Catch Journal Show all checkbox and checkmark are now 14 × 14 UI units, reduced by six in both directions. Both stay vertically centred beside the label while the click area remains easy to use.

## Catch Journal checkbox and summary

Show all now uses a small custom checkmark inside a fine, even square outline with a lightly tinted parchment interior. The stock checkbox artwork and its oversized border are gone. The catch count, discovered count and fishing-location summary now align to the left edge of the journal heading instead of sitting inset in a wide text field.

## Catch Journal Show all

Show all has no surrounding dark button panel or grey hover fill. Its label uses dark journal ink, and the checked mark uses a contrasting deep green.

## Clean-view Settings window

Turning Hide Blizzard UI While Fishing off from the open Settings window now restores the Blizzard UI after the toggle click finishes. Settings is brought back to the front if the restoration displaced it, so you can continue adjusting options. A rapid Off/On change cancels the pending restore, and closing the fishing bar still restores only the UI state Forever Fishing owns.

## Settings refinements

The compact General fishing-key card places Click to bind to the left of its button. Notification Sounds aligns the three Addon sounds sliders with the three Game sounds sliders. The Scan path selector sits just above the divider at the bottom of its section.

The separate Close camera scan switch has been removed from Experimental. Scan settings → Adaptive (current path) selects the same saved close-range scan profile and keeps its smart adjustment behavior. Existing profile choices and tuning remain saved. The Adaptive name is also used in the camera developer view.

## Four-page Fishing settings

Fishing settings uses four fixed pages: General options, Notification Sounds, Scan settings and Experimental. The dark navy and fine gold layout follows the supplied menu references. General options shows the square Forever Fishing icon beside the fishing key, with Click to bind immediately left of its button. Scan path sits beside its heading. Experimental groups fishing behaviour and the fishing view, with no gamepad option.

Notification Sounds places Sound in Background below Focus splash sound. It adds direct controls for WoW master, ambient and music volume, plus a separate Enable alert sounds switch. When the fishing bar is open, turning Focus splash sound on starts ambient and music at zero; either slider can then be raised for that fishing session. Turning Focus off or closing the bar restores the previous game levels. Turning Focus off and on starts both at zero again. Voice alert volume, idle reminder delay and repeat interval remain adjustable.

If a Fishing cast is attempted without a pole in the main hand, Forever Fishing shows a temporary warning near the top of the screen instead of playing the failed-cast alert. With Auto Equip Gear off, it says “Auto Equip Gear is OFF. Equip your fishing gear manually.” With it on, it says “No fishing rod found. Visit a fishing vendor or add any missed gear to the Gear dropdown.” Idle recast reminders pause while the pole is missing. Other cast failures keep their selected sounds.

The game’s missing-pole error can also show the appropriate warning even if it did not report a cast attempt first. If automatic equipping repeatedly fails for saved fishing gear, the addon shows “Fishing gear not found. If in your bags, add it to the Gear dropdown.” at the top of the screen in place of the former chat message. The gear warnings sit 12 UI units higher than in 0.5.140.

Event sounds are now listed as Cursor reminder, Recast reminder, Catch confirmed and Fish escaped. Fish escaped has its own selection and covers both a fish getting away and a reel made before a fish was hooked. The latter plays a new “No fish hooked” line for each voice. Existing users initially keep their prior catch sound as the new escape sound; the two choices can then be changed independently. The new menu starts centered at a size suited to its four-page layout.

## Wise voice alerts

Voice volume now defaults to 50%. Existing 100% values from the old default move to 50% once; other saved volumes and later manual choices stay as set. The retired Wow Voice selection becomes Male Voice 2. Male Voice 2 uses the same short alerts as Male Voice. Preview and repeat gaps let each line finish before another starts. The clips were generated with the Apache 2.0 licensed Kokoro model; details are in `Media/Voices/ATTRIBUTION.txt`.

## Journal links and return position

Opening a journal map link now leaves the journal ready behind the world map. Closing the map reveals the journal on the same tab and at the same position. The journal also remembers each tab's scroll position when following a fish or meal link and switching back. Linked names and coordinates use a deeper teal for clearer contrast on parchment.

## Catch Recap

Catch Recap is available in General Options and Experimental, and is on by default. When enabled, a small popup lists the items from a confirmed fishing catch and disappears after five seconds. Further items from the same catch join the popup without duplicating those already recorded. The popup stays visible with Forever Fishing when Hide Blizzard UI While Fishing is on, and closes with the Fishing bar. When the clean view is enabled and Catch Recap is off, both settings show the Recommended indicator.

## Hide Blizzard UI While Fishing

Hide Blizzard UI While Fishing is available in General Options and Experimental, and is off by default. Both copies control the same setting without changing Catch Recap. When enabled, opening the Fishing bar hides the main game UI while Forever Fishing's controls and windows remain visible. Closing the bar restores the UI only if Forever Fishing hid it. If the UI was already hidden before opening, the addon leaves it that way. Showing the UI manually during a fishing session keeps it visible until the bar closes; the next session hides it again. The setting can also be changed while the bar is open. Hiding the shared game UI parent can hide other addon windows attached to it; Forever Fishing does not alter those windows individually.

## Upcoming Events layout

Upcoming Events now uses the journal's right aligned plus/minus icons and warmer alternating rows. Event titles are larger and darker, with the realm and local times aligned directly beneath them. Expanded preparation notes sit within a subtle parchment panel and align with the event text.

## Journal skill colors

Required Fishing and Cooking skill values throughout the journal now reflect the character's current profession stats. Red means the requirement is still out of reach; yellow means the minimum is met; green means the character is at least 25 points beyond it (or at the profession cap). Fishing comparisons include equipped and temporary skill bonuses. Leveling route ranges turn green at the upper end of each range. Colors refresh as skills, gear, or auras change. If the client has not provided profession stats, the text keeps its normal color.

## Catch Journal item appearance

Catch names now use their in-game item quality colour, adjusted for contrast on the journal parchment. Uncaught collection entries still show the item tooltip on hover. The Show all checkbox has a light parchment fill, dark check mark and no surrounding button panel. Curated rare fish have a surround drawn from Blizzard's rare target frame artwork, including before discovery; rare-quality recorded catches receive it too. Item colours update when uncached item data arrives.

## Stats icons and spacing

Session and Lifetime stats now use custom Vendor and Auction icons. Their cards and the Session reset area are closer together, so the full stats fit on the journal page without scrolling at the default window size.

## Fishing Guide links

Fish and cooked meals named in the Field Guide now have dark teal links. Hover to see the in game item tooltip. Click a fish to open its Catch Journal entry, or a meal to open its Master Chef entry. Linked NPCs and coordinates open the world map with a temporary pin. Only locations with a known map position are linked. These links preserve the journal's existing parchment layout and do not replace your map waypoint.

## Notification Sounds

The sound settings now start collapsed. Open Notification Sounds to choose alerts, set repeat timing, and adjust voice volume from 0 to 100%. The default is 50%. The volume control changes only the bundled spoken lines; it does not change WoW's sound settings or the built in notification sounds. Each sound selector offers Male, Female and Male Voice 2. Voice clip attribution is in `Media/Voices/ATTRIBUTION.txt`.

## Sound option order

Notification Sounds now lists Cursor reminder (or Out of range), Catch confirmed, then Recast reminder. The idle recast delay remains directly below its selector.

## Shallow water and voice previews

Water too shallow now triggers Failed cast when WoW reports the error during a recent Fishing cast, even if channeling briefly began. Selecting a voice or pressing its preview button plays the appropriate cue for that sound setting. All three voice packs preview only the cursor or out-of-range cue used by the current fishing mode. Recast reminder previews include Recast and Failed cast, and catch sound previews include Catch confirmed and Fish got away. Starting a cast, closing the fishing bar or leaving the settings panel cancels any remaining preview line.

## Catch value per hour

Session stats and Lifetime stats now show Vendor and Auction value per hour beneath each total. Session rates include breaks, matching Catches / hour. Lifetime rates use recorded time spent fishing. Rates update while the stats page is open; missing auction data keeps the existing vendor fallback and asterisk.

## Voice and catch notifications

Notification Sounds now includes Catch confirmed sound. The selectors offer Male, Female and Male Voice 2, with spoken cues for cursor or range reminders, idle recasts, failed casts, confirmed catches and WoW fishing failure messages. The recast sound also plays promptly if a Fishing cast never starts channeling; the idle slider is now named Idle player recast reminder delay. Voice clips are bundled as Ogg files. Their source and licence are documented in `Media/Voices/ATTRIBUTION.txt`.

## Fast Auto Loot

Settings → Experimental now has **Fast Auto Loot**, on by default. While the fishing bar is open, it tries to collect confirmed fishing items as soon as loot is ready. It respects manual loot, checks free bag slots, and leaves uncertain or full bag loot to WoW. It yields to Speedy AutoLoot if that addon is loaded. The normal temporary Auto Loot setting and its restore behavior remain in place. The feature has no timer or idle update loop.

## Master Chef

The Field guide now ends with Master Chef. Meals lists 31 fish and fishable clam recipes, including Forever additions and the two New Avalon feasts. Each food icon uses its normal in-game item tooltip; a meal expands to show skill, ingredients, recipe source and fishing waters. Cooking Guide gives a practical fish-based 1–300 route with an Auto / Alliance / Horde selector. Auto reads the character's faction when the route opens. Recipe sources not yet confirmed in the Forever beta are marked as such. This reference adds no SavedVariables or background updates.

## Catch value fixes

Vendor value now reads Forever's C_Item item data. Missing Auctionator or TSM item quotes use vendor value instead. An asterisk marks a partial auction estimate, and its tooltip shows the vendor value used for items without AH data. The install prompt appears only when neither price API is available.

## Catch journal and layout reset

Show all is now on when the Catch journal first opens. Reset settings also restores the fishing bar, icon bar, Settings window and Journal window to their default positions and scales, including open windows. Catch records, lifetime stats, gear choices and launcher layout remain saved.

## Catch values

Session stats and Lifetime stats show vendor and estimated auction values for recorded catches. Vendor values use WoW item data. Auction values use available Auctionator prices, then TSM DBMarket prices, with vendor value for catches without an AH quote. Prices are looked up when viewing stats and are not saved with catches.

## Field guide

The Fishing poles guide now includes the Blump Family Fishing Pole quest in Auberdine.

## Catch collection

The Catch journal still opens with recorded catches only. Show all reveals uncaught fish and notable items fished directly from the water. Uncaught rows have muted icons and expand to show suggested waters. Catching one turns it into the usual journal row with catch statistics. The summary shows progress through 64 known collection entries. Catches outside the collection remain in the normal journal. Weight variants, one-time quest fish, random equipment, and the contents of opened containers are not collection goals. Quest fish may be impossible to obtain after the quest ends, and a complete Forever server loot table is not publicly available. Locations are leads drawn from Wowhead Forever item records and unchanged Classic fishing records; Forever beta loot can change.

## Temporary Auto Loot

Opening the fishing bar temporarily enables Auto Loot when it was off. Closing the bar restores the player's previous setting. An Auto Loot change made by the player while the bar is open is preserved.

## Fishing gear tooltip

When no rod is equipped or in the bags, the purchase icon now explains where to buy one and how to add gear the addon missed.

## Hide UI support

Alt+Z now leaves Forever Fishing's bar, icon controls and open windows visible while the rest of the game UI is hidden. The shared minimap launcher still follows the minimap's visibility.

## Auto Open option

General Options keeps Auto Open on by default. It opens the fishing bar when a rod is equipped, including at login. Turning it off stops automatic opening without closing a bar that is already open.

## General options order

Automatic Setup contains Auto Open, Auto Equip Gear and Auto Equip Lures on the left; Auto Restore Gear, Hide Lure Glow When Out Of Lures and Journal Faction are on the right. Clean Fishing View contains Hide Blizzard UI While Fishing and Catch Recap. Setting descriptions appear on hover rather than below the rows.

## Smart camera control

Smart camera adjustment is also in `/fish dev`. Selecting Adaptive in Scan settings uses its saved smart adjustment; Long range has its own saved adjustment. The developer control can still be changed while testing a scan profile.

## Rod equipped at login

The fishing bar now checks again when the world and equipped items finish loading, so logging in with a fishing rod opens it without a UI reload. Closing the bar manually still keeps it closed until the equipped rod changes.

## Refined default layout

For a fresh layout, the cast control starts at X −3.0, Y −244.0 at scale 1.000. The four-icon bar starts at X −2.0, Y −329.9 at scale 1.004. Existing saved positions and scales remain in place. The cursor box, Settings window, and Journal window defaults are unchanged.

## Settings icon

The Settings icon uses the original framing from Fishing button bar icons. The other four custom button icons retain their tighter framing from icons2.

## Revised button artwork

Four custom button icons use the tighter framing from Fishing button bar icons2. Settings retains its original framing. Their existing button and panel placements are unchanged.

## Gear and lure lists

Gear and lure lists now inherit the icon bar's scale and stay close to their buttons. If a list would reach the bottom of the screen, it opens above the button, over the fishing bar. On shorter screens, the list shows fewer rows and remains scrollable.

## New defaults

Hide Lure Glow When Out of Lures starts on for new installs and Reset to defaults. Existing saved choices remain in place.

## Fishing rod availability icon

The gear button shows Fishing Rod Purchase when no fishing rod is equipped or in carried bags, including after a rod is sold or moved to the bank. It returns to Fishing Gear when a rod is equipped or carried. Saved fishing gear choices remain intact.

## Auto Restore Gear default

Auto Restore Gear is now on by default for new installs and Reset to defaults. Existing on/off choices remain saved.

## Fishing button artwork

The fishing bar now uses the supplied Fishing Gear, Fishing Rod Purchase, Purchase Lure, Journal, and Settings artwork. Fishing Gear stays on the gear button while gear is available; selected gear items appear only in its list. Purchase icons appear when no gear or lures are available. The Journal and General options headers use the matching new artwork.

## Manual rod gear restore fix

Manually equipping a fishing rod after Auto Restore Gear closes the bar now keeps the previous normal weapons available. The Gear button and a second bar close can restore them. An uncached rod can no longer be recorded as a normal weapon.

## Auto Restore Gear

General options includes **Auto Restore Gear**, on by default. When enabled, closing the fishing bar with its Close button, the Forever minimap launcher, or `/fish` restores the normal gear recorded before Forever Fishing equipped its fishing items. Gear already restored by hand is left equipped. The existing combat restriction and gear restoration safeguards still apply.

## Camera scan profiles

`/fish dev` has five saved scan profiles: Close camera scan, Long range camera, and three test profiles. The first two retain their existing settings. New test profiles start as separate copies of the current Close camera defaults. Each profile saves its own scan speed, coverage, camera view, cursor marker, scan path, and Smart camera settings. Switching profiles stops the current scan and prepares the selected fishing view on the next cast.

Use **Export profile** in `/fish dev` to open a selectable report of the chosen profile's settings. Copy it with Ctrl+C to share test results.

## Window layout defaults

New settings windows start at X −3.1, Y +109.9 with scale 0.829. New journal windows start at X −17.8, Y +129.2 with scale 1.137. Existing saved window layouts remain in place. `/fish changes` uses these positions and scales as its default baseline.

## Escape to close

The Fishing settings and Fishing journal windows now close with Escape through WoW's normal window handling. Their close buttons and saved layouts still work as before.

## Layout report

`/fish changes` now includes the Fishing settings and Fishing journal windows. It reports each window's center position, scale, frame size, and scaled size. Windows that have not been opened use their saved layout or default values without opening them.

## Smart camera defaults

New installs and Reset to defaults use Smart adjust offset trigger **0**, Smart adjust 2nd offset trigger **7**, and Smart adjust 2nd offset **−4.5 lines**. Previously saved choices stay as set.

## Smart adjust offset trigger

`/fish dev` now has **Smart adjust offset trigger**. Set the first scan line where the regular offset can learn a fishing view. Line 0 keeps the previous behavior. A bobber found before both triggers leaves the base view unchanged; the second offset trigger takes priority when reached. Each camera scan profile saves its own setting.

## Smart camera second offset fix

When the first bobber find reaches the second offset trigger, that offset now stays active for later finds at the same fishing position. This prevents a later deep find from switching to the regular offset and pulling the saved view farther down than intended. Moving or resetting Smart camera adjustment clears the choice for the next fishing position.

## Larger stats icons

The custom icons on Session Stats and Lifetime Stats are now 33 UI units wide instead of 25. They sit higher in each card, centered beside the stat title. Metric values and card spacing remain the same.

## Revised stats icons

Catch Count and Catches per Hour now use the revised artwork from Fishing stats icons 2. The two PNG masters were converted to 64-pixel TGAs with the same framing and sharpening settings as the original stats icon pack. The other six stats icons are unchanged.

## Second Smart camera offset

`/fish dev` has **Smart adjust 2nd offset trigger** and **Smart adjust 2nd offset**. On the first bobber find after Smart camera adjustment resets, a find on or below the trigger line selects the second offset for that fishing position. Otherwise, it uses the regular offset. The trigger ranges from line 0 to 24 in whole lines; the second offset ranges from −24 to +24 in 0.25-line steps.

The defaults are trigger line 7 and second offset −4.50. Existing saved choices remain in place. Close and standard camera profiles save both controls separately. Learning still keeps the deepest detected position and never moves an established view upward.

## Custom stats icons

Session Stats and Lifetime Stats now use the eight custom icons from the Fishing stats icons pack. The small card icons use its 64-pixel TGA artwork with full texture coordinates and the journal's existing rounded mask. The metric values and layout are unchanged.

## Smart adjust offset default

New and reset scan profiles use −2.50 lines. Existing saved offsets are kept.

## Lifetime stats page

Removed the update and date note beneath Lifetime stats. The existing metrics and tooltips remain.

## Racetrack turns for testing

`/fish dev` now has a Racetrack turns toggle. It rounds each change between scan lines while keeping the current Width, Vertical spacing, Rows down, Pyramid widening, Scan speed, Smart camera adjustment, and saved fishing view. It starts Off and saves separately for close and standard camera profiles. The old Rounded turns test remains available; selecting it turns Racetrack turns off.

The curved connections run outside the row edges, leaving the full horizontal passes in place. The scanner still pauses when the cursor leaves the marker, stops when it finds the bobber, and returns to the prepared view. Use `/fish dev` → Copy Current State to include the chosen path in a report. Native camera movement and bobber coverage need testing in the Forever beta client.

## Finer Smart adjust offset

Smart adjust offset in `/fish dev` moves in 0.25-line steps from -24 to +24. Values such as -1.75 and -1.5 are saved independently in the close and standard scan profiles. Existing choices remain saved. The developer report shows the exact fractional value.

The offset still applies once to the deepest detected bobber angle. For example, at 3.25° vertical spacing, moving from -2 to -1.75 changes the learned starting tilt by 0.8125°. The camera still changes after the cast ends.

## Deepest smart camera position

Smart camera adjustment now keeps the deepest estimated bobber angle found across casts at the current fishing spot. A deeper detection lowers the learned view. An earlier or equal detection keeps it unchanged. Smart adjust offset is applied once to that deepest position; for example, -2 starts two scan lines above it to leave room for longer casts.

Preset 3 updates after the cast ends, so learning does not move the camera while waiting for the splash. A stable angle reuses the existing preset. Movement, relevant settings/profile changes and the existing missed-scan fallback reset learning as before. The developer report includes the deepest estimated detection and starting tilt. No polling or timers are added.

## Scrollable settings

Settings keeps its collapsed height of 946 UI units when sections expand. Scroll over the options with the mouse wheel; there is no visible scrollbar. The title, Close control and Reset to defaults button stay in place.

Opening Scan settings, Experimental or Advanced timing scrolls only as far as needed to show its controls. Sound dropdowns also scroll into view. Collapsing sections clamps the scroll position to the remaining content. Moving and scaling the window still work, and expanding sections no longer shrinks the window.

## Smart camera and minimap defaults

Smart camera adjustment starts On for the Close and test profiles, and Off for the Long range profile. Reset to defaults selects Close camera scan with Smart adjustment On. The developer control can be changed while testing a profile.

The standalone and separated Fishing minimap icon shows only: Forever Fishing, Left click: Open, and Right click: Settings. Family-list text and all click, separation and drag behavior stay unchanged. The canonical launcher file is unchanged.

## Open automatically with a fishing rod

Equipping a fishing rod opens the fishing bar. It also opens when you log in or reload with a rod equipped. It never closes automatically. After you close it manually, it stays closed until you equip a rod again or log in/reload. If you equip a rod during combat, the bar waits until combat ends.

Detection uses existing equipment events and the equipped item's fishing pole category. Uncached item data is requested once and handled by the existing item information event. No idle polling, new repeating timers or bag scans are added.

Close camera scan now defaults to 17° tilt and 18 rows down. These apply to fresh profiles and Reset to defaults; existing saved adjustments are preserved.

Camera scanning now defaults to a 0.6s Hook key delay. Fresh profiles and Reset to defaults use it. Existing camera profiles still at the previous 1.0s default update once; other saved delays are kept. Recast mode retains its 3.0s hook default.

## Smart adjustment after the first scan

The first verified scan detection now prepares the learned preset 3 when that cast ends. The next cast starts from the adjusted view without needing another detection or rebuilding the preset. The camera remains still while the fish waits to splash. Moving still resets learning to preset 4.

## Double right click binding

Click the binding button, then choose **Bind to double right click** below the capture prompt. The binding display uses “Double RC” where space is limited; its tooltip gives the full name. Existing keyboard, wheel and other mouse bindings still work.

Two short right clicks in the game world, within 0.4 seconds, run the normal fishing rotation: equip gear, apply the selected lure, cast or hook as needed. The first click retains normal right click behavior. Held clicks, modifiers and clicks over UI windows do not arm the gesture. The cursor marker permits right clicks through to the game world.

The gesture is active only while the fishing bar is open and outside combat. Binding capture suspends it. A secure combat handler clears the temporary mouse binding; its timers run only during clicks. No permanent BUTTON2 binding, extra action macro, or idle update loop is added. Choosing this option replaces the current fishing binding and saves across reload. The default remains mouse wheel down.

Local Lua checks cover capture/cancel, labels, click timing, held clicks, scope, combat cleanup, gear/lure/cast and both hook routes. Native right click dispatch, camera dragging and bobber interaction need in-game testing.

## Smart camera adjustment

Turn on Smart camera adjustment in `/fish dev` to test a learned starting tilt. Preset 4 holds the normal fishing view; preset 3 holds the learned view. A verified bobber find records how many rows below the start it was found. The camera stays still while waiting for the splash. When that cast ends, the camera returns to its known view, adjusts the tilt and saves preset 3 for the next scan.

`/fish dev` → Smart adjust offset changes the detected row count, from -24 to +24 lines in 0.25-line steps, default -2.50. For example, row 7 with offset -2.50 uses 4.5 rows of the cast's vertical spacing. At the close defaults, tilt 17° plus 4.5 rows × 3.25° gives 31.625°. Deeper finds lower the learned view; earlier detections keep it unchanged. The offset is applied once to the deepest estimated angle. Negative offsets leave room to find longer casts; the requested tilt stays between the configured base tilt and 80°.

Moving clears the learned adjustment. The next scan returns to preset 4 until another bobber is found. Reload, changing profile, rebuilding the view or changing the relevant tilt, spacing, offset, zoom or cursor height also clears the estimate. A complete smart scan miss falls back to the base view on the next cast. Existing base tilt and zoom settings are kept.

The option defaults to Off. Its toggle and offset save separately for close and standard profiles. It requires Saved fishing view to be on and uses Sweep or Pyramid Path, with presets 3 and 4 reserved while enabled. The selected normal Saved view preset resumes when the option is off. No timer or idle camera update is added. Local learning, movement reset, interruption, view reuse and existing camera checks pass; native camera movement and bobber detection still need in-game testing.

## Compact fishing key section

The binding button sits to the right of Fishing key, with Click to bind vertically centered immediately to its left. Binding behavior is unchanged.

## Close camera scan profile

Close camera scan is now on by default for new profiles and Reset to defaults. Its defaults are zoom 15, tilt 17°, width 7° each side, Pyramid widening 0.75°, vertical spacing 3.25° and 18 rows down. The cursor box defaults to X 0, Y +339 UI units from screen center. Scan speed remains 3× and Pyramid Path stays on.

Both profiles remember speed, width, spacing, tilt, rows, path options, saved-view options, cursor style and cursor height. Edit the active profile in Scan settings or `/fish dev`; choose Long range in the Scan path dropdown to restore the standard profile. Move the cursor box up when wading, if needed. Moving it changes only the active profile, and each height survives switching and reload. `/fish changes` reports the active profile's cursor default: +339 for Adaptive or +247 for standard scans.

Switching stops the current scan and prepares a new fishing view on the next required scan. Profiles share no saved native view record, so an old preset cannot supply the wrong angle or zoom. Settings survive reload. Fishing keys, timing, gear, lures and notification sounds are shared and unchanged. Reset to defaults selects close scans and resets both scan profiles.

The standard zoom default remains 40, the slider maximum. Existing profile choices and custom settings are preserved. Older installations without scan profiles keep their previous adjustments in the standard profile and start with the new close profile. Local profile, zoom, saved-view and camera scan checks pass; native camera behavior needs in-game testing.

## Zoom accuracy fix

Zoom preparation now asks the game to move a bounded distance instead of stopping a fast continuous zoom on a later frame. This prevents a small adjustment, such as 5 to 6, from overshooting between frames. The selected distance applies in both directions, so lowering the setting also brings the camera closer. Your normal camera limits and nearby obstructions can still keep it closer than requested.

Zoom distance in `/fish dev` ranges from 1 to 40 camera units in steps of 1. After updating from a release before 0.5.47, click Rebuild fishing view once to replace any preset prepared with the old zoom movement. Changes apply when a new view is prepared; otherwise the saved fishing view is reused. Temporary zoom speed changes are restored when preparation finishes or is cancelled, including after reload.

Local zoom, camera scan and saved-view checks pass. Native camera movement still needs in-game testing.

## Empty lure glow setting

Hide Lure Glow When Out of Lures now suppresses the vendor icon's glow even when a manually selected lure has run out. Toggling it updates the icon immediately. When other lures are available, an exhausted manual selection still glows so you can choose a replacement. The option defaults to On for new profiles and Reset to defaults; existing choices are preserved. Lure selection and application behavior are unchanged.

## Camera recovery fixes

If a cast ends or a soft bobber becomes available while the saved fishing view is loading, the camera now finishes that same transition. It keeps the preset, original settle deadline and owned blend setting instead of resetting to the normal camera center and tilting down again. Rapid recasts and closing the bar use the same return path. Manual camera control, combat and external view changes retain their cancellation guards.

A brief frame stutter now fades out of the movement timing calculation as normal frames resume, instead of slowing the remaining scan rows until recasting. Scan speed limits, coverage, bobber detection and the cancellation guard for frame gaps over 0.25 seconds remain in place. No new timer or idle update loop is added.

Local camera, saved-view, bobber hold and notification sound checks pass. Native camera rendering and the rare in-game triggers still need player testing.

## Updated defaults

Scan width defaults to 7 degrees each side for close scans or 8 degrees for standard scans. Recast reminder sound defaults to Off. These apply to new profiles and Reset to defaults; existing saved choices are preserved.

## Expanded catch table

Expanded catches now show Scope, Caught, Catch %, Best session and Last. The First column is removed from the display, with more space and consistent gaps for the remaining headings. The header has no tooltip. Recorded dates, catch data and scrolling are unchanged.

## General settings tooltips

All four General options use a setting title and short, wrapped description lines. Focus splash sound now explains its audio changes and restoration in three concise lines. Settings behavior is unchanged.

## Cursor detection refinement

Mouse detection is 20 UI units smaller in both dimensions, centered inside the unchanged 44 x 44 artwork. The 24 x 24 detection area is shared by scan readiness, cursor reminders and instruction visibility.

## Cursor box default position

The cursor box defaults to X 0, Y +339 game UI units for close scans and +247 for standard scans. Existing saved marker heights are preserved separately for each profile, and `/fish changes` uses the active profile's default.

## Saved view reload fix

Forever can save and load camera presets while returning nil for their pitch, yaw and distance CVars. Fishing now retains its own record after a successful SaveView call instead of requiring those values to be readable. It also tries the native CVar reader when the global reader has no value.

After installing, let one scan prepare the fishing view, then `/reload` and scan again. The second scan should load the retained view without a separate center, zoom and tilt preparation. Settings changes, Rebuild fishing view, failed loads and detected external SaveView/ResetView calls still rebuild it. Readable preset signatures are still checked for changes. If the client hides the values, changes to that preset while Fishing is not loaded cannot be verified; reserve the selected preset for Fishing.

## Notification sound defaults

Cursor reminders use Soft ping with Repeat Sound on. Recast reminders default to Off, with Repeat Sound off and a saved 10-second delay. Repeat interval defaults to 3 seconds and applies to both alerts. Adjust it from 1 to 15 seconds in 0.5-second steps; it is greyed out when both Repeat Sound checkboxes are off. Existing sound choices and repeat preferences are preserved. Reset to defaults applies the new defaults.

## Cursor layout report

`/fish changes` now includes a Cursor box section with its current center offset, default offset and position change in game UI units. It uses the marker's actual scaled position when available and its saved height otherwise, including before the first scan. The report does not move the marker or change saved settings.

## Good cast status

A good cast keeps its splash instruction when recasting becomes available. The extra “Good cast • recast available” status transition is removed; timing and key behavior are unchanged.

## Cursor marker fit

Icon 4 is selected once when updating. Later choices in `/fish dev` remain available and are saved. The artwork stays 44 × 44 UI units; cursor detection is now a centered 24 × 24 area, inset ten units on each edge. Marker position, artwork size and dragging are retained. Cursor reminders, instruction visibility and scan checks all use the same smaller detection area.

## Cursor instruction panel

The instruction panel now fits its text with equal padding on all sides. A small upward baseline adjustment balances its vertical spacing. Its background and amber text match the fishing bar's long-cast state. The gold border, cursor-based visibility and screen-edge positioning are retained. Text dimensions are measured once when creating the marker; no additional update loop is needed.

## Notification sounds and cursor reminders

The sound section is now **Notification Sounds**. In Camera Assist, **Cursor reminder sound** replaces the Out of range sound label and prompts you only while a scan is needed and the mouse is off the cursor box. It stays quiet while hovering or dragging the box, after a bobber is found, and after the scan ends or fails. Sound selection, previews and repeat preferences are retained. Recast mode continues to show **Out of range sound**.

Camera Assist's recast default is now **0.6s**. The previous 1.0s default updates once; other saved adjustments are kept. A later deliberate choice of 1.0s stays saved. Reset to defaults also uses 0.6s.

## Timing by fishing mode

Advanced timing saves separate values for Camera Assist and Recast mode.

| Setting | Camera Assist | Recast mode |
| --- | --- | --- |
| Too far warning delay | Fixed 0.2s; hidden | Default 0.2s; adjustable |
| Recast delay | Default 0.6s; applies to every cast | Good cast recast delay; default 3.0s |
| Hook key delay | Default 0.6s | Default 3.0s |
| Rapid press lock | Fixed 0.35s; hidden | Default 0.35s; adjustable |

In Camera Assist, the on-screen fishing button can recast any cast after Recast delay. The fishing key hooks an available bobber after Hook key delay. While a distant bobber is still being searched for, or the cursor is away, another press can recast after Recast delay. A close bobber keeps its normal Interact action. The hook and recast delays are independent.

Existing timing adjustments move into the Recast profile. Camera Assist defaults to a 0.6s recast delay and a 1.0s hook delay; later adjustments in both modes are saved. Switching modes restores that mode's values and updates an active cast. Slider edits apply to the next cast. Reset to defaults restores both profiles. The two hidden Camera Assist values still protect cast detection and rapid input.

## Scan status and missed bobbers

Preparing the fishing view now reads “Scanning for bobber” on the fishing bar. A complete scan without a detection shows the existing top-screen warning: “Bobber not found, Adjust cursor box height for this fishing location”. It clears on the next cast or scan retry, when the bobber is found, or when the fishing bar closes. Cancelled scans and unavailable camera controls do not trigger this message.

## Cursor marker

The marker now uses the supplied artwork, with Option 4 selected by default. Choose among all five designs in `/fish dev` → Cursor marker. Your choice is saved; Reset to defaults restores Option 4. Marker height, dragging and scan coverage work as before.

A compact warm-brown panel with amber text and a gold border reads “Place cursor here • drag to move”. It appears above the marker while your cursor is outside, moves below near the top of the screen, and hides while you hover or drag the marker. Camera assisted fishing shows top-screen text only after a completed scan misses the bobber; the fishing bar still shows its status. Recast mode keeps its out of range warning.

Hover visibility uses the existing active-cast update and cursor events. There is no new idle update or timer. The supplied artwork is embedded unchanged as transparent TGA textures.

## Scan defaults and bobber hold

New profiles and Settings → Reset to defaults select the close scan defaults listed above. Standard scans retain their separate defaults: speed 3×, width 8° per side, tilt +25°, 11 rows down, spacing 3.75°, Pyramid Path on and widening 1° per side per row. Existing saved adjustments are kept. Pyramid Path is in `/fish dev`; the main Scan settings section keeps its three sliders.

The first confirmed bobber ends the search for that cast. Its remaining path is discarded and camera scanning stops. Moving the cursor away no longer resumes the sweep or recenters the view. Return the cursor to the bobber at the marker to hook; hover verification still guards against other objects and NPCs. The status reads “Bobber found • return cursor to marker” while away. The next cast starts a fresh search, and the usual return happens when the cast ends.

World cursor events handle hover changes immediately, backed by the existing active-cast status check. The scanner's frame update stops after detection, with no new timer or idle loop. Catch statistics count the detection once even if the cursor leaves and returns repeatedly.

## Retained fishing view test

Saved fishing view stays available after walking, turning, changing height and manual camera movement. Movement cancels the current search; the next scan loads the same prepared angle and zoom in one transition. Camera collision can reduce the visible zoom without discarding the view.

The prepared view now has a record in your addon settings. After `/reload` or relog, it is reused from the addon record. Native pitch, yaw and distance are compared when readable; hidden values no longer prevent retention. An update from the previous saved-view test can adopt its existing centered preset, so your first scan after updating should not need the separate tilt again. Your current Camera tilt is retained.

A genuinely new profile or an unavailable/replaced preset still needs one automatic center → zoom → tilt preparation to create the view. Changing Camera tilt, Zoom distance or the chosen preset also prepares a new view. A direct arbitrary-angle setter has not been established in Forever; this update does not claim to remove that initial creation step for fresh installs.

In `/fish dev`, **Saved fishing view (test)** switches between this method and the existing preparation. **Rebuild fishing view** creates a new view on the next scan. **Saved view preset** defaults to 4 and can use 2–4; preparing a view replaces that preset. Preset 5 is left for Forever Ruler. **View settle delay** defaults to 0.4 seconds; increase it if scanning begins while the view is still moving.

Rounded turns uses the existing preparation method. If native controls fail, the existing method remains available. Temporary blend settings recover on cancellation, reload/logout and later external preference changes. Local simulations and package checks pass; native persistence, facing behavior, camera collision and smoothness still need in-game testing.

## Automatic Setup

**Auto Equip Gear** and **Auto Equip Lures** are independent and on by default. Auto Equip Gear equips configured fishing gear when `/fish` or the minimap button opens the bar, and includes the gear step in the fishing button rotation. Auto Equip Lures includes the selected lure step in that rotation. Further presses wait while gear equips or a lure is being applied. Lures are reapplied after the enchant expires when that option is on.

**Best available lure** follows your bag stock. A manually selected lure stays selected when it runs out; the Lure button glows so you can choose a replacement. It never substitutes another lure in manual selection mode.

Turn either automatic option off to handle that step yourself. The Gear and Lure buttons remain available in every combination. Change these options outside combat. Existing Manual Gear & Lures choices migrate to the two new switches.

## Journal statistics

Session Stats now shows Session time, Casts, Catches, Success rate, Catches / hour, and Avg. cast to loot. Lifetime Stats uses the same two-column layout with Time fishing, Casts, Catch count, Success rate, Catches / hour, Avg. cast to loot, Sessions, and Unique catches.

**Catches count loot quantities.** A successful cast counts once for Success rate, even when it catches several items. Only an actual fishing channel adds a cast; cancelled and expired casts remain in the denominator. Cast to loot averages use successful timed casts, not item quantities. Session time and pace include breaks after the first cast. Lifetime fishing time and pace count active fishing channels.

Click a catch row to expand its Lifetime and location statistics: Caught, Catch %, Best session, First, and Last. Catch % compares that item with all recorded catch quantities in the same scope. Locations sort by quantity, with a subtle highlight for your current location. Long tables scroll internally; wheel scrolling at an inner boundary continues scrolling the page.

Existing totals are preserved without adding catch events to item counts. Lifetime Success rate and catch pace start with this update, using matched cast and catch counters. Earlier dates and session bests cannot be recovered; unknown values show a dash. Older records keep an unknown First date, while new catches update Last and begin tracking session bests. Old explicit location counts are kept; a last-seen zone is not used to guess where earlier catches happened.

Tracking runs on cast, loot, and location events. Catch lists are cached until catches change, stats components are reused, and routine refreshes preserve scrolling. A one-second display clock runs only while a time-changing stats page is visible. The field guide's text and formatting are unchanged.

## Sound

Settings → Notification Sounds has four selectors: **Cursor reminder sound** (or **Out of range sound** in Recast mode), **Recast reminder sound**, **Catch confirmed sound**, and **Fish escaped sound**. Each offers Off, Battle.net notification, Soft ping, Chime, Raid warning, Male, Female and Male Voice 2, with a preview button. The voice clips are included with the addon; their source and licence are listed in `Media/Voices/ATTRIBUTION.txt`.

The recast reminder plays after the fishing bar has been open without a bobber for the selected **Idle player recast reminder delay**. A failed cast also alerts promptly when Fishing never starts channeling. The idle delay ranges from 1 to 60 seconds, default 10, and is greyed out while the reminder is Off. It resets when you cast or close the bar. The reminder defaults to Off, with Repeat Sound off. An enabled old channel sound becomes a Soft ping reminder; an old Off choice stays Off.

Cursor and recast reminders have **Repeat Sound** checkboxes. Catch sounds play once. Cursor reminders default to Soft ping with repeats on; recast reminders repeat only if enabled. **Repeat interval** controls both repeating alerts, default 3 seconds, adjustable from 1 to 15 seconds in 0.5-second steps. Male Voice 2 uses a minimum repeat gap so its cues finish cleanly. It is greyed out when both repeat checkboxes are off. Cursor reminders stop when the bobber becomes available, the cast ends, or the bar closes. Recast reminders stop when you cast or close the bar. Previews play once.

In Camera Assist mode, cursor reminders stay quiet on the cursor marker, while dragging it, after a bobber is found, and after a scan ends or fails. If you leave the marker while a scan is needed, the sound can prompt you to return. Both alerts use the game's Master audio channel. Use Sound in Background in General options to hear them while WoW is inactive.

Confirmed fishing loot plays the selected catch sound. WoW's fishing failure messages trigger the corresponding “Fish got away” voice line when a voice is selected. Catch sounds default to Off. Audio uses cancellable timers only for pending cast checks, reminders, or enabled repeats. Active fishing has no recast reminder timer. Closing the bar, leaving the world, or resetting settings cancels playback and pending callbacks.

## Camera scan

Sweep centers the camera before scanning. Pyramid Path is an optional variation that widens lower passes. Both center the view, zoom out, apply the chosen tilt, then search downward in alternating horizontal passes. The old paths, learned row predictions, edge recovery, and recorded movement return are removed. Saved Sweep values and the marker height are preserved; obsolete scan settings are cleared.

Open **Settings → Scan settings** for these controls:

- **Scan speed:** one control for zoom, tilt, passes, row changes, circular turns, and returning to the prepared view. Range 0.1–5×; default 3×. Changes apply to the next cast.
- **Width:** horizontal reach to each side of center.
- **Vertical spacing:** gap between rows, default 3.25° for close scans or 3.75° for standard scans. The slider ranges from 0.25° to 6°. Saved spacing choices are preserved.
- **Pyramid Path:** on by default; adjust it in `/fish dev`. The first line uses Width; each lower line extends farther on both sides. **Pyramid widening** sets the added degrees per side per line, from 0.25° to 6° in 0.25° steps. It defaults to 0.75° for close scans or 1° for standard scans.

Camera assisted mode is now the default. This update switches older profiles to it once; later choices are saved. **Settings → Experimental → Recast mode** switches to recasting distant bobbers instead of moving the camera. Turn Recast mode off to return to camera assisted fishing. There is no longer a Camera Assist toolbar icon. Long casts turn orange and stay out while scanning. Keep the cursor on the marker; press your fishing key at the splash after the bobber is found. The addon does not hook automatically. Close casts keep their existing behavior.

Left click and drag the marker up or down to suit your fishing spot. It stays on the screen center line and saves its height across casts and reloads. Dragging pauses the camera and restarts the search from a freshly prepared view when released. World hover, right clicks, and the fishing wheel binding remain available. The square guides a single cursor point; it is not an area detector.

Type **`/fish dev`** for the remaining Sweep view and coverage controls: Zoom distance, Camera tilt, Rows down, and Start below center. Camera tilt ranges from -80 to 80 degrees in 0.5 degree steps. Positive values tilt down; negative values tilt up. The same Scan speed controls the opening adjustment and the rest of the scan. Rounded turns is available only in this developer window while its camera behavior is being tested. The old Rounded turns selection is disabled once during this update; later developer choices are saved. Enabling Rounded turns disables Pyramid Path, and vice versa. Current casts retain the speed and tilt they started with; new settings apply to the next cast. Diagnostics include optional logging, statistics, and copyable reports.

After a catch, cancellation, or complete miss, Sweep recenters and reapplies the cast's tilt, keeping the prepared zoom. It leaves camera CVars and saved views untouched. Camera collisions and the client's pitch limits can affect the actual view; angles are requested offsets rather than measured values. Leaving the marker pauses preparation or scanning. Scan updates stop while idle.

See [Camera scan testing](SCAN_DEVELOPMENT.md) for the test workflow.

A compact fishing bar for the WoW: Forever beta (Interface 16001).

When WoW keeps a nearby NPC selected for soft interaction instead of the fishing bobber, Fishing now warns that the bobber is unavailable and lets the fishing key recast. It waits briefly for a newly cast bobber to become selectable before showing that warning. A missing soft target still uses the player's Too far warning delay. Routine UI refreshes no longer recheck the cast macro unless the lure macro actually changed.

The cast button now checks that its macro slot still contains Fishing. When buying a first lure causes the addon to create a lure macro, it immediately refreshes the cast button and key binding; it also responds to later macro changes. If the cast macro is missing or edited, the key falls back to the Fishing spell binding and the button cannot run another macro.

Fishing Gear swaps still save the exact items they replace, so switching between normal Equipment Manager sets before fishing restores the right items without requiring a dedicated fishing set. If a character starts with a rod equipped or changes spec while fishing, the addon checks their saved sets and remembers the last normal set worn for each spec. It reuses an item link only when that exact link is still in a bag. If multiple sets could fit and use different weapons, it asks the player to equip the intended normal set once instead of choosing a weapon pair blindly. Ignored Equipment Manager slots are left alone.

During normal play, Fishing's controls and windows sit above Blizzard's action bars and player fishing cast bar. When a standard Blizzard panel such as the map, spellbook, talents or game menu opens, Fishing moves below that panel and returns above the HUD when it closes. Panel open/close hooks and addon load events drive the change; no idle polling is added. WoW may defer a layer change opened in combat until combat ends.

The addon embeds the exact Forever launcher API v5 file from Forever RollCheck 2.0.10. It registers under the stable `ForeverFishing` ID and stores icon separation, launcher positions, and family list order in `ForeverFishingDB.launcher`. When Fishing is the only registered family addon, its own icon appears on the minimap. With other family addons, the shared icon and list appear; Ctrl click Fishing's row to separate its icon, or Ctrl click its separated icon to return it. The launcher handles icon dragging, dragging the list window and row reordering. Ordinary left click toggles the Fishing bar and right click opens Settings from either the list or separated icon; Shift and Alt retain those click actions.

The cast control carries the **Forever Fishing** title inside its button, with no duplicate title above it. Its lower line shows casting, hooking, and out of range status. Settings displays **FOREVER FISHING /fish** beneath its heading.

The detached toolbar has four evenly spaced icons: Gear, Lure, Journal and Settings. Close remains at the cast bar's upper right edge. **Session Stats** is in the Journal under **My Records**, beside Catch Journal and Lifetime Stats. Its six metrics and Reset Session control remain available. Journal and Settings stack above Fishing's cast and icon bars; clicking Journal or Settings again closes its window.

After casting, the status says **Checking cast** until the bobber is identified and the Too far warning delay has elapsed. It then reports **Good cast** without waiting for the separate Hook key delay. The Hook key delay still controls when the key changes to Interact.

The Lure button recognizes and updates lure macros created by earlier versions even when their saved ownership flag is missing. A genuinely unrelated macro with the same name is left alone; Fishing chooses an unused variant. The **Best available lure** entry uses the custom lure icon and names the lure it will use on hover. When the bags contain no lures, the main Lure button becomes a vendor coin icon and its tooltip points to a fishing vendor. The dropdown then contains only the drop target for adding a lure.

The cast control, Journal, Settings, and Trace use Blizzard's gold dialog border artwork. The cast control has one even blue surface, a larger Castbar icon sized 64 UI units, and ready/too far status icons; the Journal uses parchment pages with open guide sections and fine separators.

Gear and lure picker items now show WoW's normal item tooltip on hover, including the item name and details. The cast control tooltip explains its click, key, recast and move actions in short lines.

The Gear/Lure arrows, Settings dropdown indicators, and picker scroll arrows now have larger artwork and click targets. Click the binding badge on the cast control to choose or change its fishing key without opening Settings. Wheel bindings use readable text such as **Wheel down**; long combinations shorten to fit the button, with the full binding shown on hover.

Journal record icons use round portrait masks, so their square item artwork no longer shows dark corners. Journal navigation and page text have a larger minimum size. Journal, Settings, and Trace open as floating windows above the fishing controls; the most recently opened window appears on top. Drag the Journal header or an empty area of Settings to move it. Drag the bottom right corner grip to scale Journal or Settings. Their positions and scales persist after reload.

Version 0.4.7 attaches a separate Blizzard mask texture to each round icon. The earlier mask call distorted icon art on the Forever beta client.

Settings now uses a larger gold and blue panel with separate Fishing Key, General Options, Out of Range Sound, and Advanced Timing sections. The only key control is a button showing the current binding with "click to bind" beneath it; left click captures a new key and right click clears it. General options use switches across each row, the warning sound has a separate preview button, and timing sliders remain behind the Advanced Timing disclosure. The panel remains movable and scalable. A footer button resets the fishing key, addon options, warning sound, and timing sliders after confirmation. It leaves records, gear choices, layouts, and WoW audio settings unchanged.

The detached tool icons no longer draw a dark backing beyond their borders. Gear and Lure dropdown arrows sit at the bottom right edge of their icons while retaining their large click targets. The Best Available lure row uses borderless custom artwork inside the same Blizzard frame as the other lure entries.

The Settings header now leads directly into Fishing Key. The sound section uses Blizzard's speaker artwork and is titled **Out of Range Sound**.

The warning sound preview button and the selected sound marker now use Blizzard textures, avoiding missing glyph boxes on the beta client.

Clicking the binding button in Settings temporarily hides Settings while the full screen capture is active. The window returns after a key, wheel, or supported mouse button is chosen, and also after Escape cancels. Mouse buttons are captured on release so their selection does not leak into the fishing action.

Focus splash sound starts on for a fresh profile. An existing saved on/off choice is preserved. While the fishing bar is open, it enables game effects, raises low Master/Effects levels to at least 60%/90%, and initially silences music, ambience and dialogue. Ambient and Music slider adjustments in Forever Fishing are temporary Focus settings; closing the bar, disabling the option, leaving the world or logging out restores their previous game levels. Turning Focus on again starts Ambient and Music at zero. Other game audio changes made outside those two sliders are left to the player. Interrupted sessions are recovered at login. Sound in Background remains an independent WoW setting. This emphasizes the native splash; other game effects can still be heard. The Fishing Key section keeps its literal key icon; the fishing emblem and rod icon are used for the header and Gear.

The latest Forever Fishing icon pack is included in `Media/`: Square, Round, and borderless LureNoBoarder textures sized 64 pixels for normal UI placements, plus a detailed Castbar texture sized 128 pixels for the fishing control. Round appears in the Settings header and on Fishing's solo or separated minimap button. Square appears in WoW's AddOns list and Fishing's Forever family list entry. LureNoBoarder fills the **Best available lure** dropdown's Blizzard icon frame. The family minimap icon shows the first visible addon in the current family list order.

Type `/fish changes` to compare the current layout with the defaults listed above. Existing saved bar positions and scales stay where the player placed them.

## Install

Extract the ZIP into `_classic_beta_/Interface/AddOns/`. The folder should be `AddOns/ForeverFishing/`, with `ForeverFishing.toc` inside it. Restart or reload the game, enable the addon, and type `/fish`.

Forever Fishing is independently installable. Its TOC loads the unchanged API v5 `ForeverLauncher.lua` before Fishing's core files. The launcher shows a solo icon when Fishing is alone, and a shared family icon and list when multiple addons are registered.

## Cast and hook

- Open Fishing from its solo minimap icon, its family list row when other Forever addons are installed, or `/fish`. Shift + drag the cast or icon bar to move both together. Alt + drag either bar to move it alone. Both positions persist after reload.
- Ctrl + drag the cast button or its key badge left or right to scale the fishing control. Type `/fish changes` to open a selectable report with the cast control and icon bar positions, scales, sizes, current defaults, and game UI size. Click **Select all**, press Ctrl+C, and paste it into chat when you want the defaults adjusted.
- Click **Cast Fishing** to cast. The addon creates a character macro named `FF Fishing Cast` for this button. If character macro slots are full or a different macro already uses that name, free a slot or resolve the name, then type `/fish repair`. The bound key can still cast without this macro.
- The first run cast / hook binding is mouse wheel down, shown as `Wheel down` on the bind button. The tooltip spells it out as `Mouse wheel down`. An existing chosen binding is preserved when upgrading. Use `/fish bind` or click the current binding in Settings to change it; right click that button or use `/fish unbind` to clear it. Press a keyboard key, scroll up or down, middle mouse button, or side mouse button while the capture overlay is open. Hold Ctrl, Alt, or Shift while scrolling to bind a modified wheel direction. Left and right mouse buttons remain reserved for normal UI and camera controls. While the Fishing bar is open, one press casts Fishing. In Recast mode, immediately after a cast starts, extra key presses are ignored for the **Good cast recast delay** so spam cannot instantly replace a good cast. A confirmed too far cast bypasses this lock and makes recast available immediately. If the recast delay ends before the Hook key delay, the key directly casts Fishing during that interval, allowing a deliberate good cast recast. When the Hook key delay ends, the key invokes Blizzard's **Interact With Target** action. Press it when the actual bobber splash occurs. If the bobber becomes targetable again after a too far state, the action is selected from the current timing phase. It also switches back to cast when the fishing channel ends. Closing the Fishing bar releases its temporary key override, so the same key can activate your normal spellbar action. Reopening the bar restores the fishing override.
- **Interact assist** runs automatically and is no longer shown in General options. It temporarily enables the keyboard Interact setting and widens its bobber search arc/range while a line is out. Prior settings are restored afterward. If the client fails to select the bobber, right click it directly.
- The on screen button casts and can recast when the bar turns red, provided its `FF Fishing Cast` macro exists. It cannot click the bobber in the game world. Use the bound key to cast and hook.
- **Rapid press lock** starts when the bound key or on screen Cast button presses the shared secure cast action, before the fishing channel appears. It temporarily blocks both inputs, closing the gap where very fast presses could slip through. In Recast mode, its slider runs from off to 1.5 seconds in steps of 0.05 seconds and defaults to 0.35 seconds. The Good cast recast and Hook key delays still run from channel start. A confirmed too far result on the new cast still makes recast available immediately. Open **Advanced Timing** at the bottom of Settings to adjust the delays. Saved values still at the old defaults update once. Other timing choices stay as set.
- `/fish status` reports whether the Fishing bar is open, the current fishing channel, the actual key binding, all four timing settings, and Blizzard's soft interact settings if you need to diagnose a missed action.
- `/fish trace` opens a selectable report with the current mode, binding, timing, warning sound, interact settings, Lure click setup and the last eight fishing transitions. Click **Select all**, press Ctrl+C, then paste the report into chat. The trace stays in memory only and adds no idle update loop.
- The cast control shows the current cast status without a second progress strip. WoW's own fishing cast bar shows channel progress. There is no timed screen flash: the addon cannot read the real splash event from the client API.
- In Recast mode, shortly after the fishing channel starts, the bar turns red and its status line prompts a recast if WoW consistently reports no soft Interact game object ID. A gold message also appears near the top of the screen in a larger font: **Out of range - Catch manually or press again to recast**. A sound plays when the red state first appears for that cast; Repeat Sound repeats it at the selected interval until the condition clears. The warning clears when the bobber becomes targetable, the cast ends, or the Fishing bar closes. The **Out of range sound** dropdown in Settings offers **Off**, **Battle.net notification**, **Soft Ping** (the default), **Chime**, and **Raid Warning**. Choosing an option plays a preview. The warning uses the game's Master audio channel; Blizzard's **Sound in Background** setting controls whether WoW audio continues while the game is in the background. The initial warning used `UnitExists`, which incorrectly reported no target for a selectable fishing bobber on Forever. This version uses the bobber's game object ID: a close, hookable cast was observed with ID 35591, while a failed long cast returned no ID. The **Too far warning delay** slider runs from 0.05 to 1.5 seconds in steps of 0.05 seconds. **Good cast recast delay** and **Hook key delay** each run from 0.1 to 4.0 seconds. Their defaults are 0.2, 3.0, and 3.0 seconds. Set the recast delay below the hook delay to create a direct recast window between them; equal delays go straight to Hook mode. Settings apply to the next cast. For delays below 0.5 seconds, the addon checks the bobber every 0.05 seconds during the first second of the cast; afterward it checks every 0.2 seconds. The warning requires consecutive missing target checks, so it may appear slightly later than the selected delay. Very low values may warn before a close bobber appears or make an action available before it settles; these values are provided for testing and tuning. Press the fishing key again to recast, or click the on screen button if its macro exists. This warning does not measure the bobber's distance or detect the splash.
- **Focus splash sound** temporarily raises game and effect sound and lowers music and ambience while a line is out. Prior sound settings are restored afterward. This defaults to on for a fresh profile; an existing saved choice is preserved.
- **Sound in Background** directly switches Blizzard's Audio setting of the same name. Turn it on to keep hearing the real bobber splash when WoW is in the background. Its state reflects the game setting and remains on or off until you change it again. This switch does not require Focus splash sound.

## Other tools

- The five spell icons form a separate bar with no background: Gear, Lure, Camera Assist, Journal, and Settings. Shift + drag an icon to move both bars together, or Alt + drag it to move the icons alone. Ctrl + drag an icon left or right to scale the icon bar. These choices persist after reload. Gear and Lure use a pulsing gold proc border when attention is needed; Camera Assist has a steady gold edge when enabled. Close remains at the cast bar's upper right corner.
- The toolbar shows icons only; hover an icon for its short tooltip.
- **Gear** scans equipped slots and bags for fishing poles and equippable items whose tooltip or name identifies Fishing skill, then selects the strongest detected item for each equipment slot. Click Gear to equip the chosen items; click again to restore what they replaced. It also remembers the latest normal main hand and off hand items for each character and active spec group. If a rod is already equipped at login, clicking Gear restores that spec's remembered weapons instead of treating the rod as normal gear. Equip normal weapons once to establish the memory for a spec; Fishing will not guess if none have been seen. Its Blizzard arrow opens a vertical list of icons of the items it will equip. Left click an item there to equip or restore the full gear setup; right click to confirm its removal. Drop another equippable item onto the plus icon at the bottom. Dragging onto the main Gear icon also works. Item swaps briefly retry while WoW has an item locked. Gear changes are blocked during combat.
- **Lure** scans bags on login and bag update events, choosing the highest Fishing skill bonus available. Click Lure to apply the selected lure to the equipped rod. Its Blizzard arrow opens a vertical list of icons: automatic choice first, available lures next, and a plus icon for a lure the scan missed. Hover for a short description, then click to select; a manual choice persists after `/reload`. A lure dragged to the plus icon is remembered and remains usable even if its tooltip was not recognized by the automatic scan. Clicking Lure uses a character macro managed by the addon that activates the selected bag item and targets the equipped fishing pole. The secure button runs on mouse release. It reuses an older Forever Fishing lure macro, or creates one character macro if needed. An unrelated macro with the same name is preserved; Fishing chooses an unused name. If all character macro slots are full and no reusable lure macro exists, the Lure button reports that limit briefly. Dragging a lure onto the main icon and `/fish lure <item ID>` remain available. The icon has no numeric overlay. Its gold border glows when the rod has no temporary enchant and clears once a lure is applied. The General options toggle **Hide Lure Glow When Out of Lures** suppresses that glow when the bags contain no lures; it is on by default. A single scheduled refresh updates the glow when the enchant expires; there is no timer update loop.
- **Journal** opens the parchment journal with Catch Journal, Session Stats, Lifetime Stats, the four field guide chapters, and Upcoming events. The events page lists the next four Stranglethorn Fishing Extravaganza dates in realm and local time. Click a date for a short preparation and participation guide; Rare catches has the full reward details. Dates use the realm's weekly schedule and are calculated when the page opens. Beta schedules can change, so check the in game calendar. Expanded Catch Journal entries now show best waters, a recommended effective Fishing skill, fishing method, and relevant conditions. Discovered catches retain their recorded statistics above the guide. For catches outside the curated collection, the journal shows the player's recorded waters and marks unverified guidance clearly. Skill targets follow the reported 100% catch thresholds for the named Forever waters; pole, gear, and lure bonuses count. Pages use clean ink without shadows and scroll with the mouse wheel. Drag its header to move it or its outer bottom-right grip to scale it. See Journal statistics above for counts and migration details.
- The guide distinguishes stable Classic routes from current Forever beta data. It includes the three Forever campsite recipes, reagents and effects. The beta identifies advanced blueprints as dungeon drops but does not yet provide dependable boss assignments, so the journal says when a source is still being verified.
- Gear configuration, lure, key, settings, separate control/tool positions, tool scale, catch journal and lifetime stats persist. Session stats reset at login.
- Type `/fish reset` to confirm a full reset, then the UI reloads with default settings. This clears Forever Fishing data for all characters, including layouts, launcher preferences, gear and lure choices, journal records, and lifetime stats. WoW audio settings, items, Equipment Manager sets, and macros are left alone.

## Beta test checklist

1. Install Fishing alone: verify its individual minimap icon appears with no family list icon. Left click it to toggle the Fishing bar; right click it to open Settings. Check Shift/Alt with both clicks and confirm Ctrl click does not trigger a Fishing quick action while solo. Drag the icon along the minimap edge and verify its position after `/reload`. Shift + drag either Fishing bar and confirm both move together; Alt + drag each to move it alone. Ctrl + drag a tool icon sideways to resize the icon bar, then reload and confirm both positions and the tool scale persist. Verify all five tool icons remain clickable, the gear and lure arrows still open their lists, and Close releases the temporary binding. Click Camera Assist and confirm its gold edge and the Camera scan setting stay in sync, including after `/reload`.
2. On a fresh SavedVariables profile, confirm the Settings bind button shows `Wheel down` and mouse wheel down casts and hooks. Left click that button to bind a keyboard key, middle or side mouse button, scroll up, scroll down, and a Ctrl/Alt/Shift + scroll combination. Confirm each selected binding appears on the button and can cast and hook; right click to clear it. Expand Advanced Timing and set the Good cast recast delay below the Hook key delay. After a close cast, spam the key before the recast delay and confirm the line stays out. During the interval between the two delays, confirm one press directly replaces the good cast; `/fish status` should report `good cast recast`. After the Hook delay, confirm the mode becomes `interact` and the same key hooks at the real splash. Try a long cast with no hook icon: the bar should turn red after the selected warning delay, show an out of range recast prompt, show the gold top warning, and play the selected sound once. Confirm `/fish status` reports `too far recast`, then press the key and confirm it starts a fresh cast even if the good cast recast delay has not elapsed. Set Too far warning to 0.05 seconds, then try 0.1 seconds on Recast and Hook; watch for premature warnings or actions on close casts at aggressive values. Confirm closing the Fishing bar also clears the warning. Fish near an NPC such as Catherine Leland: if the NPC remains the soft interact target and the bobber has no hook icon, the bar should show `Bobber unavailable` and the next fishing key press should recast rather than interact with the NPC. Move away from the NPC and confirm close bobbers still show Good cast and hook normally.
   For rapid press testing, use the default of 0.35 seconds and spam the Fishing key immediately after a cast. The fishing key and the on screen Cast button use the same secure cast action, and the lock starts when that button is pressed. If a good cast still restarts, raise **Rapid press lock** by 0.05 seconds and repeat. Lower it to find the shortest reliable value for your client. Set it to 0 to compare with the previous behavior. Confirm a red too far cast can still be recast as soon as it is detected. After pressing the key, `/fish trace` should show a `cast button pressed; rapid press lock` transition.
3. Put a different spell on the same key in WoW's action bar. With the Fishing bar open, confirm the key casts/hooks. Close the bar with its X button; confirm the key activates the action bar spell. Reopen through `/fish` or the Forever menu; confirm the key controls Fishing again. Repeat while a fishing line is out, and after `/reload` (the bar opens if a fishing rod is equipped). WoW does not permit binding changes during combat, so the Fishing bar stays open if you try to close it then.
4. Choose each **Out of range sound** option and confirm its preview; **Off** should be silent. Confirm the chosen option persists after `/reload` and that one warning plays per too far cast, even if the target briefly reappears. Toggle **Sound in Background** in Forever Fishing settings. Confirm Blizzard's Audio checkbox reflects the change, and that WoW sounds continue while you are switched to another window. Toggle it off and confirm the game value follows. Separately enable **Focus splash sound** and check that sound levels stay focused between casts and return when the fishing bar closes without changing Sound in Background. Press **Reset to defaults**, accept the confirmation, and check the key, options, sound choice, and timing values. Journal records, gear choices, layouts, and Sound in Background should stay as they were.
5. Install Forever RollCheck 2.0.10 too. Check both addon load orders: the family icon lists Fishing and RollCheck once each, alphabetically until reordered. Fishing's list row should toggle its bar on left click and open Settings on right click, with Shift/Alt variants retaining those actions. Ctrl click Fishing's row to separate its icon; Ctrl click the separated icon to return it, including with Shift/Alt held. Drag the family icon and family window, reorder the rows, and confirm the family icon follows the top visible row. Repeat after `/reload` to confirm separation, positions and order persist. Check RollCheck's row opens its Settings.
6. Keep a fishing pole and Fishing skill clothing in your bags. Open the Gear arrow and confirm the vertical list contains only the icons currently chosen for equipping, plus a final drop slot, without active selection glows. Hover for item names and slots. Left click an item to toggle the full gear setup; right click an item and confirm that removal only happens after accepting the prompt. Drop an unrecognized equippable item onto plus. Starting in ordinary combat gear, click Gear once and confirm only the selected fishing slots change; click again and confirm the exact prior items and any prior empty slot return. Equip normal weapons once for each spec, log out with the rod equipped, and confirm one Gear click restores the right weapons after login. Repeat with a one hand/off hand pair and with two specs. If no normal weapons were ever seen for a spec, confirm the Okay dialog asks you to equip them once rather than saving the rod as normal gear. Temporarily remove one remembered item from the bags to verify the retry message, and verify combat blocks changes cleanly.
7. Put several lure types in the bags. Confirm the strongest bonus is selected automatically, the Lure arrow opens a vertical icon list, and one main icon click applies the selected lure to the equipped rod. Choose a weaker lure, reload and verify it stays selected. Choose the first automatic icon, then add or consume a stronger lure and verify it follows the strongest one. Drag an unrecognized lure to the plus slot and confirm it can be selected and applied. Confirm the clean icon has no numeric overlay, the gold border clears after application, and it glows again only after the rod enchant expires. On a character with no lures, buy the first lure and apply it manually, then use the fishing key; it must cast Fishing rather than apply the lure.
8. Open Journal and inspect all three records pages and the four field guide chapters. Catch an item in two locations, expand its row, and check totals, scope percentages, dates, and session bests. Confirm the location with more catches comes first. Compare multi-item loot with Success rate: it should still count one successful cast. Cancel a cast and confirm Casts increases while Catches does not. Reset the session and confirm Lifetime and Catch Journal remain intact. Reload during an active cast and confirm Lifetime Casts is not counted twice. Verify scrolling stays put during bag/gear refreshes, long location tables scroll inside their maximum height, and the existing ink/font treatment stays readable. Old dates and session bests should show a dash, not guessed history.
9. Use the default camera assisted mode and test several fishing spots. Test Scan speed at 0.1×, 0.5×, 1×, 3×, and 5×. Confirm the opening adjustment and the remaining scan change together. Recast after changing the slider. Try Pyramid Path on and off and test Pyramid widening at 0.25°, 1°, and 6° per side in `/fish dev`. Rounded turns remains available in `/fish dev` for development testing. Use `/fish dev` to tune the prepared view and coverage. Confirm the marker stays centered when dragged, its height survives `/reload`, and the camera recenters after catches and misses. Try rapid recasts, manual camera changes, and combat. Confirm closing the developer window stops its report updates. See SCAN_DEVELOPMENT.md.

10. In Sound settings, preview Battle.net notification and choose a Recast reminder sound. Set a short delay, leave the bar open without a bobber, and confirm one reminder. Enable Repeat Sound and confirm repeats follow the Repeat interval slider. Disable both repeat checkboxes and confirm the slider is greyed out. Cast again or close the bar to stop them. Test the range loop with Camera Assist on and off, including returning the cursor to the marker. Confirm both selections, repeat settings, interval and reminder delay survive `/reload`.

## Diagnosing a missed hook

After a failed hook, before casting again, type `/fish trace`. Click **Select all**, press Ctrl+C, and paste the report. With the Fishing bar open, a stopped line returns the key to Cast. Just after a cast, mode `settling` uses a harmless click binding so extra presses do nothing. Mode `good cast recast` uses Fishing directly during the optional interval between the Recast and Hook delays. Mode `interact` means the key is ready to hook. A red out of range status reports `too far recast` and uses Fishing immediately. With the bar closed, the key returns to its normal WoW binding. A separately bound Blizzard **Interact With Target** key during a missed hook is a useful control test. Keyboard input cannot reach WoW while another window has focus; mouse button input also depends on which window receives the click.

This package passes Lua 5.1 compilation, camera simulation and package checks. It has not been tested live inside your beta client. The Forever beta currently has reports that its own Interact action sometimes misses fishing bobbers; the addon cannot override that client behavior.
