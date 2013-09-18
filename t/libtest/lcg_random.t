#!/usr/bin/env perl

# mt-aws-glacier - Amazon Glacier sync client
# Copyright (C) 2012-2013  Victor Efimov
# http://mt-aws.com (also http://vs-dev.com) vs@vs-dev.com
# License: GPLv3
#
# This file is part of "mt-aws-glacier"
#
#    mt-aws-glacier is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    mt-aws-glacier is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.



use strict;
use warnings;
use utf8;
use Test::More tests => 15;
use FindBin;
use lib "$FindBin::RealBin/../", "$FindBin::RealBin/../lib", "$FindBin::RealBin/../../lib";
use TestUtils;
use LCGRandom;
use Digest::SHA qw/sha256_hex/;
use Test::Deep;

warning_fatal();


{
	# make sure we have same number sequence each time
	is sha256_hex(join(',', map { lcg_rand() } (1..10_000))), '135cbcb5641b2e7d387b083a3aa25de8e6066f28d5fe84e569dbba4ab94b1b86';
	lcg_srand(0);
	is sha256_hex(join(',', map { lcg_rand() } (1..10_000))), '135cbcb5641b2e7d387b083a3aa25de8e6066f28d5fe84e569dbba4ab94b1b86';
	lcg_srand(764846290);
	is sha256_hex(join(',', map { lcg_rand() } (1..10_000))), '8fc1c7490ccbc9fc34c484bdd94d18e3c7a43c80c8a82892127f71ce25e7d552';

	# make sure it's lcg
	lcg_srand(0);
	cmp_deeply [ map { lcg_rand } 1..10 ], [12345,1406932606,654583775,1449466924,229283573,1109335178,1051550459,1293799192,794471793,551188310];

	lcg_srand(0);
	my @a = map { lcg_rand } 1..10;
	lcg_srand();
	my @b = map { lcg_rand } 1..10;
	cmp_deeply [@b], [@a], "lcg_srand without argument works like with 0";

}

{
	for my $seed (0, 101, 105){
		lcg_srand($seed);
		my @a = map { lcg_rand } 1..10;
		lcg_srand($seed);
		my @a1 = map { lcg_rand } 1..5;
		my @bb;
		lcg_srand $seed, sub {
			@bb = map { lcg_rand } 1..10;
		};
		my @a2 = map { lcg_rand } 1..5;
		cmp_deeply [@a1, @a2], [@a], "lcg_srand properly localize seed";
		cmp_deeply [@bb], [@a], "lcg_srand accepts callback";
	}
}

{
	ok ! eval { lcg_irand(); 1 };
	ok ! eval { lcg_irand(1); 1 };
	ok ! eval { lcg_irand("a", "b"); 1 };

	{
		our $rand_fake;
		no warnings 'redefine';
		local *LCGRandom::lcg_rand = sub { $rand_fake };

		test_fast_ok 2754, "lcg_irand produce right ranges" => sub {
			for my $seed (1231236, 4_000_000_000+87654, 1_876_354_567) {
				for my $base (0, -101, 103) {
					for my $size (1, 7, 17) {
						my $previous = undef;
						for my $i (1..103) {
							local $rand_fake = $seed + $i;
							my $a = $base;
							my $b = $base+$size;
							my $r = lcg_irand($a, $b);

							if (defined $previous) {
								if ($previous == $b) {
									fast_ok $r == $a;
								} else {
									fast_ok $r == $previous+1;
								}
							}
							$previous = $r;
						}
					}
				}
			}
		}
	}
}
1;