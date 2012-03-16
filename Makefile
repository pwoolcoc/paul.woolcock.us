
SITEDIR=_site

server:
	jekyll --server

blog:
	jekyll

clean:
	[ -d $(SITEDIR) ] && rm -rf $(SITEDIR)
	

