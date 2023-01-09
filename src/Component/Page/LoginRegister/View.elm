module LoginRegister.View exposing (viewLoginOrRegisterDiv)

import App.Msg exposing (LoginRegisterPageInputType(..), Msg(..))
import Html exposing (Html, br, button, div, input, text)
import Html.Attributes exposing (class, placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Markdown


viewLoginOrRegisterDiv : String -> String -> String -> Html Msg
viewLoginOrRegisterDiv username password errorMessage =
    div [] <|
        [ Markdown.toHtml [ class "markdownDiv contentFont" ] """
bir içerik birden fazla etiket ile etiketlenebildiğinden, farklı etiketler altındaki içeriklere göz atan okuyucuların aynı içeriklere tekrar tekrar denk gelebileceğini ve bunun da deneyimi kötüleştirebileceğini düşünerek siteye bir "içerik tüketme modu" ekledim. bu özelliğin özellikle sitedeki içeriğin tümünü tüketmek istediğini söyleyen, ama sitede kaybolduğunu da söyleyen kişiler için faydalı olacağını düşünüyorum.


aşağıdan basitçe kaydolur ve ana sayfada, **arama kutusunun hemen sağında** belirecek olan kutucuğu işaretlerseniz bu mod aktif hale gelecek, ve -az önce işaretlemeye çalıştığınız gibi- bir içeriği "okundu" olarak işaretlediğinizde de, bu mod aktifken o içerik bir daha karşınıza çıkmayacak. bu şekilde tüm içerikleri tüketip siteyi tertemiz hale getirebilirsiniz. tüm içerikleri tekrar görmek istediğinizde ana sayfadan modu yine inaktif hale getirebilir ya da hesaptan çıkış yapabilirsiniz. inaktif hale getirdiğinizde önceki işaretlemeleriniz silinmez; tekrar aktif hale getirip kaldığınız yerden devam edebilirsiniz."""
        , br [] []
        , viewInput "text" "kullanıcı adı" username (LoginRegisterPageInputChanged Username)
        , br [] []
        , viewInput "text" "şifre" password (LoginRegisterPageInputChanged Pass)
        , br [] []
        , button [ onClick (TryRegister username password), style "width" "54px" ] [ text "kayıt" ]
        , button [ onClick (TryLogin username password), style "width" "54px" ] [ text "giriş" ]
        , br [] []
        , if not (String.isEmpty errorMessage) then
            Markdown.toHtml [ class "markdownDiv contentFont" ] errorMessage

          else
            text ""
        ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg, style "width" "100px" ] []