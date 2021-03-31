module Contents.View exposing (viewContentDivs)

import App.Model exposing (Model)
import App.Msg exposing (Msg)
import Content.Model exposing (Content)
import Content.View exposing (viewContentDiv)
import Html exposing (Html, br, div, hr)
import Html.Attributes exposing (style)
import Tag.Model exposing (ContentRenderType(..), Tag)
import Tag.Util exposing (contentRenderTypeOf)


viewContentDivs : Model -> List Content -> Maybe Tag -> List (Html Msg)
viewContentDivs model contents maybeTag =
    contents
        |> List.map (viewContentDiv model maybeTag)
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
            div [ style "margin-bottom" "40px" ]
                []
