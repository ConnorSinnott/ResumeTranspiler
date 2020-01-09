declare module 'reload' {
    import { Application } from 'express';

    export interface Reloader {
        reload(): void;
    }

    export interface Options {
        port: number;
    }

    function wrap(
        application: Application,
        options: Options,
    ): Promise<Reloader>;

    export default wrap;
}
