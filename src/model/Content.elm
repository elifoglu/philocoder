module Content exposing (..)

import Date exposing (Date)
import Msg exposing (Tag)


type alias Content =
    { title : String, date : ContentDate, contentId : Int, text : ContentText, tags : List Tag }


type ContentDate
    = DateExists Date PublishOrderInDay
    | DateNotExists PublishOrderInDay


type alias PublishOrderInDay =
    Int


type ContentText
    = Text String
    | NotRequestedYet
