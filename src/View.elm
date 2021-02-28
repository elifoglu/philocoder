module View exposing (view)

import Content exposing (Content)
import ContentUtil exposing (getDateTextOfContent, getTagsTextOfContent, getTextOfContent)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List
import Markdown
import Model exposing (..)
import Msg exposing (Msg(..), Tag)
import TagUtil exposing (contentCountOfTag, getContentsOfTag, nameOfTag)


view : Model -> Html Msg
view model =
    div [] (css "../style.css" :: tagButtons model ++ [ div [] [ tagContentsDiv model ] ])


tagButtons : Model -> List (Html Msg)
tagButtons model =
    List.map (tagButton model) model.allTags


tagButton : Model -> Tag -> Html Msg
tagButton model tag =
    button
        [ if tag.name == nameOfTag model.activeTag then
            class "tagButtonActive"

          else
            class "tagButton"
        , onClick (TagSelected tag)
        ]
        [ text (tag.name ++ " (" ++ contentCountOfTag model tag ++ ")") ]


tagContentsDiv : Model -> Html Msg
tagContentsDiv model =
    div [ class "tagContents" ]
        (case model.activeTag of
            Just tag ->
                tag
                    |> getContentsOfTag model.allContents
                    |> List.map contentDiv

            Nothing ->
                []
        )


contentDiv : Content -> Html Msg
contentDiv content =
    div []
        [ p [ style "margin-bottom" "30px" ]
            [ span [ class "title" ] [ text content.title ]
            , br [] []
            , getTagsTextOfContent content
            , getDateTextOfContent content
            ]
        , div [ style "max-width" "600px" ]
            [ Markdown.toHtml [] (getTextOfContent content)
            , br [] []
            , hr [] []
            , br [] []
            ]
        ]


css : String -> Html msg
css path =
    node "link" [ rel "stylesheet", href path ] []
