import os from 'os';

const PREFIX_DEBUG = 'DEBUG';
const PREFIX_INFO = ' INFO';
const PREFIX_WARN = ' WARN';
const PREFIX_ERROR = 'ERROR';

export const enum LOG_LEVEL {
    DEBUG = 4,
    INFO = 3,
    WARN = 2,
    ERROR = 1,
}

let LEVEL = process.env['log_level']
    ? (parseInt(process.env['log_level']) as LOG_LEVEL)
    : LOG_LEVEL.INFO;

export default {
    debug: (message: any) => log(LOG_LEVEL.DEBUG, PREFIX_DEBUG, message),
    info: (message: any) => log(LOG_LEVEL.INFO, PREFIX_INFO, message),
    warn: (message: any) => log(LOG_LEVEL.WARN, PREFIX_WARN, message),
    error: (message: any) => log(LOG_LEVEL.ERROR, PREFIX_ERROR, message),
};

function log(level: LOG_LEVEL, prefix: string | null, message: any) {
    if ((level as number) > (LEVEL as number)) return;

    let msg = new Date().toISOString() + ' ';
    msg += `[${process.pid}] - `;
    msg += prefix ? `${prefix}: ` : '';
    msg += message;
    msg += os.EOL;

    const stdOutput =
        level !== LOG_LEVEL.ERROR ? process.stdout : process.stderr;
    stdOutput.write(msg + os.EOL);
}
