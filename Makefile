
SITEDIR=_site
TAR_GZ=/tmp/paul.woolcock.us.tar.gz
SCP_CMD=scp $(TAR_GZ) prgmr:/tmp/

new:
	touch $(PWD)/_drafts/$(shell date +"%Y-%m-%d")-new-post.md
	gvim -f $(PWD)/_drafts/$(shell date +"%Y-%m-%d")-new-post.md

# TODO: publish task

server:
	jekyll serve -w

tarball: site
	cd $(SITEDIR) && tar -Pczf $(TAR_GZ) .

deploy: tarball
	$(SCP_CMD)
	ssh -t prgmr 'cd /usr/share/nginx/www/www.paulwoolcock.com && /bin/tar -xzvmf $(TAR_GZ) && sudo nginx -s reload'

site:
	jekyll build

clean:
	[ -d $(SITEDIR) ] && rm -rf $(SITEDIR)
	

