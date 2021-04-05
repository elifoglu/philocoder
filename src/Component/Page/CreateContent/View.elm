module CreateContent.View exposing (viewCreateContentDiv)

import App.Model exposing (CreateContentPageModel, Model)
import App.Msg exposing (CreateContentInputType(..), Msg(..), PreviewContentModel(..))
import Content.Model exposing (Content)
import Content.View exposing (viewContentDiv)
import Html exposing (Html, br, button, div, hr, input, text, textarea)
import Html.Attributes exposing (placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Tag.Util exposing (tagWithMostContents)


viewCreateContentDiv : Model -> CreateContentPageModel -> Maybe Content -> Html Msg
viewCreateContentDiv model createContentPageModel maybeContentToPreview =
    div [] <|
        List.intersperse (br [] [])
            [ viewInput "text" "id" createContentPageModel.id (ContentInputChanged Id)
            , viewInput "text" "title (empty if does not exist)" createContentPageModel.title (ContentInputChanged Title)
            , viewInput "text" "dd.mm.yyyy (e.g. 3.4.2021 or 29.12.2021)" createContentPageModel.date (ContentInputChanged Date)
            , viewInput "text" "publishOrderInDay (1, 2, 3...)" createContentPageModel.publishOrderInDay (ContentInputChanged PublishOrderInDay)
            , viewInput "text" "tagNames (use comma to separate)" createContentPageModel.tags (ContentInputChanged Tags)
            , viewInput "text" "refIDs (use comma to separate)" createContentPageModel.refs (ContentInputChanged Refs)
            , viewInput "password" "password" createContentPageModel.password (ContentInputChanged Password)
            , viewContentTextArea "content" createContentPageModel.text (ContentInputChanged Text)
            , div []
                [ viewPreviewContentButton (PreviewContent <| PreviewForContentCreate createContentPageModel)
                , viewCreateContentButton (CreateContent createContentPageModel)
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


viewContentTextArea : String -> String -> (String -> msg) -> Html msg
viewContentTextArea p v toMsg =
    textarea [ placeholder p, value v, onInput toMsg, style "width" "1000px" ] []


viewCreateContentButton : msg -> Html msg
viewCreateContentButton msg =
    button [ onClick msg ] [ text "create new content" ]


viewPreviewContentButton : msg -> Html msg
viewPreviewContentButton msg =
    button [ onClick msg ] [ text "preview content" ]
