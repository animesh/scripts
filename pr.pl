print "Content-Type: text/html\n\n<pre>\n";

$damp = 0.85;
$a = 0;
$b = 0;
$i = 40; # loop 10 times

# forward links
# a -> b - 1 outgoing link
# b -> a - 1 outgoing link

# i.e. "backward" links (what's pointing to me?)
# a <= b
# b <= a

print "I've rounded to 5 decimal places to make the output easier to read\n\n";

while ($i--) {
    printf("a: %.5f b: %.5f\n", $a, $b);
    $a = (1 - $damp) + $damp * ($b);
    $b = (1 - $damp) + $damp * ($a);
}
printf("Average pagerank = %.4f\n", ($a + $b) / 2);
print("</pre><a href=http://www.iprcom.com/papers/pagerank/#ex0>Back</a>");

#!/usr/bin/perl

print "Content-Type: text/html\n\n<pre>\n";

$damp = 0.85;
$a = 0;
$b = 0;
$c = 0;
$d = 0;
$i = 40; # loop 40 times

# forward links
# a -> b, c    - 2 outgoing links
# b -> c    - 1 outgoing link
# c -> a    - 1 outgoing link
# d -> a    - 1 outgoing link

# i.e. "backward" links (what's pointing to me?)
# a <= c
# b <= a
# c <= a, b, d
# d - nothing
while ($i--) {
    printf(
        "a: %.5f b: %.5f c: %.5f d: %.5f\n",
        $a, $b, $c, $d
    );
    $a = 1 - $damp + $damp * $c;
    $b = 1 - $damp + $damp * ($a/2);
    $c = 1 - $damp + $damp * ($a/2 + $b + $d);
    $d = 1 - $damp;
}
printf("Average pagerank = %.4f\n", ($a + $b + $c + $d) / 4);
print("</pre><a href=http://www.iprcom.com/papers/pagerank/#ex1>Back to example 1</a>");


 PageRank Explained Example 7

#!/usr/bin/perl

print "Content-Type: text/html\n\n<pre>\n";

$damp = 0.85;
$a = $b = $c = $d = $e = $f = $g = $h = 0;
$iterate = 40; # loop 40 times

# Extensive Interlinking - "Fully Meshed"
# forward links
# a -> b,c,d    - 3 outgoing links    - home
# b -> c,d,a    - 3 outgoing link    - about
# c -> d,a,b    - 3 outgoing link    - products
# d -> a,b,c    - 3 outgoing links    - more info

# i.e. "backward" links (what's pointing to me?)
# a <= b/3,c/3,d/3
# b <= c/3,d/3,a/3
# c <= d/3,a/3,b/3
# d <= a/3,b/3,c/3
while ($iterate--) {
    printf("a: %.5f b: %.5f c: %.5f d: %.5f\n", $a, $b, $c, $d);

    $a = 1 - $damp + $damp * ($b/3 + $c/3 + $d/3);
    $b = 1 - $damp + $damp * ($c/3 + $d/3 + $a/3);
    $c = 1 - $damp + $damp * ($d/3 + $a/3 + $b/3);
    $d = 1 - $damp + $damp * ($a/3 + $b/3 + $c/3);
}
printf("Average pagerank = %.4f\n", ($a + $b + $c + $d) / 4); # to 4 decimal places!
print("</pre><a href=http://www.iprcom.com/papers/pagerank/#ex7>Back to example 7</a>");
 


#!/usr/bin/perl

print "Content-Type: text/html\n\n<pre>\n";

$damp = 0.85;
$a = $b = $c = 0;
$iterate = 40; # loop 40 times

# Plain Heirarchical
# forward links
# a -> b           - 1 outgoing link      - home
# b -> c1...c1000  - 1000 outgoing links  - link list
# c1,c1000 -> a    - 1 outgoing link      - spam pages

# i.e. "backward" links (what's pointing to me?)
# a <= 1000 * c
# b <= a
# c <= b/1000
while ($iterate--) {
    printf("a: %.5f b: %.5f c: %.5f\n", $a, $b, $c);

    $a = 1 - $damp + $damp * (1000 * $c);
    $b = 1 - $damp + $damp * ($a);
    $c = 1 - $damp + $damp * ($b/1000);
}
printf("Average pagerank = %.4f\n", ($a + $b + $c*1000) / 1002);
print("</pre><a href=http://www.iprcom.com/papers/pagerank/#ex13>Back to example 13</a>");


