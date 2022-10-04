module BioGroup.Model exposing (..)

import DataResponse exposing (BioGroupID)


type alias BioGroup =
    { bioGroupID : BioGroupID
    , title : String
    , displayIndex : Int
    , info : Maybe String
    , bioItemOrder : List Int
    , isActive : Bool
    , displayInfo : Bool
    }
