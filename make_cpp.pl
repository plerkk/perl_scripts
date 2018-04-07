#!/usr/bin/perl 
use warnings;
use v5.26;

my $class_name;
my @funcs;
my @funcsGlobal;
my $in_class;
chomp(my $header=<STDIN>);
open HEADER,"<$header";
$_=$header;
s/.hpp/.cpp/;
open CPP,'>',$_;
while(<HEADER>){
    chomp;
    if(!$in_class){
        if(/\);\s?\z/){
            push(@funcsGlobal,$_);
        }
    }
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
s/class //;
s/\s:?.*//;
$class_name=$_;
print CPP "#include \"$header\"\n";
foreach(@funcs){
    s/ {2,}//;
    if(/$class_name/){
        $_=$class_name."\:\:".$_;
    }else{
        s/ / $class_name\:\:/;
    }
    s/;\s?/\{\n\n\}/;
    say CPP "$_";
}
foreach(@funcsGlobal){
    s/\s//;
    s/;\s?/\{\n\n\}/;
    say CPP "$_";
}
close CPP;
