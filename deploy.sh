#!/bin/bash
cd _site &&
zip -r ../site.zip ./* &&
cd ../ &&
scp site.zip shatnyy:www/ &&
ssh shatnyy "cd www && rm -rf andrewshatnyy && unzip site.zip -d andrewshatnyy && rm site.zip"
