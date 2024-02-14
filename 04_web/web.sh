#!/bin/bash
cat > index.html <<EOF
<h1>hello world</h1>
EOF

nohup busybox httpd -f -p ${web_port} &
