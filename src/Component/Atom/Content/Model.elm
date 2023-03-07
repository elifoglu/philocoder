module Content.Model exposing (Content, ContentDate, Ref, AllRefData, RefConnection, GraphData)

import App.GraphModel exposing (GraphModel)
import Date exposing (Date)
import Tag.Model exposing (Tag)


type alias Content =
    { title : Maybe String, date : ContentDate, contentId : ContentID, text : String, beautifiedText : String, tags : List Tag, refs : List Ref, okForBlogMode : Bool, isContentRead : Bool, furtherReadingRefs: List Ref, refData : AllRefData, graphDataIfGraphIsOn : Maybe GraphData }


type alias GraphData =
    { allRefData : AllRefData
    , graphModel : GraphModel
    , veryFirstMomentOfGraphHasPassed : Bool

    -- When graph animation starts, it is buggy somehow: Nodes are not shown in the center of the box, instead, they are shown at the top left of the box at the "very first moment" of initialization. So, we are setting "veryFirstMomentOfGraphHasPassed" as True just after the very first Tick msg of the graph, and we don't show the graph until that value becomes True
    }

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
