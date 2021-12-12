module Content.Model exposing (Content, ContentDate, Ref)

import Date exposing (Date)
import Tag.Model exposing (Tag)


type alias Content =
    { title : Maybe String, date : ContentDate, contentId : ContentID, text : String, tags : List Tag, refs : Maybe (List Ref), okForBlogMode : Bool }


type alias Ref =
    { text : String, id : String }


type alias ContentID =
    Int


type alias ContentDate =
    Date
