pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: rosepine

    /* Background Colors */
    property color background: "#121212"        // Main background (dark purple with a hint of brown)
    property color background_alt: "#64748B"    // Secondary background (dark rose with a touch of purple)
    property color background_dark: "#121212"   // Darkest background (deep rose-purple)

    /* Text Colors */
    property color text_main: "#edecee"         // Primary text color (soft off-white with a hint of lavender)
    property color text_secondary: "#c4b8e3"    // Secondary text color (light lavender-gray)
    property color text_muted: "#a89bb9"        // Tertiary text, muted (soft grayish lavender)

    /* Surface Colors */
    property color surface_disabled: "#5c4a7f"  // Disabled items (muted purple)
    property color surface_neutral: "#3e3658"   // Neutral surface for cards, panels (dark bluish purple)
    property color surface_highlight: "#eb6f92" // Selection and highlights (vibrant rose-pink)

    /* Accent Colors */
    property color accent_light: "#f6a4c5"      // Light accent (soft pastel pink)
    property color accent_pink: "#eb6f92"       // Pink accent (vibrant rose-pink)
    property color accent_purple: "#a7b8d4"     // Purple accent (muted lavender)
    property color accent_red: "#eb6f92"        // Red for errors and warnings (rose-red)
    property color accent_orange: "#f7b585"     // Orange for alerts (soft peach)
    property color accent_yellow: "#f1c27d"     // Yellow for highlights (warm soft yellow)
    property color accent_green: "#8dbe8f"      // Green for success (soft pastel green)
    property color accent_teal: "#7fb5b5"       // Teal for information (soft teal)
    property color accent_blue: "#84a0c6"       // Blue for links and actions (soft pastel blue)
    property color accent_light_blue: "#92a9c6" // Sky blue accent (light blue)
    property color accent_lavender: "#c4b8e3"   // Lavender for subtle highlights (muted lavender)

    /* Overlay Colors */
    property color text_disabled: "#b6a6d3"     // Disabled text (muted lavender-gray)
    property color text_muted_light: "#a99bb3"  // Light-muted text for hints (light grayish lavender)
    property color text_muted_dark: "#6e5a80"   // Dark-muted text (soft purple-gray)
}
