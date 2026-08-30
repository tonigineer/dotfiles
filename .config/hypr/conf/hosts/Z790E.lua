--
-- conf/hosts/Z790E.lua
-- Host profile: desktop workstation
--
-- Selected automatically when /etc/hostname reads Z790E (see conf/host.lua).
--

return {
    --- Monitor profiles, consumed by conf/monitors.lua.
    --- `desc` must match the output of `hyprctl monitors` (without the port
    --- suffix). `role` marks which monitor is primary and which is secondary.
    monitors = {
        desktop_primary = {
            desc     = "ASUSTek COMPUTER INC PG27UQR R7LMQS169187",
            mode     = "highres@highrr",
            position = "auto-right",
            scale    = "2.0",
            role     = "primary",
        },
        desktop_second = {
            desc     = "ASUSTek COMPUTER INC ROG XG27UQR R4LMQS097007",
            mode     = "highres@highrr",
            position = "auto-left",
            scale    = "2.0",
            role     = "secondary",
        },
    },
}
