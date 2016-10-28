job('DSL-ScriptJob') {
    steps {
        shell('mkdir html ; echo "Hello World" > html/index.html')
      	shell('docker run -d -p 90:80 -v $PWD/html:/var/www/html/ linuxconfig/apache')
      	shell('curl -i localhost:90')
    }
}