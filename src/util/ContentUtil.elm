module ContentUtil exposing (..)

import Content exposing (Content, ContentDate(..), ContentText(..))
import Date exposing (format)
import Html exposing (Html, text)


getTextOfContent : Content -> String
getTextOfContent content =
    case content.text of
        Text str ->
            str

        NotRequestedYet ->
            ""


getTagsTextOfContent : Content -> Html msg
getTagsTextOfContent content =
    text
        (content.tags
            |> List.filter (\tag -> tag.showAsTag)
            |> List.map (\tag -> tag.name)
            |> List.map (\str -> "#" ++ str)
            |> String.join " "
        )


getDateTextOfContent : Content -> Html msg
getDateTextOfContent content =
    let
        dateText =
            case content.date of
                DateExists date _ ->
                    format "dd.MM.yy" date

                DateNotExists _ ->
                    ""
    in
    if String.isEmpty dateText then
        text ""

    else
        text (", " ++ dateText)
