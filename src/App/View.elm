module App.View exposing (view)

import App.Model exposing (..)
import App.Msg exposing (Msg(..))
import Browser exposing (Document)
import Content.Util exposing (contentById)
import Content.View exposing (viewContentDiv)
import Contents.View exposing (viewContentDivs)
import HomeNavigator.View exposing (viewHomeNavigator)
import Html exposing (..)
import Html.Attributes exposing (..)
import NotFound.View exposing (view404Div)
import Pagination.View exposing (viewPagination)
import Tag.Util exposing (tagById, tagWithMostContents)
import Tags.View exposing (viewTagTabs)


view : Model -> Document Msg
view model =
    { title = "Philocoder"
    , body =
        [ div []
            (viewHomeNavigator
                :: viewTagTabs model
                ++ [ div [ class "contents" ]
                        ((case model.activePage of
                            HomePage contents ->
                                viewContentDivs model contents Nothing

                            ContentPage content ->
                                [ viewContentDiv model (tagWithMostContents model) content ]

                            TagPage tag contents _ ->
                                viewContentDivs model contents (Just tag)

                            NotFoundPage ->
                                [ view404Div ]

                            _ ->
                                []
                         )
                            ++ [ viewPagination model.activePage ]
                        )
                   ]
            )
        ]
    }


css : String -> Html msg
css path =
    node "link" [ rel "stylesheet", href path ] []
