module CreateContent.View exposing (..)

import App.Model exposing (CreateContentPageModel)
import App.Msg exposing (CreateContentInputType(..), Msg(..))
import Html exposing (Html, br, button, div, input, text, textarea)
import Html.Attributes exposing (placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)


viewCreateContentDiv : CreateContentPageModel -> Html Msg
viewCreateContentDiv model =
    div [] <|
        List.intersperse (br [] [])
            [ viewInput "text" "id" model.id (CreateContentInputChanged Id)
            , viewInput "text" "title (empty if does not exist)" model.title (CreateContentInputChanged Title)
            , viewInput "text" "dd.mm.yyyy (e.g. 3.4.2021 or 29.12.2021)" model.date (CreateContentInputChanged Date)
            , viewInput "text" "publishOrderInDay (1, 2, 3...)" model.publishOrderInDay (CreateContentInputChanged PublishOrderInDay)
            , viewInput "text" "tagNames (use comma to separate)" model.tags (CreateContentInputChanged Tags)
            , viewInput "text" "refIDs (use comma to separate)" model.refs (CreateContentInputChanged Refs)
            , viewInput "password" "password" model.password (CreateContentInputChanged Password)
            , viewContentTextArea "content" model.text (CreateContentInputChanged Text)
            , viewCreateContentButton (CreateContent model)
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
