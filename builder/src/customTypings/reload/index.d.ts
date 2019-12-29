declare module 'reload' {
    import { Application } from 'express';

    export interface Reloader {
        reload(): void;
    }

    function wrap(application: Application): Promise<Reloader>

    export default wrap;
}
