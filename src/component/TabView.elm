module TabView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Tab exposing (..)
import Msg exposing (..)

tabButton: Tab -> Html Msg
tabButton tab =
     button [ if(tab.active) then (class "tabButtonActive") else (class "tabButton"), onClick (TabSelected tab) ]
       [ text tab.name ]
