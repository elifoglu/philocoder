module App.View exposing (view)

import App.Model exposing (..)
import App.Msg exposing (Msg(..))
import Browser exposing (Document)
import Content.View exposing (viewContentDiv)
import Contents.View exposing (viewContentDivs)
import CreateContent.View exposing (viewCreateContentDiv)
import HomeNavigator.View exposing (viewHomeNavigator)
import Html exposing (..)
import Html.Attributes exposing (..)
import NotFound.View exposing (view404Div)
import Pagination.View exposing (viewPagination)
import Tag.Util exposing (tagWithMostContents)
import Tags.View exposing (viewTagTabs)
import UpdateContent.View exposing (viewUpdateContentDiv)


view : Model -> Document Msg
view model =
    { title = "Philocoder"
    , body =
        [ div []
            (viewHomeNavigator
                :: viewTagTabs model
                ++ [ div [ class "contents" ]
                        ((case model.activePage of
                            HomePage status ->
                                case status of
                                    NonInitialized _ ->
                                        []

                                    Initialized contents ->
                                        viewContentDivs model contents Nothing

                            ContentPage status ->
                                case status of
                                    NonInitialized _ ->
                                        []

                                    Initialized content ->
                                        [ viewContentDiv model (tagWithMostContents model) content ]

                            TagPage status ->
                                case status of
                                    NonInitialized _ ->
                                        []

                                    Initialized ( tag, contents, _ ) ->
                                        viewContentDivs model contents (Just tag)

                            CreateContentPage createContentPageModel maybeContentToPreview ->
                                [ viewCreateContentDiv model createContentPageModel maybeContentToPreview ]

                            UpdateContentPage updateContentPageModel maybeContentToPreview contentId ->
                                [ viewUpdateContentDiv model updateContentPageModel maybeContentToPreview contentId ]

                            CreatingContentPage ->
                                [ text "trying to create content..." ]

                            UpdatingContentPage ->
                                [ text "trying to update content..." ]

                            NotFoundPage ->
                                [ view404Div ]

                            MaintenancePage ->
                                [ text "*bakım çalışması*" ]
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
