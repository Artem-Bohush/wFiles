( function _Basic_s_() {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../../dwtools/Tools.s' );

  _.include( 'wProto' );
  _.include( 'wPathBasic' );
  _.include( 'wUriBasic' );
  _.include( 'wPathTools' );
  _.include( 'wRegexpObject' );
  _.include( 'wFieldsStack' );
  _.include( 'wConsequence' );
  _.include( 'wStringer' );
  _.include( 'wStringsExtra' );
  _.include( 'wVerbal' );

  _.include( 'wSelector' );
  _.include( 'wProcess' );
  _.include( 'wRoutineBasic' );
  _.include( 'wLogger' );
  _.include( 'wWebUriBasic' );

  _.include( 'wGdf' ); /* xxx2 : remove */

  _.assert( !!_.FieldsStack );

  module[ 'exports' ] = _;
}

})();
