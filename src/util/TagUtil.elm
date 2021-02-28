module TagUtil exposing (..)

import Content exposing (Content)
import List exposing (member)
import Model exposing (Model)
import Msg exposing (Tag)
import SortUtil exposing (sortContentsByStrategy)


contentCountOfTag : Model -> Tag -> String
contentCountOfTag model tag =
    (tag
        |> getContentsOfTag model.allContents
    )
        |> List.length
        |> String.fromInt


getContentsOfTag : List Content -> Tag -> List Content
getContentsOfTag allContents tag =
    allContents
        |> List.filter (\content -> member tag content.tags)
        |> sortContentsByStrategy tag.contentSortStrategy


nameOfTag : Maybe Tag -> String
nameOfTag maybeTag =
    Maybe.withDefault "" (Maybe.map (\tag -> tag.name) maybeTag)
