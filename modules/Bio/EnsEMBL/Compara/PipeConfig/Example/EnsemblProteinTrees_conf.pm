=head1 LICENSE

Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut


=head1 CONTACT

  Please email comments or questions to the public Ensembl
  developers list at <http://lists.ensembl.org/mailman/listinfo/dev>.

  Questions may also be sent to the Ensembl help desk at
  <http://www.ensembl.org/Help/Contact>.

=head1 NAME

Bio::EnsEMBL::Compara::PipeConfig::Example::EnsemblProteinTrees_conf

=head1 DESCRIPTION

The PipeConfig file for ProteinTrees pipeline that should automate most of the pre-execution tasks.

=head1 AUTHORSHIP

Ensembl Team. Individual contributions can be found in the GIT log.

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with an underscore (_)

=cut

package Bio::EnsEMBL::Compara::PipeConfig::Example::EnsemblProteinTrees_conf;

use strict;
use warnings;


use base ('Bio::EnsEMBL::Compara::PipeConfig::ProteinTrees_conf');


sub default_options {
    my ($self) = @_;

    return {
        %{$self->SUPER::default_options},   # inherit the generic ones

    # parameters that are likely to change from execution to another:
        'rel_with_suffix'       => $self->o('ensembl_release')."member", # You can add a letter to distinguish this run from other runs on the same release
        'do_not_reuse_list'     => ['homo_sapiens', 'gallus_gallus' ],     # names of species we don't want to reuse this time

    # custom pipeline name, in case you don't like the default one
        'pipeline_name'         => 'protein_trees_'.$self->o('rel_with_suffix'),   # name the pipeline to differentiate the submitted processes
        'division'              => 'ensembl',       # Tag attached to every single tree

    # dependent parameters: updating 'work_dir' should be enough
        'work_dir'              => '/lustre/scratch110/ensembl/'.$self->o('ENV', 'USER').'/protein_trees_'.$self->o('rel_with_suffix'),

    # "Member" parameters:

    # blast parameters:

    # clustering parameters:
        'outgroups'                     => { 'saccharomyces_cerevisiae' => 2 },   # affects 'hcluster_dump_input_per_genome'

    # tree building parameters:
        'treebreak_gene_count'      => 40000,     # affects msa_chooser

    # species tree reconciliation
        # you can define your own species_tree for 'treebest'. It can contain multifurcations
        # you can define your own species_tree for 'notung'. It *has* to be binary
        'binary_species_tree_input_file'   => $self->o('ensembl_cvs_root_dir').'/ensembl-compara/scripts/pipeline/species_tree.eukaryotes.topology.nw',

    # homology_dnds parameters:
        'taxlevels'                 => ['Theria', 'Sauria', 'Tetraodontiformes'],
        'filter_high_coverage'      => 1,   # affects 'group_genomes_under_taxa'

    # mapping parameters:
        'do_treefam_xref'           => 1,
        'tf_release'                => '9_69',

    # executable locations:
        'hcluster_exe'              => '/software/ensembl/compara/hcluster/hcluster_sg',
        'mcoffee_home'              => '/software/ensembl/compara/tcoffee/Version_9.03.r1318/',
        'mafft_home'                => '/software/ensembl/compara/mafft-7.113/',
        'trimal_exe'                => '/software/ensembl/compara/trimAl/source/trimal',
        'prottest_jar'              => '/software/ensembl/compara/prottest/prottest-3.4-20140123/prottest-3.4.jar',
        'treebest_exe'              => '/software/ensembl/compara/treebest',
        'raxml_exe'                 => '/software/ensembl/compara/raxml',
        'notung_jar'                => '/software/ensembl/compara/notung/Notung-2.6/Notung-2.6.jar',
        'quicktree_exe'             => '/software/ensembl/compara/quicktree_1.1/bin/quicktree',
        'buildhmm_exe'              => '/software/ensembl/compara/hmmer-3.1b1/binaries/hmmbuild',
        'codeml_exe'                => '/software/ensembl/compara/paml43/bin/codeml',
        'ktreedist_exe'             => '/software/ensembl/compara/ktreedist/Ktreedist.pl',
        'blast_bin_dir'             => '/software/ensembl/compara/ncbi-blast-2.2.28+/bin',

    # HMM specific parameters (set to 0 or undef if not in use)
        'hmm_clustering'            => 0, ## by default run blastp clustering
        'cm_file_or_directory'      => undef,
        'hmm_library_basedir'       => undef,
        'pantherScore_path'         => undef,
        'hmmer_path'                => undef,

    # hive_capacity values for some analyses:
        'reuse_capacity'            =>   3,
        'blast_factory_capacity'    =>  50,
        'blastp_capacity'           => 900,
        'mcoffee_capacity'          => 600,
        'split_genes_capacity'      => 600,
        'trimal_capacity'           => 400,
        'prottest_capacity'         => 400,
        'treebest_capacity'         => 400,
        'raxml_capacity'            => 400,
        'notung_capacity'           => 400,
        'ortho_tree_capacity'       => 200,
        'ortho_tree_annot_capacity' => 300,
        'quick_tree_break_capacity' => 100,
        'build_hmm_capacity'        => 200,
        'ktreedist_capacity'        => 150,
        'merge_supertrees_capacity' => 100,
        'other_paralogs_capacity'   => 100,
        'homology_dNdS_capacity'    => 200,
        'qc_capacity'               =>   4,
        'hc_capacity'               =>   4,
        'HMMer_classify_capacity'   => 100,
        'loadmembers_capacity'      =>  30,

    # hive priority for non-LOCAL health_check analysis:

    # connection parameters to various databases:

        # Uncomment and update the database locations

        # the production database itself (will be created)
        # it inherits most of the properties from HiveGeneric, we usually only need to redefine the host, but you may want to also redefine 'port'
        'host' => 'compara1',

        # the master database for synchronization of various ids (use undef if you don't have a master database)
        'master_db' => 'mysql://ensro@compara1:3306/sf5_ensembl_compara_master',

        # Ensembl-specific databases
        'staging_loc1' => {                     # general location of half of the current release core databases
            -host   => 'ens-staging',
            -port   => 3306,
            -user   => 'ensro',
            -pass   => '',
        },

        'staging_loc2' => {                     # general location of the other half of the current release core databases
            -host   => 'ens-staging2',
            -port   => 3306,
            -user   => 'ensro',
            -pass   => '',
        },

        'livemirror_loc' => {                   # general location of the previous release core databases (for checking their reusability)
            -host   => 'ens-livemirror',
            -port   => 3306,
            -user   => 'ensro',
            -pass   => '',
        },

        # NOTE: The databases referenced in the following arrays have to be hashes (not URLs)
        # Add the database entries for the current core databases and link 'curr_core_sources_locs' to them
        'curr_core_sources_locs'    => [ $self->o('staging_loc1'), $self->o('staging_loc2') ],
        #'curr_core_sources_locs'    => [ $self->o('livemirror_loc') ],
        'curr_file_sources_locs'    => [  ],    # It can be a list of JSON files defining an additionnal set of species

        # Add the database entries for the core databases of the previous release
        'prev_core_sources_locs'   => [ $self->o('livemirror_loc') ],
        #'prev_core_sources_locs'   => [ $self->o('staging_loc1'), $self->o('staging_loc2') ],

        # Add the database location of the previous Compara release. Use "undef" if running the pipeline without reuse
        'prev_rel_db' => 'mysql://ensro@compara1:3306/mm14_protein_trees_75',

        # To run without a master database
        #'master_db'                 => undef,
        #'do_stable_id_mapping'      => 0,
        #'mlss_id'                   => undef,
        #'ncbi_db'                   => 'mysql://ensro@ens-livemirror:3306/ncbi_taxonomy',
        #'prev_rel_db'               => undef,

    };
}


sub resource_classes {
    my ($self) = @_;
    return {
        %{$self->SUPER::resource_classes},  # inherit 'default' from the parent class

         '250Mb_job'    => {'LSF' => '-C0 -M250   -R"select[mem>250]   rusage[mem=250]"' },
         '500Mb_job'    => {'LSF' => '-C0 -M500   -R"select[mem>500]   rusage[mem=500]"' },
         '1Gb_job'      => {'LSF' => '-C0 -M1000  -R"select[mem>1000]  rusage[mem=1000]"' },
         '2Gb_job'      => {'LSF' => '-C0 -M2000  -R"select[mem>2000]  rusage[mem=2000]"' },
         '4Gb_job'      => {'LSF' => '-C0 -M4000  -R"select[mem>4000]  rusage[mem=4000]"' },
         '8Gb_job'      => {'LSF' => '-C0 -M8000  -R"select[mem>8000]  rusage[mem=8000]"' },
         'treebest_job'      => {'LSF' => '-q long -C0 -M8000  -R"select[mem>8000]  rusage[mem=8000]"' },

         'urgent_hcluster'   => {'LSF' => '-C0 -M32000 -R"select[mem>32000] rusage[mem=32000]" -q yesterday' },
    };
}


sub pipeline_analyses {
    my $self = shift;
    my $all_analyses = $self->SUPER::pipeline_analyses(@_);
    my %analyses_by_name = map {$_->{'-logic_name'} => $_} @$all_analyses;

    ## Extend this section to redefine the resource names of some analysis
    my %overriden_rc_names = (
        'treebest'                  => 'treebest_job',
    );
    foreach my $logic_name (keys %overriden_rc_names) {
        $analyses_by_name{$logic_name}->{'-rc_name'} = $overriden_rc_names{$logic_name};
    }
    return $all_analyses;
}

1;

