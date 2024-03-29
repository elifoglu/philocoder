module ContentSearch.View exposing (..)

import App.Model exposing (Theme)
import App.Msg exposing (Msg(..))
import Content.Model exposing (Content)
import Content.View exposing (viewContentDiv)
import Html exposing (Html, div, hr, input, span, text)
import Html.Attributes exposing (class, id, placeholder, style, type_, value)
import Html.Events exposing (onInput)


viewSearchContentDiv : Theme -> Bool -> String -> List Content -> Html Msg
viewSearchContentDiv activeTheme contentReadClickedAtLeastOnce searchKeyword contents =
    div []
        [ input [ type_ "text", id "contentSearchInput", class "contentSearchInput", placeholder "ara...", value searchKeyword, onInput GotSearchInput, style "width" "100px" ] []
        , span [ class "searchContentInfoText" ]
            [ text
                (if List.length contents > 0 then
                    String.fromInt (List.length contents) ++ " adet içerik bulundu"

                 else if String.length searchKeyword >= 5 && List.isEmpty contents then
                    "içerik bulunamadı"

                 else
                    "(en az 5 karakter girerek içerik ara)"
                )
            ]
        , div [ style "margin-top" "20px" ]
            (contents
                |> List.map (viewContentDiv activeTheme Nothing (Just searchKeyword) contentReadClickedAtLeastOnce)
                |> List.intersperse (hr [] [])
            )
        ]
