module Msg exposing (..)

import Http
import Json.Decode as D exposing (Decoder, bool, field, int, map, map3, map4, oneOf, string)


type Msg
    = TagSelected Tag
    | GotDataResponse (Result Http.Error DataResponse)
    | GotContentText ContentID (Result Http.Error String)


type alias Tag =
    { name : String, contentSortStrategy : String, showAsTag : Bool }



--todo birebir aynı olsa bile gottag ve tag ayrımını yap


tagResponseDecoder : Decoder DataResponse
tagResponseDecoder =
    map3 DataResponse
        (field "nameOfActiveTag" string)
        (field "allTags" (D.list tagDecoder))
        (field "allContents" (D.list contentDecoder))


tagDecoder : Decoder Tag
tagDecoder =
    map3 Tag
        (field "name" string)
        (field "contentSortStrategy" string)
        (field "showAsTag" bool)


type alias DataResponse =
    { nameOfActiveTag : String, allTags : List Tag, allContents : List GotContent }


type alias ContentID =
    Int


type alias GotContent =
    { title : String, date : GotContentDate, contentId : Int, tags : List String }


contentDecoder : Decoder GotContent
contentDecoder =
    map4 GotContent
        (field "title" string)
        (field "date" contentDateDecoder)
        (field "contentId" int)
        (field "tags" (D.list string))


type GotContentDate
    = DateExists DateAndPublishOrder
    | DateNotExists JustPublishOrder


type alias DateAndPublishOrder =
    { year : Int, month : Int, day : Int, publishOrderInDay : Int }


type alias JustPublishOrder =
    { publishOrderInDay : Int }


dateAndPublishOrderDecoder : Decoder DateAndPublishOrder
dateAndPublishOrderDecoder =
    map4 DateAndPublishOrder
        (field "year" int)
        (field "month" int)
        (field "day" int)
        (field "publishOrderInDay" int)


justPublishOrderDecoder : Decoder JustPublishOrder
justPublishOrderDecoder =
    map JustPublishOrder (field "publishOrderInDay" int)


contentDateDecoder : Decoder GotContentDate
contentDateDecoder =
    oneOf
        [ map DateExists dateAndPublishOrderDecoder
        , map DateNotExists justPublishOrderDecoder
        ]
