module EksiKonserve.View exposing (..)

import App.Msg exposing (Msg(..))
import DataResponse exposing (EksiKonserveException, EksiKonserveTopic)
import Html exposing (Html, a, button, div, hr, text)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)


viewEksiKonserveDiv : List EksiKonserveTopic -> List EksiKonserveException -> Html Msg
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


viewExceptionsDiv : List EksiKonserveException -> Html Msg
viewExceptionsDiv exceptions =
    div []
        [ div []
            (exceptions
                |> List.map
                    (\e ->
                        button
                            [ class "eksiKonserveExceptionToggleButton"
                            , onClick (ToggleEksiKonserveException e.message)
                            ]
                            [ text (String.fromInt e.count) ]
                    )
            )
        , div []
            (exceptions
                |> List.filter (\e -> e.show)
                |> List.map (\e -> text e.message )
                |> List.intersperse (hr [] [])
            )
        ]
