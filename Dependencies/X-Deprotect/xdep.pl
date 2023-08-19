#!usr/bin/perl
use File::Spec::Functions qw(rel2abs catfile);
use Cwd;
use strict;

#print File::Spec->rel2abs('../foo/../bar'); exit;
#print rel2abs('../foo/../bar'); exit;

my $cwd = cwd;
my %path;
my %cfg = ('pause_onerror', 1);

my $version = '2006-10-02';
my $copynotice = "// Map deprotected by X-deprotect (version $version) by zibada\r\n// http://dimon.xgm.ru/xdep/\r\n// Visit our modmaking community at http://xgm.ru/\r\n\r\n";


## parse configuration file

$\ = "\n";
$, = "\n";
print "##### X-deprotect: Warcraft 3 RoC/TFT Map Recovery Tool";
print "##### (C) zibada, 2006";
print "##### Version: $version";
print "##### see xdep.ini file for available options";
print "";
open(CFG, 'xdep.ini') or die_error("xdep.ini not found!");
my %scan_res;

while(<CFG>)
{
	/^(.*?)(;.*)?$/;
	$_ = $1;
	next if ($_ !~ /^(\S*)\s*=\s*(.*?)\s*$/);
	$cfg{"$1"} = "$2";
}
close CFG;


## work out necessary paths

$cfg{'inmapfile'} =~ s/[><"|]//g;
$path{'inmapfile'} = rel2abs($cfg{'inmapfile'});
$cfg{'outmapfile'} =~ s/[><"|]//g;
$path{'outmapfile'} = rel2abs($cfg{'outmapfile'});

my $mapbasename = substr($path{'inmapfile'}, rindex($path{'inmapfile'}, "\\") + 1);
$path{'temp'} = rel2abs("$mapbasename.temp");
$path{'mapfiles'} = "$path{'temp'}\\files";
$path{'sfmpq'} = "$cwd\\sfmpq.exe";
$path{'listfile'} = "$cwd\\listfile.txt";

## create temporary directories

(-e $path{'inmapfile'}) || die_error("Cannot find source map file: $cfg{'inmapfile'}");

print "Processing map: $mapbasename";

clean_temp() if ($cfg{'clean_temp_onstart'});

(-d $path{'temp'}) || mkdir $path{'temp'} || die_error("Cannot create temporary directory: $path{'temp'}");
(-d $path{'mapfiles'}) || mkdir $path{'mapfiles'} || die_error("Cannot create temporary directory: $path{'mapfiles'}");


chdir $path{'mapfiles'};



my $scanlistfile = catfile($path{'temp'}, 'listfile.txt');
my $templistfile = catfile($path{'temp'}, 'files.txt');

if (-e 'war3map.w3i')
{
	print 'Map files already extracted';
	print "To redo the extraction, delete temp dir or enable 'clean_temp' option";
}
else
{
	## prepare temporary files
	## $scanlistfile is current listfile
	## $templistfile is used to interact with sfmpq

	local $, = "";


	## initialize current listfile using "global" listfile
	
	my @files;
	if (-e $path{'listfile'})
	{
		open (SRCLISTFILE, "$path{'listfile'}");
		@files = <SRCLISTFILE>;
		close SRCLISTFILE;
	}
	open (LISTFILE, ">$scanlistfile");
	print LISTFILE @files;
	close LISTFILE;

	my $first = 1;
	my $unknowns = 0;
	my %mapfiles;
	my @scanned_files;
	
	
	# the extraction process must be done once if scanning is off
	# and possibly more than once otherwise (till we stop resolving unknown names)

	$, = "\n";

	while ($first or $cfg{'scan_enable'})
	{
		## match current listfile against archive
		
		## 2>nul redirects standard err to a file called nul. stdout will still direct to console
		system("\"" . absLinuxToWindowsPath($path{'sfmpq'}) . "\" l -l \"" . absLinuxToWindowsPath($scanlistfile) . "\" \"" . absLinuxToWindowsPath($path{'inmapfile'}) . "\" \"" . absLinuxToWindowsPath($templistfile) . "\" 2>nul");
		system("unix2dos \"$templistfile\"");
		(-e $templistfile) || die_error("Failed to extract MPQ archive $cfg{'inmapfile'}\nsfmpq.exe or sfmpq.dll are missing or damaged");

		## find any file names not retrieved before
		## count unknown files only at first iteration and only if scanning is on
		## otherwise extracting them will be a waste of time

		open(TMP, "$templistfile") || die_error("Cannot open temporary file: $templistfile");
		my @newfiles;
		while (<TMP>)
		{
			chomp;
			if (/^~unknowns/)
			{
				$unknowns++ if $first;
				next unless ($first and $cfg{'scan_enable'});
			}
			else
			{
				next if $mapfiles{lc($_)};
				$mapfiles{lc($_)} = 1;
				push @scanned_files, $_ unless $first;
			}

			$unknowns-- unless $first;
			push @newfiles, $_;

		}
		close TMP;

		## stop if nothing more to extract
		last if ($#newfiles == -1);

		## prepare extraction list for sfmpq
		open (TMP, ">$templistfile") || die_error("Cannot open temporary file: $templistfile");
		print TMP @newfiles;
		close TMP;

		## do extraction

		## 2>nil redirects standard err to a file called nil. stdout will still direct to console
		system("\"" . absLinuxToWindowsPath($path{'sfmpq'}) . "\" x -l \"" . absLinuxToWindowsPath($scanlistfile) . "\" \"" . absLinuxToWindowsPath($path{'inmapfile'}) . "\" \"" . absLinuxToWindowsPath($templistfile) . "\" 2>nil");
		my $newfiles = @newfiles;
		print "$newfiles files extracted to '$path{'mapfiles'}'";

		if ($unknowns)
		{
			print "$unknowns files still have unknown filenames" if ($cfg{'scan_enable'});
		}
		else
		{
			print "No unknown files found";
		}

		## stop here if no more unknown files or scanning is off

		last unless ($unknowns and $cfg{'scan_enable'});

		## update temp listfile
		print "Scanning for possible filenames...";
		%scan_res = ();
		foreach (@newfiles)
		{
			print_progress("Scanning $_...");
			scan_file($_);
		}
		my @possible_names = keys(%scan_res);
		my $possible_names = @possible_names;
		print_progress("Scanning completed, $possible_names possible filenames found");
		print "";

		open (LISTFILE, ">$scanlistfile");
		print LISTFILE @possible_names;
		close LISTFILE;
		
		## start the whole process over again, now with updated listfile

		$first = 0;
	}

	## delete extracted unknown files as they are no longer of any use
	
	`rmdir ~unknowns /q /s` if -d '~unknowns';

	## if we discovered any files not listed before, append them to global listfile

	if ($cfg{'scan_append_listfile'} and $#scanned_files != -1)
	{
		open (LISTFILE, ">>$path{'listfile'}");
		print LISTFILE @scanned_files;
		close LISTFILE;
		my $scanned_files = @scanned_files;
		print "$scanned_files filenames added to global listfile";
	}

	## if any unknows left, halt or warn depeding on config setting
	
	if ($unknowns)
	{
		print "Warning: $unknowns files have unresolved names" . ($cfg{'scan_enable'} ? ' even after scanning' : '');
		die_error('Unresolved files found and "halt_on_unknowns" option is on.') if ($cfg{'halt_on_unknowns'});
		print "These files will be lost and deprotected map may be incomplete or even unusable!";
	}	
}


delete_als() if ($cfg{'delete_als'});
patch_w3i() if ($cfg{'patch_w3i'});
build_imp() if ($cfg{'build_imp'});


my $script;
my @xdep_strings;
my (@globalvars, @categories, @triggers, @doodads);

if ($cfg{'recover_script'})
{

	if (-e 'scripts/war3map.j')
	{
		print "Moving 'scripts/war3map.j' to 'war3map.j'";
		rename('scripts/war3map.j', 'war3map.j');
		rmdir('scripts');
	}
	open(J, 'war3map.j') || die_error('Cannot read war3map.j');
	print 'Reading war3map.j...';

	$script .= $_ while(<J>);
	close(J);


	preserve_strings(\$script);
	$script = strip_formatting($script);
#	$script = indent_script($script) if $cfg{'indent_script'};

	inline_functions() if $cfg{'inline_functions'};
	rename_reserved_functions() if $cfg{'rename_reserved_functions'};
	process_globals();

	detect_start_locations() if $cfg{'build_doo'};
	write_doo() if ($cfg{'build_doo'} or $cfg{'build_dummy_doo'});
	
	initialize_wtg();
	write_wtg();

#	restore_strings(\$script);
#	print "Writing temp war3map.j...";
#	local $\ = '';
#	open(TEMP, '>../war3map.j');
#	print TEMP $script;
#	close TEMP;

#	@globalvars = fetch_globals();
#	print @globalvars;
}


if ($cfg{'build_w3x'})
{
	## construct the output map
	print "Building map archive...";
	my $tempmpqfile = catfile($path{'temp'}, 'out.mpq');
	unlink $tempmpqfile if -e $tempmpqfile;

	my @files = construct_files_list('.');
	open (LISTFILE, ">$templistfile");
	print LISTFILE @files;
	close LISTFILE;

	my $files = @files;

	print_progress_cmd("\"$path{'sfmpq'}\" a \"$tempmpqfile\" \"$templistfile\"");
	print_progress("Added $files files");
	print "";
	(-e $tempmpqfile) || die_error("Failed to create output MPQ archive\nsfmpq.exe or sfmpq.dll are missing or damaged");

	local $\ = "";

	## fetch map header from source
	my $headerfile = catfile($path{'temp'}, 'header.w3x');
	my $header;

	open (SRCMAP, "$path{'inmapfile'}")  || die_error("Cannot find source map file: $cfg{'inmapfile'}");
	binmode SRCMAP;
	sysread(SRCMAP, $header, 512);
	close SRCMAP;

	open (OUTMAP, ">$path{'outmapfile'}") || die_error("Cannot open target map file: $cfg{'outmapfile'}");
	binmode OUTMAP;
	syswrite(OUTMAP, $header, 512);
	open (MPQ, "$tempmpqfile") || die_error("Failed to create output MPQ archive\nsfmpq.exe or sfmpq.dll are missing or damaged");
	binmode MPQ;
	while (<MPQ>)
	{
		print OUTMAP $_;
	}
	close MPQ;
	close OUTMAP;

	print "Created map '$cfg{'outmapfile'}'\n";
}

### clean temporary files if necessary

clean_temp() if $cfg{'clean_temp_onsuccess'};
wait_enter() if $cfg{'pause_onsuccess'};


#### EVERYTHING DONE! ####



#built-in Cwd uses linux paths like /c/ instead of c:\. This fails when passing as parameters to sfmpq.exe because it doesn't understand the linux format.
sub absLinuxToWindowsPath
{
	my $linuxPath = $_[0];
	$linuxPath =~ /^\/[a-zA-Z]\//  or die_error("not a valid absolute path in linux!");	
	my $result = substr($linuxPath, 1, 1) . ":" . substr($linuxPath, 2);
	$result =~ s/\//\\/g;
	$result =~ s/\\/\\\\/g;
	return $result;
}

## clean_temp
## 	removes temporary directory

sub clean_temp
{
	chdir $cwd;
	if (-d $path{'temp'})
	{
		print "Deleting temporary files...";
#		print qq(rmdir "$path{'temp'}" /s /q);
		`rmdir "$path{'temp'}" /s /q`;
	}
}


## construct_files_list
## 	returns list of files in dir, recursing subdirs

sub construct_files_list
{
	my $dir = shift;
	my $prefix = ($dir eq '.' ? '' : "$dir\\");
	my @res;

	opendir (local *DIR, $dir);
	while (my $filename = readdir(DIR))
	{
		next if ($filename eq '.' or $filename eq '..');
		$filename = "$prefix$filename";
		if (-d $filename)
		{
			push @res, construct_files_list($filename);
			next;
		}
		push @res, $filename;
	}
	closedir DIR;
	return @res;
}


## delete_als
## 	deletes (attributes), (listfile), (signature) files

sub delete_als
{
	if (-e '(attributes)')
	{
		print "Deleting (attributes)...";
		unlink '(attributes)';
	}
	if (-e '(listfile)')
	{
		print "Deleting (listfile)...";
		unlink '(listfile)';
	}
	if (-e '(signature)')
	{
		print "Deleting (signature)...";
		unlink '(signature)';
	}
}


## patch_w3i
## 	fixes war3map.w3i file ending bytes

sub patch_w3i
{
	my $w3ipath = "war3map.w3i";
	print "Patching war3map.w3i...";
	open (W3I, "+<$w3ipath") or die_error("Cannot open $w3ipath");
	binmode W3I;
	seek (W3I, -1, 2);
	my $c;
	sysread(W3I, $c, 1);
	if ($c eq "\xFF")
	{
		seek(W3I, -1, 1);
		syswrite(W3I, "\x00\x00\x00\x00", 4);
		print "war3map.w3i patched successfully";
	}
	else
	{
		print "war3map.w3i is undamaged or already patched; skipping";
	}
	close W3I;
}


## build_imp
## 	re-creates import file

sub build_imp
{
	local $\ = '';
	local $, = "\x0D";
	print "Building war3map.imp...\n";
	my @files = construct_files_list('.');
	my @newfiles;
	foreach (@files)
	{
		next if /^war3map(\.(w[a-zA-Z0-9]{2}|doo|shd|mmp|j|imp)|misc\.txt|skin\.txt|map\.blp|units\.doo|extra\.txt)$/i;
		push @newfiles, $_ . "\x00";
	}
	my $newfiles = @newfiles;
	open (IMP, '>war3map.imp') || die_error('Cannot open war3map.imp file for writing');
	binmode IMP;
	print IMP pack('VV', 1, $newfiles);
	print IMP "\x0D";
	print IMP @newfiles;
	close IMP;
	print "$newfiles files added to import list\n";
}


## process_globals
## 	builds global variable info and renames them
## 	either by automatic or user-specified names

sub process_globals
{
	print "Renaming globals...";
	@globalvars = ();
	foreach (split(/\n\s*/, $script))
	{
		last if $_ eq 'endglobals';
		next unless /^(\w+)( | array )(\w+)(?:|\=(.*))$/;
		push @globalvars, {
			'vartype' => $1,
			'isarray' => ($2 eq ' array ') ? 1 : 0,
			'varname' => $3,
			'initial' => $4 ? $4 : '',
			'initialized' => 0,
		};
	}

	my %typecounts;
	my %replaces;

	foreach my $var (@globalvars)
	{
		my $varname = $var->{'varname'};
		my $vartype = $var->{'vartype'} . ($var->{'isarray'} ? 's' : '');
		my $newname = $varname;
		if ($cfg{'rename_globals'})
		{
			$newname = sprintf('%s%02d', $vartype, (++$typecounts{$vartype}));
		}
		elsif (substr($newname, 0, 4) eq 'udg_')
		{
			$newname = substr($newname, 4);
		}
		elsif (substr($newname, 0, 3) eq 'gg_')
		{
			$newname = substr($newname, 3);
		}
		$var->{'varname'} = $newname;
		$replaces{$varname} = "udg_$newname";
	}
	replace_tokens(\$script, \%replaces);
}



## strip_formatting
## 	kills all unnecessary spaces, tabs and newlines in code

sub strip_formatting
{
	my @lines = split(/[\r\n]+/, $_[0]);
	foreach (@lines)
	{
		s/^\s+//;
		s/\s+$//;
		s/\s+/ /g;
		s/(?<=\W)\s//g;
		s/\s(?=\W)//g;
	}
	return join("\n", @lines);
}


## inline_functions
## 	expands function calls with the code of that function
## 	functions being inlined must have no parameters, returns or locals
## 	and be called only once

sub inline_functions
{
	my $i = 0;
	print_progress("Inlining functions...");
	while ($script =~ /\ncall\s+(\w+)\(\)/gs)
	{
		my $func = $1;
#		next unless index($', "\ncall $func()") == -1;
		my $pref = $`;
		next unless $pref =~ /function $func takes nothing returns nothing\s(.*?)\bendfunction/s;
		my $code = "\n$1";
		next unless index($code, "\nlocal ") == -1;
		print_progress("Inlining function $func...");
		$script =~ s/function $func takes nothing returns nothing\s(.*?)\bendfunction\n//s;
		$script =~ s/\ncall\s+$func\(\)\n/$code/gs;
		$i++;
	}
	print_progress("Inlined $i functions");
	print "";
}


## rename_reserved_functions
## 	renames functions having names of functions automatically generated by WE
## 	they should be inlined anyway, but we have to do this if inlining is off

sub rename_reserved_functions
{
	print_progress("Renaming reserved functions...");
	my $i = 0;
	my %replaces;
	my @reserved = (
		'InitGlobals',
		'CreateRegions',
		'InitSounds',
		'CreateCameras',
		'CreateAllUnits',
		'InitCustomTriggers',
		'RunInitializationTriggers',
		'InitCustomPlayerSlots',
		'InitCustomTeams',
		'InitAllyPriorities',
		'CreateNeutralPassiveBuildings',
		'CreateNeutralPassive',
		'CreatePlayerBuildings',
		'CreatePlayerUnits',
	);
	for my $func (@reserved)
	{
		next if ($script !~ /function $func\s/);
		my $newname = $func . '2';
		$newname++ while (index($script, "function $newname") >= 0);
		print_progress ("Renaming $func to $newname");
		$replaces{$func} = $newname;
		$i++;
	}
	replace_tokens(\$script, \%replaces);
	print_progress("Renamed $i reserved functions");
	print "";
}


## indent_script
## 	adds indentation to blocks of script

sub indent_script
{
	my @lines = split(/\n/, $_[0]);
	my $lvl = 0;
	foreach my $line (@lines)
	{
		$line =~ s/^\s+(.*?)\s+$/$1/;
		$lvl-- if $line =~ /^\s*(end(if|loop|function)|else)/;
		$line = ("\t" x $lvl) . "$line";
		$lvl++ if $line =~ /^\s*(if|loop|function|else)/;
		$line .= "\n" and $lvl = 0 if $line eq 'endfunction';
	}
	return join("\n", @lines);
}


## detect_start_locations
## 	finds start location info in config function and populates doodad data

sub detect_start_locations
{
	my @playerlocs;
	print 'Detecting start location data...';
	while ($script =~ /call SetPlayerStartLocation\(Player\(([0-9]+)\),([0-9]+)\)/gs)
	{
		$playerlocs[$2] = $1;
	}
	while ($script =~ /call DefineStartLocation\((.*?),(.*?),(.*?)\)/gs)
	{
		push @doodads, {
			'typeid' => 'sloc',
			'var' => $playerlocs[$1],
			'x' => $2,
			'y' => $3,
			'z' => 1024,
			'a' => 0,
			'owner' => $playerlocs[$1],
			'flags' => 2,
			'id' => scalar(@doodads) + 1,
		};	
	}
}


## write_doo
## 	write doodad data to war3mapUnits.doo format

sub write_doo
{
	my $doo;

	print 'Creating war3mapUnits.doo...';

	$doo = 'W3do';
	$doo .= pack('V', 8);
	$doo .= pack('V', 11);
	$doo .= pack('V', scalar(@doodads));
	foreach (@doodads)
	{
		%_ = %$_;
		$doo .= $_{'typeid'};
		$doo .= pack('V', $_{'var'});
		$doo .= pack('ffff', $_{'x'}, $_{'y'}, $_{'z'}, $_{'a'});
		$doo .= pack('fff', 1, 1, 1);
		$doo .= chr($_{'flags'});
		$doo .= pack('V', $_{'owner'});
		$doo .= "\0\0";
		$doo .= pack('VV', 0, 0);
		$doo .= pack('V', -1);
		$doo .= pack('VVVVVVVVVV', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		$doo .= pack('VVV', 1, -1, -1);
		$doo .= pack('V', $_{'id'});
	}

	open(DOO, '>war3mapUnits.doo') || die_error('Cannot open war3mapUnits.doo for writing');
	binmode DOO;
	print DOO $doo;
	close DOO;
}

## initialize_wtg
## 	initializes trigger and category data

sub initialize_wtg
{
	my $mainfunc = 'main2';
	$mainfunc++ while (index($script, "function $mainfunc") >= 0);

	$script =~ s/^.*?\sendglobals//s;
	$script =~ s/\sfunction config takes nothing returns nothing.*?\sendfunction//s;
	$script =~ s/\sfunction InitCustomTeams takes nothing returns nothing.*?\sendfunction//s;
	$script =~ s/\nfunction main takes nothing returns nothing/\nfunction $mainfunc takes nothing returns nothing/;
	$script =~ s/\scall InitBlizzard\(\)//s;

	my $initcode = '';
	
	foreach (@globalvars)
	{
		next if ($_->{'initial'} =~ /^(|""|false|0|null|Create(Timer|Group|Force)\(\))$/);
#		%_ = %$_;
		if ($_->{'vartype'} =~ /^(boolean|real|integer|string)$/)
		{
			$_->{'initialized'} = 1;
			next;
		}
		$initcode .= "set udg_$_->{'varname'} = $_->{'initial'}\n";
	}

	$script .= "
function InitTrig_init takes nothing returns nothing
$initcode
call ExecuteFunc(\"$mainfunc\")
endfunction
";

	$categories[0] = {'id' => 1, 'name' => 'triggers', 'type' => 0};
	$triggers[0] = {
		'name' => 'init',
		'desc' => '',
		'type' => 0,
		'enabled' => 1,
		'custom' => 1,
		'initial' => 0,
		'runoninit' => 0,
		'category' => 1,
		'eca' => 0,
		'data' => $script,
	};
}


## write_wtg
## 	writes trigger data to wtg/wct format

sub write_wtg
{
	my $wtg;
	my @wctsections;

	print "Creating war3map.wtg...";

	$wtg .= 'WTG!';
	$wtg .= pack('V', 7);
	$wtg .= pack('V', $#categories + 1);
	foreach (@categories)
	{
		%_ = %$_;
		$wtg .= pack('V', $_{'id'});
		$wtg .= $_{'name'} . "\0";
		$wtg .= pack('V', $_{'type'});
	}

	$wtg .= pack('V', 2);
	
	$wtg .= pack('V', $#globalvars + 1);
	foreach (@globalvars)
	{
		%_ = %$_;
		$wtg .= $_{'varname'} . "\0";
		$wtg .= $_{'vartype'} . "\0";
		$wtg .= pack('VVVV', 1, $_{'isarray'}, 1, $_{'initialized'});
		if ($_{'initialized'})
		{
			my $initial = $_{'initial'};
			restore_strings(\$initial);
			$initial =~ s/^"(.*)"$/$1/;
			$wtg .= $initial;
		}
		$wtg .= "\0";
	}

	$wtg .= pack('V', $#triggers + 1);
	foreach (@triggers)
	{
		%_ = %$_;
		$wtg .= $_{'name'} . "\0";
		$wtg .= $_{'desc'} . "\0";
		$wtg .= pack('VVVVVVV', $_{'type'}, $_{'enabled'}, $_{'custom'}, $_{'initial'}, $_{'runoninit'}, $_{'category'}, $_{'eca'});
		push @wctsections, ($_{'data'} . "\0");
	}

	my $wctcustomsection = $copynotice;

	print "Creating war3map.wct...";
	my $wct = '';
	$wct .= pack('V', 1);
	$wct .= "\0";
	$wct .= pack('V', length($wctcustomsection) + 1);
	$wct .= $wctcustomsection . "\0";
	$wct .= pack('V', $#wctsections + 1);
	foreach (@wctsections)
	{
		$_ = indent_script($_) if $cfg{'indent_script'};
		$_ = $copynotice . $_;
		restore_strings(\$_);
		s/(?<!\r)\n/\r\n/gs;
		$wct .= pack('V', length($_));
		$wct .= $_;
	}

	local $\ = '';
	open(WTG, '>war3map.wtg') || die_error('Cannot open war3map.wtg for writing');
	binmode WTG;
	print WTG $wtg;
	close WTG;

	open(WCT, '>war3map.wct') || die_error('Cannot open war3map.wct for writing');
	binmode WCT;
	print WCT $wct;
	close WCT;
}




## preserve_strings
## 	replaces quoted strings with "###XDEP_STRING_xxx###" construct to avoid parsing them
## 	ignores ExecuteFunc("foo") constructs as identifiers within them are to be processed

sub preserve_strings
{
	${$_[0]} =~ s/(?<!ExecuteFunc\()"(|(?:.*?[^\\](?:\\\\)*))"/$xdep_strings[$#xdep_strings+1] = $1, "\"###XDEP_STRING_$#xdep_strings###\""/eg;
}


## restore_strings
## 	expands the "###XDEP_STRING_xxx###" constructs into original strings

sub restore_strings
{
	${$_[0]} =~ s/###XDEP_STRING_(\d+)###/$xdep_strings[$1]/eg;
}


## replace_tokens
## 	replaces list of identifiers

sub replace_tokens
{
	my $text = $_[0];
	my $r = $_[1];
	foreach my $search (keys(%$r))
	{
		my $replace = $r->{$search};
		$$text =~ s/\b(?<!')$search\b/$replace/gs;
	}
}


## scan_file
## 	scans specified file for any possible MPQ filenames

sub scan_file
{
	my $filename = shift;
	open(FILE, "$filename") || return;
	binmode FILE;
	my $line = '';
	$line .= $_ while (<FILE>);
	while ($line =~ /\b([\)\(\\\/a-zA-Z_0-9. -]{1,1000})\.(txt|blp|tga|mdx|mdl|mp3|slk|wav)\b/gi)
	{
		my $path = $1;
		my $ext = lc($2);
		$path =~ s/\\\\/\\/g;
		my $basename = substr($path, rindex($path, "\\") + 1);
		$scan_res{"$path.$ext"} = 1;
		if ($ext eq 'tga' or $ext eq 'blp')
		{
			$scan_res{"$path.blp"} = 1;
			$scan_res{"$path.tga"} = 1;
			$scan_res{"ReplaceableTextures\\CommandButtonsDisabled\\DIS$basename.tga"} = 1;
			$scan_res{"ReplaceableTextures\\CommandButtonsDisabled\\DIS$basename.blp"} = 1;
		}
		if ($ext eq 'mdl' or $ext eq 'mdx')
		{
			$scan_res{"$path.mdl"} = 1;
			$scan_res{"$path.mdx"} = 1;
			$scan_res{"$path" . "_Portrait.mdx"} = 1;
		}
	}

#	while ($line =~ /\b([\\\/a-zA-Z_0-9. -]*)\b/gi)
	while ($line =~ /\b([!@#$%^+\\\/a-zA-Z_0-9. -]{,1000})\b/gi)
	{
		my $path = $1;
		$scan_res{"$path" . "_Portrait.mdx"} = 1;
		$scan_res{"$path.mdx"} = 1;
		$scan_res{"$path.mdl"} = 1;
	}
	close FILE;
}


## prints line over previous line

sub print_progress
{
	local $\ = "";
	my $msg = substr(shift, 0, 79);
	$msg .= (" " x (79 - length($msg))) . "\r";
	print $msg;		
}


## executes shell cmd, printing its output in single re-writable line

sub print_progress_cmd
{
	my $cmd = shift;
	local $\ = "";
	open(CMD, "$cmd|");
	while(<CMD>)
	{
		chomp;
		print_progress($_);	
	}
}


## waits for a key
sub wait_enter
{
	print "\n* * * Press Enter to exit * * *";
	<STDIN>;
}

## print "Fatal Error" message and halt

sub die_error
{
	my $msg = shift;
	print STDERR "Fatal Error: $msg";
	clean_temp() if $cfg{'clean_temp_onerror'};
	wait_enter() if $cfg{'pause_onerror'};
	exit;
}