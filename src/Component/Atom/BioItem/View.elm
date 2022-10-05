module BioItem.View exposing (viewBioItemDiv)

import App.Msg exposing (Msg(..))
import BioItem.Model exposing (BioItem)
import Html exposing (Html, div, img, span, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Markdown


viewBioItemDiv : Maybe BioItem -> BioItem -> Html Msg
viewBioItemDiv maybeBioItemInfoToShow bioItem =
    span []
        [ span [ class "bioItem" ]
            [ text bioItem.name
            ]
        , case bioItem.info of
            Just info ->
                span []
                    [ img [ onClick (ClickOnABioItemInfo bioItem), class "openBioItemInfo", src (getProperInfoIcon maybeBioItemInfoToShow bioItem) ] []
                    , viewBioItemInfoModal bioItem info maybeBioItemInfoToShow
                    ]

            Nothing ->
                text ""
        ]


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
