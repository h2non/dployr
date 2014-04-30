#OPTIONS=" -f Dployrfile.yml -n german-template -p aws -r sa-east-1a"
OPTIONS=" -f Dployrfile.yml -n german-template -p gce -r europe-west1-a"


BIN="../../../bin/dployr"
COMMANDS = ["start", "provision", "halt", "start", "execute pre-provision", "destroy"]

COMMANDS.each do |cmd|
  to_run = "#{BIN} #{cmd} #{OPTIONS}"
  puts to_run
  result = system(to_run)
  if result == false
    raise "ERROR"
  end
  puts "\n\n"
end