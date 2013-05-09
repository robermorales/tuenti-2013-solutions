#!/usr/bin/php -q 
<?

function p($r){
  $uuid = sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
    $r[1], $r[2], $r[3], $r[4] & 0x0fff | 0x4000,
    $r[5] & 0x3fff | 0x8000, $r[6], $r[7], $r[8]);
  echo $uuid;// ."\n";
}

function v4($offset) {

  srand(time() + $offset);
    return sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',

      // 32 bits for "time_low"
      rand(0, 0xffff), rand(0, 0xffff),

      // 16 bits for "time_mid"
      rand(0, 0xffff),

      // 16 bits for "time_hi_and_version",
      // four most significant bits holds version number 4
      rand(0, 0x0fff) | 0x4000,

      // 16 bits, 8 bits for "clk_seq_hi_res",
      // 8 bits for "clk_seq_low",
      // two most significant bits holds zero and one for variant DCE1.1
      rand(0, 0x3fff) | 0x8000,

      // 48 bits for "node"
      rand(0, 0xffff), rand(0, 0xffff), rand(0, 0xffff)
    );
  }

function get_unique() {
  $r = unpack('v*', fread(fopen('/dev/urandom', 'r'),16));
  return p($r);
}

function getrr($offset){
	srand(time()+$offset);
	$r = unpack('v*', rand()*getrandmax() +rand() );
	return p($r);
}

function get_fake(){
	$r = unpack('v*', microtime() );
	return p($r);
}

// get_unique();
// get_fake();

$off = $GLOBALS['argv'][1];

echo v4($off);
getrr($off);

// echo v4() . "\n";
// echo v4() . "\n";
// echo v4() . "\n";
// echo v4() . "\n";
// 
// echo microtime();

?>

