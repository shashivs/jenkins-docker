job('DSL-ScriptJob') {
    steps {
        shell('mkdir html ; echo "Hello World" > html/index.html')
      	shell('cp -iv html/index.html /var/www/html/')
      	shell('curl -i localhost:80')
    }
}
