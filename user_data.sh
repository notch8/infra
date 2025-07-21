# This file is pasted into the User Data field when creating a new node group in the Rancher UI
# Must manually replace Site24x7 install key with real one
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
echo "Running custom user data script"
curl https://github.com/orangewolf.keys >> /home/ec2-user/.ssh/authorized_keys
curl https://github.com/aprilrieger.keys >> /home/ec2-user/.ssh/authorized_keys
curl https://github.com/maxkadel.keys >> /home/ec2-user/.ssh/authorized_keys

wget https://staticdownloads.site24x7.com/server/Site24x7InstallScript.sh
bash Site24x7InstallScript.sh -i -key=SITE_24X7_KEY_HERE -gn=GlassCanvas -automation=true  -tp=\"Default Threshold - SERVER\" -np="Main" -rule=\"Third Party Integrations - Main Notifications\"

--==MYBOUNDARY==--
