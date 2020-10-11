module Opm.OpmMonad (getDefaultOpmMonadSettings, runOpmMonad) where

import System.Environment

import XMonad
import XMonad.Hooks.ManageDocks(docks, avoidStruts)
import XMonad.Util.Run(spawnPipe)


opmTerminal = "alacritty"

opmLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
    where
        -- default tiling algorithm partitions the screen into two panes
        tiled = Tall nmaster delta ratio

        -- The default number of windows in the master pane
        nmaster = 1

        -- Default proportion of screen occupied by master pane
        ratio = 1/2

        -- Percent of screen to increment by when resizing panes
        delta = 3/100

getDefaultOpmMonadSettings = docks def {
        -- simple stuff
        terminal              = opmTerminal,
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
        layoutHook            = opmLayout
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
    xproc <- spawnPipe ("xmobar --screen=0 " ++ opmHomePath ++ "/etc/xmobar/xmobarrc")
    xproc <- spawnPipe ("xmobar --screen=1 " ++ opmHomePath ++ "/etc/xmobar/xmobarrc")
    xmonad getDefaultOpmMonadSettings

