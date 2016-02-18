=pod

=head1 NAME
	
	Bio::EnsEMBL::Compara::RunnableDB::OrthologQM::PairCollection

=head1 SYNOPSIS

=head1 DESCRIPTION

For a given species set, pair up members and fan out

=cut

package Bio::EnsEMBL::Compara::RunnableDB::OrthologQM::PairCollection;

use strict;
use warnings;
use Data::Dumper;

use base ('Bio::EnsEMBL::Compara::RunnableDB::BaseRunnable');

sub fetch_input {
	my $self = shift;

	# import params to variables
	my $species_set_name = $self->param( 'collection' );
	my $species_set_id   = $self->param( 'species_set_id' );
	my $ref_species      = $self->param( 'ref_species' );
	my $compara_db = $self->param( 'compara_db' );
	my $species1 = $self->param( 'species1' );
	my $species2 = $self->param( 'species2' );

	# fetch required adaptors
	my $gdb_adaptor = $self->compara_dba->get_GenomeDBAdaptor;
	my $ss_adaptor = $self->compara_dba->get_SpeciesSetAdaptor;

	# find genome_db_id for ref species
	if ( defined $ref_species ){
		my $ref_gdb = $gdb_adaptor->fetch_by_name_assembly( $ref_species );
		if ( !defined $ref_gdb ){
			$self->warning("Can't find $ref_species in the database. Continuing without reference..");
		}
		else {
			$self->param( 'ref_gdb_id', $ref_gdb->dbID );
		}
	}

	# find genome_dbs for species1 and species2 if not running on a collection
	if ( !defined $species_set_name && !defined $species_set_id ){
		die "Please provide a collection name OR individual species" unless ( $species1 && $species2 );
		
		# find GenomeDBs for each species
		my $species1_gdb = $gdb_adaptor->fetch_by_name_assembly($species1);
		my $species2_gdb = $gdb_adaptor->fetch_by_name_assembly($species2);

		die "Cannot find $species1 in the database\n" unless ( defined $species1_gdb );
		die "Cannot find $species2 in the database\n" unless ( defined $species2_gdb );

		$self->param( 'genome_db_list', [ $species1_gdb->dbID, $species2_gdb->dbID ] );

		return 1;
	}

	# if running on a collection, add all members gdb_ids to the species list
	my $ss; 
	if ( $species_set_name ){
		my @ss_list = @{ $ss_adaptor->fetch_all_by_name( $species_set_name ) };
		if ( scalar( @ss_list ) > 1 ){
			my @id_list = map { $_->dbID } @ss_list;
			die "More than one species set exists for '$species_set_name':\n" . join("\n", @id_list) . "\nPlease specify the ID of the set of interest (species_set_id)\n";
		}
		$ss = $ss_list[0];
		die "Cannot find collection '$species_set_name' in db ($compara_db)" unless ( defined $ss );
		$self->param( 'species_set_id', $ss->dbID );
	}
	elsif ( $species_set_id ){
		$ss = $ss_adaptor->fetch_by_dbID($species_set_id);
		die "Cannot find species_set with id '$species_set_id' in db ($compara_db)" unless ( defined $ss );
	}

	my $gdb_list = $ss->genome_dbs;
	my @species_list;
	foreach my $gdb ( @{ $gdb_list } ) {
		push( @species_list, $gdb->dbID );
	}
	$self->param( 'genome_db_list', \@species_list );
}

sub run {
	my $self = shift;

	my @species_list = @{ $self->param( 'genome_db_list' ) };
	my $ref_gdb_id   = $self->param('ref_gdb_id');
	my $ss_id        = $self->param('species_set_id');

	my @pairs;
	if ( $ref_gdb_id ) { # ref vs all
		foreach my $s ( @species_list ){
			next if $s == $ref_gdb_id;
			my $this_pair = {'species1_id' => $ref_gdb_id, 'species2_id' => $s};
			$this_pair->{species_set_id} = $ss_id if ( $ss_id );
			push( @pairs, $this_pair );
		}
	}
	else { # all vs all
		my @ref_list = @species_list;
		while( my $r = shift @ref_list ){
			my @nonref_list = @ref_list;
			foreach my $nr ( @nonref_list ){
				my $this_pair = {'species1_id' =>$r, 'species2_id' => $nr};
				$this_pair->{species_set_id} = $ss_id if ( $ss_id );
				push( @pairs, $this_pair );
			}
		}
	}
	$self->param('genome_db_pairs', \@pairs);
}

sub write_output {
	my $self = shift;

	$self->dataflow_output_id( $self->param('genome_db_pairs'), 2 );
}

1;
