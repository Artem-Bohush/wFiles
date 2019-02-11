( function _FileRecordFilter_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' );

}

//

let _global = _global_;
let _ = _global_.wTools;
let Parent = null;
let Self = function wFileRecordFilter( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'FileRecordFilter';

_.assert( !_.FileRecordFilter );
_.assert( !!_.regexpsEscape );

// --
//
// --

function init( o )
{
  let filter = this;

  _.instanceInit( filter );
  Object.preventExtensions( filter );

  if( o )
  filter.copy( o );

  filter._formAssociations();

  return filter;
}

//

function TollerantFrom( o )
{
  _.assert( arguments.length >= 1, 'Expects at least one argument' );
  _.assert( _.objectIs( Self.prototype.Composes ) );
  o = _.mapsExtend( null, arguments );
  return new Self( _.mapOnly( o, Self.prototype.fieldsOfCopyableGroups ) );
}

// --
// former
// --

function form()
{
  let filter = this;
  _.assert( filter.formed <= 3 );

  filter._formAssociations();
  filter._formFinal();

  _.assert( filter.formed === 5 );
  Object.freeze( filter );
  return filter;
}

//

function _formAssociations()
{
  let filter = this;

  /* */

  if( filter.hubFileProvider )
  {
    if( filter.hubFileProvider.hub && filter.hubFileProvider.hub !== filter.hubFileProvider )
    {
      _.assert( filter.effectiveFileProvider === null || filter.effectiveFileProvider === filter.hubFileProvider );
      filter.effectiveFileProvider = filter.hubFileProvider;
      filter.hubFileProvider = filter.hubFileProvider.hub;
    }
  }

  if( filter.effectiveFileProvider )
  {
    if( filter.effectiveFileProvider instanceof _.FileProvider.Hub )
    {
      _.assert( filter.hubFileProvider === null || filter.hubFileProvider === filter.effectiveFileProvider );
      filter.hubFileProvider = filter.effectiveFileProvider;
      filter.effectiveFileProvider = null;
    }
  }

  if( filter.effectiveFileProvider && filter.effectiveFileProvider.hub )
  {
    _.assert( filter.hubFileProvider === null || filter.hubFileProvider === filter.effectiveFileProvider.hub );
    filter.hubFileProvider = filter.effectiveFileProvider.hub;
  }

  if( !filter.defaultFileProvider )
  {
    filter.defaultFileProvider = filter.defaultFileProvider || filter.effectiveFileProvider || filter.hubFileProvider;
  }

  /* */

  _.assert( !filter.hubFileProvider || filter.hubFileProvider instanceof _.FileProvider.Abstract, 'Expects {- filter.hubFileProvider -}' );
  _.assert( filter.defaultFileProvider instanceof _.FileProvider.Abstract );
  _.assert( !filter.effectiveFileProvider || !( filter.effectiveFileProvider instanceof _.FileProvider.Hub ) );

  /* */

  filter.maskAll = _.RegexpObject( filter.maskAll );
  filter.maskTerminal = _.RegexpObject( filter.maskTerminal );
  filter.maskDirectory = _.RegexpObject( filter.maskDirectory );
  filter.maskTransientAll = _.RegexpObject( filter.maskTransientAll );
  filter.maskTransientTerminal = _.RegexpObject( filter.maskTransientTerminal );
  filter.maskTransientDirectory = _.RegexpObject( filter.maskTransientDirectory );

  /* */

  filter.formed = 1;
}

//

function _formFixes()
{
  let filter = this;

  if( filter.formed < 1 )
  filter._formAssociations();

  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( filter.formed === 1 );
  _.assert( filter.prefixPath === null || _.strIs( filter.prefixPath ) || _.arrayIs( filter.prefixPath ) );
  _.assert( filter.postfixPath === null || _.strIs( filter.postfixPath ) || _.arrayIs( filter.postfixPath ) );
  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );

  filter.formed = 2;
}

//

function _formBasePath()
{
  let filter = this;

  if( filter.formed === 3 )
  return;
  if( filter.formed < 2 )
  filter._formFixes();

  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( _.objectIs( filter ) );
  _.assert( filter.formed === 2 );

  // if( filter.src )
  // debugger;

  filter.prefixesApply();
  filter.pathsNormalize();

  // if( filter.src )
  // debugger;

  filter.formed = 3;
}

//

function _formMasks()
{
  let filter = this;

  if( filter.formed < 3 )
  filter._formBasePath();

  let fileProvider = filter.effectiveFileProvider || filter.defaultFileProvider || filter.hubFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( filter.formed === 3 );

  /* */

  if( filter.hasExtension )
  {
    _.assert( _.strIs( filter.hasExtension ) || _.strsAreAll( filter.hasExtension ) );

    filter.hasExtension = _.arrayAs( filter.hasExtension );
    filter.hasExtension = new RegExp( '^.*\\.(' + _.regexpsEscape( filter.hasExtension ).join( '|' ) + ')(\\.|$)(?!.*\/.+)', 'i' );

    filter.maskAll = _.RegexpObject.And( filter.maskAll,{ includeAll : filter.hasExtension } );
    filter.hasExtension = null;
  }

  if( filter.begins )
  {
    _.assert( _.strIs( filter.begins ) || _.strsAreAll( filter.begins ) );

    filter.begins = _.arrayAs( filter.begins );
    filter.begins = new RegExp( '^(\\.\\/)?(' + _.regexpsEscape( filter.begins ).join( '|' ) + ')' );

    filter.maskAll = _.RegexpObject.And( filter.maskAll,{ includeAll : filter.begins } );
    filter.begins = null;
  }

  if( filter.ends )
  {
    _.assert( _.strIs( filter.ends ) || _.strsAreAll( filter.ends ) );

    filter.ends = _.arrayAs( filter.ends );
    filter.ends = new RegExp( '(' + '^\.|' + _.regexpsEscape( filter.ends ).join( '|' ) + ')$' );

    filter.maskAll = _.RegexpObject.And( filter.maskAll,{ includeAll : filter.ends } );
    filter.ends = null;
  }

  /* */

  if( filter.globFound )
  {

    // debugger;

    _.assert( !filter.src );
    _.assert( filter.filterMap === null );
    filter.filterMap = Object.create( null );

    // let filePath = _.mapExtend( null, filter.filePath );
    // for( let f in filePath )
    // if( _.strIs( filePath[ f ] ) )
    // filePath[ f ] = true;

    // let _processed = path.fileMapToRegexps( filePath, filter.basePath  );

    // debugger;
    let _processed = path.fileMapToRegexps( filter.filePath, filter.basePath  );
    // debugger;
    // debugger;

    _.mapDelete( filter.basePath );
    _.mapDelete( filter.filePath );

    _.mapExtend( filter.basePath, _processed.unglobedBasePath );
    _.mapExtend( filter.filePath, _processed.unglobedFilePath );

    // filter.basePath = _processed.unglobedBasePath;
    // filter.filePath = _processed.unglobedFilePath;

    // filter.filePath = _.mapKeys( _processed.regexpMap );

    filter.assertBasePath();

    for( let p in _processed.regexpMap )
    {
      let basePath = filter.basePath[ p ];
      _.assert( _.strDefined( basePath ), 'No base path for', p );
      let relative = p;
      let regexps = _processed.regexpMap[ p ];
      _.assert( !filter.filterMap[ relative ] );
      let subfilter = filter.filterMap[ relative ] = Object.create( null );
      subfilter.maskAll = _.RegexpObject.And( filter.maskAll.clone(), { includeAny : regexps.actual, excludeAny : regexps.notActual } );
      subfilter.maskTerminal = filter.maskTerminal.clone();
      subfilter.maskDirectory = filter.maskDirectory.clone();
      subfilter.maskTransientAll = filter.maskTransientAll.clone();
      subfilter.maskTransientTerminal = _.RegexpObject.And( filter.maskTransientTerminal.clone(), { includeAny : /$_^/ } );
      // subfilter.maskTransientTerminal = filter.maskTransientTerminal.clone(); // xxx
      subfilter.maskTransientDirectory = _.RegexpObject.And( filter.maskTransientDirectory.clone(), { includeAny : regexps.transient } );
      _.assert( subfilter.maskAll !== filter.maskAll );
    }

  }

  /* */

  if( Config.debug )
  {

    if( filter.notOlder )
    _.assert( _.numberIs( filter.notOlder ) || _.dateIs( filter.notOlder ) );

    if( filter.notNewer )
    _.assert( _.numberIs( filter.notNewer ) || _.dateIs( filter.notNewer ) );

    if( filter.notOlderAge )
    _.assert( _.numberIs( filter.notOlderAge ) || _.dateIs( filter.notOlderAge )  );

    if( filter.notNewerAge )
    _.assert( _.numberIs( filter.notNewerAge ) || _.dateIs( filter.notNewerAge ) );

  }

  filter.formed = 4;
}

//

function _formFinal()
{
  let filter = this;

  if( filter.formed < 4 )
  filter._formMasks();

  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( filter.formed === 4 );
  _.assert( _.strIs( filter.filePath ) || _.arrayIs( filter.filePath ) || _.mapIs( filter.filePath ) );

  // _.assert( path.s.noneAreGlob( filter.filePath ) );

  let filePath = filter.filePathArrayGet();
  _.assert( path.s.noneAreGlob( filePath ) );
  _.assert( path.s.allAreAbsolute( filePath ) || path.s.allAreGlobal( filePath ) );
  _.assert( _.objectIs( filter.basePath ) );
  _.assert( _.objectIs( filter.effectiveFileProvider ) );
  _.assert( filter.hubFileProvider === filter.effectiveFileProvider.hub || filter.hubFileProvider === filter.effectiveFileProvider );
  _.assert( filter.hubFileProvider instanceof _.FileProvider.Abstract );
  _.assert( filter.defaultFileProvider instanceof _.FileProvider.Abstract );

  for( let p in filter.basePath )
  {
    let filePath = p;
    let basePath = filter.basePath[ p ];
    _.assert
    (
      path.isAbsolute( filePath ) && path.isNormalized( filePath ) && !path.isGlob( filePath ) && !path.isTrailed( filePath ),
      () => 'Stem path should be absolute and normalized, but not glob, neither trailed' + '\nstemPath : ' + _.toStr( filePath )
    );
    _.assert
    (
      path.isAbsolute( basePath ) && path.isNormalized( basePath ) && !path.isGlob( basePath ) && !path.isTrailed( basePath ),
      () => 'Base path should be absolute and normalized, but not glob, neither trailed' + '\nbasePath : ' + _.toStr( basePath )
    );
  }

  filter.applyTo = filter._applyToRecordNothing;

  if( filter.notOlder || filter.notNewer || filter.notOlderAge || filter.notNewerAge )
  filter.applyTo = filter._applyToRecordFull;
  else if( filter.hasMask() )
  filter.applyTo = filter._applyToRecordMasks;

  filter.formed = 5;
}

// --
// combiner
// --

function And()
{
  _.assert( !_.instanceIs( this ) );

  let dstFilter = null;

  if( arguments.length === 1 )
  return this.Self( arguments[ 0 ] );

  for( let a = 0 ; a < arguments.length ; a++ )
  {
    let srcFilter = arguments[ a ];

    if( dstFilter )
    dstFilter = this.Self( dstFilter );
    if( dstFilter )
    dstFilter.and( srcFilter );
    else
    dstFilter = this.Self( srcFilter );

  }

  return dstFilter;
}

//

function and( src )
{
  let filter = this;

  if( arguments.length > 1 )
  {
    for( let a = 0 ; a < arguments.length ; a++ )
    filter.and( arguments[ a ] );
    return filter;
  }

  if( Config.debug )
  if( src && !( src instanceof filter.Self ) )
  _.assertMapHasOnly( src, filter.fieldsOfCopyableGroups );

  _.assert( _.instanceIs( filter ) );
  _.assert( !filter.formed || filter.formed <= 1 );
  _.assert( !src.formed || src.formed <= 1 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  // _.assert( src.filePath === null || src.filePath === undefined );
  // _.assert( filter.filePath === null );
  _.assert( filter.filterMap === null );
  _.assert( filter.applyTo === null );

  // _.assert( src.filePath === null || src.filePath === undefined );
  // _.assert( src.basePath === null || src.basePath === undefined );
  // _.assert( filter.filePath === null );
  // _.assert( filter.basePath === null );

  // _.assert( !!( filter.hubFileProvider || src.hubFileProvider ) );
  _.assert( !filter.effectiveFileProvider || !src.effectiveFileProvider || filter.effectiveFileProvider === src.effectiveFileProvider );
  _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );
  // _.assert( filter.filePath === null );
  // _.assert( src.filePath === null || src.filePath === undefined );

  if( src === filter )
  return filter;

  /* */

  if( src.effectiveFileProvider )
  filter.effectiveFileProvider = src.effectiveFileProvider

  if( src.hubFileProvider )
  filter.hubFileProvider = src.hubFileProvider

  /* */

  // if( src.basePath )
  // {
  //   _.assert( _.strIs( src.basePath ) );
  //   _.assert( filter.basePath === null || _.strIs( filter.basePath ) );
  //   filter.basePath = path.joinIfDefined( filter.basePath, src.basePath );
  // }
  //
  // if( src.prefixPath )
  // filter.prefixPath = path.s.joinIfDefined( filter.prefixPath, src.prefixPath );
  // if( src.postfixPath )
  // filter.postfixPath = path.s.joinIfDefined( filter.postfixPath, src.postfixPath  );

  /* */

  let appending =
  {

    hasExtension : null,
    begins : null,
    ends : null,

  }

  for( let a in appending )
  {
    if( src[ a ] === null || src[ a ] === undefined )
    continue;
    _.assert( _.strIs( src[ a ] ) || _.strsAreAll( src[ a ] ) );
    _.assert( filter[ a ] === null || _.strIs( filter[ a ] ) || _.strsAreAll( filter[ a ] ) );
    if( filter[ a ] === null )
    {
      filter[ a ] = src[ a ];
    }
    else
    {
      if( _.strIs( filter[ a ] ) )
      filter[ a ] = [ filter[ a ] ];
      _.arrayAppendOnce( filter[ a ], src[ a ] );
    }
  }

  /* */

  let once =
  {
    notOlder : null,
    notNewer : null,
    notOlderAge : null,
    notNewerAge : null,
  }

  for( let n in once )
  {
    _.assert( !filter[ n ] || !src[ n ], 'Cant "and" filter with another filter, them both have field', n );
    if( src[ n ] )
    filter[ n ] = src[ n ];
  }

  /* */

  filter.maskAll = _.RegexpObject.And( filter.maskAll, src.maskAll || null );
  filter.maskTerminal = _.RegexpObject.And( filter.maskTerminal, src.maskTerminal || null );
  filter.maskDirectory = _.RegexpObject.And( filter.maskDirectory, src.maskDirectory || null );
  filter.maskTransientAll = _.RegexpObject.And( filter.maskTransientAll, src.maskTransientAll || null );
  filter.maskTransientTerminal = _.RegexpObject.And( filter.maskTransientTerminal, src.maskTransientTerminal || null );
  filter.maskTransientDirectory = _.RegexpObject.And( filter.maskTransientDirectory, src.maskTransientDirectory || null );

  return filter;
}

//

function _pathsJoin_pre( routine, args )
{
  let filter = this;
  let o;

  if( _.mapIs( args[ 0 ] ) )
  o = args[ 0 ];
  else
  o = { src : args }

  _.assert( arguments.length === 2 );
  _.routineOptions( routine, o );

  return o;
}

//

function _pathsJoin_body( o )
{
  let filter = this;

  if( _.arrayLike( o.src ) )
  {
    for( let a = 0 ; a < o.src.length ; a++ )
    {
      let o2 = _.mapExtend( null, o );
      o2.src = o2.src[ a ];
      filter._pathsJoin.body.call( filter, o2 );
    }
    return filter;
  }

  if( Config.debug )
  if( o.src && !( o.src instanceof filter.Self ) )
  _.assertMapHasOnly( o.src, filter.fieldsOfCopyableGroups );

  _.assert( _.instanceIs( filter ) );
  _.assert( !filter.formed || filter.formed <= 1 );
  _.assert( !o.src.formed || o.src.formed <= 1 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( filter.filterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( !filter.hubFileProvider || !o.src.hubFileProvider || filter.hubFileProvider === o.src.hubFileProvider );
  _.assert( o.src !== filter );
  _.assert( _.objectIs( o.src ) );
  _.assert( o.src.filePath === null || o.src.filePath === undefined || o.src.filePath === '.' || _.strIs( o.src.filePath ) );

  let fileProvider = filter.hubFileProvider || filter.defaultFileProvider || filter.effectiveFileProvider || o.src.hubFileProvider || o.src.defaultFileProvider || o.src.effectiveFileProvider;
  let path = fileProvider.path;

  /* */

  if( o.src.hubFileProvider )
  filter.hubFileProvider = o.src.hubFileProvider;

  for( let n in o.joiningWithoutNullMap )
  if( o.src[ n ] !== undefined && o.src[ n ] !== null )
  {
    _.assert( o.src[ n ] === null || _.strIs( o.src[ n ] ) );
    _.assert( filter[ n ] === null || _.strIs( filter[ n ] ) );
    filter[ n ] = path.join( filter[ n ], o.src[ n ] );
  }

  /* */

  for( let n in o.joiningMap )
  if( o.src[ n ] !== undefined )
  {
    _.assert( o.src[ n ] === null || _.strIs( o.src[ n ] ) );
    _.assert( filter[ n ] === null || _.strIs( filter[ n ] ) );
    filter[ n ] = path.join( filter[ n ], o.src.basePath );
  }

  /* */

  for( let a in o.appendingMap )
  {
    if( o.src[ a ] === null || o.src[ a ] === undefined )
    continue;

    _.assert( _.strIs( o.src[ a ] ) || _.strsAreAll( o.src[ a ] ) );
    _.assert( filter[ a ] === null || _.strIs( filter[ a ] ) || _.strsAreAll( filter[ a ] ) );

    if( filter[ a ] === null )
    {
      filter[ a ] = o.src[ a ];
    }
    else
    {
      if( _.strIs( filter[ a ] ) )
      filter[ a ] = [ filter[ a ] ];
      _.arrayAppendOnce( filter[ a ], o.src[ a ] );
    }

  }

  return filter;
}

_pathsJoin_body.defaults =
{

  src : null,

  joiningWithoutNullMap :
  {
    filePath : null,
  },

  joiningMap :
  {
    basePath : null,
  },

  appendingMap :
  {
    prefixPath : null,
    postfixPath : null,
  },

}

let _pathsJoin = _.routineFromPreAndBody( _pathsJoin_pre, _pathsJoin_body );

//

function pathsJoin()
{
  let filter = this;
  return filter._pathsJoin
  ({
    src : arguments,
    joiningWithoutNullMap :
    {
      filePath : null,
    },
    joiningMap :
    {
      basePath : null,
    },
    appendingMap :
    {
      prefixPath : null,
      postfixPath : null,
    },
  });
}

//

function pathsJoinWithoutNull()
{
  let filter = this;
  return filter._pathsJoin
  ({
    src : arguments,
    joiningWithoutNullMap :
    {
      filePath : null,
      basePath : null,
    },
    joiningMap :
    {
    },
    appendingMap :
    {
      prefixPath : null,
      postfixPath : null,
    },
  });
}

//

function pathsInherit( src )
{
  let filter = this;

  if( arguments.length > 1 )
  {
    for( let a = 0 ; a < arguments.length ; a++ )
    filter.pathsJoin( arguments[ a ] );
    return filter;
  }

  if( Config.debug )
  if( src && !( src instanceof filter.Self ) )
  _.assertMapHasOnly( src, filter.fieldsOfCopyableGroups );

  _.assert( _.instanceIs( filter ) );
  _.assert( !filter.formed || filter.formed <= 1 );
  _.assert( !src.formed || src.formed <= 1 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( filter.filterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );
  _.assert( src !== filter );

  let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider || filter.defaultFileProvider || src.effectiveFileProvider || src.hubFileProvider || src.defaultFileProvider;
  let path = fileProvider.path;

  /* */

  if( src.hubFileProvider )
  filter.hubFileProvider = src.hubFileProvider;

  /* */

  if( !( src instanceof Self ) )
  src = fileProvider.recordFilter( src );

  // debugger;

  src.prefixesApply();
  filter.prefixesApply();

  _.assert( src.prefixPath === null );
  _.assert( src.postfixPath === null );
  _.assert( filter.prefixPath === null );
  _.assert( filter.postfixPath === null );

  if( _.mapIs( src.basePath ) )
  filter.basePath = _.mapExtend( filter.basePath, src.basePath );
  else if( filter.basePath === null )
  filter.basePath = src.basePath;

  /* */

  if( src.filePath )
  filter.filePath = path.fileMapExtend( filter.filePath, src.filePath, true );

  return filter;
}

//

function pathsExtend( src )
{
  let filter = this;

  if( arguments.length > 1 )
  {
    for( let a = 0 ; a < arguments.length ; a++ )
    filter.pathsExtend( arguments[ a ] );
    return filter;
  }

  if( Config.debug )
  if( src && !( src instanceof filter.Self ) )
  _.assertMapHasOnly( src, filter.fieldsOfCopyableGroups );

  _.assert( _.instanceIs( filter ) );
  _.assert( !filter.formed || filter.formed <= 1 );
  _.assert( !src.formed || src.formed <= 1 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( filter.filterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( filter.filePath === null );
  _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );
  _.assert( src !== filter );
  _.assert( src.filePath === null || src.filePath === undefined || filter.filePath === null );

  let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider || filter.defaultFileProvider || src.effectiveFileProvider || src.hubFileProvider || src.defaultFileProvider;
  let path = fileProvider.path;

  let replacing =
  {

    hubFileProvider : null,
    basePath : null,
    filePath : null,
    prefixPath : null,
    postfixPath : null,

  }

  /* */

  for( let s in replacing )
  {
    if( src[ s ] === null || src[ s ] === undefined )
    continue;
    filter[ s ] = src[ s ];
  }

  return filter;
}

// --
// base path
// --

function basePathFor( filePath )
{
  let filter = this;
  let result = null;

  if( _.boolLike( filePath ) )
  {
    if( _.strIs( filter.basePath ) )
    return filter.basePath;
    _.assert( _.mapIs( filter.basePath ) && _.mapKeys( filter.basePath ).length === 1 );
    return _.mapVals( filter.basePath )[ 0 ];
  }

  _.assert( _.strIs( filePath ), 'Expects string' );
  _.assert( arguments.length === 1 );

  if( !filter.basePath )
  return;

  if( _.strIs( filter.basePath ) )
  return filter.basePath;

  _.assert( _.mapIs( filter.basePath ) );

  result = filter.basePath[ filePath ];

  _.assert( result !== undefined, 'No base path for ' + filePath );

  return result;
}

//

function basePathsGet()
{
  let filter = this;

  _.assert( arguments.length === 0 );
  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );

  if( _.objectIs( filter.basePath ) )
  return _.arrayUnique( _.mapVals( filter.basePath ) )
  else if( _.strIs( filter.basePath ) )
  return [ filter.basePath ];
  else
  return [];
}

//

function basePathsFrom( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  if( _.strIs( filePath ) )
  filePath = [ filePath ];

  _.assert( _.mapIs( filePath ) || _.arrayIs( filePath ) );
  _.assert( arguments.length === 1 );

  let resultArray = filePath;

  if( _.mapIs( resultArray ) )
  resultArray = filter.src ? _.mapVals( resultArray ) : _.mapKeys( resultArray );

  // _.sure( resultArray.length > 0 || ( _.arrayIs( filter.filePath ) && filter.filePath.length === 0 ), 'Cant deduce basePath' );

  let resultMap = Object.create( null );

  if( !resultArray.length )
  return resultMap;

  for( let r = 0 ; r < resultArray.length ; r++ )
  {
    let p = resultArray[ r ];
    if( !_.strIs( p ) )
    continue;
    resultMap[ p ] = path.normalize( path.fromGlob( p ) );
  }

  _.sure( resultArray.length > 0, 'Cant deduce basePath' );

  return resultMap;
}

//

function basePathStringNormalize( basePath, filePaths )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  if( basePath === undefined )
  basePath = filter.basePath
  if( filePaths === undefined )
  filePaths = filter.filePath;

  _.assert( _.strIs( basePath ) );
  _.assert( arguments.length <= 2 );

  basePath = filter.pathLocalize( basePath );

  let basePath2 = Object.create( null );

  if( _.mapIs( filePaths ) )
  filePaths = filter.src ? _.mapVals( filePaths ) : _.mapKeys( filePaths );
  else if( !_.arrayIs( filePaths ) )
  filePaths = [ filePaths ];

  // debugger;

  for( let s = 0 ; s < filePaths.length ; s++ )
  {
    let thisFilePath = filePaths[ s ];

    _.assert( _.strIs( thisFilePath ) || _.boolLike( thisFilePath ) );

    if( _.boolLike( thisFilePath ) )
    {
      // _.assert( 0, 'not tested' );
      // _.assert( _.strIs( basePath ) && !path.isGlob( basePath ) );
      // basePath2[ basePath ] = basePath;
    }
    else
    {
      basePath2[ thisFilePath ] = basePath;
    }

  }

  if( !basePath || _.mapKeys( basePath2 ).length )
  return basePath2;
  else
  return basePath;
}

//

function basePathMapNormalize( basePathMap )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  let basePathMap2 = Object.create( null );
  basePathMap = basePathMap || filter.basePath;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  // let o3 = { basePath : 1, fixes : 0, filePath : 0, onEach : basePathEach }
  // filter.allPaths( o3 );

  for( let filePath in basePathMap )
  {
    let basePath = basePathMap[ filePath ];

    _.assert( _.strIs( basePath ) );
    _.assert( _.strIs( filePath ) );
    _.assert( !path.isGlob( basePath ) );
    // _.assert( !path.isGlob( filePath ) );

    filePath = filter.pathLocalize( filePath );
    basePath = filter.pathLocalize( basePath );

    filePath = path.fromGlob( filePath );

    basePathMap2[ filePath ] = basePath;

    // _.assert( !path.isGlob( it.value ) ) );
    // it.value = filter.pathLocalize( it.value );
    // if( it.side === 'source' )
    // it.value = path.fromGlob( it.value );
  }

  return basePathMap2;
}

//

function basePathNormalize( basePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  basePath = basePath || filter.basePath;

  _.assert( !_.arrayIs( basePath ) );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( basePath === null || ( _.strIs( basePath ) && path.isRelative( basePath ) ) )
  {
    basePath = filter.basePathsFrom( filter.filePath );
  }
  else if( _.strIs( basePath ) )
  {
    basePath = filter.basePathStringNormalize( basePath, filter.filePath );
  }
  else if( _.mapIs( basePath ) )
  {
    basePath = filter.basePathMapNormalize( basePath );
  }
  else _.assert( 0 );

  return basePath;
}

// --
// file path
// --

function filePathGet()
{
  let filter = this;
  return filter.filePath;
}

//

function filePathSet( src )
{
  let filter = this;
  _.assert( src === null || _.strIs( src ) || _.arrayIs( src ) || _.mapIs( src ) );
  filter.filePath = src;
  return src;
}

//

function filePathNormalize( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 1 );

  // filePath = path.s.normalize( filePath );
  // filePath = path.fileMapExtend( null, filePath );

  if( !_.mapIs( filePath ) )
  filePath = path.fileMapExtend( null, filePath );

  if( filter.src )
  {

    for( let srcPath in filePath )
    {
      let dstPath = filePath[ srcPath ];

      if( !_.strIs( dstPath ) )
      continue;

      let dstPath2 = path.normalize( dstPath );
      dstPath2 = filter.pathLocalize( dstPath2 );
      if( dstPath === dstPath2 )
      continue;
      _.assert( _.strIs( dstPath2 ) );
      filePath[ srcPath ] = dstPath2;
    }

  }
  else
  {

    for( let srcPath in filePath )
    {
      let srcPath2 = path.normalize( srcPath );
      srcPath2 = filter.pathLocalize( srcPath2 );
      if( srcPath === srcPath2 )
      continue;
      _.assert( _.strIs( srcPath2 ) );
      filePath[ srcPath2 ] = filePath[ srcPath ];
      delete filePath[ srcPath ];
    }

  }

  return filePath;
}

//

function filePathPrependBasePath( filePath, basePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 2 );
  _.assert( _.mapIs( filePath ) );
  _.assert( _.mapIs( basePath ) );

  if( filter.src )
  {

    for( let srcPath in filePath )
    {

      let b = basePath[ srcPath ];
      let dstPath = filePath[ dstPath ];
      if( !_.strIs( dstPath ) || path.isAbsolute( dstPath ) )
      continue;

      _.assert( path.isAbsolute( b ) );

      let joinedPath = path.join( b, dstPath );
      if( joinedPath !== dstPath )
      {
        delete basePath[ dstPath ];
        basePath[ joinedPath ] = b;
        filePath[ srcPath ] = dstPath;
        // delete filePath[ srcPath ];
        // path.fileMapExtend( filePath, joinedPath, dstPath );
      }

    }

  }
  else
  {

    for( let srcPath in filePath )
    {

      let b = basePath[ srcPath ];
      let dstPath = filePath[ srcPath ];
      if( path.isAbsolute( srcPath ) )
      continue;

      _.assert( path.isAbsolute( b ) );

      let joinedPath = path.join( b, srcPath );
      if( joinedPath !== srcPath )
      {
        delete basePath[ srcPath ];
        basePath[ joinedPath ] = b;
        delete filePath[ srcPath ];
        path.fileMapExtend( filePath, joinedPath, dstPath );
      }

    }

  }

}

//

function filePathMultiplyRelatives( filePath, basePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 2 );
  _.assert( _.mapIs( filePath ) );
  _.assert( _.mapIs( basePath ) );
  _.assert( !filter.src );

  let relativePath = _.mapExtend( null, filePath );

  for( let r in relativePath )
  if( path.isRelative( r ) )
  {
    _.assert( basePath[ r ] !== undefined );
    delete basePath[ r ];
    delete filePath[ r ];
  }
  else
  {
    delete relativePath[ r ];
  }

  for( let r in relativePath )
  for( let b in basePath )
  {
    let currentBasePath = basePath[ b ];
    let dstPath = relativePath[ r ];
    let srcPath = path.join( b, r );
    _.assert( filePath[ srcPath ] === undefined || filePath[ srcPath ] === dstPath );
    filePath[ srcPath ] = dstPath;
    _.assert( basePath[ srcPath ] === undefined || basePath[ srcPath ] === currentBasePath );
    basePath[ srcPath ] = currentBasePath;
  }

}

//

function filePathAbsolutize()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( _.mapIs( filter.basePath ) );
  _.assert( _.mapIs( filter.filePath ) );

  let filePath = filter.filePathArrayGet();

  if( path.s.anyAreRelative( filePath ) )
  if( path.s.anyAreAbsolute( filePath ) )
  filter.filePathMultiplyRelatives( filter.filePath, filter.basePath );
  else
  filter.filePathPrependBasePath( filter.filePath, filter.basePath );

}

//

function filePathFromFixes()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );

  if( !filter.filePath )
  {
    // adjustingFilePath = false;
    filter.filePath = path.s.join( filter.prefixPath || '.', filter.postfixPath || '.' );
    _.assert( path.s.allAreAbsolute( filter.filePath ), 'Can deduce file path' );
  }

  return filter.filePath;
}

//

function filePathSimplest()
{
  let filter = this;

  let filePath = filter.src ? filter.dstPathGet( filter.filePath ) : filter.srcPathGet( filter.filePath );

  _.assert( !_.mapIs( filePath ) );

  if( _.arrayIs( filePath ) && filePath.length === 1 )
  return filePath[ 0 ];

  // if( filter.filePath.length === 1 )
  // filter.filePath = filter.filePath[ 0 ];

  return filePath;
}

//

function filePathArrayGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  filePath = filePath || filter.filePath;

  _.assert( _.mapIs( filePath ) );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( _.strIs( filePath ) )
  return [ filePath ];

  if( filter.src )
  {
    if( _.mapIs( filePath ) )
    {
      filePath = _.mapVals( filePath );
      filePath = filePath.filter( ( e ) => _.strIs( e ) );
    }
  }
  else
  {
    if( _.mapIs( filePath ) )
    filePath = _.mapKeys( filePath );
  }

  _.assert( _.arrayIs( filePath ) );

  return filePath;
}

// --
// other paths
// --

function dstPathGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  filePath = filePath || filter.filePath;

  if( _.strIs( filePath ) )
  filePath = [ filePath ];
  else if( _.mapIs( filePath ) )
  filePath = _.mapVals( filePath );

  _.assert( _.arrayIs( filePath ) );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  filePath = _.arrayAppendArrayOnce( [], filePath );
  filePath = _.filter( filePath, ( p ) =>
  {
    if( _.strIs( p ) )
    return p;
    if( p === true )
    return filter.prefixPath || filter.basePathFor( p ) || undefined;
    if( p === false )
    return;
    return p;
  });

  if( filter.prefixPath || filter.postfixPath )
  filePath = path.s.join( filter.prefixPath || '.', filePath, filter.postfixPath || '.' );

  return filePath;
}

//

function srcPathGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  filePath = filePath || filter.filePath;

  // if( _.strIs( filePath ) )
  // filePath = [ filePath ];

  if( _.strIs( filePath ) )
  filePath = [ filePath ];
  else if( _.mapIs( filePath ) )
  filePath = _.mapKeys( filePath );

  _.assert( _.arrayIs( filePath ) );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  filePath = _.arrayAppendArrayOnce( [], filePath );
  filePath = _.filter( filePath, ( p ) =>
  {
    if( _.strIs( p ) )
    return p;
    if( p === true )
    return filter.prefixPath || undefined;
    if( p === false )
    return;
    return p;
  });

  if( filter.prefixPath || filter.postfixPath )
  filePath = path.s.join( filter.prefixPath || '.', filePath, filter.postfixPath || '.' );

  return filePath
}

//

function dstPathCommon()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  let filePath = filter.dstPathGet();

  return path.common.apply( path, filePath );
}

//

function srcPathCommon()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  let filePath = filter.srcPathGet();

  return path.common.apply( path, filePath );
}

//

function globalsFromLocals()
{
  let filter = this;

  if( filter.basePath )
  filter.basePath = filter.effectiveFileProvider.globalsFromLocals( filter.basePath );

  if( filter.filePath )
  filter.filePath = filter.effectiveFileProvider.globalsFromLocals( filter.filePath );

}

//

function prefixesApply( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  let adjustingFilePath = true;

  if( filter.prefixPath === null && filter.postfixPath === null )
  return filter;

  o = _.routineOptions( prefixesApply, arguments );
  _.assert( filter.prefixPath === null || _.strIs( filter.prefixPath ) );
  _.assert( filter.postfixPath === null || _.strIs( filter.postfixPath ) );
  _.assert( filter.postfixPath === null, 'not implemented' );

  /* yyy */

  // if( !filter.filePath )
  // {
  //   adjustingFilePath = false;
  //   filter.filePath = path.s.join( filter.prefixPath || '.', filter.postfixPath || '.' );
  //   _.assert( path.s.allAreAbsolute( filter.filePath ), 'Can deduce file path' );
  // }

  if( !filter.filePath )
  {
    adjustingFilePath = false;
    filter.filePathFromFixes();
  }

  /* */

  if( _.strIs( filter.basePath ) )
  {
    filter.basePath = filter.basePathStringNormalize( filter.basePath, filter.filePath ); // xxx
  }

  /* */

  _.assert( filter.postfixPath === null || !path.s.AllAreGlob( filter.postfixPath ) );

  if( adjustingFilePath )
  {
    let o2 = { basePath : 0, fixes : 0, filePath : 1, onEach : filePathEach }
    filter.allPaths( o2 );
  }

  let o3 = { basePath : 1, fixes : 0, filePath : 0, onEach : basePathEach }
  filter.allPaths( o3 );

  /* */

  filter.prefixPath = null;
  filter.postfixPath = null;

  _.assert( !_.arrayIs( filter.basePath ) );
  if( filter.basePath && filter.filePath )
  filter.assertBasePath( filter.filePath );
  _.assert( _.mapIs( filter.basePath ) || _.strIs( filter.basePath ) || filter.basePath === null );

  return filter;

  /* */

  function filePathEach( it )
  {
    _.assert( it.value === null || _.strIs( it.value ) || _.boolLike( it.value ) );

    if( filter.src )
    {
      if( it.side !== 'destination' )
      return;
    }
    else
    {
      if( it.side === 'destination' )
      return;
    }

    if( filter.prefixPath || filter.postfixPath )
    if( _.strIs( it.value ) )
    {
      it.value = path.s.join( filter.prefixPath || '.', it.value, filter.postfixPath || '.' );
    }
  }

  /* */

  function basePathEach( it )
  {
    _.assert( it.value === null || _.strIs( it.value ) );
    if( filter.prefixPath || filter.postfixPath )
    if( _.strIs( it.value ) )
    {
      it.value = path.s.join( filter.prefixPath || '.', it.value, filter.postfixPath || '.' );
    }
  }

}

prefixesApply.defaults =
{
}

//

function pathLocalize( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = path.normalize( filePath );

  if( filter.effectiveFileProvider && !path.isGlobal( filePath ) )
  return filePath;

  let effectiveProvider2 = fileProvider.providerForPath( filePath );
  _.assert( filter.effectiveFileProvider === null || effectiveProvider2 === null || filter.effectiveFileProvider === effectiveProvider2, 'Record filter should have paths of single file provider' );
  filter.effectiveFileProvider = filter.effectiveFileProvider || effectiveProvider2;

  if( filter.effectiveFileProvider )
  {

    if( !filter.hubFileProvider )
    filter.hubFileProvider = filter.effectiveFileProvider.hub;
    _.assert( filter.effectiveFileProvider.hub === null || filter.hubFileProvider === filter.effectiveFileProvider.hub );
    _.assert( filter.effectiveFileProvider.hub === null || filter.hubFileProvider instanceof _.FileProvider.Hub );

  }

  if( !path.isGlobal( filePath ) )
  return filePath;

  let provider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let result = provider.localFromGlobal( filePath );
  return result;
}

//

function pathsNormalize()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  let originalFilePath = filter.filePath;

  _.assert( arguments.length === 0 );
  _.assert( filter.formed === 2 );
  _.assert( filter.prefixPath === null, 'Prefixes should be applied so far' );
  _.assert( filter.postfixPath === null, 'Posftixes should be applied so far' );
  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );
  _.assert( _.strIs( filter.filePath ) || _.arrayIs( filter.filePath ) || _.mapIs( filter.filePath ), 'filePath of file record filter is not defined' );

  /* */

  // debugger;

  filter.filePath = filter.filePathNormalize( filter.filePath );
  _.assert( _.mapIs( filter.filePath ) );

  filter.basePath = filter.basePathNormalize( filter.basePath );
  _.assert( _.mapIs( filter.basePath ) );

  filter.filePathAbsolutize();

  /* */

  if( !filter.src )
  filter.globFound = 1;

  // if( filter.src )
  // filter.filePath = filter.dstPathGet( filter.filePath ); // xxx

  // if( filter.src )
  // debugger;

  if( _.none( path.s.areGlob( filter.filePath ) ) && _.all( _.mapVals( filter.filePath ) ) )
  {
    if( filter.src )
    {
      // filter.filePath = filter.dstPathGet( filter.filePath );
      // if( filter.filePath.length === 1 )
      // filter.filePath = filter.filePath[ 0 ];
    }
    else
    {
      // filter.filePath = _.mapKeys( filter.filePath );
      // if( filter.filePath.length === 1 )
      // filter.filePath = filter.filePath[ 0 ];
    }
    filter.globFound = 0;
  }

  filter.providersNormalize();

  if( !Config.debug )
  return end();

  if( filter.basePath )
  filter.assertBasePath( filter.filePath );

  _.assert
  (
       ( _.arrayIs( filter.filePath ) && filter.filePath.length === 0 )
    || ( _.mapIs( filter.filePath ) && _.mapKeys( filter.filePath ).length === 0 )
    || ( _.mapIs( filter.basePath ) && _.mapKeys( filter.basePath ).length > 0 )
    , 'Cant deduce base path'
  );

  /* */

  return end();

  /* */

  function end()
  {
    // filter.filePath = filePath;
  }

  /* */

  function basePathEach( it )
  {
    _.assert( _.strIs( it.value ) );
    it.value = filter.pathLocalize( it.value );
    if( it.side === 'source' )
    it.value = path.fromGlob( it.value );
  }

}

// --
// etc
// --

function useDestination( dstFilter )
{
  let filter = this;

  _.assert( dstFilter instanceof Self );
  _.assert( filter instanceof Self );
  _.assert( filter.dst === null || filter.dst === dstFilter );
  _.assert( dstFilter.src === null || dstFilter.src === filter );

  filter.dst = dstFilter;
  dstFilter.src = filter;

  return filter;
}

//

function providersNormalize()
{
  let filter = this;

  if( !filter.effectiveFileProvider )
  filter.effectiveFileProvider = filter.defaultFileProvider;
  if( !filter.hubFileProvider )
  filter.hubFileProvider = filter.effectiveFileProvider;
  if( filter.hubFileProvider.hub )
  filter.hubFileProvider = filter.hubFileProvider.hub;

}

//

function providerForPath( filePath )
{
  let filter = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( filter.effectiveFileProvider )
  return filter.effectiveFileProvider;

  if( !filePath )
  filePath = filter.filePath;

  if( !filePath )
  filePath = filter.filePath;

  if( !filePath )
  filePath = filter.basePath

  _.assert( _.strIs( filePath ), 'Expects string' );

  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;

  filter.effectiveFileProvider = fileProvider.providerForPath( filePath );

  return filter.effectiveFileProvider;
}

// --
// iterative
// --

function allPaths( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  let thePath;

  if( _.routineIs( o ) )
  o = { onEach : o }
  o = _.routineOptions( allPaths, o );
  _.assert( arguments.length === 1 );

  if( o.fixes )
  if( !each( filter.prefixPath, 'prefixPath' ) )
  return false;

  if( o.fixes )
  if( !each( filter.postfix, 'postfix' ) )
  return false;

  if( o.basePath )
  if( !each( filter.basePath, 'basePath' ) )
  return false;

  if( o.filePath )
  if( !each( filter.filePath, 'filePath' ) )
  return false;

  return true;

  /* - */

  function each( thePath, fieldName )
  {
    let it = Object.create( null );

    // it.options = o;
    // it.fieldName = fieldName;
    it.fieldName = fieldName;
    it.side = null;
    // it.field = thePath;
    it.value = thePath;

    let result = path.iterateAll({ iteration : it, filePath : thePath, onEach : o.onEach });

    filter[ fieldName ] = it.value;

    return it.result;

    // if( thePath === null || _.strIs( thePath ) )
    // {
    //   if( o.onEach( it ) === false )
    //   return false;
    //   if( filter[ fieldName ] !== it.value )
    //   filter[ fieldName ] = it.value;
    // }
    // else
    // {
    //   return path.iterateAll({ iteration : it, filePath : thePath, onEach : o.onEach });
    // }
    //
    // return true;

  }

}

allPaths.defaults =
{
  onEach : null,
  fixes : 1,
  basePath : 1,
  // filePath : 1,
  filePath : 1,
}

//

function isRelative( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  let thePath;

  o = _.routineOptions( isRelative, arguments );

  _.assert( 0, 'not tested' );

  let o2 = _.mapExtend( null, o );
  o2.onEach = onEach;

  return filter.allPaths( o2 );

  /* - */

  function onEach( it )
  {
    if( it.value === null )
    return;
    if( path.isRelative( it.value ) )
    return;
    it.value = false;
    // if( it.value === null )
    // return true;
    // if( path.isRelative( it.value ) )
    // return true;
    // return false;
  }

}

isRelative.defaults =
{
  fixes : 1,
  basePath : 1,
  // filePath : 1,
  filePath : 1,
}

//

function sureRelative( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  o = _.routineOptions( sureRelative, arguments );

  _.assert( 0, 'not tested' );

  let o2 = _.mapExtend( null, o );
  o2.onEach = onEach;

  return filter.allPaths( o2 );

  /* - */

  function onEach( it )
  {
    _.sure
    (
      it.value === null || path.isRelative( it.value ),
      () => 'Filter should have relative ' + it.fieldName + ', but has  ' + _.toStr( it.value )
    );
    // return true;
  }

}

sureRelative.defaults =
{
  fixes : 1,
  basePath : 1,
  // filePath : 1,
  filePath : 1,
}

//

function sureRelativeOrGlobal( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  o = _.routineOptions( sureRelative, arguments );

  let o2 = _.mapExtend( null, o );
  o2.onEach = onEach;

  let result = filter.allPaths( o2 );

  return result;

  /* - */

  function onEach( it )
  {
    _.sure
    (
      it.value === null || _.boolLike( it.value ) || path.isRelative( it.value ) || path.isGlobal( it.value ),
      () => 'Filter should have relative ' + it.fieldName + ', but has ' + _.toStr( it.value )
    );
    // return true;
  }

}

sureRelative.defaults =
{
  fixes : 1,
  basePath : 1,
  filePath : 1,
}

//

function sureBasePath( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( !_.arrayIs( filter.basePath ) );

  filePath = filePath || filter.filePath;

  if( !filter.basePath || _.strIs( filter.basePath ) )
  return;

  // if( _.entityLength( filter.filePath ) === 76 )
  // debugger;

  if( filter.src )
  filePath = filter.dstPathGet( filePath );
  else
  filePath = filter.srcPathGet( filePath );

  // if( _.mapIs( filePath ) )
  // {
  //   if( filter.src )
  //   filePath = _.mapVals( filePath );
  //   else
  //   filePath = _.mapKeys( filePath );
  // }
  // else if( _.strIs( filePath ) )
  // {
  //   filePath = [ filePath ];
  // }

  // filePath = filePath.filter( ( g ) => _.strIs( g ) && path.isAbsolute( g ) );

  let diff = _.arraySetDiff( path.s.fromGlob( _.mapKeys( filter.basePath ) ), path.s.fromGlob( filePath ) ); // xxx
  // let diff = _.arraySetDiff( _.mapKeys( filter.basePath ), filePath );
  _.sure( diff.length === 0, () => 'Some file paths do not have base paths or opposite : ' + _.strQuote( diff ) );

  for( let g in filter.basePath )
  {
    // _.sure( path.isAbsolute( g ) );
    _.sure( !path.isGlob( filter.basePath[ g ] ) );
  }

}

//

function assertBasePath( filePath )
{
  let filter = this;

  if( !Config.debug )
  return;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  return filter.sureBasePath( filePath );
}

function filteringClear()
{
  let filter = this;

  filter.maskAll = null;
  filter.maskTerminal = null;
  filter.maskDirectory = null;
  filter.maskTransientAll = null;
  filter.maskTransientTerminal = null;
  filter.maskTransientDirectory = null;

  filter.hasExtension = null;
  filter.begins = null;
  filter.ends = null;

  filter.notOlder = null;
  filter.notNewer = null;
  filter.notOlderAge = null;
  filter.notNewerAge = null;

  return filter;
}

//

function hasMask()
{
  let filter = this;

  if( filter.filterMap )
  return true;

  let hasMask = false;

  hasMask = hasMask || ( filter.maskAll && !filter.maskAll.isEmpty() );
  hasMask = hasMask || ( filter.maskTerminal && !filter.maskTerminal.isEmpty() );
  hasMask = hasMask || ( filter.maskDirectory && !filter.maskDirectory.isEmpty() );
  hasMask = hasMask || ( filter.maskTransientAll && !filter.maskTransientAll.isEmpty() );
  hasMask = hasMask || ( filter.maskTransientTerminal && !filter.maskTransientTerminal.isEmpty() );
  hasMask = hasMask || ( filter.maskTransientDirectory && !filter.maskTransientDirectory.isEmpty() );

  hasMask = hasMask || !!filter.hasExtension;
  hasMask = hasMask || !!filter.begins;
  hasMask = hasMask || !!filter.ends;

  return hasMask;
}

//

function hasFiltering()
{
  let filter = this;

  if( filter.hasMask() )
  return true;

  if( filter.notOlder !== null )
  return true;
  if( filter.notNewer !== null )
  return true;
  if( filter.notOlderAge !== null )
  return true;
  if( filter.notNewerAge !== null )
  return true;

  return false;
}

//

function hasData()
{
  let filter = this;

  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );
  _.assert( filter.prefixPath === null || _.strIs( filter.prefixPath ) );
  _.assert( filter.postfixPath === null || _.strIs( filter.postfixPath ) );
  _.assert( filter.filePath === null || _.strIs( filter.filePath ) || _.arrayIs( filter.filePath ) );
  _.assert( filter.filePath === null || _.strIs( filter.filePath ) || _.arrayIs( filter.filePath ) || _.mapIs( filter.filePath ) );

  if( _.strIs( filter.basePath ) || _.mapIsPopulated( filter.basePath ) )
  return true;

  if( _.strIs( filter.prefixPath ) )
  return true;

  if( _.strIs( filter.postfixPath ) )
  return true;

  if( _.strIs( filter.filePath ) || _.arrayIsPopulated( filter.filePath ) )
  return true;

  if( _.strIs( filter.filePath ) || _.arrayIsPopulated( filter.filePath ) || _.mapIsPopulated( filter.filePath ) )
  return true;

  return filter.hasFiltering();
}

// --
// exporter
// --

function compactField( it )
{
  let filter = this;

  if( it.dst === null )
  return;

  if( it.dst && it.dst instanceof _.RegexpObject )
  if( !it.dst.hasData() )
  return;

  if( _.objectIs( it.dst ) && _.mapKeys( it.dst ).length === 0 )
  return;

  return it.dst;
}

//

function toStr()
{
  let filter = this;
  let result = '';

  // _.assert( arguments.length === 0 );

  result += 'Filter';

  for( let m in filter.MaskNames )
  {
    let maskName = filter.MaskNames[ m ];
    if( filter[ maskName ] !== null && !filter[ maskName ].isEmpty() )
    result += '\n' + '  ' + maskName + ' : ' + !filter[ maskName ].isEmpty();
  }

  let FieldNames =
  [
    'prefixPath', 'postfixPath',
    'filePath',
    'basePath',
    'hasExtension', 'begins', 'ends',
    'notOlder', 'notNewer', 'notOlderAge', 'notNewerAge',
  ];

  for( let f in FieldNames )
  {
    let fieldName = FieldNames[ f ];
    if( filter[ fieldName ] !== null )
    result += '\n' + '  ' + fieldName + ' : ' + _.toStr( filter[ fieldName ] );
  }

  return result;
}

// --
// applier
// --

function _applyToRecordNothing( record )
{
  let filter = this;
  return record.isActual;
}

//

function _applyToRecordMasks( record )
{
  let filter = this;
  let relative = record.relative;
  let f = record.factory;
  let path = record.path;
  filter = filter.filterMap ? filter.filterMap[ f.stemPath ] : filter;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!filter, 'Cant resolve filter for stem path', () => _.strQuote( f.stemPath ) );
  _.assert( !!f.formed, 'Record factor was not formed!' );

  // if( _.strHas( record.absolute, '/src/dir' ) )
  // debugger;

  /* */

  if( record.isDir )
  {

    if( record.isTransient && filter.maskTransientAll )
    record[ isTransientSymbol ] = filter.maskTransientAll.test( relative );
    if( record.isTransient && filter.maskTransientDirectory )
    record[ isTransientSymbol ] = filter.maskTransientDirectory.test( relative );

    if( record.isActual && filter.maskAll )
    record[ isActualSymbol ] = filter.maskAll.test( relative );
    if( record.isActual && filter.maskDirectory )
    record[ isActualSymbol ] = filter.maskDirectory.test( relative );

  }
  else
  {

    if( record.isActual && filter.maskAll )
    record[ isActualSymbol ] = filter.maskAll.test( relative );
    if( record.isActual && filter.maskTerminal )
    record[ isActualSymbol ] = filter.maskTerminal.test( relative );

    if( record.isTransient && filter.maskTransientAll )
    record[ isTransientSymbol ] = filter.maskTransientAll.test( relative );
    if( record.isTransient && filter.maskTransientTerminal )
    record[ isTransientSymbol ] = filter.maskTransientTerminal.test( relative );

  }

  /* */

  return record.isActual;
}

//

function _applyToRecordTime( record )
{
  let filter = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( record.isActual === false )
  return record.isActual;

  if( !record.isDir )
  {
    let time;
    if( record.isActual === true )
    {
      time = record.stat.mtime;
      if( record.stat.birthtime > record.stat.mtime )
      time = record.stat.birthtime;
    }

    if( record.isActual === true )
    if( filter.notOlder !== null )
    {
      record[ isActualSymbol ] = time >= filter.notOlder;
    }

    if( record.isActual === true )
    if( filter.notNewer !== null )
    {
      record[ isActualSymbol ] = time <= filter.notNewer;
    }

    if( record.isActual === true )
    if( filter.notOlderAge !== null )
    {
      record[ isActualSymbol ] = _.timeNow() - filter.notOlderAge - time <= 0;
    }

    if( record.isActual === true )
    if( filter.notNewerAge !== null )
    {
      record[ isActualSymbol ] = _.timeNow() - filter.notNewerAge - time >= 0;
    }
  }

  return record.isActual;
}

//

function _applyToRecordFull( record )
{
  let filter = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( record.isActual === false )
  return record.isActual;

  filter._applyToRecordMasks( record );
  filter._applyToRecordTime( record );

  return record.isActual;
}

// --
// relations
// --

let isTransientSymbol = Symbol.for( 'isTransient' );
let isActualSymbol = Symbol.for( 'isActual' );

let MaskNames =
[
  'maskAll',
  'maskTerminal',
  'maskDirectory',
  'maskTransientAll',
  'maskTransientTerminal',
  'maskTransientDirectory',
]

let Composes =
{

  filePath : null,

  hasExtension : null,
  begins : null,
  ends : null,

  maskTransientAll : null,
  maskTransientTerminal : null,
  maskTransientDirectory : null,
  maskAll : null,
  maskTerminal : null,
  maskDirectory : null,

  notOlder : null,
  notNewer : null,
  notOlderAge : null,
  notNewerAge : null,

  basePath : null,
  prefixPath : null,
  postfixPath : null,

}

let Aggregates =
{
}

let Associates =
{
  effectiveFileProvider : null,
  defaultFileProvider : null,
  hubFileProvider : null,
}

let Restricts =
{

  globFound : null,
  filterMap : null,

  applyTo : null,
  formed : 0,

  src : null,
  dst : null,

}

let Statics =
{
  TollerantFrom : TollerantFrom,
  And : And,
  MaskNames : MaskNames,
}

let Globals =
{
}

let Forbids =
{

  options : 'options',
  glob : 'glob',
  recipe : 'recipe',
  globOut : 'globOut',
  inPrefixPath : 'inPrefixPath',
  inPostfixPath : 'inPostfixPath',
  fixedFilePath : 'fixedFilePath',
  fileProvider : 'fileProvider',
  fileProviderEffective : 'fileProviderEffective',
  isEmpty : 'isEmpty',
  globMap : 'globMap',
  _processed : '_processed',
  test : 'test',
  inFilePath : 'inFilePath',
  stemPath : 'stemPath',

}

let Accessors =
{

  basePaths : { getter : basePathsGet, readOnly : 1 },
  // filePath : { getter : filePathGet, setter : filePathSet },
  // filePath : { getter : filePathGet, setter : filePathSet },

}

// --
// declare
// --

let Extend =
{

  init,
  TollerantFrom,

  // former

  form,
  _formAssociations,
  _formFixes,
  _formBasePath,
  _formMasks,
  _formFinal,

  // combiner

  And,
  and,
  _pathsJoin,
  pathsJoin,
  pathsJoinWithoutNull,
  pathsInherit,
  pathsExtend,

  // base path

  basePathFor,
  basePathsGet,
  basePathsFrom,
  basePathStringNormalize,
  basePathMapNormalize,
  basePathNormalize,

  // file path

  filePathGet,
  filePathSet,
  filePathNormalize,
  filePathPrependBasePath,
  filePathMultiplyRelatives,
  filePathAbsolutize,
  filePathFromFixes,
  filePathSimplest,
  filePathArrayGet,

  // other path

  dstPathGet,
  srcPathGet,
  dstPathCommon,
  srcPathCommon,
  globalsFromLocals,
  prefixesApply,
  pathLocalize,
  pathsNormalize,

  // etc

  useDestination,
  filteringClear,
  providersNormalize,
  providerForPath,

  // iterative

  allPaths,
  isRelative,
  sureRelative,
  sureRelativeOrGlobal,
  sureBasePath,
  assertBasePath,

  hasMask,
  hasFiltering,
  hasData,

  // exporter

  compactField,
  toStr,

  // applier

  _applyToRecordNothing,
  _applyToRecordMasks,
  _applyToRecordTime,
  _applyToRecordFull,

  // relations

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,
  Forbids,
  Accessors,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extend,
});

_.mapExtend( _,Globals );

_.Copyable.mixin( Self );

// --
// export
// --

_[ Self.shortName ] = Self;

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();