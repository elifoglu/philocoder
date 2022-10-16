module Main exposing (main)

import App.Model exposing (..)
import App.Msg exposing (ContentInputType(..), Msg(..), TagInputType(..))
import App.Ports exposing (sendTitle)
import App.UrlParser exposing (pageBy)
import App.View exposing (view)
import BioGroup.Util exposing (changeActivenessIfIdMatches, changeDisplayInfoIfIdMatchesAndGroupIsActive, gotBioGroupToBioGroup)
import BioGroups.View exposing (makeAllBioGroupsNonActive)
import BioItem.Util exposing (gotBioItemToBioItem)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Component.Page.Util exposing (tagsNotLoaded)
import Content.Util exposing (gotContentToContent)
import ForceDirectedGraph exposing (graphSubscriptions, initGraphModel, updateGraph)
import Home.View exposing (tagCountCurrentlyShownOnPage)
import List
import Pagination.Model exposing (Pagination)
import Requests exposing (createNewTag, getAllRefData, getAllTagsResponse, getBio, getBlogTagsResponse, getContent, getTagContents, getTimeZone, postNewContent, previewContent, updateExistingContent, updateExistingTag)
import Tag.Util exposing (tagById)
import Time
import Url


main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        page =
            pageBy url

        model =
            Model "log" key [] page False Time.utc
    in
    ( model
    , Cmd.batch [ getCmdToSendByPage model, getTimeZone ]
    )


needAllTagsData : Page -> Bool
needAllTagsData page =
    case page of
        HomePage _ _ _ ->
            True

        ContentPage _ ->
            True

        TagPage _ ->
            True

        UpdateContentPage _ ->
            True

        CreateContentPage _ ->
            False

        CreateTagPage _ ->
            False

        UpdateTagPage _ ->
            False

        BioPage _ ->
            False

        NotFoundPage ->
            False

        MaintenancePage ->
            False


getCmdToSendByPage : Model -> Cmd Msg
getCmdToSendByPage model =
    Cmd.batch
        [ sendTitle model
        , if tagsNotLoaded model && needAllTagsData model.activePage then
            getAllTagsResponse

          else
            case model.activePage of
                HomePage blogTags _ maybeGraphData ->
                    if blogTags == [] then
                        getBlogTagsResponse

                    else if maybeGraphData == Nothing then
                        getAllRefData

                    else
                        Cmd.none

                TagPage status ->
                    case status of
                        NonInitialized initializableTagPageModel ->
                            case tagById model.allTags initializableTagPageModel.tagId of
                                Just tag ->
                                    getTagContents tag initializableTagPageModel.maybePage initializableTagPageModel.readingMode

                                Nothing ->
                                    Cmd.none

                        Initialized _ ->
                            Cmd.none

                ContentPage status ->
                    case status of
                        NonInitialized contentId ->
                            getContent contentId

                        Initialized _ ->
                            Cmd.none

                UpdateContentPage status ->
                    case status of
                        NotInitializedYet contentID ->
                            getContent contentID

                        _ ->
                            Cmd.none

                BioPage maybeData ->
                    case maybeData of
                        Just _ ->
                            Cmd.none

                        Nothing ->
                            getBio

                _ ->
                    Cmd.none
        ]


createNewModelAndCmdMsg : Model -> Page -> ( Model, Cmd Msg )
createNewModelAndCmdMsg model page =
    let
        newModel =
            { model | activePage = page }
    in
    ( newModel, getCmdToSendByPage newModel )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- COMMON --
        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                activePage : Page
                activePage =
                    pageBy url

                newModel : Model
                newModel =
                    { model | allTags = [], activePage = activePage }
            in
            ( newModel, getCmdToSendByPage newModel )

        GotTimeZone zone ->
            ( { model | timeZone = zone }, Cmd.none )

        ShowAdditionalIcons ->
            ( { model | showAdditionalIcons = True }, Cmd.none )

        GotAllTagsResponse res ->
            case res of
                Ok gotTagDataResponse ->
                    let
                        newModel =
                            { model | allTags = gotTagDataResponse.allTags }
                    in
                    ( newModel, getCmdToSendByPage newModel )

                Err _ ->
                    createNewModelAndCmdMsg model MaintenancePage

        GotContent result ->
            case result of
                Ok gotContent ->
                    let
                        content =
                            gotContentToContent model gotContent

                        contentPage =
                            ContentPage <| Initialized content

                        newActivePage =
                            case model.activePage of
                                ContentPage _ ->
                                    contentPage

                                CreateContentPage status ->
                                    case status of
                                        NoRequestSentYet _ ->
                                            CreateContentPage <|
                                                NoRequestSentYet (setCreateContentPageModel content)

                                        RequestSent _ ->
                                            contentPage

                                UpdateContentPage status ->
                                    case status of
                                        NotInitializedYet _ ->
                                            UpdateContentPage <|
                                                GotContentToUpdate (setUpdateContentPageModel content)

                                        GotContentToUpdate _ ->
                                            UpdateContentPage <|
                                                GotContentToUpdate (setUpdateContentPageModel content)

                                        UpdateRequestIsSent _ ->
                                            contentPage

                                _ ->
                                    MaintenancePage

                        newModel =
                            { model | activePage = newActivePage }
                    in
                    ( newModel, getCmdToSendByPage newModel )

                Err _ ->
                    createNewModelAndCmdMsg model NotFoundPage

        -- TAG PAGE --
        GotContentsOfTag tag result ->
            case result of
                Ok contentsResponse ->
                    case model.activePage of
                        TagPage status ->
                            case status of
                                NonInitialized nonInitialized ->
                                    let
                                        currentPage =
                                            Maybe.withDefault 1 nonInitialized.maybePage

                                        pagination =
                                            Pagination currentPage contentsResponse.totalPageCount

                                        contents =
                                            List.map (gotContentToContent model) contentsResponse.contents

                                        newPage =
                                            TagPage <|
                                                Initialized (InitializedTagPageModel tag contents pagination nonInitialized.readingMode)

                                        newModel =
                                            { model | activePage = newPage }
                                    in
                                    ( newModel, getCmdToSendByPage newModel )

                                _ ->
                                    createNewModelAndCmdMsg model NotFoundPage

                        _ ->
                            createNewModelAndCmdMsg model NotFoundPage

                Err _ ->
                    createNewModelAndCmdMsg model MaintenancePage

        -- CREATE/UPDATE CONTENT PAGES --
        ContentInputChanged inputType input ->
            case model.activePage of
                CreateContentPage status ->
                    case status of
                        NoRequestSentYet createContentPageModel ->
                            let
                                newCurrentPageModel =
                                    case inputType of
                                        Id ->
                                            { createContentPageModel | id = input }

                                        Title ->
                                            { createContentPageModel | title = input }

                                        Text ->
                                            { createContentPageModel | text = input }

                                        Tags ->
                                            { createContentPageModel | tags = input }

                                        Refs ->
                                            { createContentPageModel | refs = input }

                                        OkForBlogMode ->
                                            case input of
                                                "true" ->
                                                    { createContentPageModel | okForBlogMode = True }

                                                "false" ->
                                                    { createContentPageModel | okForBlogMode = False }

                                                _ ->
                                                    { createContentPageModel | okForBlogMode = False }

                                        Password ->
                                            { createContentPageModel | password = input }

                                        ContentToCopy ->
                                            { createContentPageModel | contentIdToCopy = input }
                            in
                            ( { model | activePage = CreateContentPage <| NoRequestSentYet newCurrentPageModel }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                UpdateContentPage status ->
                    case status of
                        GotContentToUpdate updateContentPageData ->
                            let
                                newCurrentPageModel =
                                    case inputType of
                                        Id ->
                                            updateContentPageData

                                        Title ->
                                            { updateContentPageData | title = input }

                                        Text ->
                                            { updateContentPageData | text = input }

                                        Tags ->
                                            { updateContentPageData | tags = input }

                                        Refs ->
                                            { updateContentPageData | refs = input }

                                        Password ->
                                            { updateContentPageData | password = input }

                                        OkForBlogMode ->
                                            case input of
                                                "true" ->
                                                    { updateContentPageData | okForBlogMode = True }

                                                "false" ->
                                                    { updateContentPageData | okForBlogMode = False }

                                                _ ->
                                                    { updateContentPageData | okForBlogMode = False }

                                        ContentToCopy ->
                                            updateContentPageData
                            in
                            ( { model | activePage = UpdateContentPage <| GotContentToUpdate newCurrentPageModel }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        PreviewContent previewContentModel ->
            ( model
            , previewContent previewContentModel
            )

        GetContentToCopyForContentCreation contentId ->
            ( model
            , getContent contentId
            )

        GotContentToPreviewForCreatePage createContentPageModel result ->
            case result of
                Ok gotContentToPreview ->
                    let
                        content =
                            gotContentToContent model gotContentToPreview

                        newCreateContentPageModel =
                            { createContentPageModel | maybeContentToPreview = Just content }
                    in
                    ( { model | activePage = CreateContentPage <| NoRequestSentYet newCreateContentPageModel }
                    , Cmd.none
                    )

                Err _ ->
                    let
                        newCreateContentPageModel =
                            { createContentPageModel | maybeContentToPreview = Nothing }
                    in
                    ( { model | activePage = CreateContentPage <| NoRequestSentYet newCreateContentPageModel }
                    , Cmd.none
                    )

        CreateContent createContentPageModel ->
            ( { model | activePage = CreateContentPage <| RequestSent createContentPageModel }
            , postNewContent createContentPageModel
            )

        GotContentToPreviewForUpdatePage contentID updateContentPageData result ->
            case result of
                Ok gotContentToPreview ->
                    let
                        content =
                            gotContentToContent model gotContentToPreview

                        newUpdateContentPageModel =
                            { updateContentPageData | maybeContentToPreview = Just content }
                    in
                    ( { model | activePage = UpdateContentPage <| GotContentToUpdate newUpdateContentPageModel }
                    , Cmd.none
                    )

                Err _ ->
                    let
                        newUpdateContentPageModel =
                            { updateContentPageData | maybeContentToPreview = Nothing }
                    in
                    ( { model | activePage = UpdateContentPage <| GotContentToUpdate newUpdateContentPageModel }
                    , Cmd.none
                    )

        UpdateContent contentID updateContentPageData ->
            ( { model | activePage = UpdateContentPage <| UpdateRequestIsSent updateContentPageData }
            , updateExistingContent contentID updateContentPageData
            )

        -- CREATE/UPDATE TAG PAGES --
        TagInputChanged inputType ->
            case model.activePage of
                CreateTagPage status ->
                    case status of
                        NoRequestSentYet createTagPageModel ->
                            let
                                newCurrentPageModel =
                                    case inputType of
                                        TagId input ->
                                            { createTagPageModel | tagId = input }

                                        Name input ->
                                            { createTagPageModel | name = input }

                                        ContentSortStrategy input ->
                                            { createTagPageModel | contentSortStrategy = input }

                                        ShowInTagsOfContent input ->
                                            { createTagPageModel | showInTagsOfContent = input }

                                        ShowContentCount input ->
                                            { createTagPageModel | showContentCount = input }

                                        OrderIndex input ->
                                            { createTagPageModel | orderIndex = input }

                                        InfoContentId _ ->
                                            createTagPageModel

                                        Pw input ->
                                            { createTagPageModel | password = input }
                            in
                            ( { model | activePage = CreateTagPage <| NoRequestSentYet newCurrentPageModel }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                UpdateTagPage status ->
                    case status of
                        NoRequestSentYet ( updateTagPageModel, tagId ) ->
                            let
                                newCurrentPageModel =
                                    case inputType of
                                        InfoContentId input ->
                                            { updateTagPageModel | infoContentId = input }

                                        Pw input ->
                                            { updateTagPageModel | password = input }

                                        _ ->
                                            updateTagPageModel
                            in
                            ( { model | activePage = UpdateTagPage <| NoRequestSentYet ( newCurrentPageModel, tagId ) }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        CreateTag createTagPageModel ->
            ( { model | activePage = CreateTagPage <| RequestSent createTagPageModel }
            , createNewTag createTagPageModel
            )

        UpdateTag tagId updateTagPageModel ->
            ( { model | activePage = UpdateTagPage <| RequestSent updateTagPageModel }
            , updateExistingTag tagId updateTagPageModel
            )

        GotTagUpdateOrCreationDoneResponse res ->
            case res of
                Ok message ->
                    let
                        newActivePage =
                            if message == "done" then
                                HomePage [] BlogContents Nothing

                            else
                                NotFoundPage

                        newModel =
                            { model | allTags = [], activePage = newActivePage }
                    in
                    ( newModel, getCmdToSendByPage newModel )

                Err _ ->
                    createNewModelAndCmdMsg model NotFoundPage

        -- BIO PAGE --
        GotBioResponse result ->
            case result of
                Ok bio ->
                    let
                        bioGroups =
                            List.map gotBioGroupToBioGroup bio.groups

                        bioItems =
                            List.map gotBioItemToBioItem bio.items

                        bioPage =
                            BioPage (Just (BioPageModel bioGroups bioItems Nothing))

                        newModel =
                            { model | activePage = bioPage }
                    in
                    ( newModel, getCmdToSendByPage newModel )

                Err _ ->
                    createNewModelAndCmdMsg model MaintenancePage

        ClickOnABioGroup bioGroupId ->
            case model.activePage of
                BioPage maybeData ->
                    case maybeData of
                        Just bioPageModel ->
                            let
                                newBioGroupsAllNonActive =
                                    makeAllBioGroupsNonActive bioPageModel.bioGroups

                                newBioGroups =
                                    List.map (changeActivenessIfIdMatches bioGroupId) newBioGroupsAllNonActive

                                newBioPageModel =
                                    { bioPageModel | bioGroups = newBioGroups }

                                newBioPage =
                                    BioPage (Just newBioPageModel)

                                newModel =
                                    { model | activePage = newBioPage }
                            in
                            ( newModel, getCmdToSendByPage newModel )

                        Nothing ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        BioGroupDisplayInfoChanged bioGroup ->
            case model.activePage of
                BioPage maybeData ->
                    case maybeData of
                        Just bioPageModel ->
                            let
                                newBioGroups =
                                    List.map (changeDisplayInfoIfIdMatchesAndGroupIsActive bioGroup.bioGroupID) bioPageModel.bioGroups

                                newBioPageModel =
                                    { bioPageModel | bioGroups = newBioGroups }

                                newBioPage =
                                    BioPage (Just newBioPageModel)
                            in
                            ( { model | activePage = newBioPage }, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ClickOnABioItemInfo bioItem ->
            case model.activePage of
                BioPage maybeData ->
                    case maybeData of
                        Just bioPageModel ->
                            let
                                newBioItemToShowInfo =
                                    case bioPageModel.bioItemToShowInfo of
                                        Just activeBioItemToShowInfo ->
                                            if activeBioItemToShowInfo.bioItemID == bioItem.bioItemID then
                                                Nothing

                                            else
                                                Just bioItem

                                        Nothing ->
                                            Just bioItem

                                newBioPageModel =
                                    { bioPageModel | bioItemToShowInfo = newBioItemToShowInfo }

                                newBioPage =
                                    BioPage (Just newBioPageModel)
                            in
                            ( { model | activePage = newBioPage }, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        -- HOME PAGE & GRAPH --
        GotBlogTagsResponse res ->
            case res of
                Ok gotTagDataResponse ->
                    case model.activePage of
                        HomePage _ readingMode maybeGraphData ->
                            let
                                -- TODO FIX: BU GOT TAG TO TAG Bİ İŞe ARAMIYORMUŞ, allTags için kullanımlarını süpürebilirsin süpürebildiğin noktalarda
                                homePage =
                                    HomePage gotTagDataResponse.blogTags readingMode maybeGraphData

                                newModel =
                                    { model | activePage = homePage }
                            in
                            ( newModel, getCmdToSendByPage newModel )

                        _ ->
                            createNewModelAndCmdMsg model MaintenancePage

                Err _ ->
                    createNewModelAndCmdMsg model MaintenancePage

        ReadingModeChanged readingMode ->
            let
                newPage =
                    case model.activePage of
                        HomePage blogTags _ maybeGraphData ->
                            HomePage blogTags readingMode maybeGraphData

                        _ ->
                            model.activePage
            in
            ( { model | activePage = newPage }, Cmd.none )

        GotAllRefData res ->
            case res of
                Ok allRefData ->
                    let
                        newModel =
                            case model.activePage of
                                HomePage blogTags readingMode maybeGraphData ->
                                    case maybeGraphData of
                                        Just _ ->
                                            model

                                        Nothing ->
                                            { model | activePage = HomePage blogTags readingMode (Just (GraphData allRefData (initGraphModel allRefData))) }

                                _ ->
                                    model
                    in
                    ( newModel, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        GoToContentViaContentGraph contentID ->
            ( model
            , Nav.pushUrl model.key ("/contents/" ++ String.fromInt contentID)
            )

        otherMsg ->
            case model.activePage of
                HomePage blogTags readingMode maybeGraphData ->
                    case maybeGraphData of
                        Just graphData ->
                            let
                                newGraphData =
                                    Just (GraphData graphData.allRefData (updateGraph otherMsg graphData.graphModel))

                                newHomePage =
                                    HomePage blogTags readingMode newGraphData
                            in
                            ( { model | activePage = newHomePage }, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.activePage of
        HomePage blogTags readingMode maybeGraphData ->
            case maybeGraphData of
                Just graphData ->
                    let
                        totalTagCountCurrentlyShownOnPage =
                            tagCountCurrentlyShownOnPage readingMode model.allTags blogTags
                    in
                    graphSubscriptions graphData.graphModel totalTagCountCurrentlyShownOnPage

                Nothing ->
                    Sub.none

        _ ->
            Sub.none
