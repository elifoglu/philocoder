module TabData exposing (..)

import Content exposing (Content)
import List exposing (member)
import TabInfo exposing (..)
import ContentData exposing (..)

allTabs : List Tab
allTabs =
  List.map setContents
  [ ("tümü", True)
  , ("üstinsan", False)
  , ("perspektif", False)
  , ("özgün", False)
  , ("günlük", False)
  , ("kod", False)
  , ("beni_oku.txt", False)
  ]

setContents : (String, Bool) -> Tab
setContents (name, active) =
  { name = name, contents = List.filter (contentBelongsToTab name) allContents , active = active }

contentBelongsToTab: String -> Content -> Bool
contentBelongsToTab tabName content =
  member tabName content.tabs