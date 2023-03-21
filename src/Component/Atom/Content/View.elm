module Content.View exposing (viewContentDiv)

import App.Model exposing (MaybeContentFadeOutData, MaybeTextToHighlight)
import App.Msg exposing (Msg(..))
import Content.Model exposing (Content, GotGraphData)
import Content.Util exposing (maybeDateText, maybeDisplayableTagsOfContent)
import DataResponse exposing (ContentID)
import ForceDirectedGraphForContent exposing (viewGraphForContent)
import Html exposing (Html, a, div, img, input, label, p, span, text)
import Html.Attributes exposing (checked, class, href, src, style, title, type_)
import Html.Events exposing (on)
import Json.Decode as Decode
import Markdown exposing (defaultOptions)
import Tag.Model exposing (Tag)


viewContentDiv : MaybeContentFadeOutData -> MaybeTextToHighlight -> Bool -> Content -> Html Msg
viewContentDiv dataToFadeContent textToHighlight contentReadClickedAtLeastOnce content =
    case content.graphDataIfGraphIsOn of
        Nothing ->
            viewContentDivWithoutGraph dataToFadeContent textToHighlight contentReadClickedAtLeastOnce content

        Just graphData ->
            if graphData.veryFirstMomentOfGraphHasPassed then
                div []
                    [ div [ class "graphForContent" ] [ viewGraphForContent content.contentId graphData.graphData.contentIds graphData.graphModel ]
                    , viewContentDivWithoutGraph dataToFadeContent textToHighlight contentReadClickedAtLeastOnce content
                    ]

            else
                text ""


viewContentDivWithoutGraph : MaybeContentFadeOutData -> MaybeTextToHighlight -> Bool -> Content -> Html Msg
viewContentDivWithoutGraph dataToFadeContent textToHighlight contentReadClickedAtLeastOnce content =
    p [ style "opacity" (getOpacityLevel content.contentId dataToFadeContent) ]
        [ div []
            [ div [ class "title" ] [ viewContentTitle content.title content.beautifiedText ]
            , viewRefsTextOfContent content
            , viewMarkdownTextOfContent content textToHighlight
            , viewFurtherReadingRefsTextOfContent content
            ]
        , viewContentInfoDiv content contentReadClickedAtLeastOnce
        ]


getOpacityLevel : ContentID -> MaybeContentFadeOutData -> String
getOpacityLevel contentId maybeContentFadeData =
    case maybeContentFadeData of
        Just data ->
            if contentId == data.contentIdToFade then
                String.fromFloat data.opacityLevel

            else
                "1"

        Nothing ->
            "1"


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
            ++ [ text " ", viewContentLinkWithLinkIcon content, viewGraphLink content, viewContentReadCheckSpan content contentReadClickedAtLeastOnce ]
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


viewGraphLink : Content -> Html Msg
viewGraphLink content =
    if List.isEmpty content.gotGraphData.connections then
        text ""

    else
        case content.graphDataIfGraphIsOn of
            Just _ ->
                a [ href ("/contents/" ++ String.fromInt content.contentId) ]
                    [ img [ class "contentPageToggleChecked", src "/graph.svg" ] [] ]

            Nothing ->
                a [ href ("/contents/" ++ String.fromInt content.contentId ++ "?graph=true") ]
                    [ img [ class "contentPageToggleChecked", src "/graph.svg" ] [] ]


viewMarkdownTextOfContent : Content -> MaybeTextToHighlight -> Html msg
viewMarkdownTextOfContent content maybeTextToHighlight =
    Markdown.toHtmlWith { defaultOptions | sanitize = False }
        [ class "markdownDiv contentFont" ]
        (case maybeTextToHighlight of
            Just textToHighlight ->
                -- Note: This highlighting feature is unfortunately case sensitive for now
                String.replace textToHighlight ("<span class=textToHighlight>" ++ textToHighlight ++ "</span>") content.text

            Nothing ->
                content.text
        )


viewRefsTextOfContent : Content -> Html msg
viewRefsTextOfContent content =
    if List.isEmpty content.refs then
        text ""

    else
        div [ class "refsDiv" ]
            [ span [ style "font-style" "italic" ] [ text "ilgili: " ]
            , span []
                (content.refs
                    |> List.map (\r -> viewContentLink (text r.text) r.beautifiedText r.id)
                    |> List.intersperse (text ", ")
                )
            ]


viewFurtherReadingRefsTextOfContent : Content -> Html msg
viewFurtherReadingRefsTextOfContent content =
    if List.isEmpty content.furtherReadingRefs then
        text ""

    else
        div [ class "refsDiv", style "margin-top" "25px", style "margin-bottom" "14px" ]
            [ span [ style "font-style" "italic" ] [ text "ileri okuma: " ]
            , span []
                (content.furtherReadingRefs
                    |> List.map (\r -> viewContentLink (text r.text) r.beautifiedText r.id)
                    |> List.intersperse (text ", ")
                )
            ]
