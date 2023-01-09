module CreateTag.View exposing (viewCreateTagDiv)

import App.Model exposing (CreateContentPageModel, CreateTagPageModel, Model)
import App.Msg exposing (Msg(..), PreviewContentModel(..), TagInputType(..))
import Html exposing (Html, br, button, div, input, label, span, text)
import Html.Attributes exposing (checked, placeholder, selected, style, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)


viewCreateTagDiv : Model -> CreateTagPageModel -> Html Msg
viewCreateTagDiv model createTagPageModel =
    div [] <|
        List.intersperse (br [] [])
            [ viewInput "text" "tagId" createTagPageModel.tagId (createTagInputMessage TagId)
            , viewInput "text" "name" createTagPageModel.name (createTagInputMessage Name)
            , viewInput "text" "contentSortStrategy" createTagPageModel.contentSortStrategy (createTagInputMessage ContentSortStrategy)
            , viewCheckBox "showInTagsOfContent" createTagPageModel.showInTagsOfContent (createTagInputMessage ShowInTagsOfContent)
            , viewCheckBox "showContentcount" createTagPageModel.showContentCount (createTagInputMessage ShowContentCount)
            , viewInput "text" "orderIndex" createTagPageModel.orderIndex (createTagInputMessage OrderIndex)
            , viewInput "password" "password" createTagPageModel.password (createTagInputMessage Pw)
            , div []
                [ viewCreateTagButton (CreateTag createTagPageModel)
                ]
            ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, selected True, onInput toMsg, style "width" "1000px" ] []


createTagInputMessage : (eitherStringOrBool -> TagInputType) -> eitherStringOrBool -> Msg
createTagInputMessage a b =
    TagInputChanged (a b)


viewCheckBox : String -> Bool -> (Bool -> msg) -> Html msg
viewCheckBox i s toMsg =
    span []
        [ label [] [ text i ]
        , input [ type_ "checkbox", checked s, onCheck toMsg ] []
        ]


viewCreateTagButton : msg -> Html msg
viewCreateTagButton msg =
    button [ onClick msg ] [ text "create new tag" ]
