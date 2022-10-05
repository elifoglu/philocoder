module BioItem.Model exposing (..)

import DataResponse exposing (BioItemID)


type alias BioItem =
    { bioItemID : BioItemID
    , name : String
    , groups : List Int
    , colorHex : Maybe String
    , info : Maybe String
    }
