module ContentView exposing (contentDiv)

import Content exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Markdown exposing (..)
import Msg exposing (..)


contentDiv : Content -> Html Msg
contentDiv content =
    div []
        [ p [ style "margin-bottom" "30px" ]
            [ span [ class "title" ] [ text content.title ]
            , br [] []
            , contentTabsText content
            , contentDateText content
            ]
        , div [ style "max-width" "600px" ]
            [ Markdown.toHtml [] content.text
            , br [] []
            , hr [] []
            , br [] []
            ]
        ]


contentTabsText : Content -> Html msg
contentTabsText content =
    text (" " ++ String.join " " (List.map (\str -> "#" ++ str) content.tabs))


contentDateText : Content -> Html msg
contentDateText content =
    let
        dateText =
            getDateAsText content
    in
    if String.isEmpty dateText then
        text ""

    else
        text (", " ++ dateText)
