#! usr/bin/perl -w

use strict;

#package EncryptAES;

my @key1 =  (0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00);
			
my @key2 = (0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
			0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
			0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
			0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);
			
my @key3 = (0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
			0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
			0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
			0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f);

#expand_and_print(@key1);
#expand_and_print(@key2);
#expand_and_print(@key3);



#my $key =     hextoasciistring('2b7e151628aed2a6abf7158809cf4f3c');
#my $phrase3 =  hextoasciistring('6bc1bee22e409f96e93d7e117393172a');

#encryptblock($phrase, $key);

my $phrase2 = '1234567890123456';
my $key = '12345678901234567890123456789012';

my %block = ascii_string_to_block($phrase2);
print_block(\%block);

encrypt_block(\%block);

sub ascii_string_to_block{
	my $string = shift;
	my @array = ascii_string_to_key_array($string);
	my %block = build_block(\@array);
	return %block;
}

sub hex_string_to_block{
	my $string = shift;
	my @array = hex_string_to_key_array($string);
	my %block = build_block(\@array);
	return %block;
	
}


sub Encrypt{

	my $plain_text = shift;
	my $key = shift;
	
	




}

sub column_major{
	
	my $block_ref = shift;
	my @newblock;
	for my $pos (0..3){
		for my $pos2 (0..3){
			$newblock[$pos*4+$pos2] = @{$block_ref}[$pos2*4+$pos];
		}
	}
	return @newblock;
}

sub  ascii_string_to_key_array{
	
	my $ascii_string = shift;
	my @dec_string;
	for my $pos (0..(length($ascii_string)-1)){
		my $char = substr($ascii_string, $pos, 1);
		push @dec_string, ord($char);
	}
	return @dec_string;
}

sub hex_string_to_key_array {
	
	my $hexstring = shift;
	
	my @key;
	my $hex_byte = "";
	my $hex_count = 0;
	for my $pos (0..length($hexstring)){
		$hex_count++;
		$hex_byte .= substr($hexstring, $pos, 1);
		if($hex_count % 2 == 0){
			push @key, $hex_byte;
			$hex_byte = "";
			$hex_count = 0;
		}
	}
		
	return @key;
	
}

sub build_block{
	
	my $key_ref = shift;
	
	my %block;
	
	for my $x_pos (0..3){
		for my $y_pos (0..3){
			my $new_pos = ($y_pos*4+$x_pos);
			$block{$new_pos} = @{$key_ref}[$x_pos*4+$y_pos];
		}
	}
	return %block;
}

sub print_block{
	
	my $block_ref = shift;
	my $count = 0;
	while($block_ref->{$count}){
		
		my $hex_char = sprintf("%x",$block_ref->{$count});
		if($block_ref->{$count} < 16){
			$hex_char = '0' . $hex_char
		}
		$hex_char = uc($hex_char);
		print "$hex_char  ";
		
		$count++;
		if(($count % 4) == 0){
			print "\n";
		}
	}
}

sub encrypt_block{
	#my $text_block_ref = shift;
	my $key_block_ref = shift;
	
	my $key_sched_block = expand_key128($key_block_ref);
	print_block($key_sched_block);
}



sub encryptblock{
	my $phrase = shift;
	my $keystring = shift;
	my $keylength = length($keystring);
	my @state = string_to_key($phrase);
	@state = column_major(\@state);
	
	while(scalar(@state) < 16){
		push @state, 0;
	}
	
	my $stateref = \@state;
	
	my @key = string_to_key($keystring);

	print "key = \n";
	print_hexkey(@key);
	
	my @roundkeys = expand_key128(\@key);
	print "roundkey = \n";
	print_hexkey(@key);
	
	print "state = \n";
	print_hexkey(@state);
	print "\n";
	
	
	if($keylength == 16){
		
		print "RoundKey 0\n";
		
		
		AddRoundKey($stateref, $roundkeys[0]);
		print "After AddRoundKey\n";
		print_block(@{$stateref});
		
		for my $round (1..9){
			
			round($stateref, $roundkeys[$round]);
			print "RoundKey $round\n";
		}
		
		
		
		
		SubBytes($stateref);
		print "After SubBytes\n";
		print_block(@{$stateref});
	
		ShiftRows($stateref);
		print "After ShiftRows\n";
		print_block(@{$stateref});
		print "RoundKey 0\n";
		AddRoundKey($stateref, $roundkeys[10]);
		
		
		print_block(@{$stateref});
	}
	elsif($keylength == 24){
	
	}
	elsif($keylength == 32){
		
		print_block(@{$stateref});
		print "\n";
		AddRoundKey($stateref, $roundkeys[0]);
		print_block(@{$stateref});
		
		for my $round (1..13){
			round($stateref, $roundkeys[$round]);
		}
		
		SubBytes($stateref);
		ShiftRows($stateref);
		AddRoundKey($stateref, $roundkeys[14]);
		
		print "final = \n";
		print_hexkey(@{$stateref});
		
	}
	else{
	
	}
	
}

sub hextoasciistring{

	my $string = shift;
	my $returnstring = "";
	my $currenthex = "";
	my $count = 0;
	for my $pos (0..length($string)){
		$count++;
		$currenthex .= substr($string, $pos, 1);
		if($count % 2 == 0){
			$returnstring .= chr(hex($currenthex));
			$currenthex = "";
		}
		
	}
		
	return $returnstring;

}

sub get_roundkeys{
	my $keyref = shift;

	my @roundkeys;
	my $currentroundkey = "";
	my $count = 0;
	foreach my $byte (%{$keyref}){
		$currentroundkey .= chr($byte);
		$count++;
		if(($count % 16) == 0){
			push @roundkeys, $currentroundkey;
			$currentroundkey = "";
			$count = 0;
		}
		
	}
	return @roundkeys;
}

sub round{

	my $stateref = shift;
	my $roundkey = shift;
	
	
	
	SubBytes($stateref);
	print "After SubBytes\n";
	print_block(@{$stateref});
	
	ShiftRows($stateref);
	print "After ShiftRows\n";
	print_block(@{$stateref});
	
	MixColumns($stateref);
	print "After MixColumns\n";
	print_block(@{$stateref});
	
	AddRoundKey($stateref, $roundkey);
	print "After AddRoundKey\n";
	print_block(@{$stateref});
	
}


sub string_to_key{

	my $string = shift;
	my @key;
	
	for my $pos (0..(length($string)-1)){
		my $char = substr($string, $pos, 1);
		
		my $ascii = ord($char);
		$ascii = $ascii % 256;
		push @key, $ascii;
	}
	
	return @key;

}


sub expand_and_print{

	my (@tempkey) = @_;

	expand_key( \@tempkey);

	print_hexkey(@tempkey);
	
	print "\n";

}	

sub AddRoundKey{

	my $stateref = shift;
	my $roundkey = shift;
	
	my @roundkeyarray = string_to_key($roundkey);
	@roundkeyarray = column_major(\@roundkeyarray);
	print_block(@roundkeyarray);
	my $bytes = scalar(@{$stateref});
	
	for(my $count = 0; $count < $bytes; $count++){
		@{$stateref}[$count] = @{$stateref}[$count] ^ $roundkeyarray[$count];
	}
	
}

sub SubBytes{

	my $stateref = shift;
	my $bytes = scalar(@{$stateref});

	for(my $count = 0; $count < $bytes; $count++){
		@{$stateref}[$count] = sbox(@{$stateref}[$count]);
	}
}

sub ShiftRows{

	my $stateref = shift;
	my $bytes = scalar(@{$stateref});
	
	
	if ($bytes == 16){
		for my $count (4..6){
		swapper(\@{$stateref}[$count], \@{$stateref}[$count+1]);
		}
	
		for my $count (8..9){
			swapper(\@{$stateref}[$count], \@{$stateref}[$count+2]);
		}
		my $revcount = 15;
		for my $count (13..15){
			swapper(\@{$stateref}[$revcount], \@{$stateref}[$revcount-1]);
			$revcount--;
		}
	}
	elsif ($bytes == 24){
		for my $count (6..10){
		swapper(\@{$stateref}[$count], \@{$stateref}[$count+1]);
		}
	
		for my $count (12..15){
			swapper(\@{$stateref}[$count], \@{$stateref}[$count+2]);
		}
		
		for my $count (18..20){
			swapper(\@{$stateref}[$count], \@{$stateref}[$count+2]);
		}
	}
	else{
		for my $count (8..14){
		swapper(\@{$stateref}[$count], \@{$stateref}[$count+1]);
		}
	
		for my $count (16..21){
			swapper(\@{$stateref}[$count], \@{$stateref}[$count+2]);
		}
		
		for my $count (24..28){
			swapper(\@{$stateref}[$count], \@{$stateref}[$count+2]);
		}
	}
	
	
}

sub MixColumns{

	my $stateref = shift;
	my $bytes = scalar(@{$stateref});
	
	for my $count (0..(($bytes/4)-1)){
	
		my @column = (@{$stateref}[0+$count], 
					  @{$stateref}[4+$count], 
					  @{$stateref}[8+$count], 
					  @{$stateref}[12+$count]);
		
		
		gmix_column(\@column);
		
		@{$stateref}[0+$count] = ($column[0]%256);
		@{$stateref}[4+$count] = ($column[1]%256); 
		@{$stateref}[8+$count] = ($column[2]%256); 
		@{$stateref}[12+$count] = ($column[3]%256);
	}
	
}

sub swapper{
	my $valueref1 = shift;
	my $valueref2 = shift;
	my $temp = ${$valueref1};
	${$valueref1} = ${$valueref2};
	${$valueref2} = $temp;
}

sub gmix_column{
	my $rref = shift;
    my @a;
    my @b;
	my $c;
	my $h;	
	for($c=0;$c<4;$c++) {
	
		$a[$c] = @{$rref}[$c];
		$h = @{$rref}[$c] & 0x80; #/* hi bit */
		$b[$c] = @{$rref}[$c] << 1;
		
		if($h == 0x80){ 
			$b[$c] ^= 0x1b;
		}#/* Rijndael's Galois field */
	}
	@{$rref}[0] = $b[0] ^ $a[3] ^ $a[2] ^ $b[1] ^ $a[1];
	@{$rref}[1] = $b[1] ^ $a[0] ^ $a[3] ^ $b[2] ^ $a[2];
	@{$rref}[2] = $b[2] ^ $a[1] ^ $a[0] ^ $b[3] ^ $a[3];
	@{$rref}[3] = $b[3] ^ $a[2] ^ $a[1] ^ $b[0] ^ $a[0];
}	
			

sub modkey{
	my $inref = shift;
	my $count = 0;
	foreach my $i (@{$inref}){
		@{$inref}[$count] = $i % 256;
		$count++;
	}
}

sub mod_block{
	my $inref = shift;
	my $count = 0;
	while($inref->{$count}){
		$inref->{$count} = $inref->{$count} % 256;
		$count++;
	}
}

sub print_hexkey{

    my @key = @_;
	my $count = 0;
	foreach my $i (@key){
		$count++;
		if($i < 16){
			printf("0%x ",$i);
		}
		else{
			printf("%x ",$i);
		}
		if($count % 16 == 0){
			print "\n";
		}
	}
}

sub print_block2{

    my @key = @_;
	my $count = 0;
	foreach my $i (@key){
		$count++;
		if($i < 16){
			printf("0%x ",$i);
		}
		else{
			printf("%x ",$i);
		}
		if($count % 4 == 0){
			print "\n";
		}
	}
	print "\n";
}

sub rcon{
	my $in = shift;
	
	if($in == 0){
		return 0x8b;
	}
	my $c = 1;
	
	while($in != 1){
		my $b = $c & 0x80;
		$c <<= 1;
		if($b == 0x80){
			$c ^= 0x1b;
		}
		$in--;
	}
	$c = $c % 256;
	return $c;
}

sub rotate{
	my $inref = shift;
    my $a;
	my $c;
	
    $a = @{$inref}[0];
    for($c=0;$c<3;$c++){
        @{$inref}[$c] = @{$inref}[$c + 1];
	}
    @{$inref}[3] = $a;
	
}

# This is the core key expansion, which, given a 4-byte value,
# does some scrambling */
sub schedule_core{
	my $inref = shift;
	my $i = shift;
    my $a;
    # Rotate the input 8 bits to the left */
    rotate(\@{$inref});
    # Apply Rijndael's s-box on all 4 bytes */
    for($a = 0; $a < 4; $a++){
        @{$inref}[$a] = sbox(@{$inref}[$a]);
	}
    # On just the first byte, add 2^i to the byte 
    @{$inref}[0] ^= rcon($i);
}

sub my_sbox{

	my $in = shift;

	my @stable = (
   0x63, 0x7C, 0x77, 0x7B, 0xF2, 0x6B, 0x6F, 0xC5, 0x30, 0x01, 0x67, 0x2B, 0xFE, 0xD7, 0xAB, 0x76,
   0xCA, 0x82, 0xC9, 0x7D, 0xFA, 0x59, 0x47, 0xF0, 0xAD, 0xD4, 0xA2, 0xAF, 0x9C, 0xA4, 0x72, 0xC0,
   0xB7, 0xFD, 0x93, 0x26, 0x36, 0x3F, 0xF7, 0xCC, 0x34, 0xA5, 0xE5, 0xF1, 0x71, 0xD8, 0x31, 0x15,
   0x04, 0xC7, 0x23, 0xC3, 0x18, 0x96, 0x05, 0x9A, 0x07, 0x12, 0x80, 0xE2, 0xEB, 0x27, 0xB2, 0x75,
   0x09, 0x83, 0x2C, 0x1A, 0x1B, 0x6E, 0x5A, 0xA0, 0x52, 0x3B, 0xD6, 0xB3, 0x29, 0xE3, 0x2F, 0x84,
   0x53, 0xD1, 0x00, 0xED, 0x20, 0xFC, 0xB1, 0x5B, 0x6A, 0xCB, 0xBE, 0x39, 0x4A, 0x4C, 0x58, 0xCF,
   0xD0, 0xEF, 0xAA, 0xFB, 0x43, 0x4D, 0x33, 0x85, 0x45, 0xF9, 0x02, 0x7F, 0x50, 0x3C, 0x9F, 0xA8,
   0x51, 0xA3, 0x40, 0x8F, 0x92, 0x9D, 0x38, 0xF5, 0xBC, 0xB6, 0xDA, 0x21, 0x10, 0xFF, 0xF3, 0xD2,
   0xCD, 0x0C, 0x13, 0xEC, 0x5F, 0x97, 0x44, 0x17, 0xC4, 0xA7, 0x7E, 0x3D, 0x64, 0x5D, 0x19, 0x73,
   0x60, 0x81, 0x4F, 0xDC, 0x22, 0x2A, 0x90, 0x88, 0x46, 0xEE, 0xB8, 0x14, 0xDE, 0x5E, 0x0B, 0xDB,
   0xE0, 0x32, 0x3A, 0x0A, 0x49, 0x06, 0x24, 0x5C, 0xC2, 0xD3, 0xAC, 0x62, 0x91, 0x95, 0xE4, 0x79,
   0xE7, 0xC8, 0x37, 0x6D, 0x8D, 0xD5, 0x4E, 0xA9, 0x6C, 0x56, 0xF4, 0xEA, 0x65, 0x7A, 0xAE, 0x08,
   0xBA, 0x78, 0x25, 0x2E, 0x1C, 0xA6, 0xB4, 0xC6, 0xE8, 0xDD, 0x74, 0x1F, 0x4B, 0xBD, 0x8B, 0x8A,
   0x70, 0x3E, 0xB5, 0x66, 0x48, 0x03, 0xF6, 0x0E, 0x61, 0x35, 0x57, 0xB9, 0x86, 0xC1, 0x1D, 0x9E,
   0xE1, 0xF8, 0x98, 0x11, 0x69, 0xD9, 0x8E, 0x94, 0x9B, 0x1E, 0x87, 0xE9, 0xCE, 0x55, 0x28, 0xDF,
   0x8C, 0xA1, 0x89, 0x0D, 0xBF, 0xE6, 0x42, 0x68, 0x41, 0x99, 0x2D, 0x0F, 0xB0, 0x54, 0xBB, 0x16
);

	my $hexstring = sprintf("%x",$in);
	
	if($in < 16){
	$hexstring = '0' . $hexstring;
	}
	
	my $x = hextodec(substr($hexstring, 0, 1));
	my $y = hextodec(substr($hexstring, 1, 1));
	
	
	return $stable[($x*16)+$y];
	
}

sub hextodec{

	my $string = shift;

	if($string eq 'a'){return 10;}
	elsif($string eq 'b'){return 11;}
	elsif($string eq 'c'){return 12;}
	elsif($string eq 'd'){return 13;}
	elsif($string eq 'e'){return 14;}
	elsif($string eq 'f'){return 15;}
	else{return (ord($string)-48);}
}

# Calculate the s-box for a given number 
sub sbox{
	my $in = shift;
	
    my ($c, $s, $x);
	$x = gmul_inverse($in);
    $s = $x;
    for($c = 0; $c < 4; $c++) {
        # One bit circular rotate to the left 
        $s = ($s << 1) | ($s >> 7);
        # xor with x 
        $x ^= $s;
    }
    $x ^= 99; # 0x63 
	$x = $x % 256;
    return $x;
}

sub gmul_inverse{
	my $in = shift;
	
	# Log table using 0xe5 (229) as the generator */
    my @ltable = (
0x00, 0xff, 0xc8, 0x08, 0x91, 0x10, 0xd0, 0x36, 
0x5a, 0x3e, 0xd8, 0x43, 0x99, 0x77, 0xfe, 0x18, 
0x23, 0x20, 0x07, 0x70, 0xa1, 0x6c, 0x0c, 0x7f, 
0x62, 0x8b, 0x40, 0x46, 0xc7, 0x4b, 0xe0, 0x0e, 
0xeb, 0x16, 0xe8, 0xad, 0xcf, 0xcd, 0x39, 0x53, 
0x6a, 0x27, 0x35, 0x93, 0xd4, 0x4e, 0x48, 0xc3, 
0x2b, 0x79, 0x54, 0x28, 0x09, 0x78, 0x0f, 0x21, 
0x90, 0x87, 0x14, 0x2a, 0xa9, 0x9c, 0xd6, 0x74, 
0xb4, 0x7c, 0xde, 0xed, 0xb1, 0x86, 0x76, 0xa4, 
0x98, 0xe2, 0x96, 0x8f, 0x02, 0x32, 0x1c, 0xc1, 
0x33, 0xee, 0xef, 0x81, 0xfd, 0x30, 0x5c, 0x13, 
0x9d, 0x29, 0x17, 0xc4, 0x11, 0x44, 0x8c, 0x80, 
0xf3, 0x73, 0x42, 0x1e, 0x1d, 0xb5, 0xf0, 0x12, 
0xd1, 0x5b, 0x41, 0xa2, 0xd7, 0x2c, 0xe9, 0xd5, 
0x59, 0xcb, 0x50, 0xa8, 0xdc, 0xfc, 0xf2, 0x56, 
0x72, 0xa6, 0x65, 0x2f, 0x9f, 0x9b, 0x3d, 0xba, 
0x7d, 0xc2, 0x45, 0x82, 0xa7, 0x57, 0xb6, 0xa3, 
0x7a, 0x75, 0x4f, 0xae, 0x3f, 0x37, 0x6d, 0x47, 
0x61, 0xbe, 0xab, 0xd3, 0x5f, 0xb0, 0x58, 0xaf, 
0xca, 0x5e, 0xfa, 0x85, 0xe4, 0x4d, 0x8a, 0x05, 
0xfb, 0x60, 0xb7, 0x7b, 0xb8, 0x26, 0x4a, 0x67, 
0xc6, 0x1a, 0xf8, 0x69, 0x25, 0xb3, 0xdb, 0xbd, 
0x66, 0xdd, 0xf1, 0xd2, 0xdf, 0x03, 0x8d, 0x34, 
0xd9, 0x92, 0x0d, 0x63, 0x55, 0xaa, 0x49, 0xec, 
0xbc, 0x95, 0x3c, 0x84, 0x0b, 0xf5, 0xe6, 0xe7, 
0xe5, 0xac, 0x7e, 0x6e, 0xb9, 0xf9, 0xda, 0x8e, 
0x9a, 0xc9, 0x24, 0xe1, 0x0a, 0x15, 0x6b, 0x3a, 
0xa0, 0x51, 0xf4, 0xea, 0xb2, 0x97, 0x9e, 0x5d, 
0x22, 0x88, 0x94, 0xce, 0x19, 0x01, 0x71, 0x4c, 
0xa5, 0xe3, 0xc5, 0x31, 0xbb, 0xcc, 0x1f, 0x2d, 
0x3b, 0x52, 0x6f, 0xf6, 0x2e, 0x89, 0xf7, 0xc0, 
0x68, 0x1b, 0x64, 0x04, 0x06, 0xbf, 0x83, 0x38 );

# Anti-log table: */
	my @atable = (
0x01, 0xe5, 0x4c, 0xb5, 0xfb, 0x9f, 0xfc, 0x12, 
0x03, 0x34, 0xd4, 0xc4, 0x16, 0xba, 0x1f, 0x36, 
0x05, 0x5c, 0x67, 0x57, 0x3a, 0xd5, 0x21, 0x5a, 
0x0f, 0xe4, 0xa9, 0xf9, 0x4e, 0x64, 0x63, 0xee, 
0x11, 0x37, 0xe0, 0x10, 0xd2, 0xac, 0xa5, 0x29, 
0x33, 0x59, 0x3b, 0x30, 0x6d, 0xef, 0xf4, 0x7b, 
0x55, 0xeb, 0x4d, 0x50, 0xb7, 0x2a, 0x07, 0x8d, 
0xff, 0x26, 0xd7, 0xf0, 0xc2, 0x7e, 0x09, 0x8c, 
0x1a, 0x6a, 0x62, 0x0b, 0x5d, 0x82, 0x1b, 0x8f, 
0x2e, 0xbe, 0xa6, 0x1d, 0xe7, 0x9d, 0x2d, 0x8a, 
0x72, 0xd9, 0xf1, 0x27, 0x32, 0xbc, 0x77, 0x85, 
0x96, 0x70, 0x08, 0x69, 0x56, 0xdf, 0x99, 0x94, 
0xa1, 0x90, 0x18, 0xbb, 0xfa, 0x7a, 0xb0, 0xa7, 
0xf8, 0xab, 0x28, 0xd6, 0x15, 0x8e, 0xcb, 0xf2, 
0x13, 0xe6, 0x78, 0x61, 0x3f, 0x89, 0x46, 0x0d, 
0x35, 0x31, 0x88, 0xa3, 0x41, 0x80, 0xca, 0x17, 
0x5f, 0x53, 0x83, 0xfe, 0xc3, 0x9b, 0x45, 0x39, 
0xe1, 0xf5, 0x9e, 0x19, 0x5e, 0xb6, 0xcf, 0x4b, 
0x38, 0x04, 0xb9, 0x2b, 0xe2, 0xc1, 0x4a, 0xdd, 
0x48, 0x0c, 0xd0, 0x7d, 0x3d, 0x58, 0xde, 0x7c, 
0xd8, 0x14, 0x6b, 0x87, 0x47, 0xe8, 0x79, 0x84, 
0x73, 0x3c, 0xbd, 0x92, 0xc9, 0x23, 0x8b, 0x97, 
0x95, 0x44, 0xdc, 0xad, 0x40, 0x65, 0x86, 0xa2, 
0xa4, 0xcc, 0x7f, 0xec, 0xc0, 0xaf, 0x91, 0xfd, 
0xf7, 0x4f, 0x81, 0x2f, 0x5b, 0xea, 0xa8, 0x1c, 
0x02, 0xd1, 0x98, 0x71, 0xed, 0x25, 0xe3, 0x24, 
0x06, 0x68, 0xb3, 0x93, 0x2c, 0x6f, 0x3e, 0x6c, 
0x0a, 0xb8, 0xce, 0xae, 0x74, 0xb1, 0x42, 0xb4, 
0x1e, 0xd3, 0x49, 0xe9, 0x9c, 0xc8, 0xc6, 0xc7, 
0x22, 0x6e, 0xdb, 0x20, 0xbf, 0x43, 0x51, 0x52, 
0x66, 0xb2, 0x76, 0x60, 0xda, 0xc5, 0xf3, 0xf6, 
0xaa, 0xcd, 0x9a, 0xa0, 0x75, 0x54, 0x0e, 0x01 );

	# 0 is self inverting */
	if($in == 0){
		return 0;
	}
	else{
        return $atable[(255 - $ltable[$in])];
	}
}

sub expand_key128{
	
	my $blockref = shift;
	my %block = %{$blockref};
    my @temp_array;
        
    #/* c is 16 because the first sub-key is the user-supplied key */
    my $byte_count = 16;
	my $index = 1;

        #/* We need 11 sets of sixteen bytes each for 128-bit mode */
        while($byte_count < 176) {
                #/* Copy the temporary variable over from the last 4-byte
                # * block */
                for my $count (0..3){
                    $temp_array[$count] = $block{$count + $byte_count - 4};
                    #print $temp_array[$count] . "\n";
                    
        		}
                #/* Every four blocks (of four bytes), 
                # * do a complex calculation */
                if($byte_count % 16 == 0) {
					schedule_core(\@temp_array,$index);
					$index++;
				}
		        for my $count (0..3) {
                    $block{$byte_count} = $block{$byte_count - 16} ^ $temp_array[$count];
                    $byte_count++;
                }
        }
        mod_block( \%block);
		return \%block;
}

sub expand_key{
	my $block_ref = shift;
	my %block = %{$block_ref};
    my @temp_array;
    my $byte_count = 32;
	my $schedule_index = 1;
    my $array_index;
    
    while($byte_count < 240) {
        # Copy the temporary variable over */
        for($array_index = 0; $array_index < 4; $array_index++){
			$temp_array[$array_index] = $block{$array_index + $byte_count - 4};
			#print ($array_index + $byte_count - 4) ." = $temp_array[$array_index]\n";
			<STDIN>;
		}
        # Every eight sets, do a complex calculation */
        if($byte_count % 32 == 0) {
            schedule_core(\@temp_array,$schedule_index);
			$schedule_index++;
		}
        # For 256-bit keys, we add an extra sbox to the
        # calculation */
        if($byte_count % 32 == 16) {
            for($array_index = 0; $array_index < 4; $array_index++){
                $temp_array[$array_index] = sbox($temp_array[$array_index]);
			}
		}
        for($array_index = 0; $array_index < 4; $array_index++) {
			$block{$byte_count} = $block{$byte_count - 32} ^ $temp_array[$array_index];
            $byte_count++;
        }
	}
	mod_block( \%block);
	print_block(\%block);
	#return get_roundkeys(\@{$inref});
}