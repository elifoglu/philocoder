module Tag.Model exposing (Tag)


type alias Tag =
    { tagId : String, name : String, contentSortStrategy : String, showAsTag : Bool }
