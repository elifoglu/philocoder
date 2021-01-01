module Sort exposing (SortStrategy(..), sortContentsByStrategy)

import Content exposing (Content, ContentDate(..))
import Date


type SortStrategy
    = DateASC
    | DateDESC


sortContentsByStrategy : SortStrategy -> List Content -> List Content
sortContentsByStrategy strategy list =
    case strategy of
        DateASC ->
            sortContentsByDateASC list

        DateDESC ->
            List.reverse (sortContentsByDateASC list)


sortContentsByDateASC : List Content -> List Content
sortContentsByDateASC contents =
    List.sortWith compareContentsByDate contents


compareContentsByDate : Content -> Content -> Order
compareContentsByDate content1 content2 =
    case ( content1.date, content2.date ) of
        ( Date date1 publishOrder1, Date date2 publishOrder2 ) ->
            case Date.compare date1 date2 of
                EQ ->
                    Basics.compare publishOrder1 publishOrder2

                other ->
                    other

        _ ->
            --we don't expect this case
            EQ
