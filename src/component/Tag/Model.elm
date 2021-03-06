module Tag.Model exposing (ContentRenderType(..), Tag)


type alias Tag =
    { tagId : String, name : String, contentSortStrategy : String, showAsTag : Bool, contentRenderType : ContentRenderType }


type ContentRenderType
    = Normal
    | Minified
