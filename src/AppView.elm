module AppView exposing (view)

import AppModel exposing (..)
import Browser exposing (Document)
import Content.Model exposing (Content)
import Content.View exposing (..)
import HomeNavigator.View exposing (viewHomeNavigator)
import Html exposing (..)
import Html.Attributes exposing (..)
import List
import Msg exposing (Msg(..))
import NotFound exposing (view404Div)
import Tag.Model exposing (Tag)
import Tag.Util exposing (contentsOfTag, tagById, tagWithMostContents)
import Tag.View exposing (viewTagTabs)


view : Model -> Document Msg
view model =
    { title = "Philocoder"
    , body =
        [ div []
            ([ css "../style.css", viewHomeNavigator ]
                ++ viewTagTabs model
                ++ [ case model.activePage of
                        HomePage ->
                            viewContentsOfTagDiv model.allContents (tagWithMostContents model)

                        TagPage tagId ->
                            viewContentsOfTagDiv model.allContents (tagById model.allTags tagId)

                        ContentPage contentId ->
                            viewMaybeContentDiv model.allContents contentId

                        NotFoundPage ->
                            view404Div
                   ]
            )
        ]
    }


viewContentsOfTagDiv : List Content -> Maybe Tag -> Html Msg
viewContentsOfTagDiv allContents maybeTag =
    div [ class "contents" ]
        (case maybeTag of
            Just tag ->
                tag
                    |> contentsOfTag allContents
                    |> List.map viewContentDiv
                    |> List.intersperse viewContentSeparator

            Nothing ->
                [ view404Div ]
        )


css : String -> Html msg
css path =
    node "link" [ rel "stylesheet", href path ] []
