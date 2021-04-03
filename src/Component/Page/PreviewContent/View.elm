module PreviewContent.View exposing (viewPreviewContentDiv)

import App.Model exposing (CreateContentPageModel, Model)
import App.Msg exposing (CreateContentInputType(..), Msg(..))
import Content.Model exposing (Content)
import Content.View exposing (viewContentDiv)
import Html exposing (Html, br, button, div, text)
import Html.Events exposing (onClick)
import Tag.Util exposing (tagWithMostContents)


viewPreviewContentDiv : Model -> CreateContentPageModel -> Maybe Content -> Html Msg
viewPreviewContentDiv model createContentPageModel maybeContent =
    div []
        [ case maybeContent of
            Just content ->
                viewContentDiv model (tagWithMostContents model) content

            Nothing ->
                text "invalid content"
        , br [] []
        , viewBackButton <| GoToCreateContentPage createContentPageModel
        ]


viewBackButton : msg -> Html msg
viewBackButton msg =
    button [ onClick msg ] [ text "go back to content creation page" ]
