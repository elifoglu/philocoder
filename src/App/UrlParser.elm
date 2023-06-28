module App.UrlParser exposing (pageBy)

import App.Model exposing (CreateContentPageModel, CreateTagPageModel, Initializable(..), LocalStorage, MaySendRequest(..), NonInitializedYetTagPageModel, Page(..), ReadingMode(..), UpdateContentPageData, UpdateContentPageModel(..), UpdateTagPageModel)
import Url
import Url.Parser exposing ((</>), (<?>), Parser, int, map, oneOf, parse, s, string, top)
import Url.Parser.Query as Query


routeParser : ReadingMode -> Parser (Page -> a) a
routeParser readingMode =
    oneOf
        [ map (HomePage Nothing Nothing readingMode Nothing) top
        , map nonInitializedTagPageMapper (s "tags" </> string <?> Query.int "page" <?> Query.string "mode")
        , map nonInitializedBioPageMapper (s "me")
        , map nonInitializedContentPageMapper (s "contents" </> int <?> Query.string "graph")
        , map nonInitializedBulkContentsPageMapper (s "many" </> string)
        , map (CreateContentPage (NoRequestSentYet (CreateContentPageModel Nothing "" "" "" "" "" False "" ""))) (s "create" </> s "content")
        , map nonInitializedUpdateContentPageMapper (s "update" </> s "content" </> int)
        , map (CreateTagPage (NoRequestSentYet (CreateTagPageModel "" "" "DateDESC" True True "" ""))) (s "create" </> s "tag")
        , map nonInitializedUpdateTagPageMapper (s "update" </> s "tag" </> string)
        , map rPageMapper (s "r")
        , map eksiKonservePageMapper (s "eksiposta")
        , map grafPageMapper (s "g")
        ]


nonInitializedTagPageMapper : String -> Maybe Int -> Maybe String -> Page
nonInitializedTagPageMapper tagId maybePage maybeReadingMode =
    TagPage (NonInitialized (NonInitializedYetTagPageModel tagId maybePage (getReadingMode maybeReadingMode)))


getReadingMode : Maybe String -> ReadingMode
getReadingMode maybeString =
    case maybeString of
        Just "blog" ->
            BlogContents

        _ ->
            AllContents


nonInitializedContentPageMapper : Int -> Maybe String -> Page
nonInitializedContentPageMapper contentId maybeGraphIsOn =
    ContentPage
        (NonInitialized
            ( contentId
            , case maybeGraphIsOn of
                Just "true" ->
                    True

                _ ->
                    False
            )
        )


nonInitializedUpdateContentPageMapper : Int -> Page
nonInitializedUpdateContentPageMapper contentId =
    UpdateContentPage (NotInitializedYet contentId)


nonInitializedUpdateTagPageMapper : String -> Page
nonInitializedUpdateTagPageMapper tagId =
    UpdateTagPage (NoRequestSentYet ( UpdateTagPageModel "" "", tagId ))


nonInitializedBulkContentsPageMapper : String -> Page
nonInitializedBulkContentsPageMapper contentIds =
    BulkContentsPage (NonInitialized contentIds)


nonInitializedBioPageMapper : Page
nonInitializedBioPageMapper =
    BioPage Nothing


rPageMapper : Page
rPageMapper =
    ContentPage (NonInitialized ( 5, False ))


eksiKonservePageMapper : Page
eksiKonservePageMapper =
    EksiKonservePage (NonInitialized ())


grafPageMapper : Page
grafPageMapper =
    GrafPage Nothing


pageBy : Url.Url -> ReadingMode -> Page
pageBy url readingMode =
    Maybe.withDefault NotFoundPage <| parse (routeParser readingMode) url
