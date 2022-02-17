process CIRCLEMAP_REALIGN {
    tag "$meta.id"
    label 'process_high'
    conda (params.enable_conda ? "bioconda::circle-map=1.1.4 conda-forge::biopython=1.77" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/circle-map:1.1.4--pyh864c0ab_1"
    } else {
        container "quay.io/biocontainers/circle-map:1.1.4--pyh864c0ab_1"
    }

    input:
    tuple val(meta), path(re_bam), path(re_bai), path(qname), path(sbam), path(sbai)
    path fasta
    path fai

    output:
    tuple val(meta), path("*.bed"), emit: bed, optional: true
    path "versions.yml"            , emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    circle_map.py \\
        Realign \\
        $args \\
        -i $re_bam \\
        -qbam $qname \\
        -sbam $sbam \\
        -fasta $fasta \\
        --threads $task.cpus \\
        --cmapq $params.circdna_filter_mapq \\
        --bases $params.coverage_bases \\
        --extension $params.coverage_extension \\
        --split $params.circdna_filter_nSplit \\
        -o ${prefix}_circularDNA_coordinates.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Circle-Map: \$(echo \$(Circle-Map --help 2<&1) | grep -o "version=[0-9].[0-9].[0-9]")
    END_VERSIONS
    """
}
