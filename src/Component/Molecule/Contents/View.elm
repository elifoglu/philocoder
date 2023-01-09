module Contents.View exposing (viewContentDivs)

import App.Msg exposing (Msg)
import Content.Model exposing (Content)
import Content.View exposing (viewContentDiv)
import Html exposing (Html, div, hr)
import Html.Attributes exposing (style)


viewContentDivs : Bool -> List Content -> List (Html Msg)
viewContentDivs contentReadClickedAtLeastOnce contents =
    [ div [ style "margin-top" "20px" ]
        (contents
            |> List.map (viewContentDiv contentReadClickedAtLeastOnce)
            |> List.intersperse (hr [] [])
        )
    ]
