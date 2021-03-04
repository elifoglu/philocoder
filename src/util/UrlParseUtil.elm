module UrlParseUtil exposing (parseOrHome)

import Model exposing (Page(..))
import Url
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, string, top)


routeParser : Parser (Page -> a) a
routeParser =
    oneOf
        [ map HomePage top
        , map TagPage (s "tags" </> string)
        , map ContentPage (s "contents" </> int)
        ]


parseOrHome : Url.Url -> Page
parseOrHome url =
    case parse routeParser url of
        Just route ->
            route

        Nothing ->
            NotFoundPage
