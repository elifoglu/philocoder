module Main exposing (main)

import App.Model exposing (..)
import App.Msg exposing (ContentInputType(..), GotTagDataResponseForWhichPage(..), Msg(..), TagInputType(..))
import App.Ports exposing (sendTitle)
import App.UrlParser exposing (pageBy)
import App.View exposing (view)
import BioGroup.Util exposing (changeActivenessIfIdMatches, changeDisplayInfoIfIdMatchesAndGroupIsActive, gotBioGroupToBioGroup)
import BioGroups.View exposing (makeAllBioGroupsNonActive)
import BioItem.Util exposing (gotBioItemToBioItem)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Component.Page.Util exposing (areTagsLoaded)
import Content.Model exposing (Content)
import Content.Util exposing (gotContentToContent)
import ForceDirectedGraph exposing (graphSubscriptions, initGraphModel, updateGraph)
import Home.View exposing (tagCountCurrentlyShownOnPage)
import List
import Pagination.Model exposing (Pagination)
import Requests exposing (createNewTag, getAllRefData, getBio, getContent, getTagContents, getTagDataResponseForPage, getTimeZone, postNewContent, previewContent, updateExistingContent, updateExistingTag)
import Tag.Util exposing (gotTagToTag, tagById)
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
            Model "log" key page False Time.utc
    in
    ( model
    , Cmd.batch [ getCmdToSendByPage model, getTimeZone ]
    )


getCmdToSendByPage : Model -> Cmd Msg
getCmdToSendByPage model =
    Cmd.batch
        [ sendTitle model
        , case model.activePage of
            ContentPage status ->
                case status of
                    NonInitialized ( contentId, maybeAllTags ) ->
                        case maybeAllTags of
                            Just _ ->
                                getContent contentId

                            Nothing ->
                                getTagDataResponseForPage PageContent

                    Initialized _ ->
                        Cmd.none

            TagPage status ->
                case status of
                    NonInitialized initializableTagPageModel ->
                        case initializableTagPageModel.maybeAllTags of
                            Nothing ->
                                getTagDataResponseForPage PageTag

                            Just allTags ->
                                case tagById allTags initializableTagPageModel.tagId of
                                    Just tag ->
                                        getTagContents tag initializableTagPageModel.maybePage initializableTagPageModel.readingMode

                                    Nothing ->
                                        Cmd.none

                    Initialized _ ->
                        Cmd.none

            BioPage maybeData ->
                case maybeData of
                    Just _ ->
                        Cmd.none

                    Nothing ->
                        getBio

            HomePage allTags _ _ maybeGraphData ->
                if not (areTagsLoaded allTags) then
                    getTagDataResponseForPage PageHome

                else if maybeGraphData == Nothing then
                    getAllRefData

                else
                    Cmd.none

            CreateContentPage status ->
                case status of
                    NoRequestSentYet createContentPageModel ->
                        let
                            cmd =
                                if List.isEmpty createContentPageModel.allTags then
                                    getTagDataResponseForPage PageCreateContent

                                else
                                    Cmd.none
                        in
                        cmd

                    _ ->
                        Cmd.none

            UpdateContentPage status ->
                case status of
                    NoRequestSentYet pageData ->
                        let
                            updateContentPageModel : UpdateContentPageModel
                            updateContentPageModel =
                                Tuple.first pageData

                            cmd =
                                if List.isEmpty updateContentPageModel.allTags then
                                    getTagDataResponseForPage PageUpdateContent

                                else
                                    getContent (Tuple.second pageData)
                        in
                        cmd

                    _ ->
                        Cmd.none

            _ ->
                Cmd.none
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- COMMON --
        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        UrlChanged url ->
            let
                activePage : Page
                activePage =
                    pageBy url

                newModel : Model
                newModel =
                    { model | activePage = activePage }
            in
            ( newModel, getCmdToSendByPage newModel )

        GotTimeZone zone ->
            ( { model | timeZone = zone }, Cmd.none )

        ShowAdditionalIcons ->
            ( { model | showAdditionalIcons = True }, Cmd.none )

        GotTagDataResponseForPage forWhichPage res ->
            case res of
                Ok gotTagDataResponse ->
                    case forWhichPage of
                        PageHome ->
                            let
                                allTags =
                                    List.map gotTagToTag gotTagDataResponse.allTags

                                blogModeTags =
                                    List.map gotTagToTag gotTagDataResponse.blogModeTags

                                updatedHomePage =
                                    case model.activePage of
                                        HomePage _ _ readingMode maybeGraphData ->
                                            HomePage allTags blogModeTags readingMode maybeGraphData

                                        _ ->
                                            MaintenancePage
                            in
                            ( { model
                                | activePage = updatedHomePage
                              }
                            , getCmdToSendByPage model
                            )

                        PageTag ->
                            let
                                updatedTagPage : Page
                                updatedTagPage =
                                    case model.activePage of
                                        TagPage status ->
                                            case status of
                                                NonInitialized initializableTagPageModel ->
                                                    TagPage (NonInitialized { initializableTagPageModel | maybeAllTags = Just (List.map gotTagToTag gotTagDataResponse.allTags), maybeBlogModeTags = Just (List.map gotTagToTag gotTagDataResponse.blogModeTags) })

                                                _ ->
                                                    model.activePage

                                        _ ->
                                            model.activePage

                                newModel =
                                    { model | activePage = updatedTagPage }
                            in
                            ( newModel, getCmdToSendByPage newModel )

                        PageContent ->
                            let
                                allTags =
                                    List.map gotTagToTag gotTagDataResponse.allTags

                                updatedContentPage =
                                    case model.activePage of
                                        ContentPage status ->
                                            case status of
                                                NonInitialized ( contentId, _ ) ->
                                                    ContentPage (NonInitialized ( contentId, Just allTags ))

                                                _ ->
                                                    MaintenancePage

                                        _ ->
                                            MaintenancePage

                                newModel =
                                    { model | activePage = updatedContentPage }
                            in
                            ( newModel, getCmdToSendByPage newModel )

                        PageCreateContent ->
                            case model.activePage of
                                CreateContentPage status ->
                                    case status of
                                        NoRequestSentYet createContentPageModel ->
                                            let
                                                createContentPageModelWithAllTags : CreateContentPageModel
                                                createContentPageModelWithAllTags =
                                                    { createContentPageModel | allTags = List.map gotTagToTag gotTagDataResponse.allTags }

                                                newCreateContentPage : Page
                                                newCreateContentPage =
                                                    CreateContentPage (NoRequestSentYet createContentPageModelWithAllTags)
                                            in
                                            ( { model | activePage = newCreateContentPage }, Cmd.none )

                                        _ ->
                                            ( { model | activePage = MaintenancePage }, Cmd.none )

                                _ ->
                                    ( { model | activePage = MaintenancePage }, Cmd.none )

                        PageUpdateContent ->
                            case model.activePage of
                                UpdateContentPage status ->
                                    case status of
                                        NoRequestSentYet pageData ->
                                            let
                                                updateContentPageModel : UpdateContentPageModel
                                                updateContentPageModel =
                                                    Tuple.first pageData

                                                updateContentPageModelWithAllTags : UpdateContentPageModel
                                                updateContentPageModelWithAllTags =
                                                    { updateContentPageModel | allTags = List.map gotTagToTag gotTagDataResponse.allTags }

                                                newUpdateContentPage : Page
                                                newUpdateContentPage =
                                                    UpdateContentPage (NoRequestSentYet ( updateContentPageModelWithAllTags, Tuple.second pageData ))

                                                newModel =
                                                    { model | activePage = newUpdateContentPage }
                                            in
                                            ( newModel, getCmdToSendByPage newModel )

                                        _ ->
                                            ( { model | activePage = MaintenancePage }, Cmd.none )

                                _ ->
                                    ( { model | activePage = MaintenancePage }, Cmd.none )

                Err _ ->
                    ( { model | activePage = MaintenancePage }, Cmd.none )

        GotContent result ->
            case result of
                Ok gotContent ->
                    let
                        newActivePage =
                            case model.activePage of
                                ContentPage status ->
                                    let
                                        allTags =
                                            case status of
                                                NonInitialized ( _, maybeAllTags ) ->
                                                    Maybe.withDefault [] maybeAllTags

                                                Initialized ( _, tags ) ->
                                                    tags

                                        content =
                                            gotContentToContent model allTags gotContent
                                    in
                                    ContentPage <| Initialized ( content, allTags )

                                CreateContentPage status ->
                                    case status of
                                        NoRequestSentYet createContentPageModel ->
                                            let
                                                content =
                                                    gotContentToContent model createContentPageModel.allTags gotContent
                                            in
                                            CreateContentPage <|
                                                NoRequestSentYet (setCreateContentPageModel content createContentPageModel.allTags)

                                        RequestSent createContentPageModel ->
                                            let
                                                content =
                                                    gotContentToContent model createContentPageModel.allTags gotContent
                                            in
                                            ContentPage <| Initialized ( content, createContentPageModel.allTags )

                                UpdateContentPage status ->
                                    case status of
                                        NoRequestSentYet ( updateContentPageModel, contentId ) ->
                                            let
                                                allTags =
                                                    updateContentPageModel.allTags

                                                content =
                                                    gotContentToContent model updateContentPageModel.allTags gotContent
                                            in
                                            UpdateContentPage <|
                                                NoRequestSentYet ( setUpdateContentPageModel content allTags, contentId )

                                        RequestSent updateContentPageModel ->
                                            let
                                                content =
                                                    gotContentToContent model updateContentPageModel.allTags gotContent
                                            in
                                            ContentPage <| Initialized ( content, updateContentPageModel.allTags )

                                _ ->
                                    MaintenancePage

                        newModel =
                            { model | activePage = newActivePage }
                    in
                    ( newModel, sendTitle newModel )

                Err _ ->
                    let
                        newModel =
                            { model | activePage = NotFoundPage }
                    in
                    ( newModel, sendTitle newModel )

        -- TAG PAGE --
        GotContentsOfTag tag result ->
            case result of
                Ok contentsResponse ->
                    let
                        currentPage =
                            case model.activePage of
                                TagPage status ->
                                    case status of
                                        NonInitialized nonInitialized ->
                                            Maybe.withDefault 1 nonInitialized.maybePage

                                        _ ->
                                            1

                                _ ->
                                    1

                        pagination =
                            Pagination currentPage contentsResponse.totalPageCount

                        allTags =
                            case model.activePage of
                                TagPage status ->
                                    case status of
                                        NonInitialized nonInitialized ->
                                            Maybe.withDefault [] nonInitialized.maybeAllTags

                                        _ ->
                                            []

                                _ ->
                                    []

                        allBlogModeTags =
                            case model.activePage of
                                TagPage status ->
                                    case status of
                                        NonInitialized nonInitialized ->
                                            Maybe.withDefault [] nonInitialized.maybeBlogModeTags

                                        _ ->
                                            []

                                _ ->
                                    []

                        contents : List Content
                        contents =
                            List.map (gotContentToContent model allTags) contentsResponse.contents

                        readingMode =
                            case model.activePage of
                                TagPage status ->
                                    case status of
                                        NonInitialized nonInitialized ->
                                            nonInitialized.readingMode

                                        _ ->
                                            AllContents

                                _ ->
                                    AllContents

                        newPage =
                            TagPage <|
                                Initialized (InitializedTagPageModel tag contents pagination readingMode allTags allBlogModeTags)

                        newModel =
                            { model | activePage = newPage }
                    in
                    ( newModel
                    , sendTitle newModel
                    )

                Err _ ->
                    ( model, Cmd.none )

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
                        NoRequestSentYet ( updateContentPageModel, contentId ) ->
                            let
                                newCurrentPageModel =
                                    case inputType of
                                        Id ->
                                            updateContentPageModel

                                        Title ->
                                            { updateContentPageModel | title = input }

                                        Text ->
                                            { updateContentPageModel | text = input }

                                        Tags ->
                                            { updateContentPageModel | tags = input }

                                        Refs ->
                                            { updateContentPageModel | refs = input }

                                        Password ->
                                            { updateContentPageModel | password = input }

                                        OkForBlogMode ->
                                            case input of
                                                "true" ->
                                                    { updateContentPageModel | okForBlogMode = True }

                                                "false" ->
                                                    { updateContentPageModel | okForBlogMode = False }

                                                _ ->
                                                    { updateContentPageModel | okForBlogMode = False }

                                        ContentToCopy ->
                                            updateContentPageModel
                            in
                            ( { model | activePage = UpdateContentPage <| NoRequestSentYet ( newCurrentPageModel, contentId ) }, Cmd.none )

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
                            gotContentToContent model createContentPageModel.allTags gotContentToPreview

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

        GotContentToPreviewForUpdatePage contentID updateContentPageModel result ->
            case result of
                Ok gotContentToPreview ->
                    let
                        content =
                            gotContentToContent model updateContentPageModel.allTags gotContentToPreview

                        newUpdateContentPageModel =
                            { updateContentPageModel | maybeContentToPreview = Just content }
                    in
                    ( { model
                        | activePage = UpdateContentPage <| NoRequestSentYet ( newUpdateContentPageModel, contentID )
                      }
                    , Cmd.none
                    )

                Err _ ->
                    let
                        newUpdateContentPageModel =
                            { updateContentPageModel | maybeContentToPreview = Nothing }
                    in
                    ( { model | activePage = UpdateContentPage <| NoRequestSentYet ( newUpdateContentPageModel, contentID ) }
                    , Cmd.none
                    )

        UpdateContent contentID updateContentPageModel ->
            ( { model | activePage = UpdateContentPage <| RequestSent updateContentPageModel }
            , updateExistingContent contentID updateContentPageModel
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

                                        ShowAsTag input ->
                                            { createTagPageModel | showAsTag = input }

                                        ContentRenderType input ->
                                            { createTagPageModel | contentRenderType = input }

                                        ShowContentCount input ->
                                            { createTagPageModel | showContentCount = input }

                                        HeaderIndex input ->
                                            { createTagPageModel | headerIndex = input }

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
                        newModel =
                            { model
                                | activePage =
                                    if message == "done" then
                                        HomePage [] [] BlogContents Nothing

                                    else
                                        NotFoundPage
                            }
                    in
                    ( newModel, getCmdToSendByPage newModel )

                Err _ ->
                    ( { model | activePage = NotFoundPage }, Cmd.none )

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
                    ( newModel, sendTitle newModel )

                Err _ ->
                    ( { model
                        | activePage = MaintenancePage
                      }
                    , Cmd.none
                    )

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
                            ( newModel, sendTitle newModel )

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
        ReadingModeChanged readingMode ->
            let
                newPage =
                    case model.activePage of
                        HomePage allTags blogModeTags _ maybeGraphData ->
                            HomePage allTags blogModeTags readingMode maybeGraphData

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
                                HomePage allTags allBlogModeTags readingMode maybeGraphData ->
                                    case maybeGraphData of
                                        Just _ ->
                                            model

                                        Nothing ->
                                            { model | activePage = HomePage allTags allBlogModeTags readingMode (Just (GraphData allRefData (initGraphModel allRefData))) }

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
                HomePage allTags allBlogModeTags readingMode maybeGraphData ->
                    case maybeGraphData of
                        Just graphData ->
                            let
                                newGraphData =
                                    Just (GraphData graphData.allRefData (updateGraph otherMsg graphData.graphModel))

                                newHomePage =
                                    HomePage allTags allBlogModeTags readingMode newGraphData
                            in
                            ( { model | activePage = newHomePage }, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.activePage of
        HomePage allTags blogModeTags readingMode maybeGraphData ->
            case maybeGraphData of
                Just graphData ->
                    let
                        totalTagCountCurrentlyShownOnPage =
                            tagCountCurrentlyShownOnPage readingMode allTags blogModeTags
                    in
                    graphSubscriptions graphData.graphModel totalTagCountCurrentlyShownOnPage

                Nothing ->
                    Sub.none

        _ ->
            Sub.none
