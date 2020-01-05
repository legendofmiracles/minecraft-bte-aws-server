#sudo pip install mcstatus
from mcstatus import MinecraftServer
import time
import json
import os.path
import urllib2
import subprocess
import sys

def check_call(args):
    """Wrapper for subprocess that checks if a process runs correctly,
    and if not, prints stdout and stderr.
    """
    proc = subprocess.Popen(args,
		shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd='/tmp')
    stdout, stderr = proc.communicate()
    if proc.returncode != 0:
        print(stdout)
        print(stderr)
        raise subprocess.CalledProcessError(
            returncode=proc.returncode,
            cmd=args)

server = MinecraftServer.lookup("localhost:25565")
status = server.status()

# if last activity was recorded 
if os.path.exists('/tmp/mc_last_activity'):
	f = open('/tmp/mc_last_activity', 'r+')

	if status.players.online:
		# if players are online, remove timestamp file
		f.seek(0)
		f.write(str(time.time()))
		f.truncate()

		# force new backup on inactivity
		if os.path.exists("/tmp/mc_backup"):
  			os.remove("/tmp/mc_backup")

	else:
		# get timestamp of last activity
		old_time = float(f.read()) 
		time_past = time.time() - old_time

		# more than 10 min of inactivity?
		if time_past > (10*60):
			# backup mc world 
			if not os.path.exists('/tmp/mc_backup'):
				p = open('/tmp/mc_backup', 'w')
				p.write(str(time.time()))
				check_call('aws s3 sync /home/ec2-user/minecraft/ {0} --exclude logs/*'.format(sys.argv[1]))

			# hit the kill switch and start countdown again
			check_call('aws sns publish --topic-arn {0} --message {{}} --region {1}'.format(sys.argv[2], sys.argv[3]))
			os.remove("/tmp/mc_last_activity")
else:
	# start the clock
	f = open('/tmp/mc_last_activity', 'w')
	f.write(str(time.time()))
