module App.Msg exposing (..)

import App.Model exposing (CreateContentPageModel, CreateTagPageModel, Page, ReadingMode, UpdateContentPageData, UpdateTagPageModel)
import BioGroup.Model exposing (BioGroup)
import BioItem.Model exposing (BioItem)
import Browser
import Browser.Dom as Dom
import DataResponse exposing (AllTagsResponse, BioGroupID, BioItemID, BioResponse, ContentID, ContentReadResponse, ContentSearchResponse, ContentsResponse, EksiKonserveResponse, GotAllRefData, GotContent, HomePageDataResponse)
import Graph exposing (NodeId)
import Http
import Tag.Model exposing (Tag)
import Time
import Url


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | GotAllTagsResponse (Result Http.Error AllTagsResponse)
    | GotHomePageDataResponse (Result Http.Error HomePageDataResponse)
    | GotAllRefData (Result Http.Error GotAllRefData)
    | ReadingModeChanged ReadingMode
    | ConsumeModeChanged Bool
    | ContentReadChecked ContentID
    | GotSearchInput String
    | GotContentSearchResponse (Result Http.Error ContentSearchResponse)
    | FocusResult (Result Dom.Error ())
    | ShowAdditionalIcons
    | GoToContentViaContentGraph ContentID
    | GotBioResponse (Result Http.Error BioResponse)
    | ClickOnABioGroup BioGroupID
    | BioGroupDisplayInfoChanged BioGroup
    | ClickOnABioItemInfo BioItem
    | GotContentsOfTag Tag (Result Http.Error ContentsResponse)
    | GotContent (Result Http.Error GotContent)
    | GotContentToPreviewForCreatePage CreateContentPageModel (Result Http.Error GotContent)
    | GotContentToPreviewForUpdatePage ContentID UpdateContentPageData (Result Http.Error GotContent)
    | ContentInputChanged ContentInputType String
    | TagInputChanged TagInputType
    | LoginRegisterPageInputChanged LoginRegisterPageInputType String
    | TryLogin String String
    | TryRegister String String
    | GetContentToCopyForContentCreation Int
    | PreviewContent PreviewContentModel
    | CreateContent CreateContentPageModel
    | UpdateContent ContentID UpdateContentPageData
    | CreateTag CreateTagPageModel
    | UpdateTag String UpdateTagPageModel
    | GotTagUpdateOrCreationDoneResponse (Result Http.Error String)
    | GotLoginResponse LoginRequestType (Result Http.Error String)
    | GotRegisterResponse (Result Http.Error String)
    | Logout
    | GotContentReadResponse (Result Http.Error ContentReadResponse)
    | HideContentFromActiveTagPage ContentID Int (Maybe GotContent)
    | GotEksiKonserveResponse (Result Http.Error EksiKonserveResponse)
    | DeleteEksiKonserveTopic String
    | GotDeleteEksiKonserveTopicResponse (Result Http.Error EksiKonserveResponse)
    | DragStart NodeId ( Float, Float )
    | DragAt ( Float, Float )
    | DragEnd ( Float, Float )
    | Tick Time.Posix
    | GotTimeZone Time.Zone


type PreviewContentModel
    = PreviewForContentCreate CreateContentPageModel
    | PreviewForContentUpdate ContentID UpdateContentPageData


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
    | ShowInTagsOfContent Bool
    | ShowContentCount Bool
    | OrderIndex String
    | InfoContentId String
    | Pw String


type LoginRegisterPageInputType
    = Username
    | Pass


type LoginRequestType
    = AttemptAtInitialization
    | LoginRequestByUser
