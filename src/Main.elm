module Main exposing (main, needAllTagsData)

import App.Model exposing (..)
import App.Msg exposing (ContentInputType(..), LoginRegisterPageInputType(..), LoginRequestType(..), Msg(..), TagInputType(..))
import App.Ports exposing (sendTitle, storeConsumeMode, storeContentReadClickedForTheFirstTime, storeCredentials, storeReadingMode)
import App.UrlParser exposing (pageBy)
import App.View exposing (view)
import BioGroup.Util exposing (changeActivenessIfIdMatches, changeDisplayInfoIfIdMatchesAndGroupIsActive, gotBioGroupToBioGroup)
import BioGroups.View exposing (makeAllBioGroupsNonActive)
import BioItem.Util exposing (gotBioItemToBioItem)
import Browser exposing (UrlRequest)
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Component.Page.Util exposing (tagsNotLoaded)
import Content.Model exposing (Content)
import Content.Util exposing (gotContentToContent)
import ForceDirectedGraph exposing (graphSubscriptions, initGraphModel, updateGraph)
import Home.View exposing (tagCountCurrentlyShownOnPage)
import List
import List.Extra
import Pagination.Model exposing (Pagination)
import Requests exposing (createNewTag, getAllRefData, getAllTagsResponse, getBio, getContent, getHomePageDataResponse, getOnlyTotalPageCountForPagination, getSearchResult, getTagContents, getTimeZone, login, postNewContent, previewContent, register, setContentAsRead, updateExistingContent, updateExistingTag)
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


init : { readingMode : Maybe String, consumeModeIsOn : Maybe String, contentReadClickedAtLeastOnce : Maybe String, credentials : Maybe String } -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
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

        page =
            pageBy url readingMode

        getConsumeModeIsOnValueFromLocal maybeString =
            case maybeString of
                Just "true" ->
                    True

                _ ->
                    False

        model =
            Model "log" key [] page False (LocalStorage readingMode contentReadClickedAtLeastOnce username password) False (getConsumeModeIsOnValueFromLocal flags.consumeModeIsOn) Nothing Time.utc
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

        ContentSearchPage _ _ ->
            False

        LoginOrRegisterPage _ _ _ ->
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
                HomePage blogTagsToShow allTagsToShow _ maybeGraphData ->
                    if blogTagsToShow == Nothing && allTagsToShow == Nothing then
                        getHomePageDataResponse model.loggedIn model.consumeModeIsOn model.localStorage.username model.localStorage.password

                    else if maybeGraphData == Nothing then
                        getAllRefData

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
                        NonInitialized contentId ->
                            getContent contentId model

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

        ContentReadChecked contentID ->
            if model.loggedIn then
                case model.dataToFadeContent of
                    -- do not allow to check if the content is fading out
                    Just data ->
                        if Tuple.second data == contentID then
                            ( model, Cmd.none )

                        else
                            ( model, setContentAsRead contentID model )

                    Nothing ->
                        ( model, setContentAsRead contentID model )

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
            case res of
                Ok message ->
                    if String.startsWith "error" message then
                        ( model, Cmd.none )

                    else
                        let
                            contentId =
                                message

                            revertRead content =
                                if content.contentId == Maybe.withDefault 0 (String.toInt contentId) then
                                    { content | isContentRead = not content.isContentRead }

                                else
                                    content
                        in
                        case model.activePage of
                            ContentPage status ->
                                case status of
                                    NonInitialized _ ->
                                        ( model, Cmd.none )

                                    Initialized content ->
                                        ( { model | activePage = ContentPage (Initialized (revertRead content)) }, Cmd.none )

                            TagPage status ->
                                case status of
                                    NonInitialized _ ->
                                        ( model, Cmd.none )

                                    Initialized pageModel ->
                                        if model.consumeModeIsOn then
                                            ( { model
                                                | activePage = TagPage (Initialized { pageModel | contents = List.map revertRead pageModel.contents })
                                                , dataToFadeContent = Just ( 1, Maybe.withDefault 0 (String.toInt contentId) )
                                              }
                                            , getOnlyTotalPageCountForPagination pageModel.tag pageModel.readingMode model
                                              --since we hid a content on the screen, we have to recalculate total page count and set pagination again
                                            )

                                        else
                                            ( { model | activePage = TagPage (Initialized { pageModel | contents = List.map revertRead pageModel.contents }) }
                                            , Cmd.none
                                            )

                            ContentSearchPage searchKeyword contents ->
                                ( { model | activePage = ContentSearchPage searchKeyword (List.map revertRead contents) }, Cmd.none )

                            _ ->
                                ( model, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

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

        GotTotalPageCountOfTag res ->
            case res of
                Ok message ->
                    case model.activePage of
                        TagPage status ->
                            case status of
                                NonInitialized _ ->
                                    ( model, Cmd.none )

                                Initialized pageModel ->
                                    let
                                        totalPageCount =
                                            Maybe.withDefault 0 (String.toInt message)
                                    in
                                    ( { model | activePage = TagPage (Initialized { pageModel | pagination = { currentPage = pageModel.pagination.currentPage, totalPageCount = totalPageCount } }) }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        HideContentFromActiveTagPage contentId ->
            case model.activePage of
                TagPage status ->
                    case status of
                        Initialized pageModel ->
                            if model.consumeModeIsOn then
                                ( { model | activePage = TagPage (Initialized { pageModel | contents = pageModel.contents |> List.filter (\c -> c.contentId /= contentId) }) }, Cmd.none )

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
            in
            ( newModel, Cmd.batch [ sendTitle newModel, getSearchResult searchKeyword newModel, Dom.focus "contentSearchInput" |> Task.attempt FocusResult ] )

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
                    { model | localStorage = LocalStorage model.localStorage.readingMode model.localStorage.contentReadClickedAtLeastOnce username password }
            in
            ( newModel, Cmd.batch [ login LoginRequestByUser username password, storeCredentials (username ++ "|||" ++ password) ] )

        TryRegister username password ->
            let
                newModel =
                    { model | localStorage = LocalStorage model.localStorage.readingMode model.localStorage.contentReadClickedAtLeastOnce username password }
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
                    LocalStorage model.localStorage.readingMode model.localStorage.contentReadClickedAtLeastOnce "invalidUsername" "invalidPassword"

                newModel =
                    { model | loggedIn = False, localStorage = newLocalStorage }
            in
            ( newModel, Cmd.batch [ storeCredentials "invalidUsername|||invalidPassword", Nav.pushUrl model.key "/" ] )

        GotAllRefData res ->
            case res of
                Ok allRefData ->
                    let
                        newModel =
                            case model.activePage of
                                HomePage blogTags allTags readingMode maybeGraphData ->
                                    case maybeGraphData of
                                        Just _ ->
                                            model

                                        Nothing ->
                                            { model | activePage = HomePage blogTags allTags readingMode (Just (GraphData allRefData (initGraphModel allRefData) False)) }

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
                HomePage blogTags allTags readingMode maybeGraphData ->
                    case maybeGraphData of
                        Just graphData ->
                            let
                                newGraphData =
                                    Just (GraphData graphData.allRefData (updateGraph otherMsg graphData.graphModel) True)

                                newHomePage =
                                    HomePage blogTags allTags readingMode newGraphData
                            in
                            ( { model | activePage = newHomePage }, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                TagPage _ ->
                    case model.dataToFadeContent of
                        Just ( opacityLevel, contentId ) ->
                            let
                                t =
                                    0.05

                                dataToFadeContent =
                                    if opacityLevel <= t then
                                        Nothing

                                    else
                                        Just ( opacityLevel - t, contentId )
                            in
                            ( { model | dataToFadeContent = dataToFadeContent }
                            , if dataToFadeContent == Nothing then
                                Task.perform (always (HideContentFromActiveTagPage contentId)) (Task.succeed ())

                              else
                                Cmd.none
                            )

                        Nothing ->
                            ( model, Cmd.none )

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

        TagPage _ ->
            if model.dataToFadeContent /= Nothing then
                Time.every 80 Tick

            else
                Sub.none

        _ ->
            Sub.none
