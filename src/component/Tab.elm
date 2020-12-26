module Tab exposing (..)

import Content exposing (Content)

type alias Tab = { name: String, contents: List Content, active: Bool }

setActive: Tab -> Tab -> Tab
setActive selectedTab tab =
     if (tab.name == selectedTab.name)
     then { tab | active = True }
     else { tab | active = False }

tabIsActive: Tab -> Bool
tabIsActive tab = tab.active

extractMaybeTab: Maybe Tab -> Tab
extractMaybeTab maybeTab = case maybeTab of
                     Just tab -> tab
                     Nothing -> Tab "" [] False