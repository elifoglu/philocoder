module Main exposing (main, needAllTagsData)

import App.Model exposing (..)
import App.Msg exposing (ContentInputType(..), LoginRegisterPageInputType(..), LoginRequestType(..), Msg(..), TagInputType(..))
import App.Ports exposing (openNewTab, sendTitle, storeConsumeMode, storeContentReadClickedForTheFirstTime, storeCredentials, storeReadMeIconClickedForTheFirstTime, storeReadingMode)
import App.UrlParser exposing (pageBy)
import App.View exposing (view)
import BioGroup.Util exposing (changeActivenessIfIdMatches, changeDisplayInfoIfIdMatchesAndGroupIsActive, gotBioGroupToBioGroup)
import BioGroups.View exposing (makeAllBioGroupsNonActive)
import BioItem.Util exposing (gotBioItemToBioItem)
import Browser exposing (UrlRequest)
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Component.Page.Util exposing (tagsNotLoaded)
import Content.Model exposing (Content, GraphData)
import Content.Util exposing (gotContentToContent)
import DataResponse exposing (ContentID, EksiKonserveException)
import ForceDirectedGraphForContent exposing (graphSubscriptionsForContent, initGraphModelForContent)
import ForceDirectedGraphForGraph exposing (graphSubscriptionsForGraph, initGraphModelForGraphPage)
import ForceDirectedGraphForHome exposing (graphSubscriptions, initGraphModel)
import ForceDirectedGraphUtil exposing (updateGraph)
import Home.View exposing (tagCountCurrentlyShownOnPage)
import List
import List.Extra
import Pagination.Model exposing (Pagination)
import Requests exposing (createNewTag, deleteAllEksiKonserveExceptions, deleteEksiKonserveTopics, getAllTagsResponse, getBio, getBulkContents, getContent, getEksiKonserve, getHomePageDataResponse, getSearchResult, getTagContents, getTimeZone, getWholeGraphData, login, postNewContent, previewContent, register, setContentAsRead, updateExistingContent, updateExistingTag)
import Tag.Util exposing (tagById)
import Task
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


init : { readingMode : Maybe String, consumeModeIsOn : Maybe String, contentReadClickedAtLeastOnce : Maybe String, readMeIconClickedAtLeastOnce : Maybe String, credentials : Maybe String } -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        credentials =
            case flags.credentials of
                Just cred ->
                    cred

                Nothing ->
                    "invalidUsername|||invalidPassword"

        username =
            Maybe.withDefault "invalidUsername" (List.head (String.split "|||" credentials))

        password =
            Maybe.withDefault "invalidPassword" (List.Extra.getAt 1 (String.split "|||" credentials))

        readingMode =
            case flags.readingMode of
                Just "blog" ->
                    BlogContents

                Just "tümü" ->
                    AllContents

                _ ->
                    BlogContents

        contentReadClickedAtLeastOnce =
            case flags.contentReadClickedAtLeastOnce of
                Just "true" ->
                    True

                _ ->
                    False

        readMeIconClickedAtLeastOnce =
            case flags.readMeIconClickedAtLeastOnce of
                Just "true" ->
                    True

                _ ->
                    False

        page =
            pageBy url readingMode

        getConsumeModeIsOnValueFromLocal maybeString =
            case maybeString of
                Just "true" ->
                    True

                _ ->
                    False

        model =
            Model "log" key [] page False (LocalStorage readingMode contentReadClickedAtLeastOnce readMeIconClickedAtLeastOnce username password) False (getConsumeModeIsOnValueFromLocal flags.consumeModeIsOn) Nothing False Time.utc
    in
    ( model
    , Cmd.batch [ login AttemptAtInitialization username password, getTimeZone ]
    )


needAllTagsData : Page -> Bool
needAllTagsData page =
    case page of
        ContentPage _ ->
            True

        TagPage _ ->
            True

        UpdateContentPage _ ->
            True

        ContentSearchPage _ _ ->
            True

        BulkContentsPage _ ->
            True

        HomePage _ _ _ _ ->
            False

        CreateContentPage _ ->
            False

        CreateTagPage _ ->
            False

        UpdateTagPage _ ->
            False

        BioPage _ ->
            False

        LoginOrRegisterPage _ _ _ ->
            False

        GrafPage _ ->
            False

        NotFoundPage ->
            False

        MaintenancePage ->
            False

        EksiKonservePage _ ->
            False


getCmdToSendByPage : Model -> Cmd Msg
getCmdToSendByPage model =
    Cmd.batch
        [ sendTitle model
        , if tagsNotLoaded model && needAllTagsData model.activePage then
            getAllTagsResponse

          else
            case model.activePage of
                HomePage blogTagsToShow allTagsToShow _ maybeGraphData ->
                    if blogTagsToShow == Nothing && allTagsToShow == Nothing then
                        getHomePageDataResponse model.loggedIn model.consumeModeIsOn model.localStorage.username model.localStorage.password

                    else if maybeGraphData == Nothing then
                        getWholeGraphData

                    else
                        Cmd.none

                TagPage status ->
                    case status of
                        NonInitialized initializableTagPageModel ->
                            case tagById model.allTags initializableTagPageModel.tagId of
                                Just tag ->
                                    getTagContents tag initializableTagPageModel.maybePage initializableTagPageModel.readingMode model

                                Nothing ->
                                    Cmd.none

                        Initialized _ ->
                            Cmd.none

                ContentPage status ->
                    case status of
                        NonInitialized ( contentId, _ ) ->
                            getContent contentId model

                        Initialized _ ->
                            Cmd.none

                BulkContentsPage status ->
                    case status of
                        NonInitialized contentIds ->
                            getBulkContents contentIds model

                        Initialized _ ->
                            Cmd.none

                UpdateContentPage status ->
                    case status of
                        NotInitializedYet contentID ->
                            getContent contentID model

                        _ ->
                            Cmd.none

                BioPage maybeData ->
                    case maybeData of
                        Just _ ->
                            Cmd.none

                        Nothing ->
                            getBio

                EksiKonservePage status ->
                    case status of
                        NonInitialized _ ->
                            getEksiKonserve model

                        Initialized _ ->
                            Cmd.none

                GrafPage maybeGraphData ->
                    case maybeGraphData of
                        Just _ ->
                            Cmd.none

                        Nothing ->
                            getWholeGraphData

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
                    if String.contains "tags/beni_oku" (Url.toString url) then
                        let
                            localStorage =
                                model.localStorage

                            newLocalStorage =
                                { localStorage | readMeIconClickedAtLeastOnce = True }

                            newModel =
                                { model | localStorage = newLocalStorage }
                        in
                        ( newModel, Cmd.batch [ storeReadMeIconClickedForTheFirstTime "true", Nav.pushUrl newModel.key (Url.toString url) ] )

                    else
                        ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                activePage : Page
                activePage =
                    pageBy url model.localStorage.readingMode

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
                                ContentPage (NonInitialized ( _, graphIsOn )) ->
                                    let
                                        newContent =
                                            if not graphIsOn then
                                                content

                                            else
                                                { content | graphDataIfGraphIsOn = Just (GraphData content.gotGraphData (initGraphModelForContent content.gotGraphData) False) }

                                        newContentPage =
                                            ContentPage <| Initialized newContent
                                    in
                                    newContentPage

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

        ContentReadChecked contentID ->
            if model.loggedIn then
                if model.waitingForContentCheckResponse then
                    ( model, Cmd.none )

                else
                    case model.maybeContentFadeOutData of
                        -- do not allow to check if a content is fading out
                        Just _ ->
                            ( model, Cmd.none )

                        Nothing ->
                            let
                                newModel =
                                    { model | waitingForContentCheckResponse = True }

                                tagIdOfTagPage =
                                    case model.activePage of
                                        TagPage status ->
                                            case status of
                                                Initialized pageModel ->
                                                    pageModel.tag.tagId

                                                NonInitialized _ ->
                                                    ""

                                        _ ->
                                            ""

                                idOfLatestContentOnTagPage =
                                    case model.activePage of
                                        TagPage status ->
                                            case status of
                                                Initialized pageModel ->
                                                    case List.Extra.last pageModel.contents of
                                                        Just content ->
                                                            content.contentId

                                                        Nothing ->
                                                            0

                                                NonInitialized _ ->
                                                    0

                                        _ ->
                                            0
                            in
                            ( newModel, setContentAsRead contentID tagIdOfTagPage idOfLatestContentOnTagPage newModel )

            else
                let
                    oldLocalStorage =
                        model.localStorage

                    newLocalStorage =
                        { oldLocalStorage | contentReadClickedAtLeastOnce = True }

                    newModel =
                        { model | activePage = LoginOrRegisterPage "" "" "", localStorage = newLocalStorage }
                in
                ( newModel, Cmd.batch [ storeContentReadClickedForTheFirstTime "true", sendTitle newModel ] )

        GotContentReadResponse res ->
            let
                updatedModel =
                    { model | waitingForContentCheckResponse = False }
            in
            case res of
                Ok data ->
                    if String.startsWith "error" data.idOfReadContentOrErrorMessage then
                        ( updatedModel, Cmd.none )

                    else
                        let
                            contentId =
                                data.idOfReadContentOrErrorMessage

                            revertRead content =
                                if content.contentId == Maybe.withDefault 0 (String.toInt contentId) then
                                    { content | isContentRead = not content.isContentRead }

                                else
                                    content
                        in
                        case updatedModel.activePage of
                            ContentPage status ->
                                case status of
                                    NonInitialized _ ->
                                        ( updatedModel, Cmd.none )

                                    Initialized content ->
                                        ( { updatedModel | activePage = ContentPage (Initialized (revertRead content)) }, Cmd.none )

                            TagPage status ->
                                case status of
                                    NonInitialized _ ->
                                        ( updatedModel, Cmd.none )

                                    Initialized pageModel ->
                                        if updatedModel.consumeModeIsOn then
                                            ( { updatedModel
                                                | activePage = TagPage (Initialized { pageModel | contents = List.map revertRead pageModel.contents })
                                                , maybeContentFadeOutData = Just (ContentFadeOutData 1 (Maybe.withDefault 0 (String.toInt contentId)) data.newTotalPageCountToSet data.contentToShowAsReplacementOnBottom)
                                              }
                                            , Cmd.none
                                            )

                                        else
                                            ( { updatedModel | activePage = TagPage (Initialized { pageModel | contents = List.map revertRead pageModel.contents }) }
                                            , Cmd.none
                                            )

                            ContentSearchPage searchKeyword contents ->
                                ( { updatedModel | activePage = ContentSearchPage searchKeyword (List.map revertRead contents) }, Cmd.none )

                            BulkContentsPage (Initialized contents) ->
                                ( { updatedModel | activePage = BulkContentsPage (Initialized (List.map revertRead contents)) }, Cmd.none )

                            _ ->
                                ( updatedModel, Cmd.none )

                Err _ ->
                    ( updatedModel, Cmd.none )

        -- BULK CONTENTS PAGE --
        GotBulkContents result ->
            case result of
                Ok gotContents ->
                    let
                        contents =
                            gotContents
                                |> List.map (gotContentToContent model)

                        bulkContentsPage =
                            BulkContentsPage <| Initialized contents

                        newModel =
                            { model | activePage = bulkContentsPage }
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

        HideContentFromActiveTagPage contentIdToHide newTotalPageCountToSet contentToAddToBottom ->
            case model.activePage of
                TagPage status ->
                    case status of
                        Initialized pageModel ->
                            if model.consumeModeIsOn then
                                let
                                    contentsWithDeletedContent =
                                        pageModel.contents |> List.filter (\c -> c.contentId /= contentIdToHide)

                                    contentsWithNewContentToBottom =
                                        case contentToAddToBottom of
                                            Just content ->
                                                contentsWithDeletedContent ++ [ gotContentToContent model content ]

                                            Nothing ->
                                                contentsWithDeletedContent

                                    modelWithNewContentListAndTotalPageCount =
                                        { model
                                            | activePage =
                                                TagPage
                                                    (Initialized
                                                        { pageModel
                                                            | contents = contentsWithNewContentToBottom
                                                            , pagination = { currentPage = pageModel.pagination.currentPage, totalPageCount = newTotalPageCountToSet }
                                                        }
                                                    )
                                        }
                                in
                                ( modelWithNewContentListAndTotalPageCount, Cmd.none )

                            else
                                ( model, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
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
            , getContent contentId model
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
                                HomePage Nothing Nothing BlogContents Nothing

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

        -- SEARCH PAGE --
        GotSearchInput searchKeyword ->
            let
                newPage =
                    case model.activePage of
                        HomePage _ _ _ _ ->
                            ContentSearchPage searchKeyword []

                        ContentSearchPage _ contentList ->
                            ContentSearchPage searchKeyword contentList

                        _ ->
                            model.activePage

                newModel =
                    { model | activePage = newPage }

                getAllTagsCmdMsg =
                    case model.activePage of
                        HomePage _ _ _ _ ->
                            getCmdToSendByPage newModel

                        _ ->
                            Cmd.none
            in
            ( newModel, Cmd.batch [ sendTitle newModel, getAllTagsCmdMsg, getSearchResult searchKeyword newModel, Dom.focus "contentSearchInput" |> Task.attempt FocusResult ] )

        GotContentSearchResponse res ->
            case res of
                Ok gotContentSearchResponse ->
                    let
                        newPage =
                            case model.activePage of
                                ContentSearchPage searchKeyword _ ->
                                    ContentSearchPage searchKeyword (List.map (gotContentToContent model) gotContentSearchResponse.contents)

                                _ ->
                                    model.activePage
                    in
                    ( { model | activePage = newPage }, Cmd.none )

                Err _ ->
                    createNewModelAndCmdMsg model MaintenancePage

        -- LOGIN PAGE --
        LoginRegisterPageInputChanged inputType input ->
            case model.activePage of
                LoginOrRegisterPage username password errorMessage ->
                    let
                        newActivePage =
                            case inputType of
                                Username ->
                                    LoginOrRegisterPage input password errorMessage

                                Pass ->
                                    LoginOrRegisterPage username input errorMessage

                        newModel =
                            { model | activePage = newActivePage }
                    in
                    ( newModel, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        TryLogin username password ->
            let
                newModel =
                    { model | localStorage = LocalStorage model.localStorage.readingMode model.localStorage.contentReadClickedAtLeastOnce model.localStorage.contentReadClickedAtLeastOnce username password }
            in
            ( newModel, Cmd.batch [ login LoginRequestByUser username password, storeCredentials (username ++ "|||" ++ password) ] )

        TryRegister username password ->
            let
                newModel =
                    { model | localStorage = LocalStorage model.localStorage.readingMode model.localStorage.contentReadClickedAtLeastOnce model.localStorage.readMeIconClickedAtLeastOnce username password }
            in
            ( newModel, Cmd.batch [ register username password, storeCredentials (username ++ "|||" ++ password) ] )

        GotLoginResponse loginRequestType res ->
            case loginRequestType of
                AttemptAtInitialization ->
                    case res of
                        Ok message ->
                            let
                                loggedInSuccessfully =
                                    not (String.startsWith "error" message)

                                newModel =
                                    if loggedInSuccessfully then
                                        { model | loggedIn = True }

                                    else
                                        model
                            in
                            ( newModel, getCmdToSendByPage newModel )

                        Err _ ->
                            createNewModelAndCmdMsg model NotFoundPage

                LoginRequestByUser ->
                    case res of
                        Ok message ->
                            if String.startsWith "error" message then
                                let
                                    newPage =
                                        case model.activePage of
                                            LoginOrRegisterPage username password _ ->
                                                LoginOrRegisterPage username password (Maybe.withDefault "" (List.head (List.drop 1 (String.split ":" message))))

                                            page ->
                                                page
                                in
                                ( { model | activePage = newPage }, Cmd.none )

                            else
                                let
                                    newActivePage =
                                        case model.activePage of
                                            LoginOrRegisterPage _ _ _ ->
                                                HomePage Nothing Nothing BlogContents Nothing

                                            page ->
                                                page

                                    newModel =
                                        { model | activePage = newActivePage, loggedIn = True }
                                in
                                ( newModel, Nav.pushUrl model.key "/" )

                        Err _ ->
                            createNewModelAndCmdMsg model NotFoundPage

        GotRegisterResponse res ->
            case res of
                Ok message ->
                    if String.startsWith "error" message then
                        let
                            newPage =
                                case model.activePage of
                                    LoginOrRegisterPage username password _ ->
                                        LoginOrRegisterPage username password (Maybe.withDefault "" (List.head (List.drop 1 (String.split ":" message))))

                                    page ->
                                        page
                        in
                        ( { model | activePage = newPage }, Cmd.none )

                    else
                        let
                            newActivePage =
                                case model.activePage of
                                    LoginOrRegisterPage _ _ _ ->
                                        HomePage Nothing Nothing BlogContents Nothing

                                    page ->
                                        page

                            newModel =
                                { model | activePage = newActivePage, loggedIn = True }
                        in
                        ( newModel, Nav.pushUrl model.key "/" )

                Err _ ->
                    createNewModelAndCmdMsg model NotFoundPage

        -- EKŞİ KONSERVE --
        GotEksiKonserveResponse res ->
            case res of
                Ok response ->
                    let
                        newPage =
                            EksiKonservePage (Initialized ( response.topics, response.exceptions ))

                        newModel =
                            { model | activePage = newPage }
                    in
                    ( newModel, Cmd.none )

                Err _ ->
                    createNewModelAndCmdMsg model MaintenancePage

        DeleteEksiKonserveTopics topicNames ->
            ( model, deleteEksiKonserveTopics topicNames model )

        ToggleEksiKonserveException messageOfToggledException ->
            case model.activePage of
                EksiKonservePage (Initialized ( topics, exceptions )) ->
                    let
                        toggleFn : EksiKonserveException -> EksiKonserveException
                        toggleFn exception =
                            { exception | show = not exception.show }

                        newExceptions =
                            exceptions
                                |> List.map
                                    (\e ->
                                        if messageOfToggledException == e.message then
                                            toggleFn e

                                        else
                                            e
                                    )

                        newModel =
                            { model | activePage = EksiKonservePage (Initialized ( topics, newExceptions )) }
                    in
                    ( newModel, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        DeleteAllEksiKonserveExceptions ->
            ( model, deleteAllEksiKonserveExceptions model )

        -- HOME PAGE & GRAPH --
        GotHomePageDataResponse res ->
            case res of
                Ok gotTagDataResponse ->
                    case model.activePage of
                        HomePage _ _ readingMode maybeGraphData ->
                            let
                                homePage =
                                    HomePage (Just gotTagDataResponse.blogTagsToShow) (Just gotTagDataResponse.allTagsToShow) readingMode maybeGraphData

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
                        HomePage blogTags allTags _ maybeGraphData ->
                            HomePage blogTags allTags readingMode maybeGraphData

                        _ ->
                            model.activePage

                oldLocalStorage =
                    model.localStorage

                newLocalStorage =
                    { oldLocalStorage | readingMode = readingMode }
            in
            ( { model | activePage = newPage, localStorage = newLocalStorage }
            , storeReadingMode
                (case readingMode of
                    BlogContents ->
                        "blog"

                    AllContents ->
                        "tümü"
                )
            )

        ConsumeModeChanged _ ->
            ( { model | consumeModeIsOn = not model.consumeModeIsOn }
            , Cmd.batch
                [ storeConsumeMode
                    (if not model.consumeModeIsOn then
                        "true"

                     else
                        "false"
                    )
                , Nav.pushUrl model.key "/"
                ]
            )

        Logout ->
            let
                newLocalStorage =
                    LocalStorage model.localStorage.readingMode model.localStorage.contentReadClickedAtLeastOnce model.localStorage.readMeIconClickedAtLeastOnce "invalidUsername" "invalidPassword"

                newModel =
                    { model | loggedIn = False, localStorage = newLocalStorage }
            in
            ( newModel, Cmd.batch [ storeCredentials "invalidUsername|||invalidPassword", Nav.pushUrl model.key "/" ] )

        GotGraphData res ->
            case res of
                Ok gotGraphData ->
                    let
                        newModel =
                            case model.activePage of
                                HomePage blogTags allTags readingMode maybeGraphData ->
                                    case maybeGraphData of
                                        Just _ ->
                                            model

                                        Nothing ->
                                            { model | activePage = HomePage blogTags allTags readingMode (Just (GraphData gotGraphData (initGraphModel gotGraphData) False)) }

                                GrafPage maybeGraphData ->
                                    case maybeGraphData of
                                        Just _ ->
                                            model

                                        Nothing ->
                                            { model | activePage = GrafPage (Just (GraphData gotGraphData (initGraphModelForGraphPage gotGraphData) False)) }

                                _ ->
                                    model
                    in
                    ( newModel, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        GoToContentViaContentGraph contentID ctrlIsPressed ->
            ( model
            , if ctrlIsPressed then
                openNewTab ("/contents/" ++ String.fromInt contentID ++ "?graph=true")

              else
                Nav.pushUrl model.key ("/contents/" ++ String.fromInt contentID ++ "?graph=true")
            )

        otherMsg ->
            case model.activePage of
                HomePage blogTags allTags readingMode maybeGraphData ->
                    case maybeGraphData of
                        Just graphData ->
                            let
                                newGraphData =
                                    Just (GraphData graphData.graphData (updateGraph otherMsg graphData.graphModel) True)

                                newHomePage =
                                    HomePage blogTags allTags readingMode newGraphData
                            in
                            ( { model | activePage = newHomePage }, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                GrafPage maybeGraphData ->
                    case maybeGraphData of
                        Just graphData ->
                            let
                                newGraphData =
                                    Just (GraphData graphData.graphData (updateGraph otherMsg graphData.graphModel) True)

                                newHomePage =
                                    GrafPage newGraphData
                            in
                            ( { model | activePage = newHomePage }, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                ContentPage data ->
                    case data of
                        Initialized content ->
                            case content.graphDataIfGraphIsOn of
                                Just graphData ->
                                    let
                                        newGraphData =
                                            Just (GraphData graphData.graphData (updateGraph otherMsg graphData.graphModel) True)

                                        newContentPage =
                                            ContentPage (Initialized { content | graphDataIfGraphIsOn = newGraphData })
                                    in
                                    ( { model | activePage = newContentPage }, Cmd.none )

                                Nothing ->
                                    ( model, Cmd.none )

                        NonInitialized _ ->
                            ( model, Cmd.none )

                TagPage _ ->
                    let
                        modelAndCmdPairForFadeOut : ( Model, Cmd Msg )
                        modelAndCmdPairForFadeOut =
                            case model.maybeContentFadeOutData of
                                Just data ->
                                    let
                                        t =
                                            0.05

                                        dataToFadeContent =
                                            if data.opacityLevel <= t then
                                                Nothing

                                            else
                                                Just { data | opacityLevel = data.opacityLevel - t }
                                    in
                                    ( { model | maybeContentFadeOutData = dataToFadeContent }
                                    , if dataToFadeContent == Nothing then
                                        Task.perform (always (HideContentFromActiveTagPage data.contentIdToFade data.newPageCountToSet data.contentToAddToBottom)) (Task.succeed ())

                                      else
                                        Cmd.none
                                    )

                                Nothing ->
                                    ( model, Cmd.none )
                    in
                    modelAndCmdPairForFadeOut

                _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.activePage of
        HomePage blogTags allTags readingMode maybeGraphData ->
            case maybeGraphData of
                Just graphData ->
                    let
                        totalTagCountCurrentlyShownOnPage =
                            tagCountCurrentlyShownOnPage readingMode allTags blogTags
                    in
                    graphSubscriptions graphData.graphModel totalTagCountCurrentlyShownOnPage

                Nothing ->
                    Sub.none

        GrafPage maybeGraphData ->
            case maybeGraphData of
                Just graphData ->
                    graphSubscriptionsForGraph graphData.graphModel

                Nothing ->
                    Sub.none

        ContentPage data ->
            case data of
                Initialized content ->
                    case content.graphDataIfGraphIsOn of
                        Just graphData ->
                            graphSubscriptionsForContent graphData.graphModel

                        Nothing ->
                            Sub.none

                NonInitialized _ ->
                    Sub.none

        TagPage _ ->
            let
                subForContentFadeOut =
                    if model.maybeContentFadeOutData /= Nothing then
                        Time.every 80 Tick

                    else
                        Sub.none
            in
            subForContentFadeOut

        _ ->
            Sub.none
