module Model exposing (Model, Page(..))

import Browser.Navigation as Nav
import ContentModel exposing (Content)
import TagModel exposing (Tag)


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
