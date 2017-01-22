Run docker with apache in it, forward port 80 and certificate directory
docker run -td -e NAMES=`hostname -f` -p 80:80 -v /root/certs:/acme-tiny/certs --name acme dexter2cz/acme-tiny-docker

Or run docker without apache (useful, when apache is already running on your system), bind challenges in addition
Add alias to your apache configuration
Alias "/.well-known/acme-challenge/" "/var/www/html/challenges/"

docker run -td -e NAMES=`hostname -f` -p 80:80 -v /root/certs:/acme-tiny/certs -v /var/www/html/challenges:/var/www/html/.well-known/acme-challenge -e NOAPACHE=1 --name acme dexter2cz/acme-tiny-docker


