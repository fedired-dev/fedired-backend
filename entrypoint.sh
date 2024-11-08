#!/bin/bash
./node_modules/.bin/typeorm migration:run -d ormconfig.js
yarn start

