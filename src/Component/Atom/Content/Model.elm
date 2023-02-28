module Content.Model exposing (Content, ContentDate, Ref)

import Date exposing (Date)
import Tag.Model exposing (Tag)


type alias Content =
    { title : Maybe String, date : ContentDate, contentId : ContentID, text : String, beautifiedText : String, tags : List Tag, refs : Maybe (List Ref), okForBlogMode : Bool, isContentRead : Bool, furtherReadingRefs: List Ref }


type alias Ref =
    { text : String, beautifiedText : String, id : String }


type alias ContentID =
    Int


type alias ContentDate =
    Date
