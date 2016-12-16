
SITEDIR=_site
TAR_GZ=/tmp/paul.woolcock.us.tar.gz
SCP_CMD=scp $(TAR_GZ) paul.woolcock.us:/tmp/

all: site

new: TITLE=no-title
new:
	printf -- "---\nlayout: post\ntitle: ___\ndescription: ___\nslug: $(TITLE)\n---\n" > $(PWD)/_drafts/$(shell date +"%Y-%m-%d")-$(TITLE).md
	gvim -f $(PWD)/_drafts/$(shell date +"%Y-%m-%d")-$(TITLE).md &

publish: POST=$(shell date +"%Y-%m-%d")-no-title.md
publish:
	mv _drafts/$(POST) _posts/

server:
	bundle exec jekyll serve -w --incremental

tarball: site
	cd $(SITEDIR) && tar -Pczf $(TAR_GZ) .

deploy: tarball
	$(SCP_CMD)
	ssh -t paul.woolcock.us 'cd /usr/share/nginx/www/paul.woolcock.us && /bin/tar -xzvmf $(TAR_GZ) && sudo nginx -s reload'

site:
	bundle exec jekyll build --incremental

clean:
	[ -d $(SITEDIR) ] && rm -rf $(SITEDIR)
	

