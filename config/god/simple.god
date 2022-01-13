God.watch do |w|
  jobname = "/home/gallivan/ruby-projects/alice/script/simple.rb"
  w.name = File.basename(jobname, ".*")
  w.log = "/home/gallivan/ruby-projects/alice/log/#{w.name}.log"
  w.start = "ruby #{jobname}"
  w.keepalive
end
