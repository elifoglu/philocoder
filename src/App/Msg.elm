module App.Msg exposing (..)

import App.Model exposing (CreateContentPageModel)
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
    | GotContentToPreview CreateContentPageModel (Result Http.Error GotContent)
    | CreateContentInputChanged CreateContentInputType String
    | CreateContent CreateContentPageModel
    | GoToPreviewContentPage CreateContentPageModel
    | GoToCreateContentPage CreateContentPageModel


type CreateContentInputType
    = Id
    | Title
    | Text
    | Date
    | PublishOrderInDay
    | Tags
    | Refs
    | Password
