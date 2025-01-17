use v6;

use Test;

plan 32;

# https://github.com/Raku/old-issue-tracker/issues/3918
#?rakudo.moar   skip 'VM.properties does not exist RT #124624'
#?rakudo.js   skip 'I have no information how it is supposed to work'
{
    #?rakudo skip 'unimpl $?VM'
    ok $?VM.properties,     "We have properties";
    ok $*VM.properties,     "We have properties";
}

# $?VM.name is the Virtual machine we were compiled in.
# https://github.com/Raku/old-issue-tracker/issues/3918
#?rakudo skip 'unimpl $?VM RT #124624'
{
    ok $?VM.name,           "We were compiled in '{$?VM.name}'";
    ok $?VM.auth,           "Authority is '{$?VM.auth}'";
    ok $?VM.version,        "Version is '{$?VM.version}'";
    #?rakudo todo 'no VM.signature yet'
    ok $?VM.signature,      "Signature is '{$?VM.signature}'";
    #?rakudo todo 'no VM.desc yet'
    ok $?VM.desc,           "Description is '{$?VM.desc}'";
    ok $?VM.config,         "We have config";
    ok $?VM.precomp-ext,    "Extension is '{$?VM.precomp-ext}'";
    ok $?VM.precomp-target, "Extension is '{$?VM.precomp-target}'";
    ok $?VM.prefix,         "Prefix is '{$?VM.prefix}'";

    ok $?VM.raku ~~ m/\w/, 'We can do a $?VM.raku';
    ok $?VM.gist ~~ m/\w/, 'We can do a $?VM.gist';
    ok $?VM.Str  ~~ m/\w/, 'We can do a $?VM.Str ';

    diag "'{$?VM.name}' is an unknown VM, please report" if !
      ok $?VM.name eq any($?PERL.VMnames),
      "We know of the VM we were compiled in";

    isa-ok $?VM.version, Version;
    isa-ok $?VM.signature, Blob;
}

ok $*VM.name,           "We are running under '{$*VM.name}'";
ok $*VM.auth,           "Authority is '{$*VM.auth}'";
ok $*VM.version,        "Version is '{$*VM.version}'";
# https://github.com/Raku/old-issue-tracker/issues/3918
#?rakudo todo 'no VM.signature yet RT #124624'
ok $*VM.signature,      "Signature is '{$*VM.signature}'";
ok $*VM.desc,           "Description is '{$*VM.desc}'";
ok $*VM.config,         "We have config";
ok $*VM.precomp-ext,    "Extension is '{$*VM.precomp-ext}'";
ok $*VM.precomp-target, "Extension is '{$*VM.precomp-target}'";
ok $*VM.prefix,         "Prefix is '{$*VM.prefix}'";

ok $*VM.raku ~~ m/\w/, 'We can do a $*VM.raku';
ok $*VM.gist ~~ m/\w/, 'We can do a $*VM.gist';
ok $*VM.Str  ~~ m/\w/, 'We can do a $*VM.Str';

diag "'{$*VM.name}' is an unknown VM, please report" if !
  ok $*VM.name eq any($*RAKU.VMnames),
  "We know of the VM we are running under";

isa-ok $*VM.version, Version;
# https://github.com/Raku/old-issue-tracker/issues/3918
isa-ok $*VM.signature, Blob;

# vim: expandtab shiftwidth=4
