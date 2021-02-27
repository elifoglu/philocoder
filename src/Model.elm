module Model exposing (..)

import Content exposing (Content)
import Msg exposing (Tag)


type alias Model =
    { activeTag : Maybe Tag
    , allTags : List Tag
    , allContents : List Content
    }
