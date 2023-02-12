module DataResponse exposing (AllTagsResponse, BioGroupID, BioItemID, BioResponse, ContentID, ContentReadResponse, ContentSearchResponse, ContentsResponse, EksiKonserveResponse, EksiKonserveTopic, GotAllRefData, GotBioGroup, GotBioItem, GotContent, GotContentDate, GotRefConnection, GotTag, HomePageDataResponse, allTagsResponseDecoder, bioResponseDecoder, contentDecoder, contentReadResponseDecoder, contentSearchResponseDecoder, contentsResponseDecoder, eksiKonserveResponseDecoder, gotAllRefDataDecoder, homePageDataResponseDecoder)

import Content.Model exposing (Ref)
import Json.Decode as D exposing (Decoder, bool, field, int, map, map2, map3, map5, map6, map7, map8, maybe, string)


type alias AllTagsResponse =
    { allTags : List GotTag }


type alias HomePageDataResponse =
    { blogTagsToShow : List GotTag
    , allTagsToShow : List GotTag
    }


type alias ContentsResponse =
    { totalPageCount : Int, contents : List GotContent }


type alias ContentReadResponse =
    { idOfReadContentOrErrorMessage : String
    , newTotalPageCountToSet : Int
    , contentToShowAsReplacementOnBottom : Maybe GotContent
    }


type alias GotTag =
    { tagId : String
    , name : String
    , showInTagsOfContent : Bool
    , showContentCount : Bool
    , orderIndex : Maybe Int
    , contentCount : Int
    , infoContentId : Maybe Int
    }


type alias GotContent =
    { title : Maybe String, dateAsTimestamp : GotContentDate, contentId : Int, content : String, beautifiedContentText : String, tags : List String, refs : Maybe (List Ref), okForBlogMode : Bool, isContentRead : Bool }


type alias ContentID =
    Int


type alias GotContentDate =
    String


type alias GotAllRefData =
    { titlesToShow : List String
    , contentIds : List Int
    , connections : List GotRefConnection
    }


type alias GotRefConnection =
    { a : Int, b : Int }


type alias BioResponse =
    { groups : List GotBioGroup
    , items : List GotBioItem
    }


type alias GotBioGroup =
    { bioGroupID : BioGroupID
    , title : String
    , displayIndex : Int
    , info : Maybe String
    , bioItemOrder : List Int
    }


type alias BioGroupID =
    Int


type alias BioItemID =
    Int


type alias GotBioItem =
    { bioItemID : Int
    , name : String
    , groups : List Int
    , groupNames : List String
    , colorHex : Maybe String
    , info : Maybe String
    }


type alias ContentSearchResponse =
    { contents : List GotContent
    }


type alias EksiKonserveTopic =
    { name : String
    , url : String
    , count : Int
    }


type alias EksiKonserveResponse =
    { topics : List EksiKonserveTopic
    }


allTagsResponseDecoder : Decoder AllTagsResponse
allTagsResponseDecoder =
    map AllTagsResponse
        (field "allTags" (D.list tagDecoder))


homePageDataResponseDecoder : Decoder HomePageDataResponse
homePageDataResponseDecoder =
    map2 HomePageDataResponse
        (field "blogTagsToShow" (D.list tagDecoder))
        (field "allTagsToShow" (D.list tagDecoder))


contentsResponseDecoder : Decoder ContentsResponse
contentsResponseDecoder =
    map2 ContentsResponse
        (field "totalPageCount" int)
        (field "contents" (D.list contentDecoder))


contentReadResponseDecoder : Decoder ContentReadResponse
contentReadResponseDecoder =
    map3 ContentReadResponse
        (field "idOfReadContentOrErrorMessage" string)
        (field "newTotalPageCountToSet" int)
        (field "contentToShowAsReplacementOnBottom" (maybe contentDecoder))


contentSearchResponseDecoder : Decoder ContentSearchResponse
contentSearchResponseDecoder =
    map ContentSearchResponse
        (field "contents" (D.list contentDecoder))


gotAllRefDataDecoder : Decoder GotAllRefData
gotAllRefDataDecoder =
    map3 GotAllRefData
        (field "titlesToShow" (D.list string))
        (field "contentIds" (D.list int))
        (field "connections" (D.list refConnectionDecoder))


refConnectionDecoder : Decoder GotRefConnection
refConnectionDecoder =
    map2 GotRefConnection
        (field "a" int)
        (field "b" int)


tagDecoder : Decoder GotTag
tagDecoder =
    map7 GotTag
        (field "tagId" string)
        (field "name" string)
        (field "showInTagsOfContent" bool)
        (field "showContentCount" bool)
        (field "orderIndex" (maybe int))
        (field "contentCount" int)
        (field "infoContentId" (maybe int))


contentDecoder : Decoder GotContent
contentDecoder =
    let
        decodeFirst8FieldAtFirst =
            map8 GotContent
                (maybe (field "title" string))
                (field "dateAsTimestamp" contentDateDecoder)
                (field "contentId" int)
                (field "content" string)
                (field "beautifiedContentText" string)
                (field "tags" (D.list string))
                (maybe (field "refs" (D.list refDecoder)))
                (field "okForBlogMode" bool)
    in
    map2
        (<|)
        decodeFirst8FieldAtFirst
        (field "isContentRead" bool)


contentDateDecoder : Decoder GotContentDate
contentDateDecoder =
    D.string


refDecoder : Decoder Ref
refDecoder =
    map3 Ref
        (field "text" string)
        (field "beautifiedContentText" string)
        (field "id" string)


bioResponseDecoder : Decoder BioResponse
bioResponseDecoder =
    map2 BioResponse
        (field "groups" (D.list bioGroupDecoder))
        (field "items" (D.list bioItemDecoder))


bioGroupDecoder : Decoder GotBioGroup
bioGroupDecoder =
    map5 GotBioGroup
        (field "bioGroupID" int)
        (field "title" string)
        (field "displayIndex" int)
        (field "info" (maybe string))
        (field "bioItemOrder" (D.list int))


bioItemDecoder : Decoder GotBioItem
bioItemDecoder =
    map6 GotBioItem
        (field "bioItemID" int)
        (field "name" string)
        (field "groups" (D.list int))
        (field "groupNames" (D.list string))
        (field "colorHex" (maybe string))
        (field "info" (maybe string))


eksiKonserveResponseDecoder : Decoder EksiKonserveResponse
eksiKonserveResponseDecoder =
    map EksiKonserveResponse
        (field "topics" (D.list eksiKonserveTopicDecoder))


eksiKonserveTopicDecoder : Decoder EksiKonserveTopic
eksiKonserveTopicDecoder =
    map3 EksiKonserveTopic
        (field "name" string)
        (field "url" string)
        (field "count" int)
