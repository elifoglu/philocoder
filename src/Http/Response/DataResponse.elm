module DataResponse exposing (ContentID, ContentsResponse, GotAllRefs, GotContent, GotContentDate, GotRef, GotTag, TagsResponse, allRefsDecoder, contentDecoder, contentsResponseDecoder, tagsDecoder)

import Content.Model exposing (Ref)
import Json.Decode as D exposing (Decoder, andThen, bool, field, int, map, map2, map3, map6, map8, maybe, oneOf, string, succeed)
import Tag.Model exposing (ContentRenderType(..))


type alias TagsResponse =
    List GotTag


type alias ContentsResponse =
    { totalPageCount : Int, contents : List GotContent }


type alias GotTag =
    { tagId : String
    , name : String
    , showAsTag : Bool
    , contentRenderType : ContentRenderType
    , showContentCount : Bool
    , headerIndex : Maybe Int
    , contentCount : Int
    , infoContentId : Maybe Int
    }


type alias GotContent =
    { title : Maybe String, dateAsTimestamp : GotContentDate, contentId : Int, content : String, tags : List String, refs : Maybe (List Ref) }


type alias ContentID =
    Int


type alias GotContentDate =
    String


type alias GotAllRefs =
    List GotRef


type alias GotRef =
    { a : Int, b : Int }


tagsDecoder : Decoder TagsResponse
tagsDecoder =
    D.list tagDecoder


contentsResponseDecoder : Decoder ContentsResponse
contentsResponseDecoder =
    map2 ContentsResponse
        (field "totalPageCount" int)
        (field "contents" (D.list contentDecoder))


allRefsDecoder : Decoder GotAllRefs
allRefsDecoder =
    D.list <|
        map2 GotRef
            (field "a" int)
            (field "b" int)


tagDecoder : Decoder GotTag
tagDecoder =
    map8 GotTag
        (field "tagId" string)
        (field "name" string)
        (field "showAsTag" bool)
        (field "contentRenderType" contentRenderTypeDecoder)
        (field "showContentCount" bool)
        (field "headerIndex" (maybe int))
        (field "contentCount" int)
        (field "infoContentId" (maybe int))


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
        (field "dateAsTimestamp" contentDateDecoder)
        (field "contentId" int)
        (field "content" string)
        (field "tags" (D.list string))
        (maybe (field "refs" (D.list refDecoder)))


contentDateDecoder : Decoder GotContentDate
contentDateDecoder =
    D.string


refDecoder : Decoder Ref
refDecoder =
    map2 Ref
        (field "text" string)
        (field "id" string)
