import { startDevelopmentServer } from './components/DevelopmentServer';
import Logger from './components/Logger';

const SOURCE_DIRECTORY = process.env['source_directory'];
if (!SOURCE_DIRECTORY)
    throw new Error('Environment variable "source_directory not defined');

const SERVER_PORT = 3000;
const RELOAD_SERVER_PORT = 3001;

startDevelopmentServer({
    developmentServerPort: SERVER_PORT,
    sourceDirectory: SOURCE_DIRECTORY,
    reloadServerPort: RELOAD_SERVER_PORT,
}).then(() => {
    Logger.info(`Server listening on port ${SERVER_PORT}`);
});
