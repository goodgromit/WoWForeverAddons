# Camera scan testing — 0.5.76 beta

## Updated Smart camera defaults

New profiles and Reset to defaults use first trigger line 0, second trigger line 7, and second offset −4.5 lines. Existing saved values are retained. Confirm both camera profiles after Reset to defaults, and check that a fresh profile uses −4.5 rather than inheriting the regular offset.

## Smart adjust offset trigger

`/fish dev` now has a separate trigger for the regular Smart adjust offset. It ranges from line 0 to 24 and defaults to 0. If a bobber is found before both triggers, Smart camera adjustment waits and leaves preset 4 active. The second offset trigger takes priority when reached. Test finds just before, on, and after each trigger; check that close and standard scan profiles retain separate values after switching and `/reload`.

## Second Smart camera offset

In `/fish dev`, set Smart adjust 2nd offset trigger to a line from 0 to 24 and Smart adjust 2nd offset in 0.25-line steps. The first successful bobber find after Smart camera adjustment resets selects the second offset when its detected row is at least the trigger line. The selected offset stays active until Smart camera adjustment resets. Default trigger is line 7; default second offset is −4.50. Existing saved second offset choices remain unchanged.

Test a first find above, on, and below the trigger line, then another find on the trigger line from the learned preset. The second find should keep the first offset choice. Movement should clear that choice. Check both scan profiles, `/reload`, Reset to defaults, a trigger change during a cast, and the copied `/fish dev` report. Native bobber detection and camera feel still require in-game testing.

## Racetrack turns

In `/fish dev`, enable Racetrack turns while Pyramid Path is on. The row widths and spacing stay fixed; only the transitions outside each row edge curve into the next line. Try the close and standard profiles at their current defaults, then vary Width, Vertical spacing, Pyramid widening, Rows down, and Scan speed. Compare bobber coverage and camera feel with Racetrack turns Off. The toggle starts Off, saves per profile, and takes effect on the next scan. Rounded turns remains a separate older test and turns Racetrack turns off if selected.

Check cursor pause/resume during a turn, stopping immediately after finding a bobber, recasting, return to the saved fishing view, Smart camera adjustment, profile switching, `/reload`, and a complete miss. At very high speed and very small spacing, a turn may take fewer frames than the client can display. Native movement still needs in-game testing.

## Quarter-line Smart adjust offset

In `/fish dev`, set Smart adjust offset to -1.75, -0.25, +0.25 and +0.5. The slider, copied report and `/fish trace` must show the chosen fraction. With close defaults, row 7 at -1.75 should learn a starting tilt of 34.0625°; a deeper row 3 from that view should update it to 38.125°. Existing integer offsets remain unchanged. Switch profiles and reload to confirm each fractional choice persists; Reset to defaults returns -2.50.

Local checks cover quarter and half steps, positive/negative values, bounds, report text, successive finds, profile storage and normalization. Native camera precision requires in-game testing.

## Deepest smart detection

With close defaults (base tilt 17°, spacing 3.25°, offset -2), a first find on row 7 records an estimated bobber angle of 39.75° and prepares starting tilt 33.25°. From that learned view, a find on row 4 records 46.25° and lowers the next start to 39.75°. A later find on row 0 or 1 must keep that deepest angle and starting tilt, with no new preset save. Row 2 should match the previous deepest position and also reuse the preset.

Compare the deepest detection and starting tilt in `/fish dev` or `/fish trace`. Check that changes occur only after the cast ends, preset 4 stays unchanged, and movement resets learning. Test zero/negative/positive offsets and a nonzero Start below center. Existing missed-scan, setting-change, profile-switch, reload and failed-save recovery must still work.

Local checks cover consecutive deeper finds, earlier/equal detections, an offset applied once, native preset reuse, first-row offsets and existing safety guards. Native camera angles and bobber hit testing remain in-game checks.

## Settings scrolling

Open Settings and expand each section, alone and with the others open. The outer height and scale must stay unchanged, each newly opened section must become visible, and no scrollbar should appear. Wheel over the options and sliders, including at both ends. Collapse all sections at the bottom and check the content returns without a blank area. Open either sound dropdown while scrolled down: its choices must become visible. Wheel scrolling closes an open sound menu. The title, Close control and reset footer stay fixed. Move and scale the window, close/reopen it, and repeat in both fishing modes.

Local Lua checks cover every expansion combination, content height, reveal bounds, wheel limits, dropdown visibility, collapse/reopen and existing settings callbacks. Native scrolling, clipping and mouse-wheel delivery over widgets require in-game testing.

Smart camera adjustment defaults to On for new profiles and Reset to defaults. Existing saved Off choices survive initialization and profile switches. Local smart-camera and profile checks pass. The Fishing minimap tooltip is checked for solo and separated icons in both registration orders, including repeated refreshes and Ctrl-click return; native tooltip rendering remains an in-game check.

## Fishing rod auto-open

Log in and reload with a rod equipped: both bars should open with their existing positions and settings. Equip a rod from ordinary gear: both bars should open. Remove the rod: they must stay open. Close manually with the rod still equipped, then apply a lure, change another gear slot or receive repeated inventory events: the bars must stay closed. Swap to normal weapons and back to the rod: they should reopen. Opening from an equip during combat waits for combat to end and is cancelled if the rod was removed first. Test an uncached fishing pole as well.

Local event checks cover login, equipment transitions, manual closing, item classification and metadata, combat deferral, no auto-close and no new timer work. Gear/lure preparation checks still pass. Native client equipment events and the full visible bar behavior require in-game testing.

## Smart camera adjustment

Smart camera adjustment and Saved fishing view are on by default under Experimental. The first scan uses base preset 4. A bobber found seven rows down with offset -2 should record five rows of spacing. At tilt 17° and spacing 3.25°, ending that cast should prepare preset 3 at requested tilt 33.25°. The second scan must reuse it without another detection or save. Check its horizontal center stays aligned; the found bobber's sideways camera angle must not be saved as home. Preset 4 and the configured base tilt remain unchanged.

No movement or preset save should occur while waiting at a found bobber. The return after that cast loads a known native reference and applies only the relative tilt change. A stable learned tilt reuses preset 3 without rebuilding. Actual angle remains an estimate when Forever hides native preset values. Recast or move during the first return: recasting should complete the learned view safely; movement must cancel it and restore base preset 4 for the next scan.

Move between casts, including while the bar is closed, then scan again. It must use preset 4 and relearn. Test movement and recasts during preparation, mouse control, profile switches, rebuild, reload and an externally overwritten preset. Learning is session-only; the base view ownership record can survive reload. A missed smart scan clears its estimate for the following cast. No active movement or owned blend setting may remain after cancellation.

Try negative, zero and positive offsets. The range is -24 to +24 in 0.25-line steps, default -2.50. The first horizontal pass is row zero; each lower row adds Vertical spacing. Learning uses the cast's captured spacing and ignores relevant settings changed before the find. Changes to tilt, spacing, offset, zoom, start offset and cursor height invalidate the estimate. Requested tilt cannot go above the base view or past 80°. Both profiles save the toggle and offset independently. Turning the feature off restores the normal saved-view preset choice.

Local checks cover the requested row calculation, centered presets 4/3, stable reuse, no movement on detection, movement and reload reset, interruptions before/during the relative tilt, captured settings, pitch bounds, smart misses, failed saves and profile switching. Existing scan, zoom, UI and saved-view recovery checks also pass. Native view interpolation, collision and world hit testing require the beta client.

## Close camera scan profiles

Fresh profiles and Reset to defaults select Close camera scan. Verify zoom 15, tilt 17°, width 7° per side, widening 0.75°, spacing 3.25°, 18 rows down and cursor height +339 UI units. Speed remains 3×, Pyramid Path is on and view settle delay is 0.4s. Existing profile choices and tuned values must stay as set. Older installations without scan profiles preserve their previous standard adjustments before activating the new close defaults.

Adjust zoom, tilt, speed, coverage, Pyramid Path, cursor height and saved-view settings, then switch off under Experimental. Confirm the standard values return exactly. Switch on again and confirm the close values return. Repeat after reload with each profile active. Move both cursor boxes to different heights and check the actual centered position at different UI scales. `/fish changes` must use +339 as the close cursor default and +247 as the standard cursor default. General options, keys, timing, sounds and fishing items must not change.

The standard defaults remain zoom 40, tilt 25°, width 8°, widening 1°, spacing 3.75°, 11 rows down and cursor height +247. Reset to defaults resets both profiles and selects close. The trace and developer reports identify the active profile. Experimental expansion must fit both controls above Advanced timing.

Switch during zoom preparation, scanning and a camera return. Old movement and owned zoom/blend settings must stop; the next required scan prepares the selected profile's view. A profile switch clears the reusable native view instead of trusting a preset overwritten by the other profile. Switching in combat is rejected without changing settings. Check nearby buildings at lower zoom distances in game.

## Zoom accuracy

Zoom distance ranges from 1 to 40 in steps of 1, with standard default 40 and close default 15. Click Rebuild fishing view when updating from a release before 0.5.47 to replace the old preset. Compare settings 1, 5, 6 and 7 on fresh preparations: each one-unit change should be small. Test increases and decreases from a farther starting view, then reload and confirm the saved view is reused. Compare requested and achieved zoom in `/fish trace`; walls and normal camera limits may keep it closer.

Preparation uses one bounded CameraZoomOut or CameraZoomIn request. Cursor pauses and cancellation clear the native destination and restore the owned zoom speed. Resume from the current distance. Check closing the bar, manual camera input and reload; externally changed zoom speed must be preserved.

Local tests cover distances 1–40, scan speeds 0.1–5, frame intervals through 0.2 seconds, inward and outward preparation, obstruction caps, pause/resume, cancellation, unavailable controls and setting recovery. They do not verify native rendering or collision behavior; those require the game client.

## Empty lure glow setting

With no lures in the bags and a rod without an enchant, toggle Hide Lure Glow When Out of Lures. The vendor icon must stop glowing immediately when On and glow again when Off, in both automatic and manual selection modes. If a manual lure has run out but another lure remains, the replacement highlight must stay visible. An available selected lure still glows only when its enchant is missing. New profiles and Reset to defaults keep the option On.

## Interrupted saved views and frame stutters

Recast or close the controls during the saved view settle window. Also check a cast where normal Interact briefly detects the bobber during preparation. The pending native view should finish once without a center/tilt reset or restarted SetView call. Recasting during that return must retain the preset and start the next scan normally. Manual camera input, combat and external camera controls must still stop addon movement and release owned settings.

The local regression interrupts native view loads at 0, 0.1 and 0.39 seconds through channel end, soft bobber availability, immediate recast and closing the controls. It checks the original target/deadline, no extra SetView or CenterCamera call, retained metadata, released blend settings, correct return angle and idle shutdown. Manual camera and external blend changes are also checked during the transferred return.

Simulated frame hitches of 0.05, 0.1, 0.2 and 0.24 seconds must recover during the current scan without changing selected speed or losing row coverage. The following scan remains normal. Gaps over 0.25 seconds still cancel active camera motion. These simulations do not reproduce the native screen flash or establish its original cause; test the rare symptoms in game.

## Expanded catch table

Expand a catch and confirm five columns: Scope, Caught, Catch %, Best session and Last. The First column is hidden, and Best session fits on one line. Check the last date still shows the latest catch, including records whose first and last dates differ. Headings must show no tooltip; expanding, scrolling and retained records work as before.

## General settings tooltips

Hover Auto Equip Gear, Auto Equip Lures, Hide Lure Glow When Out Of Lures and Hide Blizzard UI While Fishing on General Options. Confirm the descriptions appear in tooltips only and the setting titles remain in their rows. The Experimental controls retain their existing descriptions. No other option behavior changes.

## Smaller centered detection zone

The marker artwork remains 44 x 44 UI units. Test cursor positions just inside and outside all four edges of its centered 24 x 24 detection area at different scales. Scan readiness, reminder sounds and instruction visibility must agree. Dragging the artwork remains available.

## Cursor box default position

Confirm a new profile and Reset to defaults place the close cursor box at X 0, Y +339 game UI units from screen center, including at different addon scales. Switch to standard and confirm its +247 default. Existing saved heights must remain unchanged for each profile. `/fish changes` must use the matching profile default offset.

## Saved views with hidden camera values

Reproduce the client report: SaveView and SetView work, but all three preset GetCVar results are nil. Prepare one scan, `/reload`, and confirm the next required scan loads the same native preset without centering, zooming and tilting again. The prepared status should say retained between sessions, with native angle unavailable if neither supported reader exposes the values.

Version 2 ownership records persist after a successful SaveView. They validate the slot, tilt, zoom, requested zoom and ownership flag. Existing version 1 records need a valid signature. Readable signatures still detect changes; missing values preserve the owned record. External SaveView/ResetView hooks and failed native loads still invalidate it. Changing view settings and the Rebuild button keep the existing preparation path. When native values are hidden, external changes while Fishing is not loaded cannot be checked.

The local regression repeats scans with all preset CVars hidden, loads the actual record in a fresh Lua session, and covers native CVar fallback, readable mismatches, malformed records, failed loads, known external overwrites and settings changes. Native client preset persistence still needs in-game verification. No new timer or camera movement was added.

## Notification sound controls

Fresh profiles and Reset to defaults use Soft ping with cursor repeats on, recast reminder Off with repeats off, recast reminder delay 10 seconds and repeat interval 3 seconds. Existing sound and repeat choices are preserved. Check both Repeat Sound checkboxes: Repeat interval must be adjustable while either is on, greyed out when both are off, and keep its saved value.

Change the interval while an alert repeats. Verify the old callback is cancelled, the new interval takes effect without an extra ping, and both notification types use the same setting. Changing the interval during an idle countdown must preserve its remaining delay. Hover the cursor marker, find the bobber, cast, close the bar and leave the world to confirm repeats stop.

## Updated defaults

Verify both sets of defaults listed in Close camera scan profiles above. Fresh profiles and Reset to defaults select close scans. Existing values and each profile's cursor height must survive initialization and reload.

## Cursor position reporting

Copy `/fish changes` after moving the cursor box. The Cursor box section reports current and default center offsets and their difference. Confirm the same game UI coordinates at different fishing bar scales. Hidden or uncreated markers use their saved height; a fresh profile uses the actual marker default. Reporting must not change positions or start a scan.

## Cursor reminder sound

Notification Sounds shows Cursor reminder sound in Camera Assist and Out of range sound in Recast mode. Verify previews and repeat tooltips follow the mode immediately. The cursor reminder requires an active fishing channel, a scan that is still needed, and the cursor off the box. Hovering, dragging, a latched bobber find, completed/failed scans, closing the bar and ending the channel must cancel repeats. Returning off the marker after a find must not restart reminders. Existing sound choices, enabled repeats and Recast mode alerts are retained.

The old 1.0s camera recast default migrates to 0.6s once. Other values are retained, and selecting 1.0s after migration survives reload. Reset to defaults uses 0.6s without changing the 1.0s hook default.

## Mode timing

Camera Assist defaults to Recast delay 0.6s and Hook key delay 0.6s. The range check stays fixed at 0.2s and rapid input protection at 0.35s; their sliders appear only in Recast mode. Recast mode keeps its four defaults: 0.2s, 3.0s, 3.0s and 0.35s. Each mode saves its own adjustments. Existing flat timing values migrate to Recast mode. Camera profiles at the previous 1.0s hook default update once; later choices survive reload.

Test close and distant casts before and after Recast delay. The visible button can recast either after the delay; the key hooks when the bobber is available and Hook key delay has elapsed. During a scan or away from the bobber, the key can recast after Recast delay. Try different hook and recast delays in either order. A recast becoming available must refresh bindings even if hook readiness did not change.

Switch modes with Advanced timing open: the hidden rows must leave no gaps, the label changes to Recast delay in Camera Assist, and each profile restores its values. Reload and reset settings to verify persistence and both defaults. `Tests/verify_timing_modes.py` exercises migration, profiles, cast gates, secure routing, mode changes and rapid input in Lua 5.1; protected actions still require native testing.

## Cursor marker artwork and instructions

`/fish dev` → Cursor marker offers all five supplied designs with a preview in each row. Option 4 is the default and is selected once on this update. The artwork remains 44 × 44, with detection inset ten units on each edge. Later developer choices persist. Changing artwork updates the marker immediately and saves the choice; it does not change its centered 24 × 24 detection area, height or scan path. The complete transparent image is used without cropping.

The instruction panel fits its text with equal padding and a one-unit upward baseline adjustment. Its flat background and amber text use the same colors as the long-cast fishing bar. The gold-bordered panel appears only off the marker. It flips below when there is not enough room above, accounting for UI and addon scale. It hides while dragging, after the marker closes, or when camera assistance ends. Camera assisted casts no longer show duplicate cursor instructions at the top of the screen. A completed scan that misses the bobber shows “Bobber not found, Adjust cursor box height for this fishing location”. Retrying, finding the bobber or closing the bar clears it. Cancellation and camera preparation failures do not show the height warning. Recast-mode warnings and audio are retained.

Test all five choices, leave and re-enter the marker during scans and after a find, drag near the top of the screen, change HUD scale, then `/reload`. Confirm the selected design and height persist, the panel stays readable and its background does not block world hover.

## Defaults and acquired bobber behavior

New profile/reset defaults: Scan speed 3×; Width 8 degrees each side; Camera tilt +25 degrees; Rows down 11; Vertical spacing 3.75 degrees; Pyramid Path on; Pyramid widening 1 degree each side per row. Existing settings remain unchanged. Pyramid Path is accessible only through `/fish dev`.

Detection is now a cast-long result, separate from current cursor hover. The first verified bobber discards the remaining path and removes the scanner's frame update. Moving the cursor away clears the hook-ready hover state without restarting the search. Returning over the bobber re-enables hooking; hovering an NPC remains guarded. A soft-interact update cannot recenter an acquired cast. Marker dragging after acquisition also cannot restart that cast's search. Recasting creates a new result, while channel completion/cancellation retains the existing return behavior.

Test a find, move the cursor outside the marker repeatedly, hover a nearby NPC, then return to the bobber. The camera should stay at the acquired view. Catch or allow the cast to expire, then recast: the next cast must scan normally. Repeat with both regular and Pyramid sweep, and check cursor events while the game is inactive. Live world cursor events and rendering still need in-game verification.

`Tests/verify_bobber_hold.py` executes the actual acquisition, status and binding logic for Sweep/Pyramid/Rounded scans. It verifies discarded paths, repeated leave/return, guarded NPC hover, soft-target changes, unchanged camera coordinates, one detection record, next-cast reset and close cleanup. Existing cursor-event tests also verify loss/reacquisition behavior. No idle polling or new timer is added.

## Retained fishing view

Saved fishing view now survives player movement, turning, height changes, manual camera movement and camera zoom changes. These actions still cancel the active search. They clear that search's position tracking without deleting the reusable angle and zoom.

The addon retains a small record of its chosen native preset in SavedVariables. It compares native pitch, yaw and distance when readable. Missing values preserve the record; detected changes invalidate it. The native preset stores the camera view, while the addon record tracks which view and settings it prepared.

An existing profile from the previous saved-view test can adopt its readable, centered native preset once. This avoids the separate pull-down on the first scan after updating. The migration does not apply to fresh profiles or an unreadable/uncentered preset. Preset values are confirmed in this Forever install's account camera configuration; their use across new positions and sessions still needs live testing.

A genuinely new view requires one automatic center → zoom → tilt preparation. The client has no verified arbitrary-angle setter that can create a chosen view directly. After that preparation, later scans and returns load the native preset once, including after `/reload`. Changing Camera tilt, requested zoom or preset choice prepares a new view. The return during a cast keeps that cast's captured view.

1. Update with your existing saved fishing view, then cast somewhere needing a scan. Check that the first scan loads the previous preset directly, with no separate tilt.
2. Walk, turn around, change height and move the camera manually. Cast again and confirm the same pitch and zoom return, correctly aligned behind the player. Movement during a scan must still cancel it.
3. `/reload` and relog. With the preset unchanged, the first scan should load it directly again. Check both keyboard turning and right mouse turning.
4. Fish near walls and low obstacles. The saved view should remain available even when collision temporarily reduces visible zoom. It should return to its usual zoom in an open location.
5. Change Camera tilt or Zoom distance. The next preparation should create a new view; changing them midcast must not replace that cast's captured return.
6. Use **Rebuild fishing view** in `/fish dev` if the retained view is unsuitable. The next scan prepares and saves it again. Toggle **Saved fishing view (test)** off to compare with the existing method. Rounded turns also uses that method.
7. Adjust **View settle delay** if scanning begins before the native transition finishes. It defaults to 0.4 seconds and ranges from 0.2 to 2 seconds in 0.05 second steps. There is no reliable native transition-complete event.
8. Test combat, closing the bar, movement during loading and world transitions. No scan movement or temporary blend preference should remain active after cancellation.

**Saved view preset** defaults to 4, adjustable from 2 to 4. Preparing a view replaces that preset; choose a different preset from other camera addons or personal saved views. Preset 5 is left for Forever Ruler. External SaveView calls to the selected preset discard its record, as do changed stored preset values.

The test temporarily requests smooth cameraViewBlendStyle while loading, then restores the previous value. Existing ownership checks retain later external changes and recover pending settings on reload/logout. Missing or rejected controls fall back to the existing method. The retired CameraFollowPitchOffset experiment's pending snapshots still recover.

## Settings

Settings → Scan settings has Scan speed, Width and Vertical spacing. Pyramid Path is on by default and its toggle is in `/fish dev`. The first line uses Width, and each lower line extends by the chosen Pyramid widening on each side. The `/fish dev` slider ranges from 0.25 to 6 degrees in 0.25 degree steps, default 1. It uses the same spacing, speed, bobber detection, and camera return as Sweep. Wider lower passes are intended for testing coverage as the camera tilts down; they do not guarantee equal water coverage at every view angle.

Rounded turns is available only in `/fish dev`. The old Scan settings choice is disabled once during this update, so it cannot remain active as a hidden setting. Later developer choices persist. Enabling Rounded turns disables Pyramid Path, and vice versa. Existing speed, spacing, width, tilt, and marker height are retained.

One Scan speed controls zoom, opening tilt, passes, row changes, turns, and the return tilt. It ranges from 0.1 to 5× in 0.1× steps, default 3×. The speed is captured when preparing a cast and retained until its return completes. Changing the slider takes effect on the next cast. The `/fish dev` window has the same three sliders, Pyramid Path, and Rounded turns, plus Zoom distance, Camera tilt, Rows down, Start below center, Pyramid widening, Saved view preset and View settle delay, plus a Rebuild fishing view button. Its report updates four times per second while open. Logging is off by default.

Camera assisted mode is selected once for older profiles during this update. Later mode choices persist. Recast mode is under Settings → Experimental, between Scan settings and Advanced timing. Enabling it stops camera searches; disabling it returns to camera assisted mode. The toolbar has no camera mode icon.

Vertical spacing defaults to 3.75 degrees and remains adjustable from 0.25 to 6 degrees in 0.25 degree steps. Existing saved spacing is retained; Reset to defaults uses 3.75 degrees.

## Test workflow

1. Use camera assisted mode (the new default), cast, and keep the cursor near the marker's center. Confirm retained views load directly. A fresh view centers, zooms out and adjusts vertically once before saving.
2. Set a visible Camera tilt in `/fish dev`. Try Scan speed at 0.1×, 0.5×, 1×, 3×, and 5×, recasting after each change. Confirm fresh-view preparation and scan movement scale together. Native SetView transitions use the client's own speed and View settle delay. Changing the slider midcast must not accelerate that cast.
3. Enable Pyramid Path in `/fish dev`. Confirm the first line uses Width and each lower line extends by Pyramid widening per side, without changing Vertical spacing. Compare against Sweep at the same fishing spot. To test Rounded turns, enable it in `/fish dev`; check the quarter circle entry and semicircular row joins at several speeds and spacings.
4. Leave the marker during preparation, the opening move, a pass, and a turn. Motion must pause, then resume when the cursor returns. Finding a bobber must stop movement immediately. Manual camera movement, player movement, and combat must cancel scanning.
5. Test a catch and a complete miss. Both should load the prepared view without accumulating movement; with the test off, they should recenter and reapply the cast's tilt. Midcast settings changes should apply to the next scan.
6. Drag the marker up and down. It must remain on the screen center line. Dragging pauses the camera; release starts a fresh prepared search. World hover, right clicks, and the fishing binding must remain available.
7. Recast and `/reload` to confirm settings and marker height persist. Reset settings to restore defaults without affecting catch records or gear choices.
8. Copy `/fish trace` or the developer report for failed searches. Confirm no camera or marker updates remain active while idle.

## Camera behavior

Sweep calls the native centering function and zooms within the player's current limit. Zooming stops at the requested distance, after 0.2 seconds without cumulative progress, or after a timeout scaled by Scan speed (1.5 seconds at 1×). Small per-frame zoom changes accumulate so low speeds at high FPS are not mistaken for a blocked camera. The prepared zoom stays after fishing. With Saved fishing view off, preparation changes no camera CVars or saved views. With it on, the selected preset is saved and cameraViewBlendStyle is temporarily owned during loading.

Without Rounded turns, the opening tilt keeps its existing short easing and settling period. Start below center is a separate vertical adjustment at the same Scan speed. All movement uses Scan speed, including the first sideways positioning move and vertical row transitions.

With Rounded turns, the opening vertical move includes Camera tilt and Start below center. It leads into a 90 degree circular arc, then a left pass from center. A negative opening adjustment uses an upward entry arc. The entry radius is half the row spacing, capped at half the width so the first pass continues left. The first partial pass sits one entry radius below the opening endpoint (above it for a negative adjustment).

The configured rows below it use full passes across the width. Each semicircle has a radius of half the row spacing and extends outside the side of the previous pass. Its tangent direction matches both adjacent lines. Lines and arcs share one angular path speed and one uninterrupted camera motion. There is no speed ramp, stop, priming frame, or endpoint wait at a rounded join. Initial start and cursor resume retain one zero-speed priming frame.

All movement uses one native rate setter with a shared vector speed limit. The path time line uses one rate for every segment. The path controller samples one continuous time line, accounts for the previously issued camera rate, and adjusts both native axes. It compensates for the client's yaw and pitch rate settings so the requested turns are circular in estimated angular coordinates. Pausing preserves path progress. Stopping for a bobber or cancellation is immediate. The final endpoint is confirmed before a complete miss recenters the view.

Uneven frames can carry pitch beyond a curve endpoint and previously caused a reverse correction on the next line. Pitch is now bounded before the endpoint, and each horizontal pass holds its actual arrival pitch. Small arrival offsets taper out during the next curve, with zero correction slope at its ends, so offsets do not accumulate across rows. The final endpoint check includes the held row offset. An axis at rest is stopped without starting the opposite direction at zero speed.

After fishing, the saved view restores the prepared angle and zoom when available. With the test off or unavailable, the existing native recenter and captured tilt movement restore it. All angles are estimates; native camera clamps and nearby geometry can change the actual view. Very small row gaps at high speed give the client few frames to draw a turn and can miss small bobbers. Lower Scan speed or increase Vertical spacing when testing these cases.

Cursor events and active frame checks verify fishing bobbers using world tooltip data. Generic interaction cursors and other objects are rejected. The marker guides a single cursor point, not a detection area. No idle loop or new polling timer is added.

## Local checks

`Tests/verify_saved_view.py` verifies automatic +29 degree capture, single-call reuse and return, settle waits, cursor pauses, captured settings, retention after position/facing/height/zoom changes, reload metadata validation, prior-test migration without initial tilt, fresh-profile preparation, malformed records, external preset ownership, disabled and rounded modes, rejected APIs, collision zoom handling, delayed CVar notifications and cancellation recovery. Its client interpolation and native preset persistence are simulated; actual precision and camera feel require testing.

The single-call approach follows [DynamicCam Classic's saved-view implementation](https://github.com/dernPerkins/DynamicCam-Classic/blob/master/Core.lua). It remains an experiment on Forever.

`Tests/verify_camera_scan.py` compiles addon Lua in Lua 5.1 and verifies Pyramid Path widths and row coverage, saved setting migration, per-cast shape capture, circular quarter/half turns, matching tangents, uniform speed ownership, low-speed preparation and return, uninterrupted path ownership, pause/resume, immediate bobber stops, complete misses, repeated recentering, cancellation, settings migration, marker dragging, and idle shutdown.

Low-speed checks cover 0.1× through 5×, both scan styles, midcast setting changes, cursor pauses, and the return tilt. A 500 FPS zoom test catches small per-frame progress being ignored. Slow settings and large angles may take longer than a fishing channel lasts; the normal channel end still cancels the scan.

The row join regression covers 0.25, 1.5, 4.5, and 6 degree spacing at uneven 30/60/144 FPS. It verifies no reverse pitch at curve exits, no pitch corrections within horizontal passes, and bounded offsets across repeated rows.

Package checks verify TOC order, ZIP contents, source parity, copyright headers, and the unchanged launcher. Actual camera feel, world hit boxes, rendering, collisions, and protected actions still need in-game testing.
