module Content.View exposing (viewContentDiv)

import App.Model exposing (Model)
import App.Msg exposing (Msg)
import Content.Model exposing (Content, ContentDate(..), ContentText(..))
import Content.Util exposing (contentById, maybeDateText, maybeDisplayableTagsOfContent)
import Html exposing (Html, a, br, div, img, p, span, text)
import Html.Attributes exposing (class, href, src, style)
import List.Extra exposing (uniqueBy)
import Markdown
import Maybe.Extra exposing (values)
import Tag.Model exposing (ContentRenderType(..), Tag)


type alias ContentRenderFn =
    Model -> Content -> Html Msg


viewContentDiv : Model -> Maybe Tag -> Content -> Html Msg
viewContentDiv model maybeActiveTag content =
    case maybeActiveTag of
        Just tag ->
            viewContentFn tag.contentRenderType model content

        Nothing ->
            viewContentFn Normal model content


viewContentFn : ContentRenderType -> ContentRenderFn
viewContentFn contentRenderType =
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


viewContentText : Maybe String -> Html Msg
viewContentText maybeTitle =
    text
        (case maybeTitle of
            Just title ->
                title ++ " "

            Nothing ->
                ""
        )


viewContentInfoDiv : List Content -> Content -> Html Msg
viewContentInfoDiv allContents content =
    div [ style "margin-bottom" "25px" ]
        ((case ( maybeDisplayableTagsOfContent content, maybeDateText content ) of
            ( Just displayableTagsOfContent, Just dateText ) ->
                viewTagLinks displayableTagsOfContent
                    ++ [ text (", " ++ dateText) ]

            ( _, _ ) ->
                []
         )
            ++ [ viewRefsTextOfContent allContents content ]
        )


viewTagLinks : List Tag -> List (Html Msg)
viewTagLinks tags =
    tags
        |> List.map viewTagLink
        |> List.intersperse (text " ")


viewTagLink : Tag -> Html Msg
viewTagLink tag =
    a [ href ("/tags/" ++ tag.tagId), class "tagLink" ] [ text ("#" ++ tag.name) ]


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
                            "ilgili: "
                            :: (refContents
                                    |> List.map (\refContent -> viewContentLinkWithContentTitle refContent)
                                    |> List.intersperse (text ", ")
                               )
                        )
                    ]

        Nothing ->
            text ""
