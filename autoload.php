<?php

if (isset($argv)) {
//
}else{
    $argv = ['--no-redirect'];
}
$autoloadFile = './vendor/codeception/codeception/autoload.php';
if (file_exists(__DIR__ . '/vendor/autoload.php')) {
    // for phar
    require_once __DIR__ . '/vendor/autoload.php';
} elseif (file_exists(__DIR__ . '/../../autoload.php')) {
    //for composer
    require_once __DIR__ . '/../../autoload.php';
}
unset($autoloadFile);
if (isset($argv)) {
    $argv = array_values(array_diff($argv, ['--no-redirect']));
}
if (isset($_SERVER['argv'])) {
    $_SERVER['argv'] = array_values(array_diff($_SERVER['argv'], ['--no-redirect']));
}
