module ContentView exposing (..)

import Content exposing (..)
import Html exposing (..)
import Msg exposing (..)


contentDiv : Content -> Html Msg
contentDiv content =
    div []
        [ h3 [] [ text content.title ]
        , pre []
            [ text content.text
            , br [] []
            , br [] []
            ]
        ]
