module Content.Model exposing (Content, ContentDate(..), ContentText(..))

import Date exposing (Date)
import Tag.Model exposing (Tag)


type alias Content =
    { title : Maybe String, date : ContentDate, contentId : ContentID, text : ContentText, tags : List Tag, refs : Maybe (List ContentID) }


type alias ContentID =
    Int


type ContentDate
    = DateExists Date PublishOrderInDay
    | DateNotExists PublishOrderInDay


type alias PublishOrderInDay =
    Int


type ContentText
    = Text String
    | NotRequestedYet
