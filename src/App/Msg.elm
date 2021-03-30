module App.Msg exposing (..)

import Browser
import DataResponse exposing (ContentID, ContentsResponse, GotContent, TagsResponse)
import Http
import Tag.Model exposing (Tag)
import Url


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | GotAllTags (Result Http.Error TagsResponse)
    | GotContentsOfTag Tag (Result Http.Error ContentsResponse)
    | GotHomeContents (Result Http.Error ContentsResponse)
    | GotContent (Result Http.Error GotContent)
