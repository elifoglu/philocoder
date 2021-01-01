module Tab exposing (Tab, contentsSorted, extractMaybeTab, setActive, tabIsActive)

import Content exposing (Content)
import SortStrategy exposing (SortStrategy(..))


type alias Tab =
    { name : String, contents : List Content, active : Bool, sortStrategy : SortStrategy }


setActive : Tab -> Tab -> Tab
setActive selectedTab tab =
    if tab.name == selectedTab.name then
        { tab | active = True }

    else
        { tab | active = False }


tabIsActive : Tab -> Bool
tabIsActive tab =
    tab.active


extractMaybeTab : Maybe Tab -> Tab
extractMaybeTab maybeTab =
    case maybeTab of
        Just tab ->
            tab

        Nothing ->
            Tab "" [] False ASC


contentsSorted : Tab -> List Content
contentsSorted tab =
    if tab.sortStrategy == ASC then
        tab.contents

    else
        List.reverse tab.contents
