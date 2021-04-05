module App.UrlParser exposing (pageBy)

import App.Model exposing (CreateContentPageModel, Page(..), UpdateContentPageModel)
import Url
import Url.Parser exposing ((</>), (<?>), Parser, int, map, oneOf, parse, s, string, top)
import Url.Parser.Query as Query


routeParser : Parser (Page -> a) a
routeParser =
    oneOf
        [ map NonInitializedHomePage top
        , map NonInitializedTagPage (s "tags" </> string <?> Query.int "page")
        , map NonInitializedContentPage (s "contents" </> int)
        , map (CreateContentPage (CreateContentPageModel "" "" "" "" "" "" "" "") Nothing) (s "create")
        , map (UpdateContentPage (UpdateContentPageModel "" "" "" "" "" "" "") Nothing) (s "update" </> s "content" </> int)
        ]


pageBy : Url.Url -> Page
pageBy url =
    Maybe.withDefault NotFoundPage <| parse routeParser url
