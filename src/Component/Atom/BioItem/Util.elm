module BioItem.Util exposing (getBioItemById, gotBioItemToBioItem)

import BioItem.Model exposing (BioItem)
import DataResponse exposing (BioItemID, GotBioGroup, GotBioItem, GotContent, GotContentDate, GotTag)


gotBioItemToBioItem : GotBioItem -> BioItem
gotBioItemToBioItem got =
    BioItem got.bioItemID got.name got.groups got.colorHex


getBioItemById : List BioItem -> BioItemID -> BioItem
getBioItemById bioItems bioItemID =
    bioItems
        |> List.filter (\bioItem -> bioItem.bioItemID == bioItemID)
        |> List.head
        |> Maybe.withDefault dummyBioItem


dummyBioItem : BioItem
dummyBioItem =
    BioItem 0 "" [] Nothing
