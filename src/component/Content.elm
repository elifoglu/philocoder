module Content exposing (..)


type ContentDate
    = Date String
    | DateWithDailyOrder String Int
    | NoDate


type alias Content =
    { title : String, date : ContentDate, text : String, tabs : List String }


getDateAsText : Content -> String
getDateAsText content =
    case content.date of
        Date string ->
            string

        DateWithDailyOrder string _ ->
            string

        NoDate ->
            ""
