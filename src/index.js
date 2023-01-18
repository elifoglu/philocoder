import './style.css';
//import './style_dark.css'; -- add this line to enable dark mode
import {Elm} from './Main.elm';

var readingMode = localStorage.getItem('philocoder-reading-mode');

var consumeModeIsOn = localStorage.getItem('philocoder-consume-mode-is-on');

var contentReadClickedAtLeastOnce = localStorage.getItem('philocoder-content-read-clicked');

var readMeIconClickedAtLeastOnce = localStorage.getItem('philocoder-readme-icon-clicked');

var credentials = localStorage.getItem('philocoder-credentials');

let obj = {
    readingMode: readingMode, consumeModeIsOn: consumeModeIsOn,
    contentReadClickedAtLeastOnce: contentReadClickedAtLeastOnce,
    readMeIconClickedAtLeastOnce: readMeIconClickedAtLeastOnce, credentials: credentials
};

let elm = Elm.Main.init({
    node: document.getElementById('root'),
    flags: obj
});

elm.ports.title.subscribe(title => {
    document.title = title;
});

elm.ports.storeReadingMode.subscribe(readingModeValue => {
    localStorage.setItem('philocoder-reading-mode', readingModeValue);
});

elm.ports.storeConsumeMode.subscribe(consumeModeIsOnValue => {
    localStorage.setItem('philocoder-consume-mode-is-on', consumeModeIsOnValue);
});

elm.ports.storeContentReadClickedForTheFirstTime.subscribe(contentReadClickedValue => {
    localStorage.setItem('philocoder-content-read-clicked', contentReadClickedValue);
});

elm.ports.storeReadMeIconClickedForTheFirstTime.subscribe(readMeIconClickedValue => {
    localStorage.setItem('philocoder-readme-icon-clicked', readMeIconClickedValue);
});

elm.ports.storeCredentials.subscribe(credentialsValue => {
    localStorage.setItem('philocoder-credentials', credentialsValue);
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
