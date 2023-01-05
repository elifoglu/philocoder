module ContentSearch.View exposing (..)

import App.Msg exposing (Msg(..))
import Content.Model exposing (Content)
import Content.View exposing (viewContentDiv)
import Html exposing (Html, div, hr, input, span, text)
import Html.Attributes exposing (class, id, placeholder, style, type_, value)
import Html.Events exposing (onInput)


viewSearchContentDiv : String -> List Content -> Html Msg
viewSearchContentDiv searchKeyword contents =
    div []
        [ input [ type_ "text", id "contentSearchInput", class "contentSearchInput", placeholder "ara...", value searchKeyword, onInput GotSearchInput, style "width" "100px" ] []
        , if List.length contents > 0 then
            span [ class "searchContentInfoText" ] [ text (String.fromInt (List.length contents) ++ " adet içerik bulundu") ]

          else
            span [ class "searchContentInfoText" ] [ text "(en az 5 karakter girerek içerik ara)" ]
        , div [ style "margin-top" "20px" ]
            (contents
                |> List.map viewContentDiv
                |> List.intersperse (hr [] [])
            )
        ]
