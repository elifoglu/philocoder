module ContentView exposing (..)

import Content exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Markdown exposing (..)
import Msg exposing (..)


contentDiv : Content -> Html Msg
contentDiv content =
    div []
        [ h3 [] [ text content.title ]
        , text (getDateAsText content)
        , div [ style "max-width" "600px" ]
            [ Markdown.toHtml [] content.text
            , br [] []
            , br [] []
            ]
        ]
