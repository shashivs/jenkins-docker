job('DSL-ScriptJob') {
    steps {
        shell('mkdir html; echo "Hello World" > html/index.html')
      	shell('rm -frv /var/www/html/index.html; cp -vrf html/index.html /var/www/html/')
      	shell('curl -i localhost:80')
    }
}