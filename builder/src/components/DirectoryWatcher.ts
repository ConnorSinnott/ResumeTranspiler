import chokidar from 'chokidar';

export const watchDirectory = (directory: string, onChange: () => void) => {
    chokidar.watch(directory).on('all', (event, path) => {
        onChange();
    });
};
