#!/bin/bash

# Core Detection
echo "What is the commit link?";
read LINK
	wget $LINK.patch
echo "Patch commit:";
read PATCH

git apply $PATCH.patch
	
