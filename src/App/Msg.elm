module App.Msg exposing (..)

import App.Model exposing (CreateContentPageModel, UpdateContentPageModel)
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
    | GotContentToPreviewForCreatePage CreateContentPageModel (Result Http.Error GotContent)
    | GotContentToPreviewForUpdatePage ContentID UpdateContentPageModel (Result Http.Error GotContent)
    | ContentInputChanged CreateContentInputType String
    | PreviewContent PreviewContentModel
    | CreateContent CreateContentPageModel
    | UpdateContent ContentID UpdateContentPageModel


type PreviewContentModel
    = PreviewForContentCreate CreateContentPageModel
    | PreviewForContentUpdate ContentID UpdateContentPageModel


type CreateContentInputType
    = Id
    | Title
    | Text
    | Date
    | PublishOrderInDay
    | Tags
    | Refs
    | Password
