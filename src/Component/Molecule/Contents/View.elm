module Contents.View exposing (viewContentDivs)

import App.Msg exposing (Msg)
import Content.Model exposing (Content)
import Content.View exposing (viewContentDiv)
import Html exposing (Html, br, div, hr)
import Html.Attributes exposing (style)
import Tag.Model exposing (ContentRenderType(..), Tag)
import Tag.Util exposing (contentRenderTypeOf)


viewContentDivs : List Content -> Maybe Tag -> List (Html Msg)
viewContentDivs contents maybeTag =
    contents
        |> List.map (viewContentDiv maybeTag)
        |> List.intersperse (viewContentSeparator (contentRenderTypeOf maybeTag))


viewContentSeparator : ContentRenderType -> Html Msg
viewContentSeparator contentRenderType =
    case contentRenderType of
        Normal ->
            div []
                [ hr [] []
                , br [] []
                ]

        Minified ->
            div [ style "margin-bottom" "30px" ]
                []
