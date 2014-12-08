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
