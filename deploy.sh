#!/bin/bash
echo =========================
echo GZIP All Html, css and js
echo =========================

find _site -iname '*.xml' -exec gzip -n {} +
find _site -iname '*.html' -exec gzip -n {} +
find _site -iname '*.js' -exec gzip -n {} +
find _site -iname '*.css' -exec gzip -n {} +

cd _site &&
zip -r ../site.zip ./* &&
cd ../
scp site.zip shatnyy:www/ &&
scp .htaccess shatnyy:www/andrewshatnyy &&
ssh shatnyy "cd www && rm -rf andrewshatnyy && unzip site.zip -d andrewshatnyy && rm site.zip" &&
rm site.zip