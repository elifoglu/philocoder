module Requests exposing (getAllTags, getContent, getHomeContents, getTagContents)

import App.Msg exposing (Msg(..))
import DataResponse exposing (contentDecoder, contentsResponseDecoder, tagsDecoder)
import Http
import Tag.Model exposing (Tag)


getAllTags : Cmd Msg
getAllTags =
    Http.get
        { url = "http://localhost:8090/tags"
        , expect = Http.expectJson GotAllTags tagsDecoder
        }


getTagContents : Tag -> Maybe Int -> Cmd Msg
getTagContents tag maybePage =
    Http.get
        { url =
            "http://localhost:8090/contents?tagId="
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
        { url = "http://localhost:8090/contents?tagId=tumu"
        , expect = Http.expectJson GotHomeContents contentsResponseDecoder
        }


getContent : Int -> Cmd Msg
getContent contentId =
    Http.get
        { url = "http://localhost:8090/contents/" ++ String.fromInt contentId
        , expect = Http.expectJson GotContent contentDecoder
        }
