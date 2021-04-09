module Tag.Model exposing (ContentRenderType(..), Tag)


type alias Tag =
    { tagId : String
    , name : String
    , showAsTag : Bool
    , contentRenderType : ContentRenderType
    , showContentCount : Bool
    , showInHeader : Bool
    , contentCount : Int
    , infoContentId : Maybe Int
    }


type ContentRenderType
    = Normal
    | Minified
