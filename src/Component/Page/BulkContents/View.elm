module BulkContents.View exposing (..)

import App.Model exposing (Theme)
import App.Msg exposing (Msg(..))
import Content.Model exposing (Content)
import Content.View exposing (viewContentDiv)
import Html exposing (Html, div, hr)
import Html.Attributes exposing (style)


viewBulkContentsDiv : Theme -> Bool -> List Content -> Html Msg
viewBulkContentsDiv activeTheme contentReadClickedAtLeastOnce contents =
    div []
        [ div [ style "margin-top" "20px" ]
            (contents
                |> List.map (viewContentDiv activeTheme Nothing Nothing contentReadClickedAtLeastOnce)
                |> List.intersperse (hr [] [])
            )
        ]
