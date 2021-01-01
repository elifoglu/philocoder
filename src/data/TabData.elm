module TabData exposing (..)

import Content exposing (Content)
import ContentData exposing (..)
import List exposing (member)
import SortStrategy exposing (SortStrategy(..))
import Tab exposing (..)


allTabs : List Tab
allTabs =
    List.map setContents
        [ ( "tümü", True, DESC )
        , ( "üstinsan", False, ASC )
        , ( "perspektif", False, DESC )
        , ( "özgün", False, DESC )
        , ( "günlük", False, DESC )
        , ( "kod", False, DESC )
        , ( "beni_oku.txt", False, DESC )
        ]


setContents : ( String, Bool, SortStrategy ) -> Tab
setContents ( name, active, sortStrategy ) =
    { name = name, contents = List.filter (contentBelongsToTab name) allContents, active = active, sortStrategy = sortStrategy }


contentBelongsToTab : String -> Content -> Bool
contentBelongsToTab tabName content =
    member tabName content.tabs
