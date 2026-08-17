// .config/zen/user.js
// Zen (Firefox) prefs applied at every startup, symlinked into each profile by
// scripts/installations/041-browser.sh. Values here override prefs.js on launch,
// so editing these in about:config will not survive a restart — edit this file.
// Ref: https://kb.mozillazine.org/User.js_file

// ── Profile customisation ───────────────────────────────────────────────
// Required by this module's userChrome.css wiring; without it Zen ignores the
// profile stylesheet and the Noctalia theme overrides silently do nothing.

// ── Fonts ───────────────────────────────────────────────────────────────
// use_document_fonts=0 does not block webfonts; it moves the preferred generic
// to the front of each font-family list, so our font wins and the site's font is
// only reached for codepoints ours lacks. Icon fonts break under this: either the
// generic renders a ligature name as literal text ("chevron_right"), or it owns
// the codepoint outright. The allowlist below keeps the named families ahead of
// the injected generic.
//
// Matching (gfx/thebes/gfxPlatformFontList.cpp, servo/.../computed/font.rs):
//   - compared against the family name the *site's* CSS declares, not the
//     @font-face name, the file name, or anything installed locally
//   - exact string, lowercased on both sides; no substring or wildcard match
//   - comma-separated, whitespace trimmed, but quotes are NOT stripped —
//     write bare names even though devtools prints them quoted
//   - only the leading run is protected: the generic is inserted ahead of the
//     first non-allowlisted family, so a site listing an unlisted family first
//     cannot be fixed here
//
// To extend, run on the broken page and add whatever looks like an icon font:
//   [...new Set([...document.fonts].map(f => f.family))]
//
// Grouped by origin:
//   Google Material / Font Awesome  upstream defaults, plus the FA5/6 names
//   ups.com                         upsicons, UPS Material Symbols[ Filled]
//   bahn.de                         DBWebIconFont (marketing bundle)
//   bahn.de db-ux design system     Deutsche_Bahn_VUX, db-*, icons-<size>-<style>
//   fritz.box (AVM FRITZ!OS)        FDS-Iconfont, Password Dots
// Deliberately excluded: DBScreenSans, DBScreenHead, UPSRoboto, IBM Plex, Source
// Sans Pro (fritz.box) — those are text fonts we do want overridden.
//
// FDS-Iconfont is ligature-based (content:"printer", "bin", "pencil", …), so it
// is the literal-text failure above, not the PUA one: Monaspace has those ASCII
// glyphs and wins outright, printing the icon names across the FRITZ!Box UI.
// Password Dots is not an icon font but is likewise glyph-substitution only —
// without it the password field renders its filler chars instead of dots.
user_pref("browser.display.use_document_fonts", 0);
user_pref("browser.display.use_document_fonts.icon_font_allowlist", "Material Icons, Material Icons Extended, Material Icons Outlined, Material Icons Round, Material Icons Sharp, Material Icons Two Tone, Google Material Icons, Google Material Icons Filled, Material Symbols, Material Symbols Outlined, Material Symbols Round, Material Symbols Rounded, Material Symbols Sharp, Material Symbols Rounded Non Filled, Google Symbols, FontAwesome, Font Awesome 5 Free, Font Awesome 5 Brands, Font Awesome 6 Free, Font Awesome 6 Brands, upsicons, UPS Material Symbols, UPS Material Symbols Filled, DBWebIconFont, Deutsche_Bahn_VUX, db-default, db-filled, db-ux-default, db-ux-filled, icon-font-fallback, missing-icons, icons-16-outline, icons-20-outline, icons-24-outline, icons-32-outline, icons-48-outline, icons-64-outline, icons-16-filled, icons-20-filled, icons-24-filled, icons-32-filled, icons-48-filled, icons-64-filled, FDS-Iconfont, Password Dots");

// The override font the allowlist exists to hold back. Kept here so the two stay
// in sync — note Monaspace has no Private Use Area coverage, which is what lets
// PUA-based icon fonts still fall through. A Nerd Font here would break that.
user_pref("font.name.serif.x-western", "Monaspace Krypton");
user_pref("font.name.sans-serif.x-western", "Monaspace Krypton");
user_pref("font.name.monospace.x-western", "Monaspace Krypton");
user_pref("devtools.chrome.enabled", true);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
