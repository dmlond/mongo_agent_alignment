mongo_agent_alignment
=====================

Implementation of a reproducible next generation sequence alignment pipeline using Ruby [MongoAgents](https://github.com/dmlond/mongo_agent)

---Introduction

This agent is the first agent in a series of interconnected agents designed to automate the
process of aligning a fastq next generation sequence file against a reference fasta sequence
file, using [Bwa](http://bio-bwa.sourceforge.net/bwa.shtml) and [Samtools](http://samtools.sourceforge.net/samtools.shtml).  The agents all communicate with
each other, and their human controllers, using the same [MongoDB](http://www.mongodb.org/) Document
Store.

---Architecture
The pipeline is composed of 4 MongoAgents with the following agent_names:

- alignment_agent: this agent
- split_agent: [mongo_agent_split_raw](https://github.com/dmlond/mongo_agent_split_raw)
- align_subset_agent: [mongo_agent_align_subset](https://github.com/dmlond/mongo_agent_align_subset)
- merge_bam_agent: [mongo_agent_merge_bam](https://github.com/dmlond/mongo_agent_merge_bam)

and a monitor script [mongo_agent_merge_monitor](https://github.com/dmlond/mongo_agent_merge_monitor).

These agents are designed to use a ENV['MONGO_DB'] on a central ENV['MONGO_HOST'] to communicate with
each other, and their humans.  They are designed to run in 'daemon' mode, e.g. you launch
them all on the same ENV['Queue'] Document Store, and they run continuously, listening for new
tasks (Documents) in the Queue targeted at them based on their agent_name.  [Docker.io](www.docker.com) can
be used to wire together each agent/monitor with a mongodb, and required data volumes and reference volumes
/home/bwa_user/data, and /home/bwa_user/bwa_indexed.

The agents all extend one or more of the [docker_bwa_aligner](https://github.com/dmlond/docker_bwa_aligner)
applications by wrapping them in the ruby MongoAgents context.  Again, Docker is not absolutely required
to run these, but it greatly helps.

This particular agent responds to a task targetted to the alignment_agent, with the
build, reference, and raw_file specified.  It checks that the raw_file exists, and that the reference and
build files exist and are indexed by bwa and samtools. If so, it creates new tasks targetted to
the split_agent.

---Task Flow

1. Human or other agent creates a task targetted to the alignment_agent, with a build, reference, and raw_file
2. alignment_agent responds to this task, checks the reference and raw, and creates a task for the split_agent
3. split_agent splits the raw_file into subsets, and creates align_subset_agent targetted tasks for each subset
4. align_subset_agent aligns the subset against the reference to produced a sorted bam file
5. merge_monitor monitors split_agent and align_subset_agents for a particular alignment parent_id until they
   are finished, and then submits a task targetted to the merge_bam_agent
5. merge_bam_agent merges the subset_bams into a single bam file


input task: {agent_name: 'alignment_agent',
             build: 'dirname of build directory in /home/bwa_user/bwa_indexed',
             reference: 'filename of fasta file indexed in /home/bwa_user/bwa_indexed/build',
             raw_file: 'filename of fastq file in /home/bwa_user/data',
             ready: true
            }
