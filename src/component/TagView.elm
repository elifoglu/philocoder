module TagView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Msg exposing (..)


tagButton : Maybe Tag -> Tag -> Html Msg
tagButton activeTag tag =
    button
        [ if tag.name == nameOf activeTag then
            class "tagButtonActive"

          else
            class "tagButton"
        , onClick (TagSelected tag)
        ]
        [ text tag.name ]


nameOf : Maybe Tag -> String
nameOf maybeTag =
    Maybe.withDefault "" (Maybe.map (\tag -> tag.name) maybeTag)
