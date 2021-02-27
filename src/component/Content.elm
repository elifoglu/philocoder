module Content exposing (..)

import Date exposing (Date, format)
import Msg exposing (Tag)


type alias PublishOrderInDay =
    Int


type ContentDate
    = Date Date PublishOrderInDay
    | NoDate


type ContentText
    = Text String
    | NotRequestedYet


type alias Content =
    { title : String, date : ContentDate, contentId : Int, text : ContentText, tags : List Tag }


getDateAsText : Content -> String
getDateAsText content =
    case content.date of
        Date date _ ->
            format "dd.MM.yy" date

        NoDate ->
            ""
