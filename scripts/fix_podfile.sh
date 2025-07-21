#!/bin/bash
sed -i "" "s/适用于iOS的/MainApp/g" ios/Podfile
LC_ALL=C sed -i "" "s/[^[:print:]]//g" ios/Podfile