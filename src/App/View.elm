module App.View exposing (view)

import App.Model exposing (..)
import App.Msg exposing (Msg(..))
import Breadcrumb.View exposing (viewBreadcrumb)
import Browser exposing (Document)
import Content.View exposing (viewContentDiv)
import Contents.View exposing (viewContentDivs)
import CreateContent.View exposing (viewCreateContentDiv)
import CreateTag.View exposing (viewCreateTagDiv)
import ForceDirectedGraph exposing (viewGraph)
import Home.View exposing (viewHomePageDiv)
import Html exposing (..)
import Html.Attributes exposing (..)
import NotFound.View exposing (view404Div)
import Pagination.View exposing (viewPagination)
import UpdateContent.View exposing (viewUpdateContentDiv)
import UpdateTag.View exposing (viewUpdateTagDiv)


view : Model -> Document Msg
view model =
    { title = "Philocoder"
    , body =
        [ div []
            [ div [ class "header headerFont" ] <| viewBreadcrumb model
            , div [ class "body" ]
                (case model.activePage of
                    HomePage ->
                        [ viewHomePageDiv model
                        , div
                            [ style "width" "275px"
                            , style "height" "275px"
                            , style "display" "block"
                            , style "align-items" "center"
                            ]
                            (case model.allRefData of
                                Just allRefData ->
                                    [ viewGraph allRefData.contentIds model.graphModel ]

                                Nothing ->
                                    []
                            )
                        ]

                    ContentPage status ->
                        case status of
                            NonInitialized _ ->
                                []

                            Initialized content ->
                                [ viewContentDiv content ]

                    TagPage status ->
                        case status of
                            NonInitialized _ ->
                                []

                            Initialized ( tag, contents, pagination ) ->
                                viewContentDivs contents
                                    ++ [ viewPagination tag pagination
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
        ]
    }
