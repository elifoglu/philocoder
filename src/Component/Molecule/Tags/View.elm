module Tags.View exposing (viewTagTabs)

import App.Model exposing (Model)
import Html exposing (Html)
import Msg exposing (Msg)
import Tag.View exposing (viewTagTab)


viewTagTabs : Model -> List (Html Msg)
viewTagTabs model =
    List.map (viewTagTab model) model.allTags
