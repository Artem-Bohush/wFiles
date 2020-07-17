( function _Http_test_ss_( )
{

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../wtools/Tools.s' );

  _.include( 'wTesting' );

  require( '../l4_files/entry/Files.s' );
}

var _ = _global_.wTools;

// --
// context
// --

function onSuiteBegin()
{
  let context = this;
  context.suiteTempPath = _.fileProvider.path.tempOpen( _.fileProvider.path.join( __dirname, '../..' ), 'FileProviderHttp' );
}

//

function onSuiteEnd()
{
  let context = this;
  _.fileProvider.path.tempClose( context.suiteTempPath );
}

//

function providerMake()
{
  let context = this;

  let system = _.FileProvider.System({ empty : 1 });

  let HardDrive = _.FileProvider.HardDrive
  ({
    protocols : [ 'current', 'second' ],
  });

  let Http = _.FileProvider.Http
  ({
    protocols : [ 'http', 'https' ],
  });

  system.providerRegister( HardDrive );
  system.providerRegister( Http );

  system.defaultProvider = HardDrive;

  return system;
}

//

function assetFor( test, a )
{
  let context = this;

  if( !_.mapIs( a ) )
  {
    if( _.boolIs( arguments[ 1 ] ) )
    a = { originalAssetPath : arguments[ 1 ] }
    else
    a = { assetName : arguments[ 1 ] }
  }

  if( !a.fileProvider )
  {
    a.fileProvider = context.providerMake();
  }

  a.suiteTempPath = a.fileProvider.path.tempOpen( a.fileProvider.constructor.name );

  let system = a.system;
  let effectiveProvider = a.effectiveProvider;
  let global = a.global;

  a = test.assetFor( a );

  if( !system )
  {
    if( a.fileProvider.system )
    a.system = a.fileProvider.system;
    else if( a.fileProvider instanceof _.FileProvider.System )
    a.system = a.fileProvider;
  }

  if( !effectiveProvider )
  {
    if( !( a.fileProvider instanceof _.FileProvider.System ) )
    a.effectiveProvider = a.fileProvider;
    else if( a.fileProvider.defaultProvider )
    a.effectiveProvider = a.fileProvider.defaultProvider;
  }

  _.assert( a.effectiveProvider instanceof _.FileProvider.Abstract, 'effectiveProvider is not specificed' );

  if( !global )
  a.global = globalFor;

  return a;

  function globalFor()
  {
    let a = this;
    let abs = a.abs( ... arguments );
    let result = a.system.path.s.join( a.effectiveProvider.protocol + '://', abs );
    return result;
  }

}

// --
// tests
// --

function fileReadActSync( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let provider = _.FileProvider.Http(); // temporary, till fixed problem

  let ready = new _.Consequence().take( null );

  ready

  .then( () =>
  {
    test.case = 'encoding does not specified';
    var url = 'https://raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/package.json';
    var got = provider.fileRead({ filePath : url, sync : 1 });
    test.identical( _.strIs( got ), true );
    return null;
  })

  .then( () =>
  {
    test.case = 'encoding : utf8';
    var url = 'https://raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/package.json';
    var got = provider.fileRead({ filePath : url, encoding : 'utf8', sync : 1 });
    test.identical( _.strIs( got ), true );
    return null;
  })

  .then( () =>
  {
    test.case = 'file does not exist';
    var url = 'https://raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/nonexistentFile.json';
    var got = provider.fileRead({ filePath : url, sync : 1 });
    test.identical( _.strIs( got ), true );
    test.identical( got, '404: Not Found' );
    return null;
  })

  .then( () =>
  {
    test.case = 'wrong protocol';
    var url = 'hhttppss://raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/package.json';
    test.shouldThrowErrorSync( () =>
    {
      provider.fileRead({ filePath : url, sync : 1 });
    });
    return null;
  })

  return ready;
}

//

function fileReadActAsync( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let provider = _.FileProvider.Http(); // temporary, till fixed problem

  let ready = new _.Consequence().take( null );

  ready

  .then( () =>
  {
    test.case = 'encoding does not specified';
    var url = 'https://raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/package.json';
    return provider.fileRead({ filePath : url, sync : 0 });
  })
  .then( ( got ) =>
  {
    test.identical( _.strIs( got ), true );
    return null;
  })

  .then( () =>
  {
    test.case = 'encoding : utf8';
    var url = 'https://raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/package.json';
    return provider.fileRead({ filePath : url, encoding : 'utf8', sync : 0 });
  })
  .then( ( got ) =>
  {
    test.identical( _.strIs( got ), true );
    return null;
  })

  .then( () =>
  {
    test.case = 'file does not exist';
    var url = 'https://raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/nonexistentFile.json';
    return provider.fileRead({ filePath : url, sync : 0 });
  })
  .then( ( got ) =>
  {
    test.identical( _.strIs( got ), true );
    test.identical( got, '404: Not Found' );
    return null;
  })

  .then( () =>
  {
    test.case = 'wrong protocol';
    var url = 'hhttppss://raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/package.json';
    test.shouldThrowErrorSync( () =>
    {
      provider.fileRead({ filePath : url, sync : 1 });
    });
    return null;
  })

  return ready;
}

//

function fileCopyAct( test )
{
  let context = this;
  let a = context.assetFor( test, false );
  let provider = _.FileProvider.Http(); // temporary, till fixed problem

  test.case = 'initial case';
  a.reflect();
  var got = provider.fileCopyAct
  ({
    dstPath : a.abs( 'dst.json' ),
    srcPath : 'https://raw.githubusercontent.com/Wandalen/wModuleForTesting1/master/package.json',
    relativeDstPath : '',
    relativeSrcPath : '',
    sync : 1
  });
  test.identical( got, 'staging' );
}

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.files.fileProvider.Http',
  abstract : 0,
  silencing : 1,
  enabled : 1,
  verbosity : 4,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    assetFor,
    suiteTempPath : null,
    providerMake,
  },

  tests :
  {
    fileReadActSync,
    fileReadActAsync,

    fileCopyAct,
  },

}

//

var Self = new wTestSuite( Proto )
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();