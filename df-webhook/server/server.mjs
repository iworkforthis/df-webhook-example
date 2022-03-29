'use strict'
import Debug from 'debug';
const debug = Debug('df-webhook');
debug("Initializing Module");

import http from 'http';
import accesslog from 'access-log';
import { app } from './app.mjs';

var serverPort = 3000;

http.createServer(function (req, res) {
    accesslog(req, res);
    app(req, res);
}).listen(serverPort), function() {
    console.log('Your server is listening on port %d (http://localhost:%d)', serverPort, serverPort);
}