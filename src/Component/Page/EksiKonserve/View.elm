module EksiKonserve.View exposing (..)

import App.Msg exposing (Msg(..))
import DataResponse exposing (EksiKonserveTopic)
import Html exposing (Html, a, button, div, text)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)


viewEksiKonserveDiv : List EksiKonserveTopic -> Html Msg
viewEksiKonserveDiv topics =
    div [ class "eksiKonserveDiv" ]
        (topics
            |> List.map viewTopicDiv
        )


viewTopicDiv : EksiKonserveTopic -> Html Msg
viewTopicDiv topic =
    div []
        [ button [ class "deleteEksiKonserveTopicButton", onClick (DeleteEksiKonserveTopic topic.name) ] [ text "x" ]
        , a [ href topic.url ] [ text topic.name ]
        , text (" (" ++ String.fromInt topic.count ++ ")")
        ]
