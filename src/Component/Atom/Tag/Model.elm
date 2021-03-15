module Tag.Model exposing (ContentRenderType(..), Tag)


type alias Tag =
    { tagId : String
    , name : String
    , contentSortStrategy : String
    , showAsTag : Bool
    , contentRenderType : ContentRenderType
    , showContentCount : Bool
    }


type ContentRenderType
    = Normal
    | Minified
