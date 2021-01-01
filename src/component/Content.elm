module Content exposing (..)

import Date exposing (Date, format)


type alias PublishOrderInDay =
    Int


type ContentDate
    = Date Date PublishOrderInDay
    | NoDate


type alias Content =
    { title : String, date : ContentDate, text : String, tabs : List String }


getDateAsText : Content -> String
getDateAsText content =
    case content.date of
        Date date _ ->
            format "dd.MM.yy" date

        NoDate ->
            ""
