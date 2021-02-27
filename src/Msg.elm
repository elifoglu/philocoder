module Msg exposing (..)

import Http
import Json.Decode as D exposing (Decoder, bool, field, int, map3, map4, maybe, string)


type Msg
    = TagSelected Tag
    | GotDataResponse (Result Http.Error DataResponse)
    | GotContentText ContentID (Result Http.Error String)


type alias ContentID =
    Int


type alias DataResponse =
    { nameOfActiveTag : String, allTags : List Tag, allContents : List GotContent }



--todo birebir aynı olsa bile gottag ve tag ayrımını yap


tagResponseDecoder : Decoder DataResponse
tagResponseDecoder =
    map3 DataResponse
        (field "nameOfActiveTag" string)
        (field "allTags" (D.list tagDecoder))
        (field "allContents" (D.list contentDecoder))


type alias Tag =
    { name : String, contentSortStrategy : String, showAsTag : Bool }


tagDecoder : Decoder Tag
tagDecoder =
    map3 Tag
        (field "name" string)
        (field "contentSortStrategy" string)
        (field "showAsTag" bool)


type alias GotContent =
    { title : String, maybeDate : Maybe GotContentDate, contentId : Int, tags : List String }


type alias GotContentDate =
    { year : Int, month : Int, day : Int, publishOrderInDay : Int }


contentDecoder : Decoder GotContent
contentDecoder =
    map4 GotContent
        (field "title" string)
        (field "date" (maybe contentDateDecoder))
        (field "contentId" int)
        (field "tags" (D.list string))


contentDateDecoder : Decoder GotContentDate
contentDateDecoder =
    map4 GotContentDate
        (field "year" int)
        (field "month" int)
        (field "day" int)
        (field "publishOrderInDay" int)
