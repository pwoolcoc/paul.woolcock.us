
SITEDIR=_site
IDENTITY_FILE=$(HOME)/.awskeys/pwoolcoc.pem
TAR_GZ=/tmp/paulwoolcock.com.tar.gz
AWS_USER=ec2-user
AWS_SERVER=184.73.167.64

server:
	jekyll --auto --server --url http://0.0.0.0:4000

tarball: site
	cd $(SITEDIR) && tar -Pczf $(TAR_GZ) .

deploy: tarball
	scp -i $(IDENTITY_FILE) $(TAR_GZ) $(AWS_USER)@$(AWS_SERVER):/tmp/
	ssh -t -i $(IDENTITY_FILE) $(AWS_USER)@$(AWS_SERVER) 'cd /srv/paulwoolcock.com && /usr/bin/sudo /bin/tar -xzvmf $(TAR_GZ)'

site:
	jekyll

clean:
	[ -d $(SITEDIR) ] && rm -rf $(SITEDIR)
	

