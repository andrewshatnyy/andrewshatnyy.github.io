#!/bin/bash
echo =========================
echo Build Site
echo =========================
jekyll build

echo =========================
echo GZIP All Html, css and js
echo =========================

find _site -iname '*.xml'  -exec sh -c 'gzip -c -- {} >{}.gz' \;
find _site -iname '*.html' -exec sh -c 'gzip -c -- {} >{}.gz' \;
find _site -iname '*.js' -exec sh -c 'gzip -c -- {} >{}.gz' \;
find _site -iname '*.css' -exec sh -c 'gzip -c -- {} >{}.gz' \;


echo =========================
echo Deploy to Bluehost
echo =========================

cd _site &&
zip -r ../site.zip ./* &&
cd ../
scp site.zip shatnyy:www/ &&
ssh shatnyy "cd www && rm -rf andrewshatnyy && unzip site.zip -d andrewshatnyy && rm site.zip" &&
scp .htaccess shatnyy:www/andrewshatnyy &&
rm site.zip