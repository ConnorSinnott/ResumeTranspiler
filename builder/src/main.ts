import express from 'express';
import pug from 'pug';

const SERVER_PORT = process.env['server_port'];
if (!SERVER_PORT)
    throw new Error('Environment variable "server_port" not defined');

const app = express();

app.get('/', (req, res) => {
    const TARGET = '../resume/index.pug';

    const html = pug.renderFile(TARGET);

    res.send(html);
});

app.listen(SERVER_PORT, () => {
    console.log(`Server listening on port ${SERVER_PORT}`);
});
