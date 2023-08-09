module App.Model exposing (BioPageModel, ContentFadeOutData, ContentIDToColorize, CreateContentPageModel, CreateTagPageModel, Drag, Entity, GetBulkContentsRequestModel, GetContentRequestModel, GetTagContentsRequestModel, IconInfo, Initializable(..), InitializedTagPageModel, LocalStorage, MaySendRequest(..), MaybeContentFadeOutData, MaybeTextToHighlight, Model, NonInitializedYetTagPageModel, Page(..), ReadingMode(..), TotalPageCountRequestModel, UpdateContentPageData, UpdateContentPageModel(..), UpdateTagPageModel, createContentPageModelEncoder, createTagPageModelEncoder, getBulkContentsRequestModelEncoder, getContentRequestModelEncoder, getTagContentsRequestModelEncoder, setCreateContentPageModel, setUpdateContentPageModel, totalPageCountRequestModelEncoder, updateContentPageDataEncoder, updateTagPageModelEncoder)

import BioGroup.Model exposing (BioGroup)
import BioItem.Model exposing (BioItem)
import Browser.Navigation as Nav
import Content.Model exposing (Content, GotGraphData, GraphData)
import DataResponse exposing (ContentID, EksiKonserveException, EksiKonserveTopic, GotContent)
import Force
import Graph exposing (Graph, NodeId)
import Json.Encode as Encode
import Pagination.Model exposing (Pagination)
import Tag.Model exposing (Tag)
import Time


type alias Model =
    { log : String
    , key : Nav.Key
    , allTags : List Tag
    , activePage : Page
    , showAdditionalIcons : Bool
    , localStorage : LocalStorage
    , loggedIn : Bool
    , consumeModeIsOn : Bool
    , maybeContentFadeOutData : MaybeContentFadeOutData
    , waitingForContentCheckResponse : Bool
    , timeZone : Time.Zone
    }


type alias LocalStorage =
    { readingMode : ReadingMode, contentReadClickedAtLeastOnce : Bool, readMeIconClickedAtLeastOnce : Bool, username : String, password : String }


type alias OpacityLevel =
    Float


type alias ContentToAddToBottom =
    Maybe GotContent


type alias ContentFadeOutData =
    { opacityLevel : OpacityLevel
    , contentIdToFade : ContentID
    , newPageCountToSet : Int
    , contentToAddToBottom : ContentToAddToBottom
    }


type alias MaybeContentFadeOutData =
    Maybe ContentFadeOutData


type alias MaybeTextToHighlight =
    Maybe String


type alias IconInfo =
    { urlToNavigate : String
    , iconImageUrl : String
    , marginLeft : String
    }


type alias Entity =
    Force.Entity NodeId { value : String }


type alias Drag =
    { start : ( Float, Float )
    , current : ( Float, Float )
    , index : NodeId
    }


type ReadingMode
    = BlogContents
    | AllContents


type Initializable a b
    = NonInitialized a
    | Initialized b


type MaySendRequest pageData requestSentData
    = NoRequestSentYet pageData
    | RequestSent requestSentData


type UpdateContentPageModel
    = NotInitializedYet ContentID
    | GotContentToUpdate UpdateContentPageData
    | UpdateRequestIsSent UpdateContentPageData


type alias NonInitializedYetTagPageModel =
    { tagId : String
    , maybePage : Maybe Int
    , readingMode : ReadingMode
    }


type alias InitializedTagPageModel =
    { tag : Tag
    , contents : List Content
    , pagination : Pagination
    , readingMode : ReadingMode
    }


type alias BlogTagsToShow =
    Maybe (List Tag)


type alias AllTagsToShow =
    Maybe (List Tag)


type alias ContentIDToColorize =
    Maybe ContentID


type Page
    = HomePage BlogTagsToShow AllTagsToShow ReadingMode (Maybe GraphData)
    | ContentPage (Initializable ( Int, Bool ) Content)
    | TagPage (Initializable NonInitializedYetTagPageModel InitializedTagPageModel)
    | CreateContentPage (MaySendRequest CreateContentPageModel CreateContentPageModel)
    | UpdateContentPage UpdateContentPageModel
    | CreateTagPage (MaySendRequest CreateTagPageModel CreateTagPageModel)
    | UpdateTagPage (MaySendRequest ( UpdateTagPageModel, String ) UpdateTagPageModel)
    | BioPage (Initializable String BioPageModel)
    | ContentSearchPage String (List Content)
    | BulkContentsPage (Initializable String (List Content))
    | LoginOrRegisterPage String String String
    | GraphPage (Maybe GraphData)
    | NotFoundPage
    | MaintenancePage
    | EksiKonservePage (Initializable () ( List EksiKonserveTopic, List EksiKonserveException ))


type alias GetContentRequestModel =
    { contentID : Int
    , loggedIn : Bool
    , username : String
    , password : String
    }


type alias GetBulkContentsRequestModel =
    { contentIDs : String
    , loggedIn : Bool
    , username : String
    , password : String
    }


type alias GetTagContentsRequestModel =
    { tagId : String
    , page : Maybe Int
    , blogMode : Bool
    , loggedIn : Bool
    , consumeMode : Bool
    , username : String
    , password : String
    }


type alias TotalPageCountRequestModel =
    { tagId : String
    , blogMode : Bool
    , loggedIn : Bool
    , consumeMode : Bool
    , username : String
    , password : String
    }


type alias CreateContentPageModel =
    { maybeContentToPreview : Maybe Content
    , id : String
    , title : String
    , text : String
    , tags : String
    , refs : String
    , okForBlogMode : Bool
    , password : String
    , contentIdToCopy : String
    }


type alias UpdateContentPageData =
    { contentId : ContentID
    , maybeContentToPreview : Maybe Content
    , title : String
    , text : String
    , tags : String
    , refs : String
    , okForBlogMode : Bool
    , password : String
    }


type alias CreateTagPageModel =
    { tagId : String
    , name : String
    , contentSortStrategy : String
    , showInTagsOfContent : Bool
    , showContentCount : Bool
    , orderIndex : String
    , password : String
    }


type alias UpdateTagPageModel =
    { infoContentId : String
    , password : String
    }


type alias BioPageModel =
    { bioGroups : List BioGroup
    , bioItems : List BioItem
    , bioItemToShowInfo : Maybe BioItem
    }


setCreateContentPageModel : Content -> CreateContentPageModel
setCreateContentPageModel content =
    { maybeContentToPreview = Just content
    , id = ""
    , title = Maybe.withDefault "" content.title
    , text = content.text
    , tags = String.join "," (List.map (\tag -> tag.name) content.tags)
    , refs = String.join "," (List.map (\ref -> ref.id) content.refs)
    , okForBlogMode = content.okForBlogMode
    , password = ""
    , contentIdToCopy = ""
    }


setUpdateContentPageModel : Content -> UpdateContentPageData
setUpdateContentPageModel content =
    { contentId = content.contentId
    , maybeContentToPreview = Just content
    , title = Maybe.withDefault "" content.title
    , text = content.text
    , tags = String.join "," (List.map (\tag -> tag.name) content.tags)
    , refs = String.join "," (List.map (\ref -> ref.id) content.refs)
    , okForBlogMode = content.okForBlogMode
    , password = ""
    }


getContentRequestModelEncoder : GetContentRequestModel -> Encode.Value
getContentRequestModelEncoder model =
    Encode.object
        [ ( "contentID", Encode.string (String.fromInt model.contentID) )
        , ( "loggedIn", Encode.bool model.loggedIn )
        , ( "username", Encode.string model.username )
        , ( "password", Encode.string model.password )
        ]


getBulkContentsRequestModelEncoder : GetBulkContentsRequestModel -> Encode.Value
getBulkContentsRequestModelEncoder model =
    Encode.object
        [ ( "contentIDs", Encode.string model.contentIDs )
        , ( "loggedIn", Encode.bool model.loggedIn )
        , ( "username", Encode.string model.username )
        , ( "password", Encode.string model.password )
        ]


getTagContentsRequestModelEncoder : GetTagContentsRequestModel -> Encode.Value
getTagContentsRequestModelEncoder model =
    Encode.object
        [ ( "tagId", Encode.string model.tagId )
        , ( "page"
          , case model.page of
                Just page ->
                    Encode.int page

                Nothing ->
                    Encode.int 1
          )
        , ( "blogMode", Encode.bool model.blogMode )
        , ( "loggedIn", Encode.bool model.loggedIn )
        , ( "consumeMode", Encode.bool model.consumeMode )
        , ( "username", Encode.string model.username )
        , ( "password", Encode.string model.password )
        ]


totalPageCountRequestModelEncoder : TotalPageCountRequestModel -> Encode.Value
totalPageCountRequestModelEncoder model =
    Encode.object
        [ ( "tagId", Encode.string model.tagId )
        , ( "blogMode", Encode.bool model.blogMode )
        , ( "loggedIn", Encode.bool model.loggedIn )
        , ( "consumeMode", Encode.bool model.consumeMode )
        , ( "username", Encode.string model.username )
        , ( "password", Encode.string model.password )
        ]


createContentPageModelEncoder : CreateContentPageModel -> Encode.Value
createContentPageModelEncoder model =
    Encode.object
        [ ( "id", Encode.string model.id )
        , ( "title", Encode.string model.title )
        , ( "text", Encode.string model.text )
        , ( "tags", Encode.string model.tags )
        , ( "refs", Encode.string model.refs )
        , ( "okForBlogMode", Encode.bool model.okForBlogMode )
        , ( "password", Encode.string model.password )
        ]


updateContentPageDataEncoder : ContentID -> UpdateContentPageData -> Encode.Value
updateContentPageDataEncoder contentId model =
    Encode.object
        [ ( "id", Encode.string (String.fromInt contentId) )
        , ( "title", Encode.string model.title )
        , ( "text", Encode.string model.text )
        , ( "tags", Encode.string model.tags )
        , ( "refs", Encode.string model.refs )
        , ( "okForBlogMode", Encode.bool model.okForBlogMode )
        , ( "password", Encode.string model.password )
        ]


createTagPageModelEncoder : CreateTagPageModel -> Encode.Value
createTagPageModelEncoder model =
    Encode.object
        [ ( "tagId", Encode.string model.tagId )
        , ( "name", Encode.string model.name )
        , ( "contentSortStrategy", Encode.string model.contentSortStrategy )
        , ( "showInTagsOfContent", Encode.bool model.showInTagsOfContent )
        , ( "showContentCount", Encode.bool model.showContentCount )
        , ( "orderIndex", Encode.string model.orderIndex )
        , ( "password", Encode.string model.password )
        ]


updateTagPageModelEncoder : UpdateTagPageModel -> Encode.Value
updateTagPageModelEncoder model =
    Encode.object
        [ ( "infoContentId", Encode.string model.infoContentId )
        , ( "password", Encode.string model.password )
        ]
