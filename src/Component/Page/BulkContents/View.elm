module BulkContents.View exposing (..)

import App.Msg exposing (Msg(..))
import Content.Model exposing (Content)
import Content.View exposing (viewContentDiv)
import Html exposing (Html, div, hr)
import Html.Attributes exposing (style)


viewBulkContentsDiv : Bool -> List Content -> Html Msg
viewBulkContentsDiv contentReadClickedAtLeastOnce contents =
    div []
        [ div [ style "margin-top" "20px" ]
            (contents
                |> List.map (viewContentDiv Nothing contentReadClickedAtLeastOnce)
                |> List.intersperse (hr [] [])
            )
        ]
