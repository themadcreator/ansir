module.exports = (function(){
  png            = require('./src/png');
  configure      = require('./src/config');
  ansi           = require('./src/ansi-codes');
  octree         = require('./src/octree');

  blockRenderer  = require('./src/renderers/block');
  shadedRenderer = require('./src/renderers/shaded-block');
  subRenderer    = require('./src/renderers/sub-block');

  return {
    ansi      : ansi,
    configure : configure,
    octree    : octree,
    png       : png,
    renderer  : {
      block  : blockRenderer,
      shaded : shadedRenderer,
      sub    : subRenderer
    }
  };
})();