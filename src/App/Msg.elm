module App.Msg exposing (..)

import App.Model exposing (CreateContentPageModel, CreateTagPageModel, Page, ReadingMode, UpdateContentPageModel, UpdateTagPageModel)
import BioGroup.Model exposing (BioGroup)
import BioItem.Model exposing (BioItem)
import Browser
import DataResponse exposing (AllTagsResponse, BioGroupID, BioItemID, BioResponse, BlogTagsResponse, ContentID, ContentsResponse, GotAllRefData, GotContent)
import Graph exposing (NodeId)
import Http
import Tag.Model exposing (Tag)
import Time
import Url


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | GotAllTagsResponse (Result Http.Error AllTagsResponse)
    | GotBlogTagsResponse (Result Http.Error BlogTagsResponse)
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
    | GetContentToCopyForContentCreation Int
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
    | ShowContentCount Bool
    | OrderIndex String
    | InfoContentId String
    | Pw String
