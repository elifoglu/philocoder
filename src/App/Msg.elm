module App.Msg exposing (..)

import App.Model exposing (CreateContentPageModel, CreateTagPageModel, Page, ReadingMode, UpdateContentPageModel, UpdateTagPageModel)
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
    | GotTagDataResponseForPage GotTagDataResponseForWhichPage (Result Http.Error TagDataResponse)
    | GotAllRefData (Result Http.Error GotAllRefData)
    | ReadingModeChanged ReadingMode
    | ShowAdditionalIcons
    | GoToContentViaContentGraph ContentID
    | GotBioResponse (Result Http.Error BioResponse)
    | ClickOnABioGroup BioGroupID
    | BioGroupDisplayInfoChanged BioGroup
    | ClickOnABioItemInfo BioItem
    | GotContentsOfTag Tag (Result Http.Error ContentsResponse)
    | GotContent (Result Http.Error GotContent)
    | GotContentToPreviewForCreatePage CreateContentPageModel (Result Http.Error GotContent)
    | GotContentToPreviewForUpdatePage ContentID UpdateContentPageModel (Result Http.Error GotContent)
    | ContentInputChanged ContentInputType String
    | TagInputChanged TagInputType
    | GetContentToCopy String
    | PreviewContent PreviewContentModel
    | CreateContent CreateContentPageModel
    | UpdateContent ContentID UpdateContentPageModel
    | CreateTag CreateTagPageModel
    | UpdateTag String UpdateTagPageModel
    | GotTagUpdateOrCreationDoneResponse (Result Http.Error String)
    | DragStart NodeId ( Float, Float )
    | DragAt ( Float, Float )
    | DragEnd ( Float, Float )
    | Tick Time.Posix
    | GotTimeZone Time.Zone


type GotTagDataResponseForWhichPage
    = PageHome
    | PageTag
    | PageContent
    | PageCreateContent
    | PageUpdateContent


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
