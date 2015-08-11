use SGMLS;

$\ = "\n";

$parse = new SGMLS(STDIN);

while ($event = $parse->next_event) {
    print "Event type: " . $event->type;
    print "Data: " . $event->data;
    print "File: " . $event->file || "[unavailable]";
    print "Line: " . $event->line || "[unavailable]";
    print "";
}
