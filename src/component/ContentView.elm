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
            , contentTagsText content
            , contentDateText content
            ]
        , div [ style "max-width" "600px" ]
            [ Markdown.toHtml [] (getTextOfContent content)
            , br [] []
            , hr [] []
            , br [] []
            ]
        ]


getTextOfContent : Content -> String
getTextOfContent content =
    case content.text of
        Text str ->
            str

        NotRequestedYet ->
            ""


contentTagsText : Content -> Html msg
contentTagsText content =
    text
        (content.tags
            |> List.filter (\tag -> tag.showAsTag)
            |> List.map (\tag -> tag.name)
            |> List.map (\str -> "#" ++ str)
            |> String.join " "
        )


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
