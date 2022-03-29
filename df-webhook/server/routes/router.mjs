'use strict';
 
import Debug from 'debug'
const debug = Debug('df-webhook:router');
debug("Initializing Module");
 
import express from 'express';
import fs from 'fs';
import path, { join } from 'path';
import { GET } from './request-type.mjs';
 
const basePath = path.resolve();
const handlersPath = join(basePath + "/routes/handlers");
 
export default function initializeRoutes() {
    debug("bootstrapping routes");
    const router = express.Router();
    debug("Scanning Foler:" + handlersPath);
    fs.readdirSync(handlersPath)
        .filter(file => ~file.toLowerCase().endsWith(".mjs"))
        .forEach(file => {
            try {
               console.log("bootstrapping " + file)
                import(handlersPath + "/" +  file).then(handler => {
                    const epName = handler.endpointName;
                    const rt = handler.requestType;
                    const route = handler.route;
                    router.route(`${epName}`)[rt](route);
                    debug(`successfully bootstrapped route: ${epName}`);
                });
            } catch (err) {
 
            }
 
        });
 
    router.route(`/`)[GET](defaultroute) ;
    return router;
 

}
 
function defaultroute(req, response)  {
 
    console.log(`invoke: req:${req}`);
    try {
       response.status(200).send(`OK`);
    } catch (err) {
       logger.warn(`####invoke:  Encountered error`, err);
       return response.status(500).send(err);
    }
};

