module View exposing (view)

import ContentView exposing (contentDiv)
import Html exposing (..)
import Html.Attributes exposing (..)
import Tab exposing (..)
import TabView exposing (..)
import Msg exposing (Msg(..))
import Model exposing (..)

view : Model -> Html Msg
view model =
    div [ ] (css "style.css" :: (List.map tabButton model) ++ [ div [] [ tabContentsDiv model ]])

tabContentsDiv: Model -> Html Msg
tabContentsDiv model =
    div [ class "tabContents"]
        (List.map contentDiv (extractMaybeTab (List.head (List.filter tabIsActive model))).contents)

css : String -> Html msg
css path =
    node "link" [ rel "stylesheet", href path ] []