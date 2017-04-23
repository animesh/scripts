#!/usr/bin/env perl
 
if ($#ARGV < 0) {
  print "usage: assemble.pl readsFile [-vertexSize v] [-exeDir e]\n";
  exit(0);
}
$vertexSize = 20;
$machtype = $ENV{"MACHTYPE"};
$srcDir = $ENV{"MCSRC"};
$exeDir = "$srcDir/assembly/$machtype";
$readsFile = shift @ARGV;
$curdir = "";
if (! -e $readsFile ){
  print "$readsFile does not exist\n";
  exit(1);
}
while ($#ARGV >= 0) {
  $option = shift @ARGV;
  if ($option eq "-vertexSize") {
    $vertexSize = shift @ARGV;
  }
  if ($option eq "-dir") {
    $curdir = shift @ARGV;
  }
}

if ($curdir != "") {
  chdir($curdir);
}

# create all the commands at the top of the script so 
# I don't have to look all over the place to find them


$buildVertexCmd = 
  "$exeDir/countSpectrum $readsFile $readsFile.v -tupleSize $vertexSize -printPos";
$sortVertexCmd =
  "$exeDir/sortVertexList $readsFile.v $readsFile $vertexSize $readsFile.sv";
$buildGraphCmd = 
  "$exeDir/debruijn $readsFile $readsFile.sv $readsFile.dot -vertexSize $vertexSize";
$edgesToOverlapListCmd =
  "$exeDir/edgesToOverlapList $readsFile.edge $vertexSize $readsFile.ovp";
$printReadIntervalsCmd =
  "$exeDir/printReadIntervals $readsFile.ovp $readsFile.edge $readsFile $vertexSize $readsFile.intv $readsFile.path";
$printContigsCmd = "$exeDir/printContigs $readsFile";

$removeFilesCmd = "$srcDir/assembly/CleanUpIntermediates.pl $readsFile";

print "$buildVertexCmd\n";
$res = system($buildVertexCmd);
if ($res != 0) {
  print "building vertices failed: $res\n";
  exit(1);
}
print "sorting vertices\n";
$res = system($sortVertexCmd);
if ($res != 0) {
  print "sorting vertices failed: $res\n";
  print "$sortVertexCmd\n";
  exit(1);
}
print "building graph\n";
$res = system($buildGraphCmd);
if ($res != 0) {
  print "building the graph failed: $res\n";
  print "$buildGraphCmd\n";
  exit(1);
}

print "mapping read intervals\n";
$res = system($edgesToOverlapListCmd);
if ($res != 0) {
  print "creating the overlap list failed: $res\n";
  exit(1);
}
$res = system($printReadIntervalsCmd);
if ($res != 0) {
  print "printing the read intervals failed: $res\n";
  exit(1);
}

$res = system($printContigsCmd);
if ($res != 0) {
  print "printing contigs failed: $res\n";
  exit(1);
}

$res = system($removeFilesCmd);
if ($res != 0) {
		print "removing extra files failed\n";
		exit(1);
}

