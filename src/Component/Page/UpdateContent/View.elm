module UpdateContent.View exposing (viewUpdateContentDiv)

import App.Model exposing (CreateContentPageModel, Model, Theme, UpdateContentPageData)
import App.Msg exposing (ContentInputType(..), Msg(..), PreviewContentModel(..))
import Component.Page.Util exposing (flipBoolAndToStr)
import Content.Model exposing (Content)
import Content.View exposing (viewContentDiv)
import DataResponse exposing (ContentID)
import Html exposing (Html, br, button, div, hr, input, label, span, text, textarea)
import Html.Attributes exposing (checked, name, placeholder, style, type_, value)
import Html.Events exposing (on, onClick, onInput)
import Json.Decode as Decode


viewUpdateContentDiv : Theme -> UpdateContentPageData -> Maybe Content -> ContentID -> Html Msg
viewUpdateContentDiv activeTheme updateContentPageData maybeContentToPreview contentId =
    div [] <|
        List.intersperse (br [] [])
            [ viewDisabledInput "text" (String.fromInt contentId)
            , viewInput "text" "title (empty if does not exist)" updateContentPageData.title (ContentInputChanged Title)
            , viewInput "text" "tagNames (use comma to separate)" updateContentPageData.tags (ContentInputChanged Tags)
            , viewInput "text" "refIDs (use comma to separate)" updateContentPageData.refs (ContentInputChanged Refs)
            , viewInput "password" "password" updateContentPageData.password (ContentInputChanged Password)
            , viewCheckBoxInput updateContentPageData.okForBlogMode (ContentInputChanged OkForBlogMode)
            , viewContentTextArea "content" updateContentPageData.text (ContentInputChanged Text)
            , div []
                [ viewPreviewContentButton (PreviewContent <| PreviewForContentUpdate contentId updateContentPageData)
                , viewUpdateContentButton <| UpdateContent contentId updateContentPageData
                ]
            , hr [] []
            , case maybeContentToPreview of
                Just content ->
                    viewContentDiv activeTheme Nothing Nothing False content

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
    textarea [ placeholder p, value v, onInput toMsg, style "width" "1000px", style "height" "500px" ] []


viewUpdateContentButton : msg -> Html msg
viewUpdateContentButton msg =
    button [ onClick msg ] [ text "update content" ]


viewPreviewContentButton : msg -> Html msg
viewPreviewContentButton msg =
    button [ onClick msg ] [ text "preview content" ]


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
