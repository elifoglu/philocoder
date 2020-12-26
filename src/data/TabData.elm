module TabData exposing (..)

import Tab exposing (..)
import ContentData exposing (..)

allTabs : List Tab
allTabs =
  [ { name = "Tab A", contents = [ContentData.contentA, ContentData.contentB], active = True }
  , { name = "Tab B", contents = [ContentData.contentC], active = False }
  ]