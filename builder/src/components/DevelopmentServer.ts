import express from 'express';
import reload from 'reload';
import { render } from './Renderer';
import { watchDirectory } from './DirectoryWatcher';

export interface DevelopmentServerOptions {
    sourceDirectory: string;
    developmentServerPort: number;
}

export const startDevelopmentServer = async (
    options: DevelopmentServerOptions,
) => {
    const application = express();

    application.get('/', (req, res) => {
        const rendered = render(options.sourceDirectory, 'index.pug');

        res.send(rendered);
    });

    const reloader = await reload(application, { port: 3001 });

    watchDirectory(options.sourceDirectory, () => reloader.reload());

    return new Promise(resolve =>
        application.listen(options.developmentServerPort, resolve),
    );
};
