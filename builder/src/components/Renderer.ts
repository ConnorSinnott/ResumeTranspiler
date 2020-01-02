import pug from 'pug';
import path from 'path';

interface RenderOptions {
    additionalScripts?: string[];
    additionalStyles?: string[];
}

export const render = (
    sourceDirectory: string,
    entryPoint: string,
    renderOptions?: RenderOptions,
) => {
    const targetFile = path.join(sourceDirectory, entryPoint);

    return pug.renderFile(targetFile, {
        additionalScripts: renderOptions?.additionalScripts || [],
        additionalStyles: renderOptions?.additionalStyles || [],
    });
};
