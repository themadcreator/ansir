#!/usr/bin/env node

// CoffeScript CLI shim
if (require.main === module){
  require('coffeescript').register();
  require('./ansir-cli.coffee');
}
