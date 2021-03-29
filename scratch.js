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
