module UpdateContent.View exposing (viewUpdateContentDiv)

import App.Model exposing (CreateContentPageModel, Model, UpdateContentPageModel)
import App.Msg exposing (ContentInputType(..), Msg(..), PreviewContentModel(..))
import Content.Model exposing (Content)
import Content.View exposing (viewContentDiv)
import DataResponse exposing (ContentID)
import Html exposing (Html, br, button, div, hr, input, text, textarea)
import Html.Attributes exposing (placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Tag.Util exposing (tagWithMostContents)


viewUpdateContentDiv : Model -> UpdateContentPageModel -> Maybe Content -> ContentID -> Html Msg
viewUpdateContentDiv model updateContentPageModel maybeContentToPreview contentId =
    div [] <|
        List.intersperse (br [] [])
            [ viewDisabledInput "text" (String.fromInt contentId)
            , viewInput "text" "title (empty if does not exist)" updateContentPageModel.title (ContentInputChanged Title)
            , viewInput "text" "dd.mm.yyyy (e.g. 3.4.2021 or 29.12.2021)" updateContentPageModel.date (ContentInputChanged Date)
            , viewInput "text" "publishOrderInDay (1, 2, 3...)" updateContentPageModel.publishOrderInDay (ContentInputChanged PublishOrderInDay)
            , viewInput "text" "tagNames (use comma to separate)" updateContentPageModel.tags (ContentInputChanged Tags)
            , viewInput "text" "refIDs (use comma to separate)" updateContentPageModel.refs (ContentInputChanged Refs)
            , viewInput "password" "password" updateContentPageModel.password (ContentInputChanged Password)
            , viewContentTextArea "content" updateContentPageModel.text (ContentInputChanged Text)
            , div []
                [ viewPreviewContentButton (PreviewContent <| PreviewForContentUpdate contentId updateContentPageModel)
                , viewUpdateContentButton <| UpdateContent contentId updateContentPageModel
                ]
            , hr [] []
            , case maybeContentToPreview of
                Just content ->
                    viewContentDiv model (tagWithMostContents model) content

                Nothing ->
                    text "invalid content, or no content at all"
            ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg, style "width" "1000px" ] []


viewDisabledInput : String -> String -> Html msg
viewDisabledInput t v =
    input [ type_ t, value v, style "width" "1000px", style "enabled" "false" ] []


viewContentTextArea : String -> String -> (String -> msg) -> Html msg
viewContentTextArea p v toMsg =
    textarea [ placeholder p, value v, onInput toMsg, style "width" "1000px" ] []


viewUpdateContentButton : msg -> Html msg
viewUpdateContentButton msg =
    button [ onClick msg ] [ text "update content" ]


viewPreviewContentButton : msg -> Html msg
viewPreviewContentButton msg =
    button [ onClick msg ] [ text "preview content" ]
