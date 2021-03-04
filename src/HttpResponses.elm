module HttpResponses exposing (ContentID, DataResponse, DateAndPublishOrder, GotContent, GotContentDate(..), GotTag, JustPublishOrder, dataResponseDecoder)

import Json.Decode as D exposing (Decoder, bool, field, int, map, map2, map4, oneOf, string)



--todo change module name & add to a new directory


type alias DataResponse =
    { allTags : List GotTag, allContents : List GotContent }


type alias GotTag =
    { tagId : String, name : String, contentSortStrategy : String, showAsTag : Bool }


type alias GotContent =
    { title : String, date : GotContentDate, contentId : Int, tags : List String }


type alias ContentID =
    Int


type GotContentDate
    = DateExists DateAndPublishOrder
    | DateNotExists JustPublishOrder


type alias DateAndPublishOrder =
    { year : Int, month : Int, day : Int, publishOrderInDay : Int }


type alias JustPublishOrder =
    { publishOrderInDay : Int }


dataResponseDecoder : Decoder DataResponse
dataResponseDecoder =
    map2 DataResponse
        (field "allTags" (D.list tagDecoder))
        (field "allContents" (D.list contentDecoder))


tagDecoder : Decoder GotTag
tagDecoder =
    map4 GotTag
        (field "tagId" string)
        (field "name" string)
        (field "contentSortStrategy" string)
        (field "showAsTag" bool)


contentDecoder : Decoder GotContent
contentDecoder =
    map4 GotContent
        (field "title" string)
        (field "date" contentDateDecoder)
        (field "contentId" int)
        (field "tags" (D.list string))


contentDateDecoder : Decoder GotContentDate
contentDateDecoder =
    oneOf
        [ map DateExists dateAndPublishOrderDecoder
        , map DateNotExists justPublishOrderDecoder
        ]


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
