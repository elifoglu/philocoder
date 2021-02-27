module View exposing (view)

import ContentView exposing (contentDiv)
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Msg exposing (Msg(..))
import Tab exposing (..)
import TabView exposing (..)


view : Model -> Html Msg
view model =
    div [] (css "../style.css" :: List.map tabButton model ++ [ div [] [ tabContentsDiv model ] ])


tabContentsDiv : Model -> Html Msg
tabContentsDiv model =
    div [ class "tabContents" ]
        (case List.head (List.filter tabIsActive model) of
            Just tab ->
                List.map contentDiv tab.contents

            Nothing ->
                []
        )


css : String -> Html msg
css path =
    node "link" [ rel "stylesheet", href path ] []
