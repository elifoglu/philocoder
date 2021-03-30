module DataResponse exposing (ContentID, ContentsResponse, DateAndPublishOrder, GotContent, GotContentDate(..), GotTag, JustPublishOrder, TagsResponse, contentDecoder, contentsDecoder, tagsDecoder)

import Content.Model exposing (Ref)
import Json.Decode as D exposing (Decoder, andThen, bool, field, int, map, map2, map4, map6, map7, map8, maybe, oneOf, string, succeed)
import Tag.Model exposing (ContentRenderType(..))


type alias TagsResponse =
    List GotTag


type alias ContentsResponse =
    List GotContent


type alias GotTag =
    { tagId : String
    , name : String
    , contentSortStrategy : String
    , showAsTag : Bool
    , contentRenderType : ContentRenderType
    , showContentCount : Bool
    , showInHeader : Bool
    , contentCount : Int
    }


type alias GotContent =
    { title : Maybe String, date : GotContentDate, contentId : Int, content : String, tags : List String, refs : Maybe (List Ref) }


type alias ContentID =
    Int


type GotContentDate
    = DateExists DateAndPublishOrder
    | DateNotExists JustPublishOrder


type alias DateAndPublishOrder =
    { year : Int, month : Int, day : Int, publishOrderInDay : Int }


type alias JustPublishOrder =
    { publishOrderInDay : Int }


tagsDecoder : Decoder TagsResponse
tagsDecoder =
    D.list tagDecoder


contentsDecoder : Decoder ContentsResponse
contentsDecoder =
    D.list contentDecoder


tagDecoder : Decoder GotTag
tagDecoder =
    map8 GotTag
        (field "tagId" string)
        (field "name" string)
        (field "contentSortStrategy" string)
        (field "showAsTag" bool)
        (field "contentRenderType" contentRenderTypeDecoder)
        (field "showContentCount" bool)
        (field "showInHeader" bool)
        (field "contentCount" int)


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
    map6 GotContent
        (maybe (field "title" string))
        (field "date" contentDateDecoder)
        (field "contentId" int)
        (field "content" string)
        (field "tags" (D.list string))
        (maybe (field "refs" (D.list refDecoder)))


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


refDecoder : Decoder Ref
refDecoder =
    map2 Ref
        (field "text" string)
        (field "id" string)
