module Requests exposing (getDataResponse)

import App.Msg exposing (Msg(..))
import Content.Model exposing (Content)
import DataResponse exposing (dataResponseDecoder)
import Http


getDataResponse : Cmd Msg
getDataResponse =
    Http.get
        { url = "http://localhost:8090/all"
        , expect = Http.expectJson GotDataResponse dataResponseDecoder
        }
