module BioItem.View exposing (viewBioItemDiv)

import App.Msg exposing (Msg(..))
import BioItem.Model exposing (BioItem)
import BioItem.Util exposing (separatorBioItem)
import Html exposing (Html, a, div, img, span, text)
import Html.Attributes exposing (class, href, src, style, target)
import Html.Events exposing (onClick)
import Markdown


viewBioItemDiv : Maybe BioItem -> BioItem -> Html Msg
viewBioItemDiv maybeBioItemInfoToShow bioItem =
    if bioItem == separatorBioItem then
        span [ class "bioItemSeparator" ] [ text "|" ]

    else
        span [ style "white-space" "nowrap" ]
            (case bioItem.info of
                Just info ->
                    if String.startsWith "http" info then
                        [ a [ href info, target "_blank" ]
                            [ span [ class "bioItem bioItemHasAnInfo" ]
                                [ text bioItem.name
                                ]
                            , img [ class "goToBioItemExternalLink", src "/external-link.svg" ] []
                            ]
                        ]

                    else
                        [ span [ class "bioItem bioItemHasAnInfo", onClick (ClickOnABioItemInfo bioItem) ]
                            [ text bioItem.name
                            ]
                        , span []
                            [ img [ onClick (ClickOnABioItemInfo bioItem), class "openBioItemInfo", src (getProperInfoIcon maybeBioItemInfoToShow bioItem) ] []
                            , viewBioItemInfoModal bioItem info maybeBioItemInfoToShow
                            ]
                        ]

                Nothing ->
                    [ span [ class "bioItem" ]
                        [ text bioItem.name
                        ]
                    ]
            )


getProperInfoIcon : Maybe BioItem -> BioItem -> String
getProperInfoIcon maybeBioItemToShowInfo bioItem =
    case maybeBioItemToShowInfo of
        Just bioItemToShowInfo ->
            if bioItemToShowInfo.bioItemID == bioItem.bioItemID then
                "/info.svg"

            else
                "/info-gray.svg"

        Nothing ->
            "/info-gray.svg"


viewBioItemInfoModal : BioItem -> String -> Maybe BioItem -> Html Msg
viewBioItemInfoModal bioItem info maybeBioItemToShowInfo =
    case maybeBioItemToShowInfo of
        Just bioItemToShowInfo ->
            if bioItemToShowInfo.bioItemID == bioItem.bioItemID then
                div []
                    [ div [ class "bioItemInfoContainer" ] [ Markdown.toHtml [ class "bioItemInfoMarkdownP" ] info ]
                    ]

            else
                text ""

        Nothing ->
            text ""
