module Content.View exposing (viewContentDiv)

import App.Msg exposing (Msg)
import Content.Model exposing (Content)
import Content.Util exposing (maybeDateText, maybeDisplayableTagsOfContent)
import Html exposing (Html, a, div, img, p, span, text)
import Html.Attributes exposing (class, href, src, style)
import Markdown
import Tag.Model exposing (ContentRenderType(..), Tag)


viewContentDiv : Content -> Html Msg
viewContentDiv content =
    p []
        [ div []
            [ div [ class "title" ] [ viewContentTitle content.title ]
            , viewRefsTextOfContent content
            , addBrIfContentEitherHasTitleOrRefs content
            , viewMarkdownTextOfContent content
            ]
        , viewContentInfoDiv content
        ]


addBrIfContentEitherHasTitleOrRefs : Content -> Html Msg
addBrIfContentEitherHasTitleOrRefs content =
    case ( content.title, content.refs ) of
        ( Nothing, Nothing ) ->
            text ""

        ( _, _ ) ->
            text ""


viewContentTitle : Maybe String -> Html Msg
viewContentTitle maybeTitle =
    case maybeTitle of
        Just title ->
            text (title ++ " ")

        Nothing ->
            text ""


viewContentInfoDiv : Content -> Html Msg
viewContentInfoDiv content =
    div [ class "contentInfoDiv" ]
        ((case ( maybeDisplayableTagsOfContent content, maybeDateText content ) of
            ( Just displayableTagsOfContent, Just dateText ) ->
                viewTagLinks displayableTagsOfContent
                    ++ [ text (", " ++ dateText) ]

            ( _, _ ) ->
                []
         )
            ++ [ text " ", viewContentLinkWithLinkIcon content ]
        )


viewTagLinks : List Tag -> List (Html Msg)
viewTagLinks tags =
    tags
        |> List.map viewTagLink
        |> List.intersperse (text " ")


viewTagLink : Tag -> Html Msg
viewTagLink tag =
    a [ href ("/tags/" ++ tag.tagId), class "tagLink" ] [ text ("#" ++ tag.name) ]


viewContentLink : Html msg -> String -> Html msg
viewContentLink htmlToClick contentId =
    a [ href ("/contents/" ++ contentId) ]
        [ htmlToClick
        ]


viewContentLinkWithLinkIcon : Content -> Html msg
viewContentLinkWithLinkIcon content =
    viewContentLink (img [ class "navToContent", src "/link.svg" ] []) (String.fromInt content.contentId)


viewMarkdownTextOfContent : Content -> Html msg
viewMarkdownTextOfContent content =
    Markdown.toHtml [ class "markdownDiv contentFont" ] content.text


viewRefsTextOfContent : Content -> Html msg
viewRefsTextOfContent content =
    case content.refs of
        Just refs ->
            if List.isEmpty refs then
                text ""

            else
                div [ class "refsDiv" ]
                    [ span [ style "font-style" "italic" ] [ text "ilgili: " ]
                    , span []
                        (refs
                            |> List.map (\r -> viewContentLink (text r.text) r.id)
                            |> List.intersperse (text ", ")
                        )
                    ]

        Nothing ->
            text ""
