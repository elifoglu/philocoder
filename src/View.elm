module View exposing (view)

import Content exposing (Content)
import ContentView exposing (contentDiv)
import Html exposing (..)
import Html.Attributes exposing (..)
import List exposing (member)
import Model exposing (..)
import Msg exposing (Msg(..), Tag)
import Sort exposing (sortContentsByStrategy)
import TabView exposing (..)


view : Model -> Html Msg
view model =
    div [] (css "../style.css" :: tabButtons model ++ [ div [] [ tabContentsDiv model ] ])


tabButtons : Model -> List (Html Msg)
tabButtons model =
    List.map (tabButton model.activeTag) model.allTags


tabContentsDiv : Model -> Html Msg
tabContentsDiv model =
    div [ class "tabContents" ]
        (case model.activeTag of
            Just tag ->
                tag
                    |> getContentsOfTag model.allContents
                    |> List.map contentDiv

            Nothing ->
                []
        )


getContentsOfTag : List Content -> Tag -> List Content
getContentsOfTag allContents tag =
    allContents
        |> List.filter (\content -> member tag content.tags)
        |> sortContentsByStrategy tag.contentSortStrategy


css : String -> Html msg
css path =
    node "link" [ rel "stylesheet", href path ] []
