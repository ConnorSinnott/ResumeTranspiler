import express from 'express';
import reload from 'reload';
import { render } from 'resume-renderer';
import { watchDirectory } from './DirectoryWatcher';

export interface DevelopmentServerOptions {
    sourceDirectory: string;
    developmentServerPort: number;
    reloadServerPort: number;
}

export const startDevelopmentServer = async (
    options: DevelopmentServerOptions,
) => {
    const application = express();

    application.get('/', (req, res) => {
        const rendered = render(options.sourceDirectory, 'index.pug', {
            additionalScripts: ['/reload/reload.js'],
        });

        res.send(rendered);
    });

    const reloader = await reload(application, {
        port: options.reloadServerPort,
    });

    watchDirectory(options.sourceDirectory, () => reloader.reload());

    return new Promise(resolve =>
        application.listen(options.developmentServerPort, resolve),
    );
};
