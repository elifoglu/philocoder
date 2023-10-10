module Contents.View exposing (viewContentDivs)

import App.Model exposing (MaybeContentFadeOutData, Theme)
import App.Msg exposing (Msg)
import Content.Model exposing (Content)
import Content.View exposing (viewContentDiv)
import Html exposing (Html, div, hr)
import Html.Attributes exposing (style)


viewContentDivs : Theme -> MaybeContentFadeOutData -> Bool -> List Content -> List (Html Msg)
viewContentDivs activeTheme dataToFadeContent contentReadClickedAtLeastOnce contents =
    [ div [ style "margin-top" "20px" ]
        (contents
            |> List.map (viewContentDiv activeTheme dataToFadeContent Nothing contentReadClickedAtLeastOnce)
            |> List.intersperse (hr [] [])
        )
    ]
