if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();

//directoryRead sync

var content = files.dirRead({ filePath : `${__dirname}/../tmp.tmp` });
console.log( content );

// directoryRead async

var con = files.dirRead({ filePath : `${__dirname}/../tmp.tmp`, sync : 0 });
con.got( ( content ) => console.log( content ) );
