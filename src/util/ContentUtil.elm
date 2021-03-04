module ContentUtil exposing (..)

import Content exposing (Content, ContentDate(..), ContentText(..))
import Date exposing (format)
import Html exposing (Html, text)
import Markdown


getContentById : List Content -> Int -> Maybe Content
getContentById contents id =
    contents
        |> List.filter (\a -> a.contentId == id)
        |> List.head


getTextOfContent : Content -> Html msg
getTextOfContent content =
    Markdown.toHtml []
        (case content.text of
            Text str ->
                str

            NotRequestedYet ->
                ""
        )


viewTagsTextOfContent : Content -> Html msg
viewTagsTextOfContent content =
    text
        (content.tags
            |> List.filter (\tag -> tag.showAsTag)
            |> List.map (\tag -> tag.name)
            |> List.map (\str -> "#" ++ str)
            |> String.join " "
        )


viewDateTextOfContent : Content -> Html msg
viewDateTextOfContent content =
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
