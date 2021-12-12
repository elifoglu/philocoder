module CreateContent.View exposing (viewCreateContentDiv)

import App.Model exposing (CreateContentPageModel, Model, ReadingMode(..))
import App.Msg exposing (ContentInputType(..), Msg(..), PreviewContentModel(..))
import Component.Page.Util exposing (flipBoolAndToStr)
import Content.Model exposing (Content)
import Content.View exposing (viewContentDiv)
import Html exposing (Html, br, button, div, hr, input, label, span, text, textarea)
import Html.Attributes exposing (checked, name, placeholder, style, type_, value)
import Html.Events exposing (on, onClick, onInput)
import Json.Decode as Decode


viewCreateContentDiv : Model -> CreateContentPageModel -> Maybe Content -> Html Msg
viewCreateContentDiv model createContentPageModel maybeContentToPreview =
    div [] <|
        [ text "Create a new content using this content's data:"
        , viewInput "text" "id of content to copy" createContentPageModel.contentIdToCopy (ContentInputChanged ContentToCopy)
        , viewGetContentToCopyButton (GetContentToCopy createContentPageModel.contentIdToCopy)
        ]
            ++ List.intersperse (br [] [])
                [ viewInput "text" "id" createContentPageModel.id (ContentInputChanged Id)
                , viewInput "text" "title (empty if does not exist)" createContentPageModel.title (ContentInputChanged Title)
                , viewInput "text" "tagNames (use comma to separate)" createContentPageModel.tags (ContentInputChanged Tags)
                , viewInput "text" "refIDs (use comma to separate)" createContentPageModel.refs (ContentInputChanged Refs)
                , viewCheckBoxInput createContentPageModel.okForBlogMode (ContentInputChanged OkForBlogMode)
                , viewInput "password" "password" createContentPageModel.password (ContentInputChanged Password)
                , viewContentTextArea "content" createContentPageModel.text (ContentInputChanged Text)
                , div []
                    [ viewPreviewContentButton (PreviewContent <| PreviewForContentCreate createContentPageModel)
                    , viewCreateContentButton (CreateContent createContentPageModel)
                    ]
                , hr [] []
                , case maybeContentToPreview of
                    Just content ->
                        viewContentDiv content

                    Nothing ->
                        text "invalid content, or no content at all"
                ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg, style "width" "1000px" ] []


viewContentTextArea : String -> String -> (String -> msg) -> Html msg
viewContentTextArea p v toMsg =
    textarea [ placeholder p, value v, onInput toMsg, style "width" "1000px", style "height" "500px" ] []


viewCreateContentButton : msg -> Html msg
viewCreateContentButton msg =
    button [ onClick msg ] [ text "create new content" ]


viewPreviewContentButton : msg -> Html msg
viewPreviewContentButton msg =
    button [ onClick msg ] [ text "preview content" ]


viewGetContentToCopyButton : msg -> Html msg
viewGetContentToCopyButton msg =
    button [ onClick msg ] [ text "get content to copy" ]


viewCheckBoxInput : Bool -> (String -> Msg) -> Html Msg
viewCheckBoxInput okForBlogMode msgFn =
    span []
        [ label [] [ text "okForBlogMode" ]
        , span []
            [ input
                [ type_ "checkbox"
                , name "okForBlogMode"
                , checked okForBlogMode
                , on "change" (Decode.succeed (msgFn (flipBoolAndToStr okForBlogMode)))
                ]
                []
            ]
        ]
