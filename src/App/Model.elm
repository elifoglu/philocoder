module App.Model exposing (CreateContentPageModel, Model, Page(..), createContentPageModelEncoder)

import Browser.Navigation as Nav
import Content.Model exposing (Content)
import Json.Encode as Encode
import Pagination.Model exposing (Pagination)
import Tag.Model exposing (Tag)


type alias Model =
    { log : String
    , key : Nav.Key
    , activePage : Page
    , allTags : List Tag
    }


type Page
    = NonInitializedHomePage
    | HomePage (List Content)
    | NonInitializedContentPage Int
    | ContentPage Content
    | NonInitializedTagPage String (Maybe Int)
    | TagPage Tag (List Content) Pagination
    | CreateContentPage CreateContentPageModel
    | CreatingContentPage
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
