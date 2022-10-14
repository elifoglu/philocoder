module App.UrlParser exposing (pageBy)

import App.Model exposing (CreateContentPageModel, CreateTagPageModel, Initializable(..), MaySendRequest(..), NoVal(..), NonInitializedYetTagPageModel, Page(..), ReadingMode(..), UpdateContentPageModel, UpdateTagPageModel)
import Url
import Url.Parser exposing ((</>), (<?>), Parser, int, map, oneOf, parse, s, string, top)
import Url.Parser.Query as Query


routeParser : Parser (Page -> a) a
routeParser =
    oneOf
        [ map (HomePage [] [] BlogContents Nothing) top
        , map nonInitializedTagPageMapper (s "tags" </> string <?> Query.int "page" <?> Query.string "mode")
        , map nonInitializedBioPageMapper (s "me")
        , map nonInitializedContentPageMapper (s "contents" </> int)
        , map (CreateContentPage (NoRequestSentYet ( CreateContentPageModel "" "" "" "" "" False "" "", Nothing ))) (s "create" </> s "content")
        , map nonInitializedUpdateContentPageMapper (s "update" </> s "content" </> int)
        , map (CreateTagPage (NoRequestSentYet (CreateTagPageModel "" "" "DateDESC" True "normal" True "" ""))) (s "create" </> s "tag")
        , map nonInitializedUpdateTagPageMapper (s "update" </> s "tag" </> string)
        ]


nonInitializedTagPageMapper : String -> Maybe Int -> Maybe String -> Page
nonInitializedTagPageMapper tagId maybePage maybeReadingMode =
    TagPage (NonInitialized (NonInitializedYetTagPageModel tagId maybePage (getReadingMode maybeReadingMode) Nothing Nothing))


getReadingMode : Maybe String -> ReadingMode
getReadingMode maybeString =
    case maybeString of
        Just "blog" ->
            BlogContents

        _ ->
            AllContents


nonInitializedContentPageMapper : Int -> Page
nonInitializedContentPageMapper contentId =
    ContentPage (NonInitialized ( contentId, Nothing ))


nonInitializedUpdateContentPageMapper : Int -> Page
nonInitializedUpdateContentPageMapper contentId =
    UpdateContentPage (NoRequestSentYet ( UpdateContentPageModel "" "" "" "" False "", Nothing, contentId ))


nonInitializedUpdateTagPageMapper : String -> Page
nonInitializedUpdateTagPageMapper tagId =
    UpdateTagPage (NoRequestSentYet ( UpdateTagPageModel "" "", tagId ))


nonInitializedBioPageMapper : Page
nonInitializedBioPageMapper =
    BioPage Nothing


pageBy : Url.Url -> Page
pageBy url =
    Maybe.withDefault NotFoundPage <| parse routeParser url
