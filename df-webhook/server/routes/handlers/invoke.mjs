import { lstat } from "fs";
import { POST } from "../request-type.mjs";

export const requestType = POST;
export const endpointName = "/invoke";

export async function route(req, response) {

    try {

        console.log(`invoke reqBody: ${JSON.stringify(req.body)}`);

        const tag = req.body.fulfillmentInfo.tag;
        let text = '';

        if (tag === 'Default Welcome Intent') {
            text = 'Hello from a GCF Webhook';
        } else if (tag === 'get-name') {
            text = 'My name is Flowhook';
        } else {
            text = `There are no fulfillment responses defined for "${tag}"" tag`;
        }
        let responsePayload = getResponse(text);

        console.log(`--Response Payload: ${JSON.stringify(responsePayload)}`);

        response.status(200).send(JSON.stringify(responsePayload));

    } catch (err) {
        console.log(err);
        return response.status(500).send(err);
    }


}

function getResponse(text) {

    let response = {
        fulfillment_response: {
            messages: [
                {
                    text: {
                        //fulfillment text response to be sent to the agent
                        text: [text],
                    },
                },
            ],
        },
    };
    return response;

}


