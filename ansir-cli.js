#!/usr/bin/env node

// CoffeScript CLI shim
if (require.main === module){
  require('coffee-script').register();
  require('./ansir-cli.coffee');
}
