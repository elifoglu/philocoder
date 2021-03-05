module Requests exposing (..)

import Constants exposing (contentApiURL, dataFilename)
import Content.Model exposing (Content)
import DataResponse exposing (dataResponseDecoder)
import Http
import Msg exposing (Msg(..))


getDataResponse : Cmd Msg
getDataResponse =
    Http.get
        { url = contentApiURL ++ dataFilename
        , expect = Http.expectJson GotDataResponse dataResponseDecoder
        }


getContentText : Content -> Cmd Msg
getContentText content =
    Http.get
        { url = contentApiURL ++ String.fromInt content.contentId
        , expect = Http.expectString (GotContentText content.contentId)
        }
