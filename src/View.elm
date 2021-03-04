module View exposing (view)

import Browser exposing (Document)
import Content exposing (Content, viewContentDiv, viewMaybeContentDiv)
import Html exposing (..)
import Html.Attributes exposing (..)
import List
import Model exposing (..)
import Msg exposing (Msg(..), Tag)
import NotFound exposing (view404Div)
import Tag exposing (contentsOfTag, tagById, tagWithMostContents, viewTagTabs)


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

                        ContentPage contentId ->
                            viewMaybeContentDiv model.allContents contentId

                        TagPage tagId ->
                            viewContentsOfTagDiv model.allContents (tagById model.allTags tagId)

                        NotFoundPage ->
                            view404Div
                   ]
            )
        ]
    }


viewHomeNavigator : Html Msg
viewHomeNavigator =
    a [ class "homeLink", href "/" ]
        [ b [ style "font-weight" "bolder" ]
            [ text "philocoder" ]
        ]


viewContentsOfTagDiv : List Content -> Maybe Tag -> Html Msg
viewContentsOfTagDiv allContents maybeTag =
    div [ class "contents" ]
        (case maybeTag of
            Just tag ->
                tag
                    |> contentsOfTag allContents
                    |> List.map viewContentDiv

            Nothing ->
                [ view404Div ]
        )


css : String -> Html msg
css path =
    node "link" [ rel "stylesheet", href path ] []
