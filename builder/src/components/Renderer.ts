import pug from 'pug';
import path from 'path';

export const render = (sourceDirectory: string, entryPoint: string) => {
    const targetFile = path.join(sourceDirectory, entryPoint);

    return pug.renderFile(targetFile);
};
