module AppView exposing (view)

import AppModel exposing (..)
import Browser exposing (Document)
import Content.Util exposing (contentById)
import Content.View exposing (..)
import HomeNavigator.View exposing (viewHomeNavigator)
import Html exposing (..)
import Html.Attributes exposing (..)
import Msg exposing (Msg(..))
import NotFound exposing (view404Div)
import Tag.Util exposing (tagById, tagWithMostContents)
import Tag.View exposing (viewTagTabs)


view : Model -> Document Msg
view model =
    { title = "Philocoder"
    , body =
        [ div []
            ([ css "../style.css", viewHomeNavigator ]
                ++ viewTagTabs model
                ++ [ div [ class "contents" ]
                        (case model.activePage of
                            HomePage ->
                                viewContentDivs model (tagWithMostContents model)

                            TagPage tagId ->
                                viewContentDivs model (tagById model.allTags tagId)

                            ContentPage contentId ->
                                case contentById model.allContents contentId of
                                    Just content ->
                                        [ viewContentDiv model (tagWithMostContents model) content ]

                                    Nothing ->
                                        [ view404Div ]

                            NotFoundPage ->
                                [ view404Div ]
                        )
                   ]
            )
        ]
    }


css : String -> Html msg
css path =
    node "link" [ rel "stylesheet", href path ] []
