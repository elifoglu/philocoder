module Content.View exposing (viewContentDiv)

import App.Msg exposing (Msg(..))
import Content.Model exposing (Content)
import Content.Util exposing (maybeDateText, maybeDisplayableTagsOfContent)
import Html exposing (Html, a, div, img, input, label, p, span, text)
import Html.Attributes exposing (checked, class, href, src, style, title, type_)
import Html.Events exposing (on)
import Json.Decode as Decode
import Markdown
import Tag.Model exposing (Tag)


viewContentDiv : Bool -> Content -> Html Msg
viewContentDiv contentReadClickedAtLeastOnce content =
    p []
        [ div []
            [ div [ class "title" ] [ viewContentTitle content.title content.beautifiedText ]
            , viewRefsTextOfContent content
            , addBrIfContentEitherHasTitleOrRefs content
            , viewMarkdownTextOfContent content
            ]
        , viewContentInfoDiv content contentReadClickedAtLeastOnce
        ]


addBrIfContentEitherHasTitleOrRefs : Content -> Html Msg
addBrIfContentEitherHasTitleOrRefs content =
    case ( content.title, content.refs ) of
        ( Nothing, Nothing ) ->
            text ""

        ( _, _ ) ->
            text ""


viewContentTitle : Maybe String -> String -> Html Msg
viewContentTitle maybeTitle beautifiedText =
    case maybeTitle of
        Just title ->
            if title == beautifiedText then
                text ""

            else
                text (title ++ " ")

        Nothing ->
            text ""


viewContentInfoDiv : Content -> Bool -> Html Msg
viewContentInfoDiv content contentReadClickedAtLeastOnce =
    div [ class "contentInfoDiv" ]
        ((case ( maybeDisplayableTagsOfContent content, maybeDateText content ) of
            ( Just displayableTagsOfContent, Just dateText ) ->
                viewTagLinks displayableTagsOfContent
                    ++ [ text (", " ++ dateText) ]

            ( _, _ ) ->
                []
         )
            ++ [ text " ", viewContentLinkWithLinkIcon content, viewContentReadCheckSpan content contentReadClickedAtLeastOnce ]
        )


viewContentReadCheckSpan : Content -> Bool -> Html Msg
viewContentReadCheckSpan content contentReadClickedAtLeastOnce =
    span []
        [ input
            [ type_ "checkbox"
            , class "contentReadCheckBox"
            , checked content.isContentRead
            , on "change" (Decode.succeed (ContentReadChecked content.contentId))
            ]
            []
        , if contentReadClickedAtLeastOnce then
            text ""

          else
            label [] [ text "(okundu)" ]
        ]


viewTagLinks : List Tag -> List (Html Msg)
viewTagLinks tags =
    tags
        |> List.map viewTagLink
        |> List.intersperse (text " ")


viewTagLink : Tag -> Html Msg
viewTagLink tag =
    a [ href ("/tags/" ++ tag.tagId), class "tagLink" ] [ text ("#" ++ tag.name) ]


viewContentLink : Html msg -> String -> String -> Html msg
viewContentLink htmlToClick beautifiedText contentId =
    a [ href ("/contents/" ++ contentId), title beautifiedText ]
        [ htmlToClick
        ]


viewContentLinkWithLinkIcon : Content -> Html msg
viewContentLinkWithLinkIcon content =
    viewContentLink (img [ class "navToContent", src "/link.svg" ] []) "" (String.fromInt content.contentId)


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
                            |> List.map (\r -> viewContentLink (text r.text) r.beautifiedText r.id)
                            |> List.intersperse (text ", ")
                        )
                    ]

        Nothing ->
            text ""
