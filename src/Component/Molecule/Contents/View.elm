module Contents.View exposing (viewContentDivs)

import App.Model exposing (MaybeContentFadeOutData)
import App.Msg exposing (Msg)
import Content.Model exposing (Content)
import Content.View exposing (viewContentDiv)
import Html exposing (Html, div, hr)
import Html.Attributes exposing (style)


viewContentDivs : MaybeContentFadeOutData -> Bool -> List Content -> List (Html Msg)
viewContentDivs dataToFadeContent contentReadClickedAtLeastOnce contents =
    [ div [ style "margin-top" "20px" ]
        (contents
            |> List.map (viewContentDiv dataToFadeContent contentReadClickedAtLeastOnce)
            |> List.intersperse (hr [] [])
        )
    ]
