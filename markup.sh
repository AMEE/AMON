#!/bin/bash

echo "---" > index.markdown
echo "title: AMON Data Format" >> index.markdown
echo "layout: default" >> index.markdown
echo "---" >> index.markdown
echo "" >> index.markdown
cat readme.markdown >> index.markdown
