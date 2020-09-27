module Opm.OpmMonad (getDefaultOpmMonadSettings) where

import XMonad

opmTerminal = "alacritty"

getDefaultOpmMonadSettings = def {
        -- simple stuff
        terminal              = opmTerminal
        -- focusFollowsMouse  = myFocusFollowsMouse,
        -- clickJustFocuses   = myClickJustFocuses,
        -- borderWidth        = myBorderWidth,
        -- modMask            = myModMask,
        -- workspaces         = myWorkspaces,
        -- normalBorderColor  = myNormalBorderColor,
        -- focusedBorderColor = myFocusedBorderColor,

        -- key bindings
        -- keys               = myKeys,
        -- mouseBindings      = myMouseBindings,

        -- hooks, layouts
        -- layoutHook         = myLayout,
        -- manageHook         = myManageHook,
        -- handleEventHook    = myEventHook,
        -- logHook            = myLogHook,
        -- startupHook        = myStartupHook
    }
