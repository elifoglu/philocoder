module Content.View exposing (viewContentDiv)

import App.Model exposing (Model)
import App.Msg exposing (Msg)
import Content.Model exposing (Content, ContentDate(..))
import Content.Util exposing (contentById, maybeDateText, maybeDisplayableTagsOfContent)
import Html exposing (Html, a, br, div, img, p, span, text)
import Html.Attributes exposing (class, href, src, style)
import List.Extra exposing (uniqueBy)
import Markdown
import Maybe.Extra exposing (values)
import Tag.Model exposing (ContentRenderType(..), Tag)


type alias ContentRenderFn =
    Content -> Html Msg


viewContentDiv : Model -> Maybe Tag -> Content -> Html Msg
viewContentDiv model maybeActiveTag content =
    case maybeActiveTag of
        Just tag ->
            viewContentFn tag.contentRenderType content

        Nothing ->
            viewContentFn Normal content


viewContentFn : ContentRenderType -> ContentRenderFn
viewContentFn contentRenderType =
    case contentRenderType of
        Normal ->
            viewContentInNormalView

        Minified ->
            viewContentInMinifiedView


viewContentInNormalView : ContentRenderFn
viewContentInNormalView content =
    p []
        [ span [ class "title" ] [ viewContentText content.title, viewContentLinkWithLinkIcon content ]
        , viewContentInfoDiv content
        , div []
            [ viewMarkdownTextOfContent content
            , br [] []
            ]
        ]


viewContentInMinifiedView : ContentRenderFn
viewContentInMinifiedView content =
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


viewContentInfoDiv : Content -> Html Msg
viewContentInfoDiv content =
    div [ style "margin-bottom" "25px" ]
        ((case ( maybeDisplayableTagsOfContent content, maybeDateText content ) of
            ( Just displayableTagsOfContent, Just dateText ) ->
                viewTagLinks displayableTagsOfContent
                    ++ [ text (", " ++ dateText) ]

            ( _, _ ) ->
                []
         )
            ++ [ viewRefsTextOfContent content ]
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



--viewContentLinkWithDate function may be useful for later


viewContentLinkWithDate : Content -> Html msg
viewContentLinkWithDate content =
    case maybeDateText content of
        Just dateText ->
            viewContentLink (text dateText) (String.fromInt content.contentId)

        Nothing ->
            text ""


viewContentLinkWithLinkIcon : Content -> Html msg
viewContentLinkWithLinkIcon content =
    viewContentLink (img [ class "navToContent", src "../link.svg" ] []) (String.fromInt content.contentId)


viewContentLinkWithContentTitle : String -> String -> Html msg
viewContentLinkWithContentTitle txt id =
    viewContentLink (text txt) id


viewMarkdownTextOfContent : Content -> Html msg
viewMarkdownTextOfContent content =
    Markdown.toHtml [ class "markdownDiv" ] content.text


viewRefsTextOfContent : Content -> Html msg
viewRefsTextOfContent content =
    case content.refs of
        Just refs ->
            if List.isEmpty refs then
                text ""

            else
                div [ style "margin-top" "2px" ]
                    [ span []
                        (text
                            "ilgili: "
                            :: (refs
                                    |> List.map (\r -> viewContentLinkWithContentTitle r.text r.id)
                                    |> List.intersperse (text ", ")
                               )
                        )
                    ]

        Nothing ->
            text ""
