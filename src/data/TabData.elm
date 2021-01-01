module TabData exposing (..)

import Content exposing (Content)
import List exposing (member)
import TabInfo exposing (..)
import ContentData exposing (..)

allTabs : List Tab
allTabs =
  List.map setContents
  [ ("tümü", True)
  , ("üstinsan", False)
  , ("perspektif", False)
  , ("özgün", False)
  , ("günlük", False)
  , ("kod", False)
  , ("beni_oku.txt", False)
  ]

setContents : (String, Bool) -> Tab
setContents (name, active) =
  { name = name, contents = List.filter (contentBelongsToTab name) allContents , active = active }

contentBelongsToTab: String -> Content -> Bool
contentBelongsToTab tabName content =
  member tabName content.tabs

  --todo 2 - tab için sort strategy oluştur. order by date asc/desc olsun. tarihleri güncelle.
  --todo 3 - yazılarında bold, italik kısımlar varsa onları halletmen gerek bir şekilde (beni_oku.txt'de var mesela)
  --todo 4 - fonksiyonel programlama 101 stili yamuk yumuk oluyor, html gömebilmen gerek.
  --todo 5 - eksik olan tek yazı fonk. programlama şimdilik
  --todo 6 - bir view counter ekle siteye. arada bi file'a yazsın falan.