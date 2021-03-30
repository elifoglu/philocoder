module App.Model exposing (Model, Page(..))

import Browser.Navigation as Nav
import Content.Model exposing (Content)
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
    | NonInitializedTagPage String
    | TagPage Tag (List Content)
    | NotFoundPage
