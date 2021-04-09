module App.Model exposing (CreateContentPageModel, CreateTagPageModel, Initializable(..), MaySendRequest(..), Model, NoVal(..), Page(..), UpdateContentPageModel, contentToUpdateContentPageModel, createContentPageModelEncoder, createTagPageModelEncoder, updateContentPageModelEncoder)

import Browser.Navigation as Nav
import Content.Model exposing (Content, ContentDate(..))
import DataResponse exposing (ContentID)
import Date exposing (day, monthNumber, year)
import Json.Encode as Encode
import Pagination.Model exposing (Pagination)
import Tag.Model exposing (Tag)


type NoVal
    = NoVal


type alias Model =
    { log : String
    , key : Nav.Key
    , activePage : Page
    , allTags : List Tag
    }


type Initializable a b
    = NonInitialized a
    | Initialized b


type MaySendRequest pageData
    = NoRequestSentYet pageData
    | RequestSent String


type Page
    = HomePage (Initializable NoVal (List Content))
    | ContentPage (Initializable Int Content)
    | TagPage (Initializable ( String, Maybe Int ) ( Tag, List Content, Pagination ))
    | CreateContentPage (MaySendRequest ( CreateContentPageModel, Maybe Content ))
    | UpdateContentPage (MaySendRequest ( UpdateContentPageModel, Maybe Content, Int ))
    | CreateTagPage (MaySendRequest CreateTagPageModel)
    | NotFoundPage
    | MaintenancePage


type alias CreateContentPageModel =
    { id : String
    , title : String
    , text : String
    , date : String
    , publishOrderInDay : String
    , tags : String
    , refs : String
    , password : String
    }


type alias UpdateContentPageModel =
    { title : String
    , text : String
    , date : String
    , publishOrderInDay : String
    , tags : String
    , refs : String
    , password : String
    }


type alias CreateTagPageModel =
    { tagId : String
    , name : String
    , contentSortStrategy : String
    , showAsTag : Bool
    , contentRenderType : String
    , showContentCount : Bool
    , showInHeader : Bool
    , password : String
    }


contentToUpdateContentPageModel : Content -> UpdateContentPageModel
contentToUpdateContentPageModel content =
    { title = Maybe.withDefault "" content.title
    , text = content.text
    , date =
        case content.date of
            DateExists date _ ->
                String.fromInt (day date) ++ "." ++ String.fromInt (monthNumber date) ++ "." ++ String.fromInt (year date)

            DateNotExists _ ->
                ""
    , publishOrderInDay =
        case content.date of
            DateExists _ publishOrderInDay ->
                String.fromInt publishOrderInDay

            DateNotExists publishOrderInDay ->
                String.fromInt publishOrderInDay
    , tags = String.join "," (List.map (\tag -> tag.name) content.tags)
    , refs =
        case content.refs of
            Just refs ->
                String.join "," (List.map (\ref -> ref.id) refs)

            Nothing ->
                ""
    , password = ""
    }


createContentPageModelEncoder : CreateContentPageModel -> Encode.Value
createContentPageModelEncoder model =
    Encode.object
        [ ( "id", Encode.string model.id )
        , ( "title", Encode.string model.title )
        , ( "text", Encode.string model.text )
        , ( "date", Encode.string model.date )
        , ( "publishOrderInDay", Encode.string model.publishOrderInDay )
        , ( "tags", Encode.string model.tags )
        , ( "refs", Encode.string model.refs )
        , ( "password", Encode.string model.password )
        ]


updateContentPageModelEncoder : ContentID -> UpdateContentPageModel -> Encode.Value
updateContentPageModelEncoder contentId model =
    Encode.object
        [ ( "id", Encode.string (String.fromInt contentId) )
        , ( "title", Encode.string model.title )
        , ( "text", Encode.string model.text )
        , ( "date", Encode.string model.date )
        , ( "publishOrderInDay", Encode.string model.publishOrderInDay )
        , ( "tags", Encode.string model.tags )
        , ( "refs", Encode.string model.refs )
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
        , ( "showInHeader", Encode.bool model.showInHeader )
        , ( "password", Encode.string model.password )
        ]
