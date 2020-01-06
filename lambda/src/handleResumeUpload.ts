import { Handler } from 'aws-lambda';

// noinspection JSUnusedGlobalSymbols
export const handler: Handler = (event, context, callback) => {
    let response = {
        statusCode: 200,
        body: JSON.stringify({
            message: 'hello world',
        }),
    };

    callback(undefined, response);
};
