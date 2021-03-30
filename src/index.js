import './style.css';
import { Elm } from './Main.elm';

let elm = Elm.Main.init({
  node: document.getElementById('root')
});

elm.ports.title.subscribe( title => {
  document.title = title;
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
