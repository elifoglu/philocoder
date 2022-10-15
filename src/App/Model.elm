module App.Model exposing (BioPageModel, CreateContentPageModel, CreateTagPageModel, Drag, Entity, GraphData, GraphModel, IconInfo, Initializable(..), InitializedTagPageModel, MaySendRequest(..), Model, NoVal(..), NonInitializedYetTagPageModel, Page(..), ReadingMode(..), UpdateContentPageModel, UpdateTagPageModel, createContentPageModelEncoder, createTagPageModelEncoder, setCreateContentPageModel, setUpdateContentPageModel, updateContentPageModelEncoder, updateTagPageModelEncoder)

import BioGroup.Model exposing (BioGroup)
import BioItem.Model exposing (BioItem)
import Browser.Navigation as Nav
import Content.Model exposing (Content)
import DataResponse exposing (ContentID, GotAllRefData, GotRefConnection)
import Force
import Graph exposing (Graph, NodeId)
import Json.Encode as Encode
import Pagination.Model exposing (Pagination)
import Tag.Model exposing (Tag)
import Time


type NoVal
    = NoVal


type alias Model =
    { log : String
    , key : Nav.Key
    , allTags : List Tag
    , activePage : Page
    , showAdditionalIcons : Bool
    , timeZone : Time.Zone
    }


type alias IconInfo =
    { urlToNavigate : String
    , iconImageUrl : String
    , marginLeft : String
    }


type alias GraphModel =
    { drag : Maybe Drag
    , graph : Graph Entity ()
    , simulation : Force.State NodeId
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


type Page
    = HomePage (List Tag) ReadingMode (Maybe GraphData)
    | ContentPage (Initializable Int Content)
    | TagPage (Initializable NonInitializedYetTagPageModel InitializedTagPageModel)
    | CreateContentPage (MaySendRequest CreateContentPageModel CreateContentPageModel)
    | UpdateContentPage (MaySendRequest ( UpdateContentPageModel, Int ) UpdateContentPageModel)
    | CreateTagPage (MaySendRequest CreateTagPageModel CreateTagPageModel)
    | UpdateTagPage (MaySendRequest ( UpdateTagPageModel, String ) UpdateTagPageModel)
    | BioPage (Maybe BioPageModel)
    | NotFoundPage
    | MaintenancePage


type alias GraphData =
    { allRefData : GotAllRefData
    , graphModel : GraphModel
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


type alias UpdateContentPageModel =
    { maybeContentToPreview : Maybe Content
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
    , showAsTag : Bool
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
    , refs =
        case content.refs of
            Just refs ->
                String.join "," (List.map (\ref -> ref.id) refs)

            Nothing ->
                ""
    , okForBlogMode = content.okForBlogMode
    , password = ""
    , contentIdToCopy = ""
    }


setUpdateContentPageModel : Content -> UpdateContentPageModel
setUpdateContentPageModel content =
    { maybeContentToPreview = Just content
    , title = Maybe.withDefault "" content.title
    , text = content.text
    , tags = String.join "," (List.map (\tag -> tag.name) content.tags)
    , refs =
        case content.refs of
            Just refs ->
                String.join "," (List.map (\ref -> ref.id) refs)

            Nothing ->
                ""
    , okForBlogMode = content.okForBlogMode
    , password = ""
    }


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


updateContentPageModelEncoder : ContentID -> UpdateContentPageModel -> Encode.Value
updateContentPageModelEncoder contentId model =
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
        , ( "showAsTag", Encode.bool model.showAsTag )
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
