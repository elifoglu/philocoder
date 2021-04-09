module App.View exposing (view)

import App.Model exposing (..)
import App.Msg exposing (Msg(..))
import Browser exposing (Document)
import Content.View exposing (viewContentDiv)
import Contents.View exposing (viewContentDivs)
import CreateContent.View exposing (viewCreateContentDiv)
import CreateTag.View exposing (viewCreateTagDiv)
import HomeNavigator.View exposing (viewHomeNavigator)
import Html exposing (..)
import Html.Attributes exposing (..)
import NotFound.View exposing (view404Div)
import Pagination.View exposing (viewPagination)
import Tag.Util exposing (tagWithMostContents)
import TagInfoIcon.View exposing (viewTagInfoIcon)
import Tags.View exposing (viewTagTabs)
import UpdateContent.View exposing (viewUpdateContentDiv)
import UpdateTag.View exposing (viewUpdateTagDiv)


view : Model -> Document Msg
view model =
    { title = "Philocoder"
    , body =
        [ div []
            (viewHomeNavigator
                :: viewTagTabs model
                ++ [ div [ class "contents" ]
                        (case model.activePage of
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

                                    Initialized ( tag, contents, pagination ) ->
                                        viewContentDivs model contents (Just tag)
                                            ++ [ viewTagInfoIcon tag
                                               , viewPagination tag pagination
                                               ]

                            CreateContentPage status ->
                                case status of
                                    NoRequestSentYet ( createContentPageModel, maybeContentToPreview ) ->
                                        [ viewCreateContentDiv model createContentPageModel maybeContentToPreview ]

                                    RequestSent infoToShowAfterRequest ->
                                        [ text infoToShowAfterRequest ]

                            UpdateContentPage status ->
                                case status of
                                    NoRequestSentYet ( updateContentPageModel, maybeContentToPreview, contentId ) ->
                                        [ viewUpdateContentDiv model updateContentPageModel maybeContentToPreview contentId ]

                                    RequestSent infoToShowAfterRequest ->
                                        [ text infoToShowAfterRequest ]

                            CreateTagPage status ->
                                case status of
                                    NoRequestSentYet createTagPageModel ->
                                        [ viewCreateTagDiv model createTagPageModel ]

                                    RequestSent infoToShowAfterRequest ->
                                        [ text infoToShowAfterRequest ]

                            UpdateTagPage status ->
                                case status of
                                    NoRequestSentYet ( updateTagPageModel, tagId ) ->
                                        [ viewUpdateTagDiv updateTagPageModel tagId ]

                                    RequestSent infoToShowAfterRequest ->
                                        [ text infoToShowAfterRequest ]

                            NotFoundPage ->
                                [ view404Div ]

                            MaintenancePage ->
                                [ text "*bakım çalışması*" ]
                        )
                   ]
            )
        ]
    }


css : String -> Html msg
css path =
    node "link" [ rel "stylesheet", href path ] []
