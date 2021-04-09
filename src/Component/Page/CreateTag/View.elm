module CreateTag.View exposing (viewCreateTagDiv)

import App.Model exposing (CreateContentPageModel, CreateTagPageModel, Model)
import App.Msg exposing (CreateTagInputType(..), Msg(..), PreviewContentModel(..))
import Html exposing (Html, br, button, div, input, label, select, span, text)
import Html.Attributes exposing (checked, for, id, placeholder, selected, style, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)
import Tag.Model exposing (Tag)


viewCreateTagDiv : Model -> CreateTagPageModel -> Html Msg
viewCreateTagDiv model createTagPageModel =
    div [] <|
        List.intersperse (br [] [])
            [ viewInput "text" "tagId" createTagPageModel.tagId (createTagInputMessageForStrings TagId)
            , viewInput "text" "name" createTagPageModel.name (createTagInputMessageForStrings Name)
            , viewInput "text" "contentSortStrategy" createTagPageModel.contentSortStrategy (createTagInputMessageForStrings ContentSortStrategy)
            , viewCheckBox "showAsTag" createTagPageModel.showAsTag (createTagInputMessageForStrings ShowAsTag)
            , viewInput "text" "contentRenderType" createTagPageModel.contentRenderType (createTagInputMessageForStrings ContentRenderType)
            , viewCheckBox "showContentcount" createTagPageModel.showContentCount (createTagInputMessageForStrings ShowContentCount)
            , viewCheckBox "showInHeader" createTagPageModel.showInHeader (createTagInputMessageForStrings ShowInHeader)
            , viewInput "password" "password" createTagPageModel.password (createTagInputMessageForStrings Pw)
            , div []
                [ viewCreateTagButton (CreateTag createTagPageModel)
                ]
            ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, selected True, onInput toMsg, style "width" "1000px" ] []


createTagInputMessageForStrings : (eitherStringOrBool -> CreateTagInputType) -> eitherStringOrBool -> Msg
createTagInputMessageForStrings a b =
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
