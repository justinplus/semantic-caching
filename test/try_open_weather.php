<?php  

$app_id='a057f18208f763ae';                              
$privatekey='f2528f_SmartWeatherAPI_d59bd6c';         

//接收参数  
$type='forecast_f';
$areaid='101010100';  
//格式化当前时间yyyyMMddHHmm  
$date=date('YmdHi', time());  

//api请求固定部分  
$api_head='http://open.weather.com.cn/data/?areaid='.$areaid.'&type='.$type.'&date='.$date;  

//拼接publickey  
$publickey=$api_head.'&appid='.$app_id;  

//生成key  
$sign_key=base64_encode(hash_hmac('sha1',$publickey,$privatekey,true));  
echo 'key: '.$sign_key.PHP_EOL;

//截取appid前6位  
$api_url_appid=substr($app_id,0,6);  

//拼接和urlencode处理最终url  
$api_url=$api_head.'&appid='.$api_url_appid.'&key='.urlencode($sign_key);  
echo 'url: '.$api_url.PHP_EOL;

//省事省到底，直接执行 生成的url 访问数据  
echo file_get_contents($api_url);  

?>  
