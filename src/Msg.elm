module Msg exposing (..)

import Http
import Json.Decode exposing (Decoder, bool, field, map4, string)
import Tab exposing (Tab)


type Msg
    = TabSelected Tab
    | GotTags (Result Http.Error (List Tag))


type alias Tag =
    { name : String, contentSortStrategy : String, showAsTag : Bool, active : Bool }


tagDecoder : Decoder Tag
tagDecoder =
    map4 Tag
        (field "name" string)
        (field "contentSortStrategy" string)
        (field "showAsTag" bool)
        (field "active" bool)
