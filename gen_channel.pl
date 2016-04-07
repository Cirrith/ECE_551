#!/usr/bin/perl

##############################################
## used to generate CH1..5mem.txt files for Spring '16 project testing
#############################################

$tstep = 16/65536;		## CH5 will have 16 periods of waveform within 65536 samples

for ($CH=5; $CH>0; $CH--) {
  $t = 0.0;
  $outname = "CH".$CH."mem.txt";
  printf "Opening $outname for write\n";
  open(OUTFILE,">$outname") || die "ERROR: Can't open $outname for write\n";
  
  for ($x=0; $x<65536; $x++) {
    $value = 128 + 127*sin($t);
	$val = sprintf("%2x",$value);
    printf OUTFILE "\@%x %s\n",$x,$val;
	$t += $tstep;
  }
  close(OUTFILE);
  $tstep *= 2;		## CH5 is slowest, CH4 is twice CH5, CH3 is twice CH2, ...
}

