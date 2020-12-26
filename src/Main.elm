port module Main exposing (..)

import Browser
import Msg exposing (Msg(..))
import Model exposing (..)
import View exposing (view)
import Tab
import TabData exposing (allTabs)

port title : String -> Cmd a

main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

init : () -> (Model, Cmd Msg)
init _ =
  ( allTabs
  , title "Philocoder"
  )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    TabSelected tab -> (List.map (Tab.setActive tab) model, Cmd.none)

view = View.view

subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none
