--
-- conf/hosts/Z790E.lua
-- Host profile: desktop workstation
--

return {
    --- NZXT Kraken Elite LCD
    kraken_lcd = true,

    --- Razer Leviathan V2 X soundbar
    razer_leviathan = true,

    --- `desc` as in `hyprctl monitors`, without the port suffix
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
