import { startDevelopmentServer } from './components/DevelopmentServer';
import Logger from './components/Logger';

const SOURCE_DIRECTORY = process.env['source_directory'];
if (!SOURCE_DIRECTORY)
    throw new Error('Environment variable "source_directory not defined');

const SERVER_PORT = process.env['server_port'];
if (!SERVER_PORT)
    throw new Error('Environment variable "server_port" not defined');

startDevelopmentServer({
    developmentServerPort: parseInt(SERVER_PORT),
    sourceDirectory: SOURCE_DIRECTORY,
    reloadServerPort: 3001,
}).then(() => {
    Logger.info(`Server listening on port ${SERVER_PORT}`);
});
