'use strict';

import Debug from "debug";
const debug = Debug("Initializing Module");

console.log("Logging is set to: ", process.env.DEBUG);

import express from 'express';
import router from './routes/router.mjs';
import bodyParser from 'body-parser';

export const app = new express();

app.use(bodyParser.json());

app.use(router());