( function _Path_test_ss_( ) {

'use strict'; /*eee*/

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }


  var _ = _global_.wTools;

  if( !_global_.wTools.FileProvider )
  require( '../files/UseTop.s' );
  var Path = require( 'path' );
  var Process = require( 'process' );

  _.include( 'wTesting' );

}

//

var _ = _global_.wTools;
var Parent = _.Tester;

//

function onSuiteBegin()
{
  this.isBrowser = typeof module === 'undefined';

  if( !this.isBrowser )
  this.testRootDirectory = _.dirTempMake( _.pathJoin( __dirname, '../..' ) );
  else
  this.testRootDirectory = _.pathCurrent();
}

//

function onSuiteEnd()
{
  if( !this.isBrowser )
  _.fileProvider.filesDelete( this.testRootDirectory );
}

// --
// routines
// --

function createTestsDirectory( path, rmIfExists )
{
  if( rmIfExists && _.fileProvider.fileStat( path ) )
  _.fileProvider.filesDelete( path );
  return _.fileProvider.directoryMake( path );
}

//

function createInTD( path )
{
  return this.createTestsDirectory( _.pathJoin( this.testRootDirectory, path ) );
}

//

function createTestFile( path, data, decoding )
{
  var dataToWrite = ( decoding === 'json' ) ? JSON.stringify( data ) : data;
  _.fileProvider.fileWrite({ filePath : _.pathJoin( this.testRootDirectory, path ), data : dataToWrite })
}

//

function createTestSymLink( path, target, type, data )
{
  var origin,
    typeOrigin;

  if( target === void 0 )
  {
    origin = Path.parse( path )
    origin.name = origin.name + '_orig';
    origin.base = origin.name + origin.ext;
    origin = Path.format( origin );
  }
  else
  {
    origin = target;
  }

  if( 'sf' === type )
  {
    typeOrigin = 'file';
    data = data || 'test origin';
    this.createTestFile( origin, data );
  }
  else if( 'sd' === type )
  {
    typeOrigin = 'dir';
    this.createInTD( origin );
  }
  else throw new Error( 'unexpected type' );

  path = _.pathJoin( this.testRootDirectory, path );
  origin = _.pathResolve( _.pathJoin( this.testRootDirectory, origin ) );

  if( _.fileProvider.fileStat( path ) )
  _.fileProvider.filesDelete( path );
  _.fileProvider.linkSoft( path, origin );
}

//

function createTestResources( cases, dir )
{
  if( !Array.isArray( cases ) ) cases = [ cases ];

  var l = cases.length,
    testCheck,
    paths;

  while ( l-- )
  {
    testCheck = cases[ l ];
    switch( testCheck.type )
    {
      case 'f' :
        paths = Array.isArray( testCheck.path ) ? testCheck.path : [ testCheck.path ];
        paths.forEach( ( path, i ) => {
          path = dir ? Path.join( dir, path ) : path;
          if( testCheck.createResource !== void 0 )
          {
            let res =
              ( Array.isArray( testCheck.createResource ) && testCheck.createResource[i] ) || testCheck.createResource;
            this.createTestFile( path, res );
          }
          this.createTestFile( path );
        } );
        break;

      case 'd' :
        paths = Array.isArray( testCheck.path ) ? testCheck.path : [ testCheck.path ];
        paths.forEach( ( path, i ) =>
        {
          path = dir ? Path.join( dir, path ) : path;
          this.createInTD( path );
          if ( testCheck.folderContent )
          {
            var res = Array.isArray( testCheck.folderContent ) ? testCheck.folderContent : [ testCheck.folderContent ];
            this.createTestResources( res, path );
          }
        } );
        break;

      case 'sd' :
      case 'sf' :
        let path, target;
        if( Array.isArray( testCheck.path ) )
        {
          path = dir ? Path.join( dir, testCheck.path[0] ) : testCheck.path[0];
          target = dir ? Path.join( dir, testCheck.path[1] ) : testCheck.path[1];
        }
        else
        {
          path = dir ? Path.join( dir, testCheck.path ) : testCheck.path;
          target = dir ? Path.join( dir, testCheck.linkTarget ) : testCheck.linkTarget;
        }
        this.createTestSymLink( path, target, testCheck.type, testCheck.createResource );
        break;
    }
  }
}

// --
// test
// --

function pathGet( test )
{
  var pathStr1 = '/foo/bar/baz',
      pathStr2 = 'tmp/pathGet/test.txt',
    expected = pathStr1,
    expected2 = _.pathResolve( _.pathJoin( test.context.testRootDirectory,pathStr2 ) ),
    got,
    fileRecord;

  test.context.createTestFile( pathStr2 );
  fileRecord = _.fileProvider.fileRecord( _.pathResolve( _.pathJoin( test.context.testRootDirectory,pathStr2 ) ) );

  test.case = 'string argument';
  got = _.pathGet( pathStr1 );
  test.identical( got, expected );

  test.case = 'file record argument';
  got = _.pathGet( fileRecord );
  test.identical( got, expected2 );

  if( Config.debug )
  {
    test.case = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.pathGet( );
    } );

    test.case = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.pathGet( 'temp/sample.txt', 'hello' );
    } );

    test.case = 'path is not string/or file record';
    test.shouldThrowErrorSync( function( )
    {
      _.pathGet( 3 );
    } );
  }
};

//

function pathForCopy( test )
{

  var defaults =
    {
      postfix : 'copy',
      srcPath : null
    },
    path1 = 'tmp/pathForCopy/test_original.txt',
    expected1 = { path :  _.pathResolve( _.pathJoin( test.context.testRootDirectory,'tmp/pathForCopy/test_original-copy.txt' ) ), error : false },
    path2 = 'tmp/pathForCopy/test_original2',
    expected2 = { path : _.pathResolve( _.pathJoin( test.context.testRootDirectory,'tmp/pathForCopy/test_original-backup-2.txt' ) ), error : false },
    got = { path : void 0, error : void 0 };

  test.context.createTestFile( path1 );
  test.context.createTestFile( path2 );

  test.case = 'simple existing file path';
  try
  {
    debugger
    got.path = _.pathForCopy( { path : _.pathResolve( _.pathJoin( test.context.testRootDirectory,path1 ) ) } );
  }
  catch( err )
  {
    _.errLogOnce( err )
    got.error = !!err;
  }
  got.error = !!got.error;
  test.identical( got, expected1 );

  test.case = 'generate names for several copies';
  try
  {
    var path_tmp = _.pathForCopy( { path : _.pathResolve( _.pathJoin( test.context.testRootDirectory,path1 ) ), postfix : 'backup' } );
    test.context.createTestFile( path_tmp );
    path_tmp = _.pathForCopy( { path : path_tmp, postfix : 'backup' } );
    test.context.createTestFile( path_tmp );
    got.path = _.pathForCopy( { path : path_tmp, postfix : 'backup' } );
  }
  catch( err )
  {
    _.errLogOnce( err )
    got.error = !!err;
  }
  got.error = !!got.error;
  test.identical( got, expected2 );


  if( Config.debug )
  {
    test.case = 'missed arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.pathForCopy( );
    } );

    test.case = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.pathForCopy( { srcPath : _.pathJoin( test.context.testRootDirectory,path1 ) }, { srcPath : _.pathJoin( test.context.testRootDirectory,path2 ) } );
    } );

    test.case = 'unexisting file';
    test.shouldThrowErrorSync( function( )
    {
      _.pathForCopy( { srcPath : 'temp/sample.txt' } );
    } );
  }

}

//

function pathResolve( test )
{

  var provider = _.fileProvider;

  test.case = 'join windows os paths';
  var paths = [ 'c:\\', 'foo\\', 'bar\\' ];
  var expected = '/c/foo/bar';
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  test.case = 'join unix os paths';
  var paths = [ '/bar/', '/baz', 'foo/', '.' ];
  var expected = '/baz/foo';
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  test.case = 'here cases'; /* */

  var paths = [ 'aa','.','cc' ];
  var expected = _.pathJoin( _.pathCurrent(), 'aa/cc' );
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  var paths = [  'aa','cc','.' ];
  var expected = _.pathJoin( _.pathCurrent(), 'aa/cc' );
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  var paths = [  '.','aa','cc' ];
  var expected = _.pathJoin( _.pathCurrent(), 'aa/cc' );
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  test.case = 'down cases'; /* */

  var paths = [  '.','aa','cc','..' ];
  var expected = _.pathJoin( _.pathCurrent(), 'aa' );
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  var paths = [  '.','aa','cc','..','..' ];
  var expected = _.pathCurrent();
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  console.log( '_.pathCurrent()',_.pathCurrent() );
  var paths = [  'aa','cc','..','..','..' ];
  var expected = _.strCutOffRight( _.pathCurrent(),'/' )[ 0 ];
  if( _.pathCurrent() === '/' )
  expected = '/..';
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  test.case = 'like-down or like-here cases'; /* */

  var paths = [  '.x.','aa','bb','.x.' ];
  var expected = _.pathJoin( _.pathCurrent(), '.x./aa/bb/.x.' );
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  var paths = [  '..x..','aa','bb','..x..' ];
  var expected = _.pathJoin( _.pathCurrent(), '..x../aa/bb/..x..' );
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  test.case = 'period and double period combined'; /* */

  var paths = [  '/abc','./../a/b' ];
  var expected = '/a/b';
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  var paths = [  '/abc','a/.././a/b' ];
  var expected = '/abc/a/b';
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  var paths = [  '/abc','.././a/b' ];
  var expected = '/a/b';
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  var paths = [  '/abc','./.././a/b' ];
  var expected = '/a/b';
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  var paths = [  '/abc','./../.' ];
  var expected = '/';
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  var paths = [  '/abc','./../../.' ];
  var expected = '/..';
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  var paths = [  '/abc','./../.' ];
  var expected = '/';
  var got = provider.pathResolve.apply( provider, paths );
  test.identical( got, expected );

  if( !Config.debug ) //
  return;

  test.case = 'nothing passed';
  test.shouldThrowErrorSync( function()
  {
    provider.pathResolve();
  });

  test.case = 'non string passed';
  test.shouldThrowErrorSync( function()
  {
    provider.pathResolve( {} );
  });
}

//

function pathsResolve( test )
{
  var provider = _.fileProvider;
  var current = _.pathCurrent();

  test.case = 'paths resolve';

  var got = provider.pathsResolve( 'c', [ '/a', 'b' ] );
  var expected = [ '/a', _.pathJoin( current, 'c/b' ) ];
  test.identical( got, expected );

  var got = provider.pathsResolve( [ '/a', '/b' ], [ '/a', '/b' ] );
  var expected = [ '/a', '/b' ];
  test.identical( got, expected );

  var got = provider.pathsResolve( '../a', [ 'b', '.c' ] );
  var expected = [ _.pathDir( current ) + '/a/b', _.pathDir( current ) + '/a/.c' ]
  test.identical( got, expected );

  var got = provider.pathsResolve( '../a', [ '/b', '.c' ], './d' );
  var expected = [ '/b/d', _.pathDir( current ) + '/a/.c/d' ];
  test.identical( got, expected );

  var got = provider.pathsResolve( [ '/a', '/a' ],[ 'b', 'c' ] );
  var expected = [ '/a/b' , '/a/c' ];
  test.identical( got, expected );

  var got = provider.pathsResolve( [ '/a', '/a' ],[ 'b', 'c' ], 'e' );
  var expected = [ '/a/b/e' , '/a/c/e' ];
  test.identical( got, expected );

  var got = provider.pathsResolve( [ '/a', '/a' ],[ 'b', 'c' ], '/e' );
  var expected = [ '/e' , '/e' ];
  test.identical( got, expected );

  var got = provider.pathsResolve( '.', '../', './', [ 'a', 'b' ] );
  var expected = [ _.pathDir( current ) + '/a', _.pathDir( current ) + '/b' ];
  test.identical( got, expected );

  //

  test.case = 'works like pathResolve';

  var got = provider.pathsResolve( '/a', 'b', 'c' );
  var expected = provider.pathResolve( '/a', 'b', 'c' );
  test.identical( got, expected );

  var got = provider.pathsResolve( '/a', 'b', 'c' );
  var expected = provider.pathResolve( '/a', 'b', 'c' );
  test.identical( got, expected );

  var got = provider.pathsResolve( '../a', '.c' );
  var expected = provider.pathResolve( '../a', '.c' );
  test.identical( got, expected );

  var got = provider.pathsResolve( '/a' );
  var expected = provider.pathResolve( '/a' );
  test.identical( got, expected );

  //

  test.case = 'scalar + array with single argument'

  var got = provider.pathsResolve( '/a', [ 'b/..' ] );
  var expected = [ '/a' ];
  test.identical( got, expected );

  test.case = 'array + array with single arguments'

  var got = provider.pathsResolve( [ '/a' ], [ 'b/../' ] );
  var expected = [ '/a' ];
  test.identical( got, expected );

  //

  if( !Config.debug )
  return

  test.case = 'arrays with different length'
  test.shouldThrowError( function()
  {
    provider.pathsResolve( [ '/b', '.c' ], [ '/b' ] );
  });

  test.shouldThrowError( function()
  {
    provider.pathsResolve( [ '/a' , '/a' ] );
  });

  test.shouldThrowError( function()
  {
    provider.pathsResolve();
  });

  test.case = 'inner arrays'
  test.shouldThrowError( function()
  {
    provider.pathsResolve( [ '/b', '.c' ], [ '/b', [ 'x' ] ] );
  });
}

//

function regexpMakeSafe( test )
{

  test.case = 'only default safe paths'; /* */
  var expected1 =
  {
    includeAny : [],
    includeAll : [],
    excludeAny :
    [
      /node_modules/,
      // /\.unique/,
      // /\.git/,
      // /\.svn/,
      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-/,
    ],
    excludeAll : []
  };
  var got = _.regexpMakeSafe();
  // logger.log( 'got',_.toStr( got,{ levels : 3 } ) );
  // logger.log( 'expected1',_.toStr( expected1,{ levels : 3 } ) );
  test.contains( got, expected1 );

  test.case = 'single path for include any mask'; /* */
  var path2 = 'foo/bar';
  var expected2 =
  {
    includeAny : [ /foo\/bar/ ],
    includeAll : [],
    excludeAny :
    [
      /node_modules/,
      // /\.unique/,
      // /\.git/,
      // /\.svn/,
      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-/,
    ],
    excludeAll : []
  };
  var got = _.regexpMakeSafe( path2 );
  test.contains( got, expected2 );

  test.case = 'array of paths for include any mask'; /* */
  var path3 = [ 'foo/bar', 'foo2/bar2/baz', 'some.txt' ];
  var expected3 =
  {
    includeAny : [ /foo\/bar/, /foo2\/bar2\/baz/, /some\.txt/ ],
    includeAll : [],
    excludeAny : [
      /node_modules/,
      // /\.unique/,
      // /\.git/,
      // /\.svn/,
      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-/,
    ],
    excludeAll : []
  };
  var got = _.regexpMakeSafe( path3 );
  test.contains( got, expected3 );

  test.case = 'regex object passed as mask for include any mask'; /* */
  var paths4 =
  {
    includeAny : [ 'foo/bar', 'foo2/bar2/baz', 'some.txt' ],
    includeAll : [ 'index.js' ],
    excludeAny : [ 'aa.js', 'bb.js' ],
    excludeAll : [ 'package.json', 'bower.json' ]
  };
  var expected4 =
  {
    includeAny : [ /foo\/bar/, /foo2\/bar2\/baz/, /some\.txt/ ],
    includeAll : [ /index\.js/ ],
    excludeAny :
    [
      /aa\.js/,
      /bb\.js/,
      /node_modules/,
      // /\.unique/,
      // /\.git/,
      // /\.svn/,
      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-/,
    ],
    excludeAll : [ /package\.json/, /bower\.json/ ]
  };
  var got = _.regexpMakeSafe( paths4 );
  test.contains( got, expected4 );

  if( Config.debug ) //
  {
    test.case = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.regexpMakeSafe( 'package.json', 'bower.json' );
    });
  }

}

//

function pathRealMainFile( test )
{
  if( require.main === module )
  var expected1 = __filename;
  else
  var expected1 = require.main.filename;

  test.case = 'compare with __filename path for main file';
  var got = _.fileProvider.pathNativize( _.pathRealMainFile( ) );
  test.identical( got, expected1 );
};

//

function pathRealMainDir( test )
{

  if( require.main === module )
  var file = __filename;
  else
  var file = require.main.filename;

  var expected1 = _.pathDir( file );

  test.case = 'compare with __filename path dir';
  var got = _.fileProvider.pathNativize( _.pathRealMainDir( ) );
  test.identical( _.pathNormalize( got ), _.pathNormalize( expected1 ) );

  test.case = 'absolute pathes'; /* */
  var pathFrom = _.pathRealMainDir();
  var pathTo = _.pathRealMainFile();
  var expected = _.pathName({ path : _.pathRealMainFile(), withExtension : 1 });
  var got = _.pathRelative( pathFrom, pathTo );
  test.identical( got, expected );

  test.case = 'absolute pathes, pathFrom === pathTo'; /* */
  var pathFrom = _.pathRealMainDir();
  var pathTo = _.pathRealMainDir();
  var expected = '.';
  var got = _.pathRelative( pathFrom, pathTo );
  test.identical( got, expected );

}

//

function pathEffectiveMainFile( test )
{
  if( require.main === module )
  var expected1 = __filename;
  else
  var expected1 = process.argv[ 1 ];

  test.case = 'compare with __filename path for main file';
  var got = _.fileProvider.pathNativize( _.pathEffectiveMainFile( ) );
  test.identical( got, expected1 );

  if( Config.debug )
  {
    test.case = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.pathEffectiveMainFile( 'package.json' );
    } );
  }
};

//

function pathEffectiveMainDir( test )
{
  if( require.main === module )
  var file = __filename;
  else
  var file = process.argv[ 1 ];

  var expected1 = _.pathDir( file );

  test.case = 'compare with __filename path dir';
  var got = _.fileProvider.pathNativize( _.pathEffectiveMainDir( ) );
  test.identical( _.pathNormalize( got ), _.pathNormalize( expected1 ) );

  if( Config.debug )
  {
    test.case = 'extra arguments';
    test.shouldThrowErrorSync( function( )
    {
      _.pathEffectiveMainDir( 'package.json' );
    } );
  }
};

//

function pathCurrent( test )
{
  var path1 = 'tmp/pathCurrent/foo',
    expected = Process.cwd( ),
    expected1 = _.fileProvider.pathNativize( _.pathResolve( _.pathJoin( test.context.testRootDirectory,path1 ) ) );

  test.case = 'get current working directory';
  var got = _.fileProvider.pathNativize( _.pathCurrent( ) );
  test.identical( got, expected );

  test.case = 'set new current working directory';
  test.context.createInTD( path1 );
  var pathBefore = _.pathCurrent();
  _.pathCurrent( _.pathNormalize( _.pathJoin( test.context.testRootDirectory,path1 ) ) );
  var got = Process.cwd( );
  _.pathCurrent( pathBefore );
  test.identical( got, expected1 );

  if( !Config.debug )
  return;

  test.case = 'extra arguments';
  test.shouldThrowErrorSync( function( )
  {
    _.pathCurrent( 'tmp/pathCurrent/foo', 'tmp/pathCurrent/foo' );
  } );

  test.case = 'unexist directory';
  test.shouldThrowErrorSync( function( )
  {
    _.pathCurrent( _.pathJoin( test.context.testRootDirectory, 'tmp/pathCurrent/bar' ) );
  });

}

//

function pathCurrent2( test )
{
  var got, expected;

  test.case = 'get current working dir';

  if( test.context.isBrowser )
  {
    /*default*/

    got = _.pathCurrent();
    expected = '.';
    test.identical( got, expected );

    /*incorrect arguments count*/

    test.shouldThrowErrorSync( function()
    {
      _.pathCurrent( 0 );
    })

  }
  else
  {
    /*default*/

    if( _.fileProvider )
    {

      got = _.pathCurrent();
      expected = _.pathNormalize( process.cwd() );
      test.identical( got,expected );

      /*empty string*/

      expected = _.pathNormalize( process.cwd() );
      got = _.pathCurrent( '' );
      test.identical( got,expected );

      /*changing cwd*/

      got = _.pathCurrent( './staging' );
      expected = _.pathNormalize( process.cwd() );
      test.identical( got,expected );

      /*try change cwd to terminal file*/

      // got = _.pathCurrent( './dwtools/amid/files/base/Path.ss' );
      got = _.pathCurrent( _.pathNormalize( __filename ) );
      expected = _.pathNormalize( process.cwd() );
      test.identical( got,expected );

    }

    /*incorrect path*/

    test.shouldThrowErrorSync( function()
    {
      got = _.pathCurrent( './incorrect_path' );
      expected = _.pathNormalize( process.cwd() );
      test.identical( got,expected );
    });

    if( Config.debug )
    {
      /*incorrect arguments length*/

      test.shouldThrowErrorSync( function()
      {
        _.pathCurrent( '.', '.' );
      })

      /*incorrect argument type*/

      test.shouldThrowErrorSync( function()
      {
        _.pathCurrent( 123 );
      })
    }

  }

}

//

function pathRelative( test )
{
  test.case = 'path and record';

  var pathFrom = _.fileProvider.fileRecord( _.pathCurrent() );
  var pathTo = _.pathDir( _.pathCurrent() );
  var expected = '..';
  var got = _.pathRelative( pathFrom, pathTo );
  test.identical( got, expected );

  var pathFrom = _.fileProvider.fileRecord( _.pathCurrent() );
  var pathTo = _.pathJoin( _.pathDir( _.pathCurrent() ), 'a' )
  var expected = '../a';
  var got = _.pathRelative( pathFrom, pathTo );
  test.identical( got, expected );

  var pathFrom = _.pathDir( _.pathCurrent() );
  var pathTo = _.fileProvider.fileRecord( _.pathCurrent() );
  var expected = _.pathName({ path : pathTo.absolute, withExtension : 1 });
  var got = _.pathRelative( pathFrom, pathTo );
  test.identical( got, expected );

  var pathFrom = _.fileProvider.fileRecord( _.pathCurrent() );
  var pathTo = _.fileProvider.fileRecord( _.pathDir( _.pathCurrent() ) );
  var expected = '..';
  var got = _.pathRelative( pathFrom, pathTo );
  test.identical( got, expected );

  _.fileProvider.fieldSet( 'safe', 0 );

  var pathFrom = _.fileProvider.fileRecord( '/a/b/c');
  var pathTo = _.fileProvider.fileRecord( '/a' );
  var expected = '../..';
  var got = _.pathRelative( pathFrom, pathTo );
  test.identical( got, expected );

  var pathFrom = _.fileProvider.fileRecord( '/a/b/c' );
  var pathTo = '/a'
  var expected = '../..';
  var got = _.pathRelative( pathFrom, pathTo );
  test.identical( got, expected );

  var pathFrom = '/a'
  var pathTo = _.fileProvider.fileRecord( '/a/b/c' );
  var expected = 'b/c';
  var got = _.pathRelative( pathFrom, pathTo );
  test.identical( got, expected );

  test.case = 'both relative, long, not direct, resolving : 1'; /* */
  var pathFrom = 'a/b/xx/yy/zz';
  var pathTo = 'a/b/files/x/y/z.txt';
  var expected = '../../../files/x/y/z.txt';
  var got = _.pathRelative({ relative : pathFrom, path : pathTo, resolving : 1 });
  test.identical( got, expected );

  test.case = 'both relative, long, not direct,resolving 1'; /* */
  var pathFrom = 'a/b/xx/yy/zz';
  var pathTo = 'a/b/files/x/y/z.txt';
  var expected = '../../../files/x/y/z.txt';
  var o =
  {
    relative :  pathFrom,
    path : pathTo,
    resolving : 1
  }
  var got = _.pathsRelative( o );
  test.identical( got, expected );

  _.fileProvider.fieldReset( 'safe', 0 );
}

// --
// define class
// --

var Self =
{

  name : 'Tools/mid/files/Paths',
  silencing : 1,

  onSuiteBegin : onSuiteBegin,
  onSuiteEnd : onSuiteEnd,

  context :
  {
    testRootDirectory : null,
    isBrowser : null,

    createTestsDirectory : createTestsDirectory,
    createInTD : createInTD,
    createTestFile : createTestFile,
    createTestSymLink : createTestSymLink,
    createTestResources : createTestResources
  },

  tests :
  {

    pathGet : pathGet,
    pathForCopy : pathForCopy,

    pathResolve : pathResolve,
    pathsResolve : pathsResolve,

    regexpMakeSafe : regexpMakeSafe,

    pathRealMainFile : pathRealMainFile,
    pathRealMainDir : pathRealMainDir,
    pathEffectiveMainFile : pathEffectiveMainFile,
    pathEffectiveMainDir : pathEffectiveMainDir,

    pathCurrent : pathCurrent,
    pathCurrent2 : pathCurrent2,

    pathRelative : pathRelative

  },

}

//

Self = wTestSuite( Self )
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );