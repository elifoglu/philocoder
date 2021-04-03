module Requests exposing (getAllTags, getContent, getHomeContents, getTagContents, postNewContent)

import App.Model exposing (CreateContentPageModel, createContentPageModelEncoder)
import App.Msg exposing (Msg(..))
import DataResponse exposing (contentDecoder, contentsResponseDecoder, tagsDecoder)
import Http
import Tag.Model exposing (Tag)


apiURL =
    "http://localhost:8090/"


getAllTags : Cmd Msg
getAllTags =
    Http.get
        { url = apiURL ++ "tags"
        , expect = Http.expectJson GotAllTags tagsDecoder
        }


getTagContents : Tag -> Maybe Int -> Cmd Msg
getTagContents tag maybePage =
    Http.get
        { url =
            apiURL
                ++ "contents?tagId="
                ++ tag.tagId
                ++ (case maybePage of
                        Just page ->
                            "&page=" ++ String.fromInt page

                        Nothing ->
                            ""
                   )
        , expect = Http.expectJson (GotContentsOfTag tag) contentsResponseDecoder
        }


getHomeContents : Cmd Msg
getHomeContents =
    Http.get
        { url = apiURL ++ "contents?tagId=tumu"
        , expect = Http.expectJson GotHomeContents contentsResponseDecoder
        }


getContent : Int -> Cmd Msg
getContent contentId =
    Http.get
        { url = apiURL ++ "contents/" ++ String.fromInt contentId
        , expect = Http.expectJson GotContent contentDecoder
        }


postNewContent : CreateContentPageModel -> Cmd Msg
postNewContent model =
    Http.post
        { url = apiURL ++ "contents"
        , body = Http.jsonBody (createContentPageModelEncoder model)
        , expect = Http.expectJson GotContent contentDecoder
        }
