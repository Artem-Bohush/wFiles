( function _FileProvider_Git_test_ss_( ) {

'use strict'; 

if( typeof module !== 'undefined' )
{
  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );
  
  try
  {
    require( 'gitconfiglocal' )
  }
  catch( err )
  { 
    return;
  }

  require( '../files/UseTop.s' );
}

//

var _ = _global_.wTools;

//

function onSuiteBegin( test )
{
  let context = this;

  context.providerSrc = _.FileProvider.Git();
  context.providerDst = _.FileProvider.HardDrive();
  context.hub = _.FileProvider.Hub({ providers : [ context.providerSrc, context.providerDst ] });
  context.hub.defaultProvider = context.providerDst;

  let path = context.providerDst.path;

  context.testSuitePath = path.dirTempOpen( 'FileProviderGit' );
  context.testSuitePath = context.providerDst.pathResolveLinkFull({ filePath : context.testSuitePath, resolvingSoftLink : 1 });
}

function onSuiteEnd( test )
{
  let context = this;
  let path = context.providerDst.path;
  _.assert( _.strHas( context.testSuitePath, 'FileProviderGit' ) );
  path.dirTempClose( context.testSuitePath );
}

// --
// tests
// --

function filesReflectTrivial( test )
{ 
  let context = this;
  let providerSrc = context.providerSrc;
  let providerDst = context.providerDst;
  let hub = context.hub;
  let path = context.providerDst.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );
  let localPath = path.join( testPath, 'wPathFundamentals' );
  let clonePathGlobal = providerDst.path.globalFromLocal( localPath );

  let con = new _.Consequence().take( null )

  .thenKeep( () =>
  {
    test.case = 'no hash, no trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git';
    return hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      includingTerminals : 1,
      includingDirs : 1,
      outputFormat : 'relative',
      recursive : 2
    });

    let expected =
    [
      '.',
      './appveyor.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './out',
      './out/wPathFundamentals.out.will.yml',
      './out/debug',
      './proto',
      './sample'
    ]

    test.is( _.arraySetContainAll( files, expected ) )
    return got;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'no hash, trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git/';
    return hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      includingTerminals : 1,
      includingDirs : 1,
      outputFormat : 'relative',
      recursive : 2
    });

    let expected =
    [
      '.',
      './appveyor.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './out',
      './out/wPathFundamentals.out.will.yml',
      './out/debug',
      './proto',
      './sample'
    ]

    test.is( _.arraySetContainAll( files, expected ) )
    return got;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'hash, no trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git#master';
    return hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      includingTerminals : 1,
      includingDirs : 1,
      outputFormat : 'relative',
      recursive : 2
    });

    let expected =
    [
      '.',
      './appveyor.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './out',
      './out/wPathFundamentals.out.will.yml',
      './out/debug',
      './proto',
      './sample'
    ]

    test.is( _.arraySetContainAll( files, expected ) )
    return got;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'not existing repository';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///DoesNotExist.git';
    let result = hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
    return test.shouldThrowErrorAsync( result );
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      includingTerminals : 1,
      includingDirs : 1,
      outputFormat : 'relative',
      recursive : 2
    });

    test.identical( files, [ '.' ] );
    return got;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'reflect twice in a row';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git#master';
    let o = { reflectMap : { [ remotePath ] : clonePathGlobal }};

    let ready = new _.Consequence().take( null );
    ready.then( () => hub.filesReflect( _.mapExtend( null, o ) ) )
    ready.then( () => hub.filesReflect( _.mapExtend( null, o ) ) )

    return ready;
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      includingTerminals : 1,
      includingDirs : 1,
      outputFormat : 'relative',
      recursive : 2
    });

    let expected =
    [
      '.',
      './appveyor.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './out',
      './out/wPathFundamentals.out.will.yml',
      './out/debug',
      './proto',
      './sample'
    ]

    test.is( _.arraySetContainAll( files, expected ) )
    return got;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'reflect twice in a row, fetching off';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git#master';
    let o =
    {
      reflectMap : { [ remotePath ] : clonePathGlobal },
      extra : { fetching : false }
    };

    let ready = new _.Consequence().take( null );
    ready.then( () => hub.filesReflect( _.mapExtend( null, o ) ) )
    ready.then( () => hub.filesReflect( _.mapExtend( null, o ) ) )

    return ready;
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      includingTerminals : 1,
      includingDirs : 1,
      outputFormat : 'relative',
      recursive : 2
    });

    let expected =
    [
      '.',
      './appveyor.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './out',
      './out/wPathFundamentals.out.will.yml',
      './out/debug',
      './proto',
      './sample'
    ]

    test.is( _.arraySetContainAll( files, expected ) )
    return got;
  })

  /*  */

  .thenKeep( () =>
  {
    test.case = 'commit hash, no trailing /';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git#05930d3a7964b253ea3bbfeca7eb86848f550e96';
    return hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }});
  })
  .thenKeep( ( got ) =>
  {
    let files = providerDst.filesFind
    ({
      filePath : localPath,
      includingTerminals : 1,
      includingDirs : 1,
      outputFormat : 'relative',
      recursive : 2
    });

    let expected =
    [
      '.',
      './appveyor.yml',
      './LICENSE',
      './package.json',
      './README.md',
      './out',
      './out/wPathFundamentals.out.will.yml',
      './out/debug',
      './proto',
      './sample'
    ]

    test.is( _.arraySetContainAll( files, expected ) )
    let packagePath = providerDst.path.join( localPath, 'package.json' );
    let packageRead = providerDst.fileRead
    ({
      filePath : packagePath,
      encoding : 'json'
    });
    test.identical( packageRead.version, '0.6.157' );
    return got;
  })
  
  /*  */

  .thenKeep( () =>
  {
    test.case = 'local is behind remote';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git';
    
    let ready = hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });
    
    _.shell
    ({
      execPath : 'git reset --hard HEAD~1',
      currentPath : localPath,
      ready : ready
    })
    
    ready.then( () => hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 }) );
    
    _.shell
    ({
      execPath : 'git status',
      currentPath : localPath,
      ready : ready,
      outputCollecting : 1
    })
    
    ready.then( ( got ) => 
    { 
      test.identical( got.exitCode, 0 );
      test.is( _.strHas( got.output, `Your branch is up to date with 'origin/master'.` ) ) 
      return null;
    })
    
    return ready;
  })
  
  /*  */

  .thenKeep( () =>
  {
    test.case = 'local has new commit, remote up to date, no merge required';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git';
    
    let ready = hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });
    
    _.shell
    ({
      execPath : 'git commit --allow-empty -m emptycommit',
      currentPath : localPath,
      ready : ready
    })
    
    ready.then( () => hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 }) );
    
    _.shell
    ({
      execPath : 'git status',
      currentPath : localPath,
      ready : ready,
      outputCollecting : 1
    })
    
    ready.then( ( got ) => 
    { 
      test.identical( got.exitCode, 0 );
      test.is( _.strHas( got.output, `Your branch is ahead of 'origin/master' by 1 commit` ) ) 
      return null;
    })
    
    _.shell
    ({
      execPath : 'git log -n 2',
      currentPath : localPath,
      ready : ready,
      outputCollecting : 1
    })
    
    ready.then( ( got ) => 
    { 
      test.identical( got.exitCode, 0 );
      test.is( !_.strHas( got.output, `Merge remote-tracking branch 'refs/remotes/origin/master'` ) ) 
      test.is( _.strHas( got.output, `emptycommit` ) ) 
      return null;
    })
    
    return ready;
  })
  
  /*  */

  .thenKeep( () =>
  {
    test.case = 'local and remote have one new commit, should be merged';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git';
    
    let ready = hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });
    
    _.shell
    ({
      execPath : 'git reset --hard HEAD~1',
      currentPath : localPath,
      ready : ready
    })
    
    _.shell
    ({
      execPath : 'git commit --allow-empty -m emptycommit',
      currentPath : localPath,
      ready : ready
    })
    
    ready.then( () => hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 }) );
    
    _.shell
    ({
      execPath : 'git status',
      currentPath : localPath,
      ready : ready,
      outputCollecting : 1
    })
    
    ready.then( ( got ) => 
    { 
      test.identical( got.exitCode, 0 );
      test.is( _.strHas( got.output, `Your branch is ahead of 'origin/master' by 2 commits` ) ) 
      return null;
    })
    
    _.shell
    ({
      execPath : 'git log -n 2',
      currentPath : localPath,
      ready : ready,
      outputCollecting : 1
    })
    
    ready.then( ( got ) => 
    { 
      test.identical( got.exitCode, 0 );
      test.is( _.strHas( got.output, `Merge remote-tracking branch 'refs/remotes/origin/master'` ) ) 
      test.is( _.strHas( got.output, `emptycommit` ) ) 
      return null;
    })
    
    return ready;
  })
  
  /*  */

  .thenKeep( () =>
  {
    test.case = 'local version is fixate and has local commit, update to latest';
    providerDst.filesDelete( localPath );
    let remotePathFixate = 'git+https:///github.com/Wandalen/wPathFundamentals.git#05930d3a7964b253ea3bbfeca7eb86848f550e96';
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git';
    
    let ready = hub.filesReflect({ reflectMap : { [ remotePathFixate ] : clonePathGlobal }, verbosity : 5 });
    
    _.shell
    ({
      execPath : 'git commit --allow-empty -m emptycommit',
      currentPath : localPath,
      ready : ready
    })
    
    ready.then( () => hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 }) );
    
    _.shell
    ({
      execPath : 'git status',
      currentPath : localPath,
      ready : ready,
      outputCollecting : 1
    })
    
    ready.then( ( got ) => 
    { 
      test.identical( got.exitCode, 0 );
      test.is( _.strHas( got.output, `Your branch is up to date with 'origin/master'.` ) ) 
      return null;
    })
    
    return ready;
  })
  
  /*  */

  .thenKeep( () =>
  {
    test.case = 'local has fixed version, update to latest';
    providerDst.filesDelete( localPath );
    let remotePathFixate = 'git+https:///github.com/Wandalen/wPathFundamentals.git#05930d3a7964b253ea3bbfeca7eb86848f550e96';
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git';
    
    let ready = hub.filesReflect({ reflectMap : { [ remotePathFixate ] : clonePathGlobal }, verbosity : 5 });
    
    ready.then( () => hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 }) );
    
    _.shell
    ({
      execPath : 'git status',
      currentPath : localPath,
      ready : ready,
      outputCollecting : 1
    })
    
    ready.then( ( got ) => 
    { 
      test.identical( got.exitCode, 0 );
      test.is( _.strHas( got.output, `Your branch is up to date with 'origin/master'.` ) ) 
      return null;
    })
    
    return ready;
  })

  return con;
}

filesReflectTrivial.timeOut = 60000;

//

function isUpToDate( test )
{
  let context = this;
  let providerSrc = context.providerSrc;
  let providerDst = context.providerDst;
  let hub = context.hub;
  let path = context.providerDst.path;
  let testPath = path.join( context.testSuitePath, 'routine-' + test.name );
  let localPath = path.join( testPath, 'wPathFundamentals' );
  let clonePathGlobal = providerDst.path.globalFromLocal( localPath );

  let con = new _.Consequence().take( null )
  
  .then( () => 
  { 
    test.open( 'local master' );
    test.case = 'setup';
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git';
    providerDst.filesDelete( localPath );
    return hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }}); 
  })
  
  .then( () => 
  { 
    test.case = 'remote master';
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git';
    return providerSrc.isUpToDate({ localPath : localPath, remotePath : remotePath })
    .then( ( got ) => 
    {
      test.identical( got, true );
      return got;
    })
  })
  
  .then( () => 
  { 
    test.case = 'remote has different branch';
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git#other';
    return providerSrc.isUpToDate({ localPath : localPath, remotePath : remotePath })
    .then( ( got ) => 
    {
      test.identical( got, false );
      return got;
    })
  })
  
  .then( () => 
  { 
    test.case = 'remote has fixed version';
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git#c94e0130358ba54fc47237e15bac1ab18024c0a9';
    return providerSrc.isUpToDate({ localPath : localPath, remotePath : remotePath })
    .then( ( got ) => 
    { 
      test.identical( got, false );
      return got;
    })
  })
  
  .then( () => 
  {
    test.close( 'local master' );
    return null;
  })
  
  /**/
  
  .then( () => 
  { 
    test.open( 'local detached' );
    test.case = 'setup';
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git#c94e0130358ba54fc47237e15bac1ab18024c0a9';
    providerDst.filesDelete( localPath );
    return hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }}); 
  })
  
  .then( () => 
  { 
    test.case = 'remote has same fixed version';
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git#c94e0130358ba54fc47237e15bac1ab18024c0a9';
    return providerSrc.isUpToDate({ localPath : localPath, remotePath : remotePath })
    .then( ( got ) => 
    { 
      test.identical( got, true );
      return got;
    })
  })
  
  .then( () => 
  { 
    test.case = 'remote has other fixed version';
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git#469a6497f616cf18639b2aa68957f4dab78b7965';
    return providerSrc.isUpToDate({ localPath : localPath, remotePath : remotePath })
    .then( ( got ) => 
    { 
      test.identical( got, false );
      return got;
    })
  })
  
  .then( () => 
  { 
    test.case = 'remote has other branch';
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git#other';
    return providerSrc.isUpToDate({ localPath : localPath, remotePath : remotePath })
    .then( ( got ) => 
    { 
      test.identical( got, false );
      return got;
    })
  })
  
  .then( () => 
  {
    test.close( 'local detached' );
    return null;
  })
  
  /**/
  
  .then( () => 
  {
    test.case = 'local is behind remote';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git';
    
    let ready = hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });
    
    _.shell
    ({
      execPath : 'git reset --hard HEAD~1',
      currentPath : localPath,
      ready : ready
    })
    
    ready
    .then( () => providerSrc.isUpToDate({ localPath : localPath, remotePath : remotePath }) )
    .then( ( got ) => 
    { 
      test.identical( got, false );
      return got;
    })
    
    return ready;
  })
  
  .then( () => 
  {
    test.case = 'local is ahead remote';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git';
    
    let ready = hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });
    
    _.shell
    ({
      execPath : 'git commit --allow-empty -m emptycommit',
      currentPath : localPath,
      ready : ready
    })
    
    ready
    .then( () => providerSrc.isUpToDate({ localPath : localPath, remotePath : remotePath }) )
    .then( ( got ) => 
    { 
      test.identical( got, true );
      return got;
    })
    
    return ready;
  })
  
  .then( () => 
  {
    test.case = 'local and remote have new commit';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git';
    
    let ready = hub.filesReflect({ reflectMap : { [ remotePath ] : clonePathGlobal }, verbosity : 5 });
    
    _.shell
    ({
      execPath : 'git reset --hard HEAD~1',
      currentPath : localPath,
      ready : ready
    })
    
    _.shell
    ({
      execPath : 'git commit --allow-empty -m emptycommit',
      currentPath : localPath,
      ready : ready
    })
    
    ready
    .then( () => providerSrc.isUpToDate({ localPath : localPath, remotePath : remotePath }) )
    .then( ( got ) => 
    { 
      test.identical( got, false );
      return got;
    })
    
    return ready;
  })
  
  .then( () => 
  {
    test.case = 'local is detached and has local commit';
    providerDst.filesDelete( localPath );
    let remotePath = 'git+https:///github.com/Wandalen/wPathFundamentals.git';
    let remotePathFixate = 'git+https:///github.com/Wandalen/wPathFundamentals.git#05930d3a7964b253ea3bbfeca7eb86848f550e96';
    
    let ready = hub.filesReflect({ reflectMap : { [ remotePathFixate ] : clonePathGlobal }, verbosity : 5 });
    
    _.shell
    ({
      execPath : 'git commit --allow-empty -m emptycommit',
      currentPath : localPath,
      ready : ready
    })
    
    ready
    .then( () => providerSrc.isUpToDate({ localPath : localPath, remotePath : remotePath }) )
    .then( ( got ) => 
    { 
      test.identical( got, false );
      return got;
    })
    
    return ready;
  })
  
  return con;
}

isUpToDate.timeOut = 30000;

// --
// declare
// --

var Proto =
{

  name : 'Tools/mid/files/fileProvider/Git',
  abstract : 0,
  silencing : 1,
  enabled : 1,
  verbosity : 4,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    testSuitePath : null,
    providerSrc : null,
    providerDst : null,
    hub : null
  },

  tests :
  {
    filesReflectTrivial : filesReflectTrivial,
    isUpToDate : isUpToDate,
  },

}

//

var Self = new wTestSuite( Proto )/* .inherit( Parent ); */
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
