module Model exposing (Model, Page(..))

import Browser.Navigation as Nav
import Content exposing (Content)
import Msg exposing (Tag)
import Url


type alias Model =
    { log : String
    , key : Nav.Key
    , currentUrl : Url.Url
    , activePage : Page
    , allTags : List Tag
    , allContents : List Content
    }



--todo currenturl'e gerek yok, kaldırılabilir


type Page
    = HomePage
    | ContentPage Int
    | TagPage String
    | NotFoundPage
