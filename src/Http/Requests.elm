module Requests exposing (createNewTag, getAllRefData, getAllTagsResponse, getBio, getBioPageIcons, getHomePageDataResponse, getContent, getIcons, getOnlyTotalPageCountForPagination, getSearchResult, getTagContents, getTimeZone, login, postNewContent, previewContent, register, setContentAsRead, updateExistingContent, updateExistingTag)

import App.Model exposing (CreateContentPageModel, CreateTagPageModel, GetContentRequestModel, GetTagContentsRequestModel, IconInfo, Model, ReadingMode(..), TotalPageCountRequestModel, UpdateContentPageData, UpdateTagPageModel, createContentPageModelEncoder, createTagPageModelEncoder, getContentRequestModelEncoder, getTagContentsRequestModelEncoder, totalPageCountRequestModelEncoder, updateContentPageDataEncoder, updateTagPageModelEncoder)
import App.Msg exposing (LoginRequestType, Msg(..), PreviewContentModel(..))
import DataResponse exposing (ContentID, allTagsResponseDecoder, bioResponseDecoder, homePageDataResponseDecoder, contentDecoder, contentSearchResponseDecoder, contentsResponseDecoder, gotAllRefDataDecoder)
import Http
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
                (model.loggedIn && model.consumeModeIsOn)
                model.loggedIn
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


getAllRefData : Cmd Msg
getAllRefData =
    Http.get
        { url = apiURL ++ "ref-data"
        , expect = Http.expectJson GotAllRefData gotAllRefDataDecoder
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


aboutMeIcon : IconInfo
aboutMeIcon =
    { urlToNavigate = "https://about.me/m.e", iconImageUrl = "/about-me.svg", marginLeft = "4px" }


bioPageIcon : IconInfo
bioPageIcon =
    { urlToNavigate = "/me", iconImageUrl = "/bio.svg", marginLeft = "4px" }


homeIcon : IconInfo
homeIcon =
    { urlToNavigate = "/", iconImageUrl = "/home.svg", marginLeft = "4px" }


readMeIcon : IconInfo
readMeIcon =
    { urlToNavigate = "/tags/beni_oku", iconImageUrl = "/question-mark.svg", marginLeft = "4px" }


getBioPageIcons : Bool -> List IconInfo
getBioPageIcons showAdditionalIcons =
    aboutMeIcon
        :: getAdditionalIcons showAdditionalIcons
        ++ [ homeIcon, readMeIcon ]


getIcons : Bool -> List IconInfo
getIcons showAdditionalIcons =
    [ aboutMeIcon, bioPageIcon, readMeIcon ]
        ++ getAdditionalIcons showAdditionalIcons


getAdditionalIcons : Bool -> List IconInfo
getAdditionalIcons showAdditionalIcons =
    if not showAdditionalIcons then
        []

    else
        [ { urlToNavigate = "https://open.spotify.com/user/215irwufih45cpoovmxs2r25q/", iconImageUrl = "/spotify.svg", marginLeft = "4px" }
        , { urlToNavigate = "https://github.com/elifoglu", iconImageUrl = "/github.svg", marginLeft = "4px" }
        , { urlToNavigate = "https://philocoder.medium.com/", iconImageUrl = "/medium.svg", marginLeft = "4px" }
        , { urlToNavigate = "https://eksisozluk.com/biri/ajora", iconImageUrl = "/eksi.svg", marginLeft = "4px" }
        , { urlToNavigate = "https://twitter.com/philocoder", iconImageUrl = "/twitter.svg", marginLeft = "4px" }
        , { urlToNavigate = "https://youtube.com/ajora", iconImageUrl = "/youtube.svg", marginLeft = "4px" }
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


setContentAsRead : Int -> Model -> Cmd Msg
setContentAsRead contentId model =
    Http.post
        { url = apiURL ++ "set-content-as-read"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "contentId", Encode.int contentId )
                    , ( "username", Encode.string model.localStorage.username )
                    , ( "password", Encode.string model.localStorage.password )
                    ]
                )
        , expect = Http.expectString GotContentReadResponse
        }


getOnlyTotalPageCountForPagination : Tag -> ReadingMode -> Model -> Cmd Msg
getOnlyTotalPageCountForPagination tag readingMode model =
    let
        totalPageCountRequestModel : TotalPageCountRequestModel
        totalPageCountRequestModel =
            TotalPageCountRequestModel tag.tagId
                (case readingMode of
                    BlogContents ->
                        True

                    AllContents ->
                        False
                )
                (model.loggedIn && model.consumeModeIsOn)
                model.localStorage.username
                model.localStorage.password
    in
    Http.post
        { url = apiURL ++ "total-page-count-of-tag"
        , body = Http.jsonBody (totalPageCountRequestModelEncoder totalPageCountRequestModel)
        , expect = Http.expectString GotTotalPageCountOfTag
        }
