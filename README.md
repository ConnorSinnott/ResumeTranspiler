# ResumeTranspiler

### Boy, do I hate writing resumes in Word.

Requirements:

-   `Docker`
-   `docker-compose`
-   Ports 3000, 3001 (configured in `docker-compose.yml`)

## Use

### Resume Development

To enable live-editing of your resume, start
the development server by executing `docker-compose up`
within the root directory of the project.

With the development server running, navigate
to `http://localhost:3000` to view live changes
to the resume.

SASS dependencies can be included just like CSS:
`link(rel='stylesheet' href="./style/layout.scss")`.

### Options

The ports Express (the development server) and Reload
(the websocket server used to invoking page reloading) 
operate on can be configured in `docker-compose`.

```yaml
services:
  ...
  environment:
      server_port: 3000
      reload_port: 3001
```

