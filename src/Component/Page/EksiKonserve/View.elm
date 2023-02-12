module EksiKonserve.View exposing (..)

import App.Msg exposing (Msg(..))
import DataResponse exposing (EksiKonserveTopic)
import Html exposing (Html, a, button, div, text)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)


viewEksiKonserveDiv : List EksiKonserveTopic -> Html Msg
viewEksiKonserveDiv topics =
    if List.isEmpty topics then
        text "✓"

    else
        div []
            [ div [ class "eksiKonserveDiv" ]
                (topics
                    |> List.map viewTopicDiv
                )
            , div [ class "eksiKonserveDiv eksiKonserveUrlDiv" ]
                (List.append
                    (topics |> List.map viewUrlsOfTopicsDiv)
                    [ viewDeleteAllTopicsButton topics ]
                )
            ]


viewTopicDiv : EksiKonserveTopic -> Html Msg
viewTopicDiv topic =
    div []
        [ button [ class "deleteEksiKonserveTopicButton", onClick (DeleteEksiKonserveTopics [ topic.name ]) ] [ text "x" ]
        , a [ href topic.url ] [ text topic.name ]
        , text (" (" ++ String.fromInt topic.count ++ ")")
        ]


viewUrlsOfTopicsDiv : EksiKonserveTopic -> Html Msg
viewUrlsOfTopicsDiv topic =
    div []
        [ text topic.url ]


viewDeleteAllTopicsButton : List EksiKonserveTopic -> Html Msg
viewDeleteAllTopicsButton topics =
    let
        topicNames =
            topics
                |> List.map (\topic -> topic.name)
    in
    button [ class "deleteAllEksiKonserveTopicsButton", onClick (DeleteEksiKonserveTopics topicNames) ] [ text "delete all" ]
