module ContentView exposing (viewContentDiv, viewMaybeContentDiv)

import ContentModel exposing (Content, ContentDate(..), ContentText(..))
import ContentUtil exposing (contentById)
import Date exposing (Date, format)
import Html exposing (Html, a, br, div, hr, img, p, span, text)
import Html.Attributes exposing (class, href, src, style)
import Markdown
import Msg exposing (Msg)
import NotFound exposing (view404Div)
import TagModel exposing (Tag)


viewContentDiv : Content -> Html Msg
viewContentDiv content =
    div [ class "contents" ]
        [ p [ style "margin-bottom" "30px" ]
            [ span [ class "title" ] [ text (content.title ++ " "), viewContentLink content.contentId ]
            , br [] []
            , viewTagsTextOfContent content
            , viewDateTextOfContent content
            ]
        , div [ style "max-width" "600px" ]
            [ viewMarkdownTextOfContent content
            , br [] []
            , hr [] []
            , br [] []
            ]
        ]


viewMaybeContentDiv : List Content -> Int -> Html Msg
viewMaybeContentDiv allContents contentId =
    case contentById allContents contentId of
        Just content ->
            viewContentDiv content

        Nothing ->
            view404Div


viewContentLink : Int -> Html msg
viewContentLink contentId =
    a [ href ("/contents/" ++ String.fromInt contentId) ]
        [ img [ class "navToContent", src "../link.svg" ] []
        ]


viewMarkdownTextOfContent : Content -> Html msg
viewMarkdownTextOfContent content =
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
