if( typeof module !== 'undefined' )
require( 'wFiles' )

var _ = wTools;

var files = _.FileProvider.HardDrive();

// fileRead sync

var data = files.fileRead
({
  filePath : `${__dirname}/../tmp.tmp/forReading.txt`,
  sync : 1
});
console.log( data );

// fileRead async

files.fileRead
({
  filePath : `${__dirname}/../tmp.tmp/forReading.txt`,
  sync : 0
})
.finallyGive( ( err, data ) =>
{
  if( err ) throw err;
  console.log( data )
});
