module Tag.Model exposing (Tag)


type alias Tag =
    { tagId : String
    , name : String
    , showAsTag : Bool
    , showContentCount : Bool
    , orderIndex : Maybe Int
    , contentCount : Int
    , infoContentId : Maybe Int
    }
