from typing import Literal

Layer = Literal[
    "background",
    "bottom",
    "top",
    "overlay"
]

Anchor = Literal[
    "center-left",
    "center",
    "center-right",
    "top",
    "top-right",
    "top-center",
    "top-left",
    "bottom-left",
    "bottom-center",
    "bottom-right",
]

KeyboardMode = Literal[
    "none",
    "exclusive",
    "on-demand"
]

TransitionType = Literal[
    "none",
    "crossfade",
    "slide-right",
    "slide-left",
    "slide-up",
    "slide-down",
]
