module TabData exposing (..)

import Basics exposing (Order(..))
import Content exposing (Content, ContentDate(..))
import ContentData exposing (..)
import List exposing (member)
import Sort exposing (SortStrategy(..), sortContentsByStrategy)
import Tab exposing (..)


tümüTabName =
    "tümü"


allTabs : List Tab
allTabs =
    List.map setContents
        [ ( tümüTabName, True, DateDESC )
        , ( "üstinsan", False, DateASC )
        , ( "perspektif", False, DateDESC )
        , ( "özgün", False, DateDESC )
        , ( "günlük", False, DateDESC )
        , ( "kod", False, DateDESC )
        , ( "beni_oku.txt", False, DateDESC )
        ]


setContents : ( String, Bool, SortStrategy ) -> Tab
setContents ( name, active, sortStrategy ) =
    { name = name, contents = sortContentsByStrategy sortStrategy (getTabContents name), active = active }


getTabContents tabName =
    List.filter (contentBelongsToTab tabName) allContents


contentBelongsToTab : String -> Content -> Bool
contentBelongsToTab tabName content =
    member tabName content.tabs
