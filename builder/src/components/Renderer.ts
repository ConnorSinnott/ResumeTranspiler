import pug from 'pug';
import path from 'path';
import sass from 'node-sass';

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

    let htmlContent = pug.renderFile(targetFile, {
        additionalScripts: renderOptions?.additionalScripts || [],
        additionalStyles: renderOptions?.additionalStyles || [],
    });

    htmlContent = htmlContent.replace(
        /<link rel="stylesheet" href="(?<file>.*\.scss)"\/>/,
        (match, file) => {
            const targetFile = path.join(sourceDirectory, file);

            const cssContent = sass
                .renderSync({ file: targetFile, outputStyle: 'compressed' })
                .css.toString();

            return `<style>${cssContent}</style>`;
        },
    );

    return htmlContent;
};
