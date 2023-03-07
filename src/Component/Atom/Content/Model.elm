module Content.Model exposing (Content, ContentDate, Ref, AllRefData, RefConnection)

import Date exposing (Date)
import Tag.Model exposing (Tag)


type alias Content =
    { title : Maybe String, date : ContentDate, contentId : ContentID, text : String, beautifiedText : String, tags : List Tag, refs : List Ref, okForBlogMode : Bool, isContentRead : Bool, furtherReadingRefs: List Ref, refData : AllRefData }


type alias Ref =
    { text : String, beautifiedText : String, id : String }


type alias AllRefData =
    { titlesToShow : List String
    , contentIds : List Int
    , connections : List RefConnection
    }


type alias RefConnection =
    { a : Int, b : Int }


type alias ContentID =
    Int


type alias ContentDate =
    Date
