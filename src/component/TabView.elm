module TabView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Msg exposing (..)


tabButton : Maybe Tag -> Tag -> Html Msg
tabButton activeTab tab =
    button
        [ if tab.name == nameOf activeTab then
            class "tabButtonActive"

          else
            class "tabButton"
        , onClick (TagSelected tab)
        ]
        [ text tab.name ]


nameOf : Maybe Tag -> String
nameOf maybeTab =
    Maybe.withDefault "" (Maybe.map (\tab -> tab.name) maybeTab)
