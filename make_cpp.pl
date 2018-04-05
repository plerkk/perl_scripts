#!/usr/bin/perl 
use warnings;
use v5.26;

my $class_name;
my @funcs;
my $in_class;
chomp(my $header=<STDIN>);
open HEADER,"<$header";
$_=$header;
s/.hpp/.cpp/;
open CPP,'>',$_;
while(<HEADER>){
    chomp;
    if(/class/){
         $class_name=$_;
         $in_class=1;
    }
    if(/\};\s?\z/){
        $in_class=0;
    }
    if($in_class){
        if(/\);\s?\z/){
            push(@funcs,$_);
        }
    }
}
close HEADER;
$_=$class_name;
s/class//;
s/\{\z//;
$class_name=$_;
print CPP "#include \"$header\"\n";
foreach(@funcs){
    s/ {2,}//;
    s/ / $class_name\:\:/;
    s/;/\{\n\n\}/;
    say CPP "$_";
}
close CPP;
