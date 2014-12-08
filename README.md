mongo_agent_alignment
=====================

extends [dmlond/bwa_samtools_base](https://github.com/dmlond/bwa_samtools_base) with a Ruby MongoAgent:Agent wrapper that monitors for alignment_agent tasks, and, for each task:

- checks to ensure that the specified reference is available and indexed in the specified build directory
- checks to ensure that the specified raw files is available in the data directory
- creates a split_agent task
