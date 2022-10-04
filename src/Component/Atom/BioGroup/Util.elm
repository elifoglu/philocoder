module BioGroup.Util exposing (changeActivenessIfIdMatches, gotBioGroupToBioGroup, changeDisplayInfoIfIdMatches)

import BioGroup.Model exposing (BioGroup)
import DataResponse exposing (BioGroupID, GotBioGroup, GotContent, GotContentDate, GotTag)


gotBioGroupToBioGroup : GotBioGroup -> BioGroup
gotBioGroupToBioGroup got =
    BioGroup got.bioGroupID got.title got.displayIndex (gotBioGroupInfoToBioGroupInfo got.info) got.bioItemOrder (getActivenessOnInit got.bioGroupID) True


gotBioGroupInfoToBioGroupInfo : Maybe String -> Maybe String
gotBioGroupInfoToBioGroupInfo gotBioGroupInfo =
    case gotBioGroupInfo of
        Just "null" ->
            Nothing

        _ ->
            gotBioGroupInfo


changeActivenessIfIdMatches : BioGroupID -> BioGroup -> BioGroup
changeActivenessIfIdMatches id bioGroup =
    if bioGroup.bioGroupID == id then
        { bioGroup | isActive = not bioGroup.isActive }

    else
        bioGroup


changeDisplayInfoIfIdMatches : BioGroupID -> BioGroup -> BioGroup
changeDisplayInfoIfIdMatches id bioGroup =
    if bioGroup.bioGroupID == id then
        { bioGroup | displayInfo = not bioGroup.displayInfo }

    else
        bioGroup

getActivenessOnInit : BioGroupID -> Bool
getActivenessOnInit bioGroupID =
    bioGroupID == 0
