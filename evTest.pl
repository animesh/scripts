#!/sw/arch/bin/perl

use SWISS::Entry;
use Data::Dumper;
use Carp;

# Read an entire record at a time
$/ = "\/\/\n";

$opt_warn=3;

my @kws = ('Transferase', 'Kinase');

while (<>){
  
  my $entry = SWISS::Entry->fromText($_);

  # get a valid evidence tag
  my $tag = $entry->EV->updateEvidence('P', 
				       'TestProgram1', 
				       '-', 
				       'RU000044');
  
  # For each of the keywords in question ...
  foreach my $kw (@kws) {

    # Check if the keyword is already there
    $matchedKWs = $entry->KWs->filter(SWISS::ListBase::attributeEquals('text',
									$kw));
    
    # Security check, there might be duplicates
    if ($matchedKWs->size > 1) {
      croak("More than one KW matches $kw in $_");
    }
    
    my $kwObject;
    if ($matchedKWs->size == 0) {
      
      # Create the keyword object
      $kwObject = new SWISS::KW;
      $kwObject->text($kw);
      $kwObject->addEvidenceTag($tag);
      $entry->KWs->add($kwObject);
    } else {
      # add the evidence tag 
      $kwObject = $matchedKWs->head();
      $kwObject->addEvidenceTag($tag);
    }
  }

  # Delete another evidence tag, just to see the method.
  map {$_->deleteEvidenceTag('EC2')} $entry->KWs->elements();

  # Output the entry
  print $entry->toText();

}
