module App.View exposing (view)

import App.Model exposing (..)
import App.Msg exposing (Msg(..))
import Bio.View exposing (viewBioPageDiv)
import Breadcrumb.View exposing (viewBreadcrumb)
import Browser exposing (Document)
import Component.Page.Util exposing (tagsLoaded)
import Content.View exposing (viewContentDiv)
import ContentSearch.View exposing (viewSearchContentDiv)
import Contents.View exposing (viewContentDivs)
import CreateContent.View exposing (viewCreateContentDiv)
import CreateTag.View exposing (viewCreateTagDiv)
import ForceDirectedGraph exposing (viewGraph)
import Home.View exposing (tagCountCurrentlyShownOnPage, viewHomePageDiv)
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
            [ div [ class "header" ] <| viewBreadcrumb model
            , div [ class "body" ]
                (case model.activePage of
                    HomePage blogTags readingMode maybeGraphData ->
                        if tagsLoaded blogTags then
                            case maybeGraphData of
                                Just graphData ->
                                    if graphData.veryFirstMomentOfGraphHasPassed then
                                        let
                                            tagsCount =
                                                tagCountCurrentlyShownOnPage readingMode model.allTags blogTags

                                            initialMarginTop =
                                                50

                                            heightOfASingleTagAsPx =
                                                20

                                            marginTopForGraph : Int
                                            marginTopForGraph =
                                                initialMarginTop + round (toFloat tagsCount * heightOfASingleTagAsPx)
                                        in
                                        [ viewHomePageDiv model.allTags blogTags readingMode
                                        , div [ class "graph", style "margin-top" (String.fromInt marginTopForGraph ++ "px") ] [ viewGraph graphData.allRefData.contentIds graphData.graphModel tagsCount ]
                                        ]

                                    else
                                        []

                                Nothing ->
                                    []

                        else
                            []

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

                            Initialized initialized ->
                                viewContentDivs initialized.contents
                                    ++ [ viewPagination initialized.tag initialized.pagination initialized.readingMode
                                       ]

                    CreateContentPage status ->
                        case status of
                            NoRequestSentYet createContentPageModel ->
                                [ viewCreateContentDiv createContentPageModel ]

                            RequestSent _ ->
                                [ text "..." ]

                    UpdateContentPage updateContentPageModel ->
                        case updateContentPageModel of
                            GotContentToUpdate updateContentPageData ->
                                [ viewUpdateContentDiv updateContentPageData updateContentPageData.maybeContentToPreview updateContentPageData.contentId ]

                            _ ->
                                [ text "..." ]

                    CreateTagPage status ->
                        case status of
                            NoRequestSentYet createTagPageModel ->
                                [ viewCreateTagDiv model createTagPageModel ]

                            RequestSent _ ->
                                [ text "..." ]

                    UpdateTagPage status ->
                        case status of
                            NoRequestSentYet ( updateTagPageModel, tagId ) ->
                                [ viewUpdateTagDiv updateTagPageModel tagId ]

                            RequestSent _ ->
                                [ text "..." ]

                    BioPage data ->
                        case data of
                            Just bioPageModel ->
                                [ viewBioPageDiv bioPageModel ]

                            Nothing ->
                                [ text "..." ]

                    ContentSearchPage searchKeyword contents ->
                        [ viewSearchContentDiv searchKeyword contents ]

                    NotFoundPage ->
                        [ view404Div ]

                    MaintenancePage ->
                        [ text "*bakım çalışması*" ]
                )
            ]
        ]
    }
