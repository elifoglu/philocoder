module App.Model exposing (CreateContentPageModel, Initializable(..), Model, NoVal(..), Page(..), UpdateContentPageModel, contentToUpdateContentPageModel, createContentPageModelEncoder, updateContentPageModelEncoder)

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


type Page
    = HomePage (Initializable NoVal (List Content))
    | ContentPage (Initializable Int Content)
    | TagPage (Initializable ( String, Maybe Int ) ( Tag, List Content, Pagination ))
    | CreateContentPage CreateContentPageModel (Maybe Content)
    | UpdateContentPage UpdateContentPageModel (Maybe Content) Int
    | CreatingContentPage
    | UpdatingContentPage
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
