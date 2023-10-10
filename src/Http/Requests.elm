module Requests exposing (createNewTag, deleteAllEksiKonserveExceptions, deleteEksiKonserveTopics, getAllTagsResponse, getBio, getBioPageIcons, getBulkContents, getContent, getEksiKonserve, getHomePageDataResponse, getIcons, getSearchResult, getTagContents, getTimeZone, getWholeGraphData, login, postNewContent, previewContent, register, setContentAsRead, updateExistingContent, updateExistingTag, getUrlToRedirect)

import App.IconUtil exposing (getIconPath)
import App.Model exposing (CreateContentPageModel, CreateTagPageModel, GetBulkContentsRequestModel, GetContentRequestModel, GetTagContentsRequestModel, IconInfo, Model, ReadingMode(..), Theme, TotalPageCountRequestModel, UpdateContentPageData, UpdateTagPageModel, createContentPageModelEncoder, createTagPageModelEncoder, getBulkContentsRequestModelEncoder, getContentRequestModelEncoder, getTagContentsRequestModelEncoder, updateContentPageDataEncoder, updateTagPageModelEncoder)
import App.Msg exposing (LoginRequestType, Msg(..), PreviewContentModel(..))
import DataResponse exposing (ContentID, allTagsResponseDecoder, bioResponseDecoder, contentDecoder, contentReadResponseDecoder, contentSearchResponseDecoder, contentsResponseDecoder, eksiKonserveResponseDecoder, gotGraphDataDecoder, homePageDataResponseDecoder)
import Http
import Json.Decode as D
import Json.Encode as Encode
import Tag.Model exposing (Tag)
import Task
import Time


apiURL =
    "http://localhost:8090/"


getTimeZone : Cmd Msg
getTimeZone =
    Task.perform GotTimeZone Time.here


getAllTagsResponse : Cmd Msg
getAllTagsResponse =
    Http.get
        { url = apiURL ++ "get-all-tags"
        , expect = Http.expectJson GotAllTagsResponse allTagsResponseDecoder
        }


getHomePageDataResponse : Bool -> Bool -> String -> String -> Cmd Msg
getHomePageDataResponse loggedIn consumeMode username password =
    Http.post
        { url = apiURL ++ "get-homepage-data"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "loggedIn", Encode.bool loggedIn )
                    , ( "consumeMode", Encode.bool consumeMode )
                    , ( "username", Encode.string username )
                    , ( "password", Encode.string password )
                    ]
                )
        , expect = Http.expectJson GotHomePageDataResponse homePageDataResponseDecoder
        }


getTagContents : Tag -> Maybe Int -> ReadingMode -> Model -> Cmd Msg
getTagContents tag maybePage readingMode model =
    let
        getTagContentsRequestModel : GetTagContentsRequestModel
        getTagContentsRequestModel =
            GetTagContentsRequestModel tag.tagId
                maybePage
                (case readingMode of
                    BlogContents ->
                        True

                    AllContents ->
                        False
                )
                model.loggedIn
                model.consumeModeIsOn
                model.localStorage.username
                model.localStorage.password
    in
    Http.post
        { url = apiURL ++ "contents-of-tag"
        , body = Http.jsonBody (getTagContentsRequestModelEncoder getTagContentsRequestModel)
        , expect = Http.expectJson (GotContentsOfTag tag) contentsResponseDecoder
        }


getContent : Int -> Model -> Cmd Msg
getContent contentId model =
    Http.post
        { url = apiURL ++ "get-content"
        , body = Http.jsonBody (getContentRequestModelEncoder (GetContentRequestModel contentId model.loggedIn model.localStorage.username model.localStorage.password))
        , expect = Http.expectJson GotContent contentDecoder
        }


getBulkContents : String -> Model -> Cmd Msg
getBulkContents contentIds model =
    Http.post
        { url = apiURL ++ "get-bulk"
        , body = Http.jsonBody (getBulkContentsRequestModelEncoder (GetBulkContentsRequestModel contentIds model.loggedIn model.localStorage.username model.localStorage.password))
        , expect = Http.expectJson GotBulkContents (D.list contentDecoder)
        }


getWholeGraphData : Cmd Msg
getWholeGraphData =
    Http.get
        { url = apiURL ++ "graph-data"
        , expect = Http.expectJson GotGraphData gotGraphDataDecoder
        }


postNewContent : CreateContentPageModel -> Cmd Msg
postNewContent model =
    Http.post
        { url = apiURL ++ "contents"
        , body = Http.jsonBody (createContentPageModelEncoder model)
        , expect = Http.expectJson GotContent contentDecoder
        }


updateExistingContent : ContentID -> UpdateContentPageData -> Cmd Msg
updateExistingContent contentId model =
    Http.post
        { url = apiURL ++ "contents/" ++ String.fromInt contentId
        , body = Http.jsonBody (updateContentPageDataEncoder contentId model)
        , expect = Http.expectJson GotContent contentDecoder
        }


previewContent : PreviewContentModel -> Cmd Msg
previewContent model =
    case model of
        PreviewForContentCreate createContentPageModel ->
            Http.post
                { url = apiURL ++ "preview-content"
                , body = Http.jsonBody (createContentPageModelEncoder createContentPageModel)
                , expect = Http.expectJson (GotContentToPreviewForCreatePage createContentPageModel) contentDecoder
                }

        PreviewForContentUpdate contentID updateContentPageData ->
            Http.post
                { url = apiURL ++ "preview-content"
                , body = Http.jsonBody (updateContentPageDataEncoder contentID updateContentPageData)
                , expect = Http.expectJson (GotContentToPreviewForUpdatePage contentID updateContentPageData) contentDecoder
                }


createNewTag : CreateTagPageModel -> Cmd Msg
createNewTag model =
    Http.post
        { url = apiURL ++ "tags"
        , body = Http.jsonBody (createTagPageModelEncoder model)
        , expect = Http.expectString GotTagUpdateOrCreationDoneResponse
        }


updateExistingTag : String -> UpdateTagPageModel -> Cmd Msg
updateExistingTag tagId model =
    Http.post
        { url = apiURL ++ "tags/" ++ tagId
        , body = Http.jsonBody (updateTagPageModelEncoder model)
        , expect = Http.expectString GotTagUpdateOrCreationDoneResponse
        }


aboutMeIcon : Theme -> IconInfo
aboutMeIcon activeTheme =
    { urlToNavigate = "https://about.me/m.e", iconImageUrl = (getIconPath activeTheme "about-me"), marginLeft = "4px" }


bioPageIcon : Theme -> IconInfo
bioPageIcon activeTheme =
    { urlToNavigate = "/me", iconImageUrl = (getIconPath activeTheme "bio"), marginLeft = "4px" }


homeIcon : Theme -> IconInfo
homeIcon activeTheme =
    { urlToNavigate = "/", iconImageUrl = (getIconPath activeTheme "home"), marginLeft = "4px" }


readMeIcon : Theme -> Bool -> IconInfo
readMeIcon activeTheme readMeIconClickedAtLeastOnce =
    { urlToNavigate = "/tags/beni_oku"
    , iconImageUrl =
        if readMeIconClickedAtLeastOnce then
            (getIconPath activeTheme "question-mark")

        else
            (getIconPath activeTheme "question-mark-red")
    , marginLeft = "4px"
    }


getBioPageIcons : Theme -> Bool -> Bool -> List IconInfo
getBioPageIcons activeTheme showAdditionalIcons readMeIconClickedAtLeastOnce =
    aboutMeIcon activeTheme
        :: getAdditionalIcons activeTheme showAdditionalIcons
        ++ [ homeIcon activeTheme, readMeIcon activeTheme readMeIconClickedAtLeastOnce ]


getIcons : Theme -> Bool -> Bool -> List IconInfo
getIcons activeTheme showAdditionalIcons readMeIconClickedAtLeastOnce =
    [ aboutMeIcon activeTheme, bioPageIcon activeTheme, readMeIcon activeTheme readMeIconClickedAtLeastOnce ]
        ++ getAdditionalIcons activeTheme showAdditionalIcons


getAdditionalIcons : Theme -> Bool -> List IconInfo
getAdditionalIcons activeTheme showAdditionalIcons =
    if not showAdditionalIcons then
        []

    else
        [ { urlToNavigate = "https://open.spotify.com/user/215irwufih45cpoovmxs2r25q/", iconImageUrl = (getIconPath activeTheme "spotify"), marginLeft = "4px" }
        , { urlToNavigate = "https://github.com/elifoglu", iconImageUrl = (getIconPath activeTheme "github"), marginLeft = "4px" }
        , { urlToNavigate = "https://philocoder.medium.com/", iconImageUrl = (getIconPath activeTheme "medium"), marginLeft = "4px" }
        , { urlToNavigate = "https://eksisozluk1923.com/biri/ajora", iconImageUrl = (getIconPath activeTheme "eksi"), marginLeft = "4px" }
        , { urlToNavigate = "https://twitter.com/philocoder", iconImageUrl = (getIconPath activeTheme "twitter"), marginLeft = "4px" }
        , { urlToNavigate = "https://youtube.com/ajora", iconImageUrl = (getIconPath activeTheme "youtube"), marginLeft = "4px" }
        , { urlToNavigate = "https://www.criticker.com/ratings/philocoder", iconImageUrl = (getIconPath activeTheme "criticker"), marginLeft = "4px" }
        ]


getBio : Cmd Msg
getBio =
    Http.get
        { url = apiURL ++ "bio"
        , expect = Http.expectJson GotBioResponse bioResponseDecoder
        }


getSearchResult : String -> Model -> Cmd Msg
getSearchResult searchKeyword model =
    Http.post
        { url = apiURL ++ "search"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "keyword", Encode.string searchKeyword )
                    , ( "loggedIn", Encode.bool model.loggedIn )
                    , ( "username", Encode.string model.localStorage.username )
                    , ( "password", Encode.string model.localStorage.password )
                    ]
                )
        , expect = Http.expectJson GotContentSearchResponse contentSearchResponseDecoder
        }


login : LoginRequestType -> String -> String -> Cmd Msg
login loginType username password =
    Http.post
        { url = apiURL ++ "login"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "username", Encode.string username )
                    , ( "password", Encode.string password )
                    ]
                )
        , expect = Http.expectString (GotLoginResponse loginType)
        }


register : String -> String -> Cmd Msg
register username password =
    Http.post
        { url = apiURL ++ "register"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "username", Encode.string username )
                    , ( "password", Encode.string password )
                    ]
                )
        , expect = Http.expectString GotRegisterResponse
        }

getUrlToRedirect : String -> Cmd Msg
getUrlToRedirect path =
    Http.post
        { url = apiURL ++ "get-url-to-redirect"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "path", Encode.string path )
                    ]
                )
        , expect = Http.expectString GotUrlToRedirectResponse
        }


setContentAsRead : Int -> String -> Int -> Model -> Cmd Msg
setContentAsRead contentId tagIdOfTagPage idOfLatestContentOnTagPage model =
    Http.post
        { url = apiURL ++ "set-content-as-read"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "contentId", Encode.int contentId )
                    , ( "tagIdOfTagPage", Encode.string tagIdOfTagPage )
                    , ( "contentIdOfLatestContentOnTagPage", Encode.int idOfLatestContentOnTagPage )
                    , ( "loggedIn", Encode.bool model.loggedIn )
                    , ( "consumeMode", Encode.bool model.consumeModeIsOn )
                    , ( "blogMode"
                      , Encode.bool
                            (case model.localStorage.readingMode of
                                BlogContents ->
                                    True

                                AllContents ->
                                    False
                            )
                      )
                    , ( "username", Encode.string model.localStorage.username )
                    , ( "password", Encode.string model.localStorage.password )
                    ]
                )
        , expect = Http.expectJson GotContentReadResponse contentReadResponseDecoder
        }


getEksiKonserve : Model -> Cmd Msg
getEksiKonserve model =
    Http.post
        { url = apiURL ++ "get-eksi-konserve"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "loggedIn", Encode.bool model.loggedIn )
                    , ( "username", Encode.string model.localStorage.username )
                    , ( "password", Encode.string model.localStorage.password )
                    ]
                )
        , expect = Http.expectJson GotEksiKonserveResponse eksiKonserveResponseDecoder
        }


deleteEksiKonserveTopics : List String -> Model -> Cmd Msg
deleteEksiKonserveTopics topicNames model =
    Http.post
        { url = apiURL ++ "delete-eksi-konserve-topics"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "loggedIn", Encode.bool model.loggedIn )
                    , ( "username", Encode.string model.localStorage.username )
                    , ( "password", Encode.string model.localStorage.password )
                    , ( "topicNames", Encode.list Encode.string topicNames )
                    ]
                )
        , expect = Http.expectJson GotEksiKonserveResponse eksiKonserveResponseDecoder
        }


deleteAllEksiKonserveExceptions : Model -> Cmd Msg
deleteAllEksiKonserveExceptions model =
    Http.post
        { url = apiURL ++ "delete-all-eksi-konserve-exceptions"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "loggedIn", Encode.bool model.loggedIn )
                    , ( "username", Encode.string model.localStorage.username )
                    , ( "password", Encode.string model.localStorage.password )
                    ]
                )
        , expect = Http.expectJson GotEksiKonserveResponse eksiKonserveResponseDecoder
        }
