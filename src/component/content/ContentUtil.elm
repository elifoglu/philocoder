module ContentUtil exposing (contentById)

import ContentModel exposing (Content)


contentById : List Content -> Int -> Maybe Content
contentById contents id =
    contents
        |> List.filter (\a -> a.contentId == id)
        |> List.head
