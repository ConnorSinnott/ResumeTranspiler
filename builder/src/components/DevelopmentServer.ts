import express from 'express';

export interface DevelopmentServerOptions {
    sourceDirectory: string;
    developmentServerPort: number;
}

export const startDevelopmentServer = (options: DevelopmentServerOptions) => {
    const application = express();

    return new Promise(resolve =>
        application.listen(options.developmentServerPort, resolve),
    );
};
