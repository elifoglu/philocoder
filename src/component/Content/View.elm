module Content.View exposing (viewContentDiv, viewContentDivs, viewContentSeparator)

import AppModel exposing (Model)
import Content.Model exposing (Content, ContentDate(..), ContentText(..))
import Content.Util exposing (contentById, maybeDateText, maybeTagsText)
import Html exposing (Html, a, br, div, hr, img, p, span, text)
import Html.Attributes exposing (class, href, src, style)
import List.Extra exposing (uniqueBy)
import Markdown
import Maybe.Extra exposing (values)
import Msg exposing (Msg)
import NotFound exposing (view404Div)
import Tag.Model exposing (ContentRenderType(..), Tag)
import Tag.Util exposing (contentsOfTag)


viewContentDivs : Model -> Maybe Tag -> List (Html Msg)
viewContentDivs model maybeTag =
    case maybeTag of
        Just tag ->
            tag
                |> contentsOfTag model.allContents
                |> List.map (viewContentDiv model maybeTag)
                |> List.intersperse (viewContentSeparator tag.contentRenderType)

        Nothing ->
            [ view404Div ]


viewContentDiv : Model -> Maybe Tag -> Content -> Html Msg
viewContentDiv model maybeActiveTag content =
    case maybeActiveTag of
        Just tag ->
            renderContentFn tag.contentRenderType model content

        Nothing ->
            viewContentInNormalView model content


type alias ContentRenderFn =
    Model -> Content -> Html Msg


renderContentFn : ContentRenderType -> ContentRenderFn
renderContentFn contentRenderType =
    case contentRenderType of
        Normal ->
            viewContentInNormalView

        Minified ->
            viewContentInMinifiedView


viewContentInNormalView : ContentRenderFn
viewContentInNormalView model content =
    p []
        [ span [ class "title" ] [ viewContentText content.title, viewContentLinkWithLinkIcon content ]
        , viewContentInfoDiv model.allContents content
        , div []
            [ viewMarkdownTextOfContent content
            , br [] []
            ]
        ]


viewContentInMinifiedView : ContentRenderFn
viewContentInMinifiedView _ content =
    p []
        [ div []
            [ viewContentLinkWithLinkIcon content
            , viewMarkdownTextOfContent content
            ]
        ]


viewContentInfoDiv : List Content -> Content -> Html Msg
viewContentInfoDiv allContents content =
    div [ style "margin-bottom" "25px" ]
        ((case ( maybeTagsText content, maybeDateText content ) of
            ( Just tagsText, Just contentText ) ->
                [ text (tagsText ++ ", " ++ contentText) ]

            ( _, _ ) ->
                []
         )
            ++ [ viewRefsTextOfContent allContents content ]
        )


viewContentText : Maybe String -> Html Msg
viewContentText maybeTitle =
    text
        (case maybeTitle of
            Just title ->
                title ++ " "

            Nothing ->
                ""
        )


viewContentLink : Html msg -> Int -> Html msg
viewContentLink htmlToClick contentId =
    a [ href ("/contents/" ++ String.fromInt contentId) ]
        [ htmlToClick
        ]



--viewContentLinkWithDate function may be useful for later


viewContentLinkWithDate : Content -> Html msg
viewContentLinkWithDate content =
    case maybeDateText content of
        Just dateText ->
            viewContentLink (text dateText) content.contentId

        Nothing ->
            text ""


viewContentLinkWithLinkIcon : Content -> Html msg
viewContentLinkWithLinkIcon content =
    viewContentLink (img [ class "navToContent", src "../link.svg" ] []) content.contentId


viewContentLinkWithContentTitle : Content -> Html msg
viewContentLinkWithContentTitle content =
    case content.title of
        Just exists ->
            viewContentLink (text exists) content.contentId

        Nothing ->
            viewContentLink (text (String.fromInt content.contentId)) content.contentId


viewMarkdownTextOfContent : Content -> Html msg
viewMarkdownTextOfContent content =
    Markdown.toHtml [ class "markdownDiv" ]
        (case content.text of
            Text str ->
                str

            NotRequestedYet ->
                ""
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
                div [ style "margin-top" "2px" ]
                    [ span []
                        (text
                            "refs: "
                            :: (refContents
                                    |> List.map (\refContent -> viewContentLinkWithContentTitle refContent)
                                    |> List.intersperse (text ", ")
                               )
                        )
                    ]

        Nothing ->
            text ""


viewContentSeparator : ContentRenderType -> Html Msg
viewContentSeparator contentRenderType =
    case contentRenderType of
        Tag.Model.Normal ->
            div []
                [ hr [] []
                , br [] []
                ]

        Tag.Model.Minified ->
            div [ style "margin-bottom" "40px" ]
                []
