--
-- conf/hosts/X13GEN5.lua
-- Host profile: ThinkPad X13 Gen 5 notebook
--
-- Selected automatically when /etc/hostname reads X13GEN5 (see conf/host.lua).
-- Externals that are plugged in on the road are not listed on purpose: they
-- are picked up by the catch-all rule in conf/monitors.lua.
--

return {
    monitors = {
        notebook_main = {
            desc     = "AU Optronics 0x6693",
            mode     = "highres@highrr",
            position = "auto",
            scale    = "1.25",
            role     = "primary",
        },
    },
}
