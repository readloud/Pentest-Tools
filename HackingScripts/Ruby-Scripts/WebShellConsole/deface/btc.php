<?php
date_default_timezone_set("Asia/Bangkok");
error_reporting(0);
 
 
function call($addr) {
    $data= "address=$addr&sponsor=8320";
    $cok = tempnam('tmp','avo'.rand(1000000,9999999).'tmp.txt');
    $c = curl_init("https://thebestbitcoinfaucet.com/");
    curl_setopt($c, CURLOPT_REFERER, "https://www.thebestbitcoinfaucet.com/?refid=8320");
    curl_setopt($c, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($c, CURLOPT_USERAGENT, "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36");
    curl_setopt($c, CURLOPT_POSTFIELDS, $data);
    curl_setopt($c, CURLOPT_POST, true);
    curl_setopt($c, CURLOPT_ENCODING, 'gzip, deflate');
    //curl_setopt($c, CURLOPT_VERBOSE, true);
    curl_setopt($c, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($c, CURLOPT_SSL_VERIFYHOST, 0);
    curl_setopt($c, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($c, CURLOPT_HEADER, true);
    curl_setopt($c, CURLOPT_COOKIEJAR, $cok);
    curl_setopt($c, CURLOPT_COOKIEFILE, $cok);
    //curl_setopt($c, CURLOPT_COOKIEFILE, $cookie);
    $response = curl_exec($c);
    $httpcode = curl_getinfo($c);
    //$error = curl_strerror($c);
    if (!$httpcode)
        return false;
    else {
        $header = substr($response, 0, curl_getinfo($c, CURLINFO_HEADER_SIZE));
        $body   = substr($response, curl_getinfo($c, CURLINFO_HEADER_SIZE));
    }
   
 $data= "faucetclaim=$addr";
   
    $c = curl_init("https://thebestbitcoinfaucet.com/");
    curl_setopt($c, CURLOPT_REFERER, "https://www.thebestbitcoinfaucet.com/?refid=8320");
    curl_setopt($c, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($c, CURLOPT_USERAGENT, "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36");
    curl_setopt($c, CURLOPT_POSTFIELDS, $data);
    curl_setopt($c, CURLOPT_POST, true);
    curl_setopt($c, CURLOPT_ENCODING, 'gzip, deflate');
    //curl_setopt($c, CURLOPT_VERBOSE, true);
    curl_setopt($c, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($c, CURLOPT_SSL_VERIFYHOST, 0);
    curl_setopt($c, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($c, CURLOPT_HEADER, true);
    curl_setopt($c, CURLOPT_COOKIEJAR, $cok);
    curl_setopt($c, CURLOPT_COOKIEFILE, $cok);
    $response = curl_exec($c);
    $httpcode = curl_getinfo($c);
    //$error = curl_strerror($c);
    if (!$httpcode)
        return false;
    else {
        $header = substr($response, 0, curl_getinfo($c, CURLINFO_HEADER_SIZE));
        $body   = substr($response, curl_getinfo($c, CURLINFO_HEADER_SIZE));
    }
    preg_match_all('~(<h2 style="color:#CE224D"><b>(.*?)</h2>)~', $body, $bal);
    preg_match_all("~(</h3> <p align='left'>(.*?)</p>)~", $body, $claim);
    preg_match_all('~(<div class="panel-body">(.*?) </div>)~', $body, $ava);
    //print_r($bal).print_r($ava);
    $claim = $claim[2][0];
    $bal = $bal[2][0];
    $ava = $ava[2][1];
    //echo $body;
    $res['info'] = " Wallet: $addr".PHP_EOL."$bal".PHP_EOL."$ava";
    if(!preg_match("/Error/", $body)){
        $res['status'] = true;
        $res['message'] = $claim;
    }elseif(preg_match("/Only one account is allowed/", $body)){
       $res['status'] = false;
        $res['message'] = "IP MU KE BANDENG!";
    }else{
        $res['status'] = false;
        $res['message'] = $claim;
    }
    return $res;
}
 
$CY="\e[36m"; $GR="\e[2;32m"; $OG="\e[92m"; $WH="\e[37m"; $RD="\e[31m"; $YL="\e[33m"; $BF="\e[34m"; $DF="\e[39m"; $OR="\e[33m"; $PP="\e[35m"; $B="\e[1m"; $CC="\e[0m";
echo "Masukan BTC Address: ";
$btc = trim(fgets(STDIN));
//if ($cookies == false) exit($time . "No such file!");
for($i=0; $i<100; $i++) {
    echo "[" . date("H:i:s") . "] OTW ...\n";
    echo "[" . date("H:i:s") . "] Claim ...\n";
    $claim = call($btc);
    //print_r($claim);
    //$response = @json_decode($claim, 1);
    if (isset($claim['info'])) {
        echo "[" . date("H:i:s") . "] Hasil:\n";
        echo $PP . $claim['info'] . $CC . "\n";
        if ($claim['status'] == 1) {
            echo $GR . "[" . date("H:i:s") . "] Sukses! " . $claim['message'] . $CC . "\n";
        } elseif ($response['status'] == 0) {
            echo $RD . "[" . date("H:i:s") . "] Gagal! " . $claim['message'] . $CC . "\n";
        }
    } else {
        exit("[" . date("H:i:s") . "] " . $RD . "Invalid cookies!" . $CC);
    }
    echo "[" . date("H:i:s") . "] Wes Rampung ...\n";
    echo "[" . date("H:i:s") . "] Tunggu 60 Detik ...\n";
    echo "[" . date("H:i:s") . "] +++++++++++++++EVPHREAK.COM+++++++++++++ \n";
    sleep(60);
 
   
}