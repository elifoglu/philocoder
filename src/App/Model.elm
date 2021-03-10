module App.Model exposing (Model, Page(..))

import Browser.Navigation as Nav
import Content.Model exposing (Content)
import Tag.Model exposing (Tag)


type alias Model =
    { log : String
    , key : Nav.Key
    , activePage : Page
    , allTags : List Tag
    , allContents : List Content
    }


type Page
    = HomePage
    | ContentPage Int
    | TagPage String
    | NotFoundPage
