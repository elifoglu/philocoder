module App.View exposing (view)

import App.Model exposing (..)
import App.Msg exposing (Msg(..))
import Bio.View exposing (viewBioPageDiv)
import Breadcrumb.View exposing (viewBreadcrumb)
import Browser exposing (Document)
import Component.Page.Util exposing (areTagsLoaded)
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
    { title = "philocoder"
    , body =
        [ div []
            [ div [ class "header headerFont" ] <| viewBreadcrumb model
            , div [ class "body" ]
                (case model.activePage of
                    HomePage allTags blogModeTags readingMode ->
                        [ viewHomePageDiv allTags blogModeTags readingMode
                        , case readingMode of
                            AllContents ->
                                text ""

                            _ ->
                                if areTagsLoaded allTags then
                                    div [ class "graph" ]
                                        (case model.allRefData of
                                            Just allRefData ->
                                                [ viewGraph allRefData.contentIds model.graphModel (List.length allTags) ]

                                            Nothing ->
                                                []
                                        )

                                else
                                    text ""
                        ]

                    ContentPage status ->
                        case status of
                            NonInitialized _ ->
                                []

                            Initialized ( content, _ ) ->
                                [ viewContentDiv content ]

                    TagPage status ->
                        case status of
                            NonInitialized _ ->
                                []

                            Initialized initialized ->
                                viewContentDivs initialized.contents
                                    ++ [ viewPagination initialized.tag initialized.pagination initialized.readingMode
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

                    BioPage data ->
                        case data of
                            Just bioPageModel ->
                                [ viewBioPageDiv bioPageModel ]

                            Nothing ->
                                [ text "..." ]

                    NotFoundPage ->
                        [ view404Div ]

                    MaintenancePage ->
                        [ text "*bakım çalışması*" ]
                )
            ]
        ]
    }
