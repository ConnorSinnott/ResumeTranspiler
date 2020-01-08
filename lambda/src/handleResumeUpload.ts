import { Handler, S3Event } from 'aws-lambda';
import { S3 } from 'aws-sdk';
import extract from 'extract-zip';
import fs from 'fs';
import path from 'path';

const WORKING_DIR = '/tmp';

// noinspection JSUnusedGlobalSymbols
export const handler: Handler = async (event: S3Event) => {
    const generateResponse = (statusCode: number, message: string) => ({
        statusCode,
        body: JSON.stringify({ message }),
    });

    const records = event.Records;

    if (records.length === 0)
        return generateResponse(400, 'No records provided');

    const s3 = records[0].s3;
    const bucketName = s3.bucket.name;
    const key = s3.object.key;

    const unzippedPath = await unzipToTempFromS3(bucketName, key);

    return generateResponse(200, unzippedPath);
};

async function unzipToTempFromS3(bucketName: string, key: string) {
    const s3 = new S3();

    const writeTarget = path.join(WORKING_DIR, 'resume.zip');

    const writeStream = fs.createWriteStream(writeTarget);

    s3.getObject({
        Bucket: bucketName,
        Key: key,
    })
        .createReadStream()
        .pipe(writeStream);

    await new Promise(r => writeStream.on('close', r));

    await new Promise((resolve, reject) => {
        extract(writeTarget, { dir: WORKING_DIR }, err =>
            err ? reject(err) : resolve(),
        );
    });

    return path.join(WORKING_DIR, 'resume');
}
