module Tags.View exposing (viewTagTabs)

import App.Model exposing (Model)
import App.Msg exposing (Msg)
import Html exposing (Html)
import Tag.View exposing (viewTagTab)


viewTagTabs : Model -> List (Html Msg)
viewTagTabs model =
    model.allTags
        |> List.filter (\tag -> tag.showInHeader)
        |> List.map (viewTagTab model)
