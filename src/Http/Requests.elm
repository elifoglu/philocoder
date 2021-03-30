module Requests exposing (getAllTags, getContent, getHomeContents, getTagContents)

import App.Msg exposing (Msg(..))
import DataResponse exposing (contentDecoder, contentsDecoder, tagsDecoder)
import Http
import Tag.Model exposing (Tag)


getAllTags : Cmd Msg
getAllTags =
    Http.get
        { url = "http://localhost:8090/tags"
        , expect = Http.expectJson GotAllTags tagsDecoder
        }


getTagContents : Tag -> Cmd Msg
getTagContents tag =
    Http.get
        { url = "http://localhost:8090/contents?tagId=" ++ tag.tagId
        , expect = Http.expectJson (GotContentsOfTag tag) contentsDecoder
        }


getHomeContents : Cmd Msg
getHomeContents =
    Http.get
        { url = "http://localhost:8090/contents?tagId=tumu"
        , expect = Http.expectJson GotHomeContents contentsDecoder
        }


getContent : Int -> Cmd Msg
getContent contentId =
    Http.get
        { url = "http://localhost:8090/contents/" ++ String.fromInt contentId
        , expect = Http.expectJson GotContent contentDecoder
        }
