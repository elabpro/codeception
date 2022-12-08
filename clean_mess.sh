#!/bin/bash
# Script for removing abusing banners from the software
# It's not polite to use software in such way
sed -i "s/\. ' https:\/\/helpukrainewin\.org'//g" /codecept/vendor/codeception/codeception/src/Codeception/Command/Run.php
