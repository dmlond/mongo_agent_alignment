#!/usr/local/bin/ruby

require 'mongo_agent'

def indexed?(reference_file)
  if File.exists? reference_file
    if File.exists? "#{reference_file}.bwt"
      if File.exists? "#{reference_file}.fai"
        return true
      end
    end
  end
  false
end

agent = MongoAgent::Agent.new({name: 'alignment_agent', queue: ENV['QUEUE']})
agent.work! { |task|
  #task = { build, reference, raw_file, agent_name: alignment_agent, ready:true }
  successful = true
  error_message = nil

  reference_file = ['/home/bwa_user', 'bwa_indexed', task[:build], task[:reference]].join('/')
  unless indexed?(reference_file)
    successful = false
    error_message = "#{ task[:reference] } does not exist for #{ task[:build] }, or is not indexed properly!"
  end

  if successful
    raw_file = ['/home/bwa_user', 'data', task[:raw_file]].join('/')
    unless File.exists?(raw_file)
      successful = false
      error_message = "#{ task[:raw_file] } does not exist!"
    end
  end
  if successful
    files_produced = Dir["#{ reference_file }*"].collect do |file|
      {name: File.basename(file), sha1: `sha1sum #{ file }`.split(' ')[0]}
    end

    files_produced << {name: task[:raw_file], sha1: `sha1sum #{ raw_file }`.split(' ')[0]}
    agent.db[agent.queue].insert({
      build: task[:build],
      reference: File.basename(reference_file),
      raw_file: File.basename(raw_file),
      parent_id: task[:_id],
      agent_name: 'split_agent',
      ready: true
    })
    [true, { has_children: true, files: files_produced }]
  else
    [false, {error_message: error_message}]
  end
}
