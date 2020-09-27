module Opm.OpmMonad (getDefaultOpmMonadSettings, runOpmMonad) where

import System.Environment

import XMonad
import XMonad.Util.Run(spawnPipe)


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


getOpmHomePath = do
    env <- lookupEnv "OPM_HOME"
    case env of
        Nothing -> return ""
        Just v -> return v


runOpmMonad = do
    opmHomePath <- getOpmHomePath
    xproc <- spawnPipe ("xmobar " ++ opmHomePath ++ "/etc/xmobar/xmobarrc")
    xmonad getDefaultOpmMonadSettings

