resource "exoscale_compute" "compute-1" {
    zone = "de-muc-1"
    display_name = "instance-1"
    template = "Linux Ubuntu 18.04 LTS 64-bit"
    size = "Micro"
    disk_size = 10
    key_pair = ""
    security_groups = ["${exoscale_security_group.security-group-1.name}"]
    user_data = <<EOF
#!/bin/bash
apt update
apt install -y nginx
apt install -y s3cmd
echo "Hello World!" >/var/www/html/index.html
echo "[default]
host_base = sos-de-muc-1.exo.io
host_bucket = %(bucket)s.de-muc-1.exo.io
access_key = $EXO_SOS_KEY
secret_key = $EXO_SOS_SECRET
use_https = True" >/etc/sos.s3cfg
EOF

}
