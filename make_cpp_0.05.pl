#!/usr/bin/perl 
use warnings;
use v5.26;

my $class_name;
my @funcs;
my @funcsGlobal;
my $in_class;
my @headers;
foreach(@ARGV){
    push(@headers,$_);
}
open HEADER,"<$headers[0]";
$_=$headers[0];
s/.h(pp)?/.cpp/;
open CPP,'>',$_;
while(<HEADER>){
    chomp;
    if(!$in_class){
        if(/\);\s?\z/){
            push(@funcsGlobal,$_);
        }
    }
    if(/class/){
        if(/friend/){say "$_ is a friend";}
        if(/[^\{]/){say "$_ is not initialized";}
        if(/\{/){
            say "$_ is the names class";
            $class_name=$_;
            $in_class=1;
            }
    }
    if(/\};\s?\z/){
        $in_class=0;
    }
    if($in_class){
        if(/\)(const)?;\s?\z/){
            push(@funcs,$_);
        }
    }
}
close HEADER;
$_=$class_name;
say"$_";
s/class //;
say"$_";
s/\s:?.*//;
say"$_";
$class_name=$_;
print CPP "#include \"$headers[0]\"\n";
foreach(@funcs){
    s/virtual//;
    s/ {2,}|\t//;
    if(/$class_name/){
        $_=$class_name."\:\:".$_;
    }else{
        if(/(\w+\s[0-9a-zA-Z:&]*\s)(\w+\()/p){
            $_="$1$class_name\:\:$2${^POSTMATCH}";
        }else{
        s/ / $class_name\:\:/;
        }
    }
    s/;\s?/\{\n    \n\}/;
    say CPP "$_";
}
foreach(@funcsGlobal){
    s/\A\s//;
    s/;\s?/\{\n\t\n\}/;
    say CPP "$_";
}
close CPP;
