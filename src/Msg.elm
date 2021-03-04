module Msg exposing (..)

import Browser
import Http
import HttpResponses exposing (ContentID, DataResponse)
import Url


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotDataResponse (Result Http.Error DataResponse)
    | GotContentText ContentID (Result Http.Error String)
