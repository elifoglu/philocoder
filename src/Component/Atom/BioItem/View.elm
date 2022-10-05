module BioItem.View exposing (viewBioItemDiv)

import App.Msg exposing (Msg(..))
import BioItem.Model exposing (BioItem)
import Html exposing (Html, img, span, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)


viewBioItemDiv : BioItem -> Html Msg
viewBioItemDiv bioItem =
    span []
        [ span [ class "bioItem" ]
            [ text bioItem.name
            ]
        , case bioItem.info of
            Just info ->
                span []
                    [ img [ onClick (ClickOnABioItemInfo bioItem.bioItemID), class "navToTagDesc", src "/info.svg" ] []
                    ]

            Nothing ->
                text ""
        ]
