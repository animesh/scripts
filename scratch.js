//https://github.blog/2022-02-14-include-diagrams-markdown-files-mermaid/
```mermaid
  graph TD;
      A-->B;
      A-->C;
      B-->D;
      C-->D;
```
//https://betterprogramming.pub/accessing-an-objects-keys-values-and-entries-in-javascript-e7bb5d33d11c
var user = {
    name : "John",
    age  : 25
}
let entries = Object.entries(user);
entries.map( ([prop, val]) => console.log(prop, val));
Alternatively, we can also use forEach.
entries.forEach( ([prop, val]) => console.log(prop, val));
Using for…of with Object.entries:
for(const [prop, val] of entries) {
    console.log(prop, val);
}
//https://betterprogramming.pub/higher-order-functions-in-javascript-4c9b40119ba6
hand = [1,2]
for (let i = 0; i < hand.length; i++) {
    console.log(hand[i]);
}
hand.forEach((die) => console.log(die));
const rollDice = () => {
    return new Array(5).fill(null).map(() => Math.ceil(Math.random() * 6));
};
const nextHand = () => {
    return hand.filter((_, idx) => retain[idx]);
};
const getChoiceScore = () => {
    return hand.reduce((score, die) => score + die);
};
const getYachtScore = () => {
    return hand.every((die) => die === hand[0]) ? 50 : 0;
};

//iwr https://deno.land/x/install/install.ps1 -useb | iex 
//deno scratch.js
function fact(x) {
   if(x==0) {
      return 1;
   }
   return x * fact(x-1);
}
console.log(fact(4))
function dbl (x){return x*2;}
y=dbl(5)
z=dbl(y)
console.log(fact(z+y))
var name="test+it+out"
var url = "https://translate.google.com/translate?sl=auto&tl=en&u=" + encodeURIComponent("https://www.google.no/search?q=") + name + "&callback=?";$.get(url, function(response) {  console.log(response);});

//https://github.com/microsoft/Web-Dev-For-Beginners/blob/main/3-terrarium/3-intro-to-DOM-and-closures/README.md
function displayCandy(){
	let candy = ['jellybeans'];
	function addCandy(candyType) {
		candy.push(candyType)
	}
	addCandy('gumdrops');
}
displayCandy();
console.log(candy)
