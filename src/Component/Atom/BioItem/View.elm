module BioItem.View exposing (viewBioItemDiv)

import App.Msg exposing (Msg)
import BioItem.Model exposing (BioItem)
import Html exposing (Html, span, text)
import Html.Attributes exposing (class)


viewBioItemDiv : BioItem -> Html Msg
viewBioItemDiv bioItem =
    span [ class "bioItem" ] [ text bioItem.name ]
