module Contents.View exposing (viewContentDivs)

import App.Msg exposing (Msg)
import Content.Model exposing (Content)
import Content.View exposing (viewContentDiv)
import Html exposing (Html, br, div, hr)
import Html.Attributes exposing (style)
import Tag.Model exposing (ContentRenderType(..), Tag)
import Tag.Util exposing (contentRenderTypeOf)


viewContentDivs : List Content -> List (Html Msg)
viewContentDivs contents =
    [ div [ style "margin-top" "20px" ]
        (contents
            |> List.map viewContentDiv
            |> List.intersperse (hr [] [])
        )
    ]
