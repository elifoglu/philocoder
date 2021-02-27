module Sort exposing (sortContentsByStrategy)

import Content exposing (Content, ContentDate(..))
import Date


sortContentsByStrategy : String -> List Content -> List Content
sortContentsByStrategy strategy list =
    case strategy of
        "DateDESC" ->
            List.reverse (sortContentsByDateASC list)

        _ ->
            sortContentsByDateASC list


sortContentsByDateASC : List Content -> List Content
sortContentsByDateASC contents =
    List.sortWith compareContentsByDate contents


compareContentsByDate : Content -> Content -> Order
compareContentsByDate content1 content2 =
    case ( content1.date, content2.date ) of
        ( DateExists date1 publishOrder1, DateExists date2 publishOrder2 ) ->
            case Date.compare date1 date2 of
                EQ ->
                    Basics.compare publishOrder1 publishOrder2

                other ->
                    other

        ( DateNotExists publishOrder1, DateNotExists publishOrder2 ) ->
            Basics.compare publishOrder1 publishOrder2

        _ ->
            --we don't expect this case
            EQ
