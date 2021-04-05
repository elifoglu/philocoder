module App.UrlParser exposing (pageBy)

import App.Model exposing (CreateContentPageModel, Initializable(..), NoVal(..), Page(..), UpdateContentPageModel)
import Url
import Url.Parser exposing ((</>), (<?>), Parser, int, map, oneOf, parse, s, string, top)
import Url.Parser.Query as Query


routeParser : Parser (Page -> a) a
routeParser =
    oneOf
        [ map (HomePage (NonInitialized NoVal)) top
        , map nonInitializedTagPageMapper (s "tags" </> string <?> Query.int "page")
        , map nonInitializedContentPageMapper (s "contents" </> int)
        , map (CreateContentPage (CreateContentPageModel "" "" "" "" "" "" "" "") Nothing) (s "create")
        , map (UpdateContentPage (UpdateContentPageModel "" "" "" "" "" "" "") Nothing) (s "update" </> s "content" </> int)
        ]


nonInitializedTagPageMapper : String -> Maybe Int -> Page
nonInitializedTagPageMapper tagId maybePage =
    TagPage (NonInitialized ( tagId, maybePage ))


nonInitializedContentPageMapper : Int -> Page
nonInitializedContentPageMapper contentId =
    ContentPage (NonInitialized contentId)


pageBy : Url.Url -> Page
pageBy url =
    Maybe.withDefault NotFoundPage <| parse routeParser url
