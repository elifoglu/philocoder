module App.Msg exposing (..)

import Browser
import DataResponse exposing (ContentID, DataResponse)
import Http
import Url


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotDataResponse (Result Http.Error DataResponse)
