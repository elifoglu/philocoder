module App.UrlParser exposing (pageBy)

import App.Model exposing (Page(..))
import Url
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, string, top)


routeParser : Parser (Page -> a) a
routeParser =
    oneOf
        [ map NonInitializedHomePage top
        , map NonInitializedTagPage (s "tags" </> string)
        , map NonInitializedContentPage (s "contents" </> int)
        ]


pageBy : Url.Url -> Page
pageBy url =
    case parse routeParser url of
        Just page ->
            page

        Nothing ->
            NotFoundPage
