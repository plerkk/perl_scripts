#!/usr/bin/perl
use warnings;
use v5.26;

my @files;
foreach(@ARGV){
    push(@files,$_);
}

my $cmake;
if(! open $cmake,'>',"CMakeLists.txt"){
    die "Can't write 'CMakeLists.txt': $!";
}
my %cmk_data=(
    'project' => 'project(cmake_generated)',
    'min_V' => 'cmake_minimum_required(VERSION 3.10)',
    'set_inc' =>'set(INCROOT ${CMAKE_CURRENT_SOURCE_DIR}/)',
    'set_src' =>'set(SRCROOT ${CMAKE_CURRENT_SOURCE_DIR}/)',
    'set_rt_out' =>'set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})',
    'set_out' => 'set(OUT_NAME main)',
    'set_flags' => 'set(CMAKE_CXX_FLAGS"${CMAKE_CXX_FLAGS} -Wall -g")',
    'set_libs' =>'set(LIBS -lX11 -lXrandr -lpthread -lXi -lsfml-graphics -lsfml-window -lsfml-system -lsfml-audio)',
    'set_files_h' =>"set(FILES_HEADER\n)",
    'set_files_src' =>"set(FILES_SRC\n)",
    'add_ex' => 'add_executable(${OUT_NAME} ${FILES_HEADER} ${FILES_SRC})',
    'link_libs' => 'target_link_libraries(${OUT_NAME} ${LIBS})'
);
my @key=qw (project
        min_V 
        set_inc 
        set_src 
        set_rt_out 
        set_out 
        set_flags 
        set_libs 
        set_files_h
        set_files_src
        add_ex
        link_libs
);
my $h_rot="\$\{INCROOT\}\/";
my $c_rot="\$\{SRCROOT\}\/";
foreach my $file(@files){
    if($file=~/\.h(pp)?\Z/){
        if($cmk_data{set_files_h} =~s/(set\(FILES_HEADER)/${^MATCH}\n\t$h_rot$file/p){
            say "this put $file in H";
        }
    }
    if($file=~/\.c(pp)?\Z/){
        if($cmk_data{set_files_src}=~s/(set\(FILES_SRC)/${^MATCH}\n\t$c_rot$file/p){
            say "this put $file in C";
        }
    }
}

foreach my $kis(@key){
    printf $cmake ("%s\n",$cmk_data{$kis});
}
