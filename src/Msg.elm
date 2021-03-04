module Msg exposing (..)

import Browser
import Http
import Json.Decode as D exposing (Decoder, bool, field, int, map, map2, map4, oneOf, string)
import Url


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotDataResponse (Result Http.Error DataResponse)
    | GotContentText ContentID (Result Http.Error String)


type alias Tag =
    { tagId : String, name : String, contentSortStrategy : String, showAsTag : Bool }



--todo birebir aynı olsa bile gottag ve tag ayrımını yap


type alias DataResponse =
    { allTags : List Tag, allContents : List GotContent }


dataResponseDecoder : Decoder DataResponse
dataResponseDecoder =
    map2 DataResponse
        (field "allTags" (D.list tagDecoder))
        (field "allContents" (D.list contentDecoder))


tagDecoder : Decoder Tag
tagDecoder =
    map4 Tag
        (field "tagId" string)
        (field "name" string)
        (field "contentSortStrategy" string)
        (field "showAsTag" bool)


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
