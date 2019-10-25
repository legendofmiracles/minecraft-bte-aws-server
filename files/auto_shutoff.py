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

if os.path.exists('/tmp/mc_last_activity'):
	f = open('/tmp/mc_last_activity', 'r+')

	if status.players.online:
		f.seek(0)
		f.write(str(time.time()))
		f.truncate()

		if os.path.exists("/tmp/mc_backup"):
  			os.remove("/tmp/mc_backup")

	else:
		old_time = float(f.read()) 
		time_past = time.time() - old_time
		if time_past > (30*60):
			if not os.path.exists('/tmp/mc_backup'):
				p = open('/tmp/mc_backup', 'w')
				p.write(str(time.time()))
				check_call(['aws', 's3', 'sync', '/homes/ec2-user/minecraft/', sys.argv[1]])
			
			#req = urllib2.urlopen('<SERVER DESTROY LAMBDA FUNCTION>')

else:
	f = open('/tmp/mc_last_activity', 'w')
	f.write(str(time.time()))
