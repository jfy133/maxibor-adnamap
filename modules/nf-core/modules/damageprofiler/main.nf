process DAMAGEPROFILER {
    tag "${meta.id}_${meta.genome_name}"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::damageprofiler=1.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/damageprofiler:1.1--hdfd78af_2' :
        'quay.io/biocontainers/damageprofiler:1.1--hdfd78af_2' }"

    input:
    tuple val(meta), path(bam), path(bai), path(fasta), path(fai)

    output:
    tuple val(meta), path("${prefix}"), emit: results
    path  "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args   ?: ''
    prefix   = task.ext.prefix ?: "${meta.id}_${meta.genome_name}"
    """

    damageprofiler \\
        -Xmx${task.memory.toGiga()}g \\
        -i $bam \\
        -r $fasta \\
        -l ${params.damageprofiler_length} \\
        -t ${params.damageprofiler_threshold} \\
        -o $prefix \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        damageprofiler: \$(damageprofiler -v | sed 's/^DamageProfiler v//')
    END_VERSIONS
    """
}
