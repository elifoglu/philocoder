module Tag.Model exposing (Tag)


type alias Tag =
    { tagId : String
    , name : String
    , showInTagsOfContent : Bool
    , showContentCount : Bool
    , orderIndex : Maybe Int
    , contentCount : Int
    , infoContentId : Maybe Int
    }
