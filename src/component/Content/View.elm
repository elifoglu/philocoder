module Content.View exposing (viewContentDiv, viewContentSeparator, viewMaybeContentDiv)

import Content.Model exposing (Content, ContentDate(..), ContentText(..))
import Content.Util exposing (contentById)
import Date exposing (Date, format)
import Html exposing (Html, a, br, div, hr, img, p, span, text)
import Html.Attributes exposing (class, href, src, style)
import List.Extra exposing (uniqueBy)
import Markdown
import Maybe.Extra exposing (values)
import Msg exposing (Msg)
import NotFound exposing (view404Div)
import Tag.Model exposing (Tag)


viewContentDiv : List Content -> Content -> Html Msg
viewContentDiv allContents content =
    div [ class "contents" ]
        [ p [ style "margin-bottom" "30px" ]
            [ span [ class "title" ] [ text (content.title ++ " "), viewContentLinkWithLinkIcon content.contentId ]
            , br [] []
            , viewTagsTextOfContent content
            , viewDateTextOfContent content
            , br [] []
            , viewRefsTextOfContent allContents content
            ]
        , div [ style "max-width" "600px" ]
            [ viewMarkdownTextOfContent content
            , br [] []
            ]
        ]


viewMaybeContentDiv : List Content -> Int -> Html Msg
viewMaybeContentDiv allContents contentId =
    case contentById allContents contentId of
        Just content ->
            viewContentDiv allContents content

        Nothing ->
            view404Div


viewContentLink : Html msg -> Int -> Html msg
viewContentLink htmlToClick contentId =
    a [ href ("/contents/" ++ String.fromInt contentId) ]
        [ htmlToClick
        ]


viewContentLinkWithLinkIcon : Int -> Html msg
viewContentLinkWithLinkIcon contentId =
    viewContentLink (img [ class "navToContent", src "../link.svg" ] []) contentId


viewContentLinkWithContentTitle : Content -> Html msg
viewContentLinkWithContentTitle content =
    viewContentLink (text content.title) content.contentId


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


viewRefsTextOfContent : List Content -> Content -> Html msg
viewRefsTextOfContent allContents content =
    case content.refs of
        Just refContentIds ->
            let
                refContents =
                    refContentIds
                        |> List.map (contentById allContents)
                        |> values
                        |> uniqueBy (\c -> c.contentId)
            in
            if List.isEmpty refContents then
                text ""

            else
                span []
                    (text
                        "refs: "
                        :: (refContents
                                |> List.map (\refContent -> viewContentLinkWithContentTitle refContent)
                                |> List.intersperse (text ", ")
                           )
                    )

        Nothing ->
            text ""


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


viewContentSeparator : Html Msg
viewContentSeparator =
    div [ class "contents", style "max-width" "600px" ]
        [ hr [] []
        , br [] []
        ]
