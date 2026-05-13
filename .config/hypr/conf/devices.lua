--
-- conf/devices.lua
-- Input device sensitivity configuration
-- Reference: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
--

-------------------------------------------------------
-- Configuration
-------------------------------------------------------

local devices = {
    -- X13Gen5 Lenovo Notebook
    { name = "elan06c4:00-04f3:3209-touchpad",  sensitivity =  0.25 },
    { name = "tpps/2-synaptics-trackpoint",     sensitivity = -0.50 },
}

-------------------------------------------------------
-- Apply
-------------------------------------------------------

for _, device in ipairs(devices) do
    hl.device(device)
end
