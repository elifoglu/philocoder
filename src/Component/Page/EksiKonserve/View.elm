module EksiKonserve.View exposing (..)

import App.Model exposing (Exception)
import App.Msg exposing (Msg(..))
import DataResponse exposing (EksiKonserveTopic)
import Html exposing (Html, a, button, div, hr, text)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)


viewEksiKonserveDiv : List EksiKonserveTopic -> List Exception -> Html Msg
viewEksiKonserveDiv topics exceptions =
    div []
        [ div []
            [ if List.isEmpty topics then
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
            ]
        , viewExceptionsDiv exceptions
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


viewExceptionsDiv : List Exception -> Html Msg
viewExceptionsDiv exceptions =
    div []
        (exceptions
            |> List.map (\e -> text e)
            |> List.intersperse (hr [] [])
        )
