// Prefs here override about:config edits on every launch.

// use_document_fonts=0 puts our font ahead of the site's, which breaks icon
// fonts (ligature names render as text, e.g. FRITZ!Box FDS-Iconfont). The
// allowlist matches the site's declared family name exactly (case-insensitive,
// no quotes, only the leading run of the font-family list). Find candidates with:
//   [...new Set([...document.fonts].map(f => f.family))]
// By origin: Material/Font Awesome (upstream defaults), ups.com, bahn.de (incl.
// db-ux), fritz.box (FDS-Iconfont, Password Dots). Text fonts such as
// DBScreenSans, UPSRoboto, IBM Plex are deliberately left out.
// Password Dots is not an icon font, but the password field needs it.
user_pref("browser.display.use_document_fonts", 0);
user_pref("browser.display.use_document_fonts.icon_font_allowlist", "Material Icons, Material Icons Extended, Material Icons Outlined, Material Icons Round, Material Icons Sharp, Material Icons Two Tone, Google Material Icons, Google Material Icons Filled, Material Symbols, Material Symbols Outlined, Material Symbols Round, Material Symbols Rounded, Material Symbols Sharp, Material Symbols Rounded Non Filled, Google Symbols, FontAwesome, Font Awesome 5 Free, Font Awesome 5 Brands, Font Awesome 6 Free, Font Awesome 6 Brands, upsicons, UPS Material Symbols, UPS Material Symbols Filled, DBWebIconFont, Deutsche_Bahn_VUX, db-default, db-filled, db-ux-default, db-ux-filled, icon-font-fallback, missing-icons, icons-16-outline, icons-20-outline, icons-24-outline, icons-32-outline, icons-48-outline, icons-64-outline, icons-16-filled, icons-20-filled, icons-24-filled, icons-32-filled, icons-48-filled, icons-64-filled, FDS-Iconfont, Password Dots");

// No Nerd Font here: Monaspace lacking PUA glyphs lets PUA icon fonts fall through.
user_pref("font.name.serif.x-western", "Monaspace Krypton");
user_pref("font.name.sans-serif.x-western", "Monaspace Krypton");
user_pref("font.name.monospace.x-western", "Monaspace Krypton");
// Without it Zen ignores userChrome.css and the Noctalia overrides.
user_pref("devtools.chrome.enabled", true);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
