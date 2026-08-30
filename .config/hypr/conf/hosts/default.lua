--
-- conf/hosts/default.lua
-- Host profile: any machine without a file of its own
--
-- A new box runs from here until it gets a conf/hosts/<hostname>.lua
-- (`hostnamectl --static` prints the name). It declares no monitors on
-- purpose: whatever is plugged in is handled by the catch-all rule in
-- conf/monitors.lua, which is the sane thing to do for a display this
-- config has never seen. Copy the closest existing profile and adjust.
--

return {
    monitors = {},
}
