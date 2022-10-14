module App.Msg exposing (..)

import App.Model exposing (CreateContentPageModel, CreateTagPageModel, ReadingMode, UpdateContentPageModel, UpdateTagPageModel)
import BioGroup.Model exposing (BioGroup)
import BioItem.Model exposing (BioItem)
import Browser
import DataResponse exposing (BioGroupID, BioItemID, BioResponse, ContentID, ContentsResponse, GotAllRefData, GotContent, TagDataResponse)
import Graph exposing (NodeId)
import Http
import Tag.Model exposing (Tag)
import Time
import Url


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | GotTagDataResponseForHomePage (Result Http.Error TagDataResponse)
    | GotTagDataResponseForTagPage (Result Http.Error TagDataResponse)
    | GotTagDataResponseForContentPage (Result Http.Error TagDataResponse)
    | GotContentsOfTag Tag (Result Http.Error ContentsResponse)
    | GotContent (Result Http.Error GotContent)
    | GotAllRefData (Result Http.Error GotAllRefData)
    | GotContentToPreviewForCreatePage CreateContentPageModel (Result Http.Error GotContent)
    | GotContentToPreviewForUpdatePage ContentID UpdateContentPageModel (Result Http.Error GotContent)
    | ContentInputChanged ContentInputType String
    | TagInputChanged TagInputType
    | PreviewContent PreviewContentModel
    | CreateContent CreateContentPageModel
    | GetContentToCopy String
    | UpdateContent ContentID UpdateContentPageModel
    | CreateTag CreateTagPageModel
    | UpdateTag String UpdateTagPageModel
    | GotDoneResponse (Result Http.Error String)
    | GotBioResponse (Result Http.Error BioResponse)
    | ClickOnABioGroup BioGroupID
    | BioGroupDisplayInfoChanged BioGroup
    | ClickOnABioItemInfo BioItem
    | ReadingModeChanged ReadingMode
    | ShowAdditionalIcons
    | DragStart NodeId ( Float, Float )
    | DragAt ( Float, Float )
    | DragEnd ( Float, Float )
    | Tick Time.Posix
    | GoToContent ContentID
    | GotTimeZone Time.Zone


type PreviewContentModel
    = PreviewForContentCreate CreateContentPageModel
    | PreviewForContentUpdate ContentID UpdateContentPageModel


type ContentInputType
    = Id
    | Title
    | Text
    | Tags
    | Refs
    | OkForBlogMode
    | Password
    | ContentToCopy


type TagInputType
    = TagId String
    | Name String
    | ContentSortStrategy String
    | ShowAsTag Bool
    | ContentRenderType String
    | ShowContentCount Bool
    | HeaderIndex String
    | InfoContentId String
    | Pw String
