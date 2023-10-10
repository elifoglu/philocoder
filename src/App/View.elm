module App.View exposing (view)

import App.Model exposing (..)
import App.Msg exposing (Msg(..))
import Bio.View exposing (viewBioPageDiv)
import Breadcrumb.View exposing (viewBreadcrumb)
import Browser exposing (Document)
import BulkContents.View exposing (viewBulkContentsDiv)
import Content.View exposing (viewContentDiv)
import ContentSearch.View exposing (viewSearchContentDiv)
import Contents.View exposing (viewContentDivs)
import CreateContent.View exposing (viewCreateContentDiv)
import CreateTag.View exposing (viewCreateTagDiv)
import EksiKonserve.View exposing (viewEksiKonserveDiv)
import ForceDirectedGraphForGraph exposing (viewGraphForGraphPage)
import ForceDirectedGraphForHome exposing (viewGraph)
import Home.View exposing (tagCountCurrentlyShownOnPage, viewHomePageDiv)
import Html exposing (..)
import Html.Attributes exposing (..)
import LoginRegister.View exposing (viewLoginOrRegisterDiv)
import Markdown
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
                    HomePage blogTagsToShow allTagsToShow readingMode maybeGraphData ->
                        if blogTagsToShow /= Nothing then
                            case maybeGraphData of
                                Just graphData ->
                                    if graphData.veryFirstMomentOfGraphHasPassed then
                                        let
                                            tagsCount =
                                                tagCountCurrentlyShownOnPage readingMode allTagsToShow blogTagsToShow

                                            initialMarginTop =
                                                50

                                            heightOfASingleTagAsPx =
                                                20

                                            marginTopForGraph : Int
                                            marginTopForGraph =
                                                initialMarginTop + round (toFloat tagsCount * heightOfASingleTagAsPx)
                                        in
                                        [ viewHomePageDiv allTagsToShow blogTagsToShow readingMode model.loggedIn model.consumeModeIsOn model.activeTheme
                                        , div [ class "graph", style "margin-top" (String.fromInt marginTopForGraph ++ "px") ] [ viewGraph model.activeTheme graphData.graphData.contentIds graphData.graphModel tagsCount graphData.contentToColorize ]
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
                                [ viewContentDiv model.activeTheme Nothing Nothing model.localStorage.contentReadClickedAtLeastOnce content
                                , if model.localStorage.username == "mert" then
                                    a [ href ("/update/content/" ++ String.fromInt content.contentId), class "updateContentLink" ] [ text "(update this content)" ]

                                  else
                                    text ""
                                ]

                    TagPage status ->
                        case status of
                            NonInitialized _ ->
                                []

                            Initialized initialized ->
                                viewContentDivs model.activeTheme model.maybeContentFadeOutData model.localStorage.contentReadClickedAtLeastOnce initialized.contents
                                    ++ [ viewPagination initialized.tag initialized.pagination initialized.readingMode
                                       ]

                    CreateContentPage status ->
                        case status of
                            NoRequestSentYet createContentPageModel ->
                                [ viewCreateContentDiv model.activeTheme createContentPageModel ]

                            RequestSent _ ->
                                [ text "..." ]

                    UpdateContentPage updateContentPageModel ->
                        case updateContentPageModel of
                            GotContentToUpdate updateContentPageData ->
                                [ viewUpdateContentDiv model.activeTheme updateContentPageData updateContentPageData.maybeContentToPreview updateContentPageData.contentId ]

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
                            Initialized bioPageModel ->
                                [ viewBioPageDiv model.activeTheme bioPageModel ]

                            _ ->
                                [ text "..." ]

                    ContentSearchPage searchKeyword contents ->
                        [ viewSearchContentDiv model.activeTheme model.localStorage.contentReadClickedAtLeastOnce searchKeyword contents ]

                    BulkContentsPage status ->
                        case status of
                            NonInitialized _ ->
                                [ text "..." ]

                            Initialized contents ->
                                if List.isEmpty contents then
                                    [ text "içerik adedi 2'den az, 20'den de fazla olamaz" ]

                                else
                                    [ viewBulkContentsDiv model.activeTheme model.localStorage.contentReadClickedAtLeastOnce contents ]

                    LoginOrRegisterPage username password errorMessage ->
                        [ viewLoginOrRegisterDiv username password errorMessage ]

                    GraphPage maybeGraphData ->
                        case maybeGraphData of
                            Just graphData ->
                                if graphData.veryFirstMomentOfGraphHasPassed then
                                    [ div [ class "graphForGraphPage", style "margin-top" "5px" ] [ viewGraphForGraphPage model.activeTheme graphData.graphData.contentIds graphData.graphModel graphData.contentToColorize ]
                                    , Markdown.toHtml [ class "graphPageInformationText" ] ("*(imleç nodun üzerinde bekletilerek ilgili içerik hakkında bilgi sahibi olunabilir," ++ "  \n" ++ "sol tık ile ilgili içeriğe gidilebilir (ctrl + sol tık yeni sekmede açar)," ++ "  \n" ++ "sağ tık ile nod sürüklenerek eğlenilebilir)*")
                                    ]

                                else
                                    []

                            Nothing ->
                                []

                    RedirectPage _ ->
                        [ text "..." ]

                    NotFoundPage ->
                        [ view404Div ]

                    MaintenancePage ->
                        [ text "*bakım çalışması*" ]

                    EksiKonservePage status ->
                        case status of
                            NonInitialized _ ->
                                [ text "..." ]

                            Initialized data ->
                                [ viewEksiKonserveDiv (Tuple.first data) (Tuple.second data)
                                ]
                )
            ]
        ]
    }
