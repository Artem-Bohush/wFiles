( function _StatCarriage_s_() {

'use strict'; 

var _global = _global_;
var _ = _global_.wTools;
var Parent = null;
var Self = function wStatsStatCarriage( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'StatCarriage';

//

function init( o )
{
  var self = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );
  _.workpiece.initFields( self );

  if( self.Self === Self )
  Object.preventExtensions( self );

  return self;
}

// --
// relationship
// --

var Composes =
{
}

var Aggregates =
{
}

var Associates =
{
}

var Restricts =
{
}

var Statics =
{
}

// --
// declare
// --

var Extension =
{

  init,

  // relations

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extension,
});

_.Copyable.mixin( Self );

//

_.[ Self.shortName ] = Self;

// --
// export
// --

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
