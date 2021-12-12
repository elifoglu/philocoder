module App.Model exposing (CreateContentPageModel, CreateTagPageModel, Drag, Entity, GraphModel, IconInfo, Initializable(..), MaySendRequest(..), Model, NoVal(..), Page(..), ReadingMode(..), UpdateContentPageModel, UpdateTagPageModel, contentToCreateContentPageModel, contentToUpdateContentPageModel, createContentPageModelEncoder, createTagPageModelEncoder, updateContentPageModelEncoder, updateTagPageModelEncoder)

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
    , readingMode : ReadingMode
    , activePage : Page
    , allTags : List Tag
    , allRefData : Maybe GotAllRefData
    , icons : List IconInfo
    , graphModel : Maybe GraphModel
    , timeZone : Time.Zone
    }


type alias IconInfo =
    { urlToNavigate : String
    , iconImageUrl : String
    , marginRight : String
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
    = NotSelectedYet
    | BlogContents
    | AllContents


type Initializable a b
    = NonInitialized a
    | Initialized b


type MaySendRequest pageData
    = NoRequestSentYet pageData
    | RequestSent String


type Page
    = HomePage
    | ContentPage (Initializable Int Content)
    | TagPage (Initializable ( String, Maybe Int, Maybe String ) ( Tag, List Content, Pagination ))
    | CreateContentPage (MaySendRequest ( CreateContentPageModel, Maybe Content ))
    | UpdateContentPage (MaySendRequest ( UpdateContentPageModel, Maybe Content, Int ))
    | CreateTagPage (MaySendRequest CreateTagPageModel)
    | UpdateTagPage (MaySendRequest ( UpdateTagPageModel, String ))
    | NotFoundPage
    | MaintenancePage


type alias CreateContentPageModel =
    { id : String
    , title : String
    , text : String
    , tags : String
    , refs : String
    , okForBlogMode : Bool
    , password : String
    , contentIdToCopy : String
    }


type alias UpdateContentPageModel =
    { title : String
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
    , contentRenderType : String
    , showContentCount : Bool
    , headerIndex : String
    , password : String
    }


type alias UpdateTagPageModel =
    { infoContentId : String
    , password : String
    }


contentToCreateContentPageModel : Content -> CreateContentPageModel
contentToCreateContentPageModel content =
    { id = ""
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


contentToUpdateContentPageModel : Content -> UpdateContentPageModel
contentToUpdateContentPageModel content =
    { title = Maybe.withDefault "" content.title
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
        , ( "contentRenderType", Encode.string model.contentRenderType )
        , ( "showContentCount", Encode.bool model.showContentCount )
        , ( "headerIndex", Encode.string model.headerIndex )
        , ( "password", Encode.string model.password )
        ]


updateTagPageModelEncoder : UpdateTagPageModel -> Encode.Value
updateTagPageModelEncoder model =
    Encode.object
        [ ( "infoContentId", Encode.string model.infoContentId )
        , ( "password", Encode.string model.password )
        ]
