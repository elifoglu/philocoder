module DataResponse exposing (ContentID, DataResponse, DateAndPublishOrder, GotContent, GotContentDate(..), GotTag, JustPublishOrder, dataResponseDecoder)

import Json.Decode as D exposing (Decoder, andThen, bool, field, int, map, map2, map4, map5, maybe, oneOf, string, succeed)
import Tag.Model exposing (ContentRenderType(..))


type alias DataResponse =
    { allTags : List GotTag, allContents : List GotContent }


type alias GotTag =
    { tagId : String, name : String, contentSortStrategy : String, showAsTag : Bool, contentRenderType : ContentRenderType }


type alias GotContent =
    { title : Maybe String, date : GotContentDate, contentId : Int, tags : List String, refs : Maybe (List Int) }


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
    map5 GotTag
        (field "tagId" string)
        (field "name" string)
        (field "contentSortStrategy" string)
        (field "showAsTag" bool)
        (field "contentRenderType" contentRenderTypeDecoder)


contentRenderTypeDecoder : Decoder ContentRenderType
contentRenderTypeDecoder =
    string
        |> andThen
            (\str ->
                case str of
                    "minified" ->
                        succeed Minified

                    _ ->
                        succeed Normal
            )


contentDecoder : Decoder GotContent
contentDecoder =
    map5 GotContent
        (maybe (field "title" string))
        (field "date" contentDateDecoder)
        (field "contentId" int)
        (field "tags" (D.list string))
        (maybe (field "refs" (D.list int)))


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
