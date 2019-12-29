import express from 'express';

const SERVER_PORT = process.env['server_port'];
if (!SERVER_PORT)
    throw new Error('Environment variable "server_port" not defined');

const app = express();

app.get('/', (req, res) => {
    res.send('Hello World');
});

app.listen(SERVER_PORT, () => {
    console.log(`Server listening on port ${SERVER_PORT}`);
});
